terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

# Configure AWS provider
provider "aws" {
  region = var.aws_region # Update with your desired region
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}
# Use default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Create ECS cluster
resource "aws_ecs_cluster" "api_cluster" {
  name = var.cluster_name
}

# create ecs role and policy for ecst task
resource "aws_iam_role" "execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logs_policy" {
  name        = "ecs_task_logs_policy"
  description = "Policy for ECS task to access CloudWatch Logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"

      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.logs_policy.arn
}
# ecs logs group
resource "aws_cloudwatch_log_group" "ecs_logs_group" {
  name              = "${var.project_name}-logs-group"
  retention_in_days = 30
}
# Create ECS task definition
resource "aws_ecs_task_definition" "api_task_definition" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_mem
  execution_role_arn       = aws_iam_role.execution_role.arn
  container_definitions = jsonencode([{
    name      = "${var.container_name}"
    image     = "${var.image_name}"
    essential = true

    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port


    }]
    environment = [
      {
        name  = "DOCKER_USERNAME"
        value = "${var.DOCKER_USERNAME}"
      },
      {
        name  = "DOCKER_PASSWORD",
        value = "${var.DOCKER_PASSWORD}"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs_group.name
        "awslogs-region"        = "${var.aws_region}"
        "awslogs-stream-prefix" = "${var.project_name}"
      }
    }
  }])
}
# security group for alb
resource "aws_security_group" "alb_api_security_group" {
  name        = "${var.project_name}-lb-security-group"
  description = "${var.project_name}-loadbalancer-security group description"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rules


  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# security group for ecs task
resource "aws_security_group" "api_security_group" {
  name        = "${var.project_name}-security-group"
  description = "${var.project_name} security group description"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rules


  ingress {
    from_port = var.container_port
    to_port   = var.container_port
    protocol  = "tcp"
    security_groups = [aws_security_group.alb_api_security_group.id]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB 
resource "aws_lb" "api_load_balancer" {
  name               = "${var.project_name}-load-balancer"
  subnets            = data.aws_subnets.default.ids
  internal           = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.alb_api_security_group.id ]
}

# Create ALB listener 
resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.api_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_target_group.arn
  }
}

# Create ALB target group 
resource "aws_lb_target_group" "api_target_group" {
  name        = "${var.project_name}-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# Create ECS service
resource "aws_ecs_service" "my_service" {
  name                               = "${var.project_name}-ecs-service"
  cluster                            = aws_ecs_cluster.api_cluster.id
  task_definition                    = aws_ecs_task_definition.api_task_definition.arn
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller {
    type = "ECS"
  }

  health_check_grace_period_seconds = 60

  lifecycle {
    create_before_destroy = true
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.api_security_group.id]
    assign_public_ip = true
  }



  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}




