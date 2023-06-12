# terraform-ecs-python-app

I have utilized Terraform, an Infrastructure as Code (IaC) tool, to build the project. The repository comprises two folders: "Python_App" and "Infra".

In the "Python_App" folder, you will find the Python application along with its Dockerfile. The Docker image has been uploaded to my Docker Hub account for easy accessibility.

On the other hand, the "Infra" folder contains the Terraform code responsible for provisioning essential infrastructure components. This includes the ECS cluster, service, task definition, load balancer (equipped with a single listener and target group), and two security groups (one for the load balancer and the other for ECS tasks). To ensure modularity and flexibility, I have adhered to best practices by utilizing variables within the Terraform code.

With the help of Terraform, I have automated the deployment process, guaranteeing consistent and replicable setups of the ECS cluster and related resources.
