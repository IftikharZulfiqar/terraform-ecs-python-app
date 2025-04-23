# terraform-ecs-python-app 🐍🚀  
End-to-end demo that packages a containerised **Flask API** and deploys it to AWS **ECS Fargate** behind an Application Load Balancer – everything defined with **Terraform**.

[![Terraform CI](https://img.shields.io/github/actions/workflow/status/IftikharZulfiqar/terraform-ecs-python-app/terraform-ci.yml?label=Terraform%20CI)](../../actions)
[![Docker Image](https://img.shields.io/docker/pulls/<docker-hub-user>/python-app?label=Docker%20Hub)](https://hub.docker.com/r/<docker-hub-user>/python-app)
[![Licence](https://img.shields.io/github/license/IftikharZulfiqar/terraform-ecs-python-app)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/IftikharZulfiqar/terraform-ecs-python-app)](../../commits)

---

## ✨ Features
| Layer | Highlights |
|-------|------------|
| **Python App** | Flask demo API <br> Multi-stage Dockerfile (slim Py 3.12) |
| **Terraform Infra** | VPC, subnets, IGW <br> ECS cluster (Fargate) <br> Task definition & service <br> ALB + listener + target group <br> SGs for ALB & tasks |
| **IaC best practice** | Remote state ready, version-locked providers, variables / locals / outputs, pre-commit hooks |
| **CI/CD ready** | Sample GitHub Actions workflow for `fmt → validate → plan → apply` |

---

## 📂 Repo structure
. ├── Infra/ │ ├── main.tf │ ├── variables.tf │ ├── outputs.tf │ └── modules/ │ ├── network/ │ └── ecs/ └── Python_App/ ├── app/ ├── Dockerfile └── requirements.txt

---

## 🏗️ Prerequisites
| Tool      | Minimum |
|-----------|---------|
| Terraform | 1.6.x |
| AWS CLI   | 2.x (configured) |
| Docker    | 24.x |
| Python    | 3.12 (local dev only) |

---

## 🚀 Quick start

### 1 — Build & push the image
```bash
cd Python_App
docker build -t <docker-hub-user>/python-app:latest .
docker push <docker-hub-user>/python-app:latest

2 — Provision the infrastructure

cd Infra
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan

3 — Tear down
terraform destroy

