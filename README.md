# EKS Cluster on AWS with Terraform

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazonaws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29-326CE5?logo=kubernetes&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

Provision a production-style **Amazon EKS** cluster — with its own **VPC, public/private
subnets, NAT gateway, IAM roles, and a managed node group** — end to end with Terraform.
Everything is built from native `aws` provider resources (no wrapper modules), so the
networking and IAM wiring is fully transparent and easy to learn from.

---

## Architecture

```
                          ┌─────────────────────────── VPC (10.0.0.0/16) ───────────────────────────┐
                          │                                                                          │
        Internet ◄──────► │   Internet Gateway                                                       │
                          │        │                                                                  │
                          │   ┌────┴───────────────┐          ┌────────────────────┐                 │
                          │   │  Public subnet AZ-a │          │ Public subnet AZ-b │   (ELB / NAT)   │
                          │   │   NAT Gateway ──────┼──────────┘                    │                 │
                          │   └─────────┬──────────┘                                                  │
                          │             │ (egress)                                                    │
                          │   ┌─────────▼──────────┐          ┌────────────────────┐                 │
                          │   │ Private subnet AZ-a │          │ Private subnet AZ-b│  (worker nodes) │
                          │   │   ┌──────────────┐  │          │   ┌──────────────┐ │                 │
                          │   │   │ EKS Node(s)  │  │          │   │ EKS Node(s)  │ │                 │
                          │   │   └──────────────┘  │          │   └──────────────┘ │                 │
                          │   └────────────────────┘          └────────────────────┘                 │
                          │                                                                          │
                          └──────────────────────────────────────────────────────────────────────────┘
                                              ▲
                                              │ managed control plane
                                       ┌──────┴───────┐
                                       │  EKS Cluster │  (AWS-managed control plane)
                                       └──────────────┘
```

- **Worker nodes run in private subnets** and reach the internet through a NAT gateway.
- **Public subnets** are tagged for internet-facing load balancers (`kubernetes.io/role/elb`).
- **Private subnets** are tagged for internal load balancers (`kubernetes.io/role/internal-elb`).
- Subnets are spread across **multiple Availability Zones** for high availability.

## Features

- 🏗️ **Self-contained VPC** — subnets, IGW, NAT, and route tables, all CIDR-computed dynamically
- ☸️ **EKS control plane + managed node group** with autoscaling bounds
- 🔐 **Least-privilege IAM** roles for the control plane and nodes via AWS-managed policies
- 🌍 **Configurable AZ count** (2–4) with single or per-AZ NAT (cost vs. HA trade-off)
- 🏷️ **Default tags** applied to every resource (`Project`, `Environment`, `ManagedBy`)
- 📤 **Useful outputs**, including a ready-to-run `aws eks update-kubeconfig` command

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.5 | |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | v2 | configured with credentials (`aws configure`) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | matches cluster | to talk to the cluster after creation |

Your AWS credentials need permissions to manage VPC, EKS, EC2, and IAM resources.

## Usage

```bash
# 1. Clone and enter the repo
git clone https://github.com/Harish-n1/terraform.git
cd terraform

# 2. (Optional) customise inputs
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

# 3. Initialise providers
terraform init

# 4. Review the plan
terraform plan

# 5. Apply
terraform apply

# 6. Point kubectl at the new cluster (command is also printed as an output)
aws eks update-kubeconfig --region ap-south-1 --name eks-demo-dev

# 7. Verify
kubectl get nodes
```

## Configurable inputs

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | Region to deploy into | `ap-south-1` |
| `project_name` | Prefix/tag for all resources | `eks-demo` |
| `environment` | Environment name | `dev` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `az_count` | Number of AZs (2–4) | `2` |
| `single_nat_gateway` | One NAT (cheap) vs. one per AZ (HA) | `true` |
| `cluster_version` | EKS Kubernetes version | `1.29` |
| `node_instance_types` | Node group instance types | `["t3.medium"]` |
| `node_desired_size` / `node_min_size` / `node_max_size` | Node group scaling | `2` / `1` / `4` |
| `endpoint_public_access` | Expose the API server publicly | `true` |

## Outputs

`cluster_name`, `cluster_endpoint`, `cluster_version`, `vpc_id`, `private_subnet_ids`,
`public_subnet_ids`, and `configure_kubectl` (the exact command to wire up `kubectl`).

## File layout

```
.
├── versions.tf      # Terraform & provider version constraints
├── providers.tf     # AWS provider + default tags
├── variables.tf     # Input variables with validation
├── locals.tf        # AZ lookup + dynamic subnet CIDRs
├── vpc.tf           # VPC, subnets, IGW, NAT, route tables
├── eks.tf           # IAM roles, EKS control plane, managed node group
├── outputs.tf       # Exposed outputs
└── terraform.tfvars.example
```

## 💰 Cost & teardown

This creates billable resources — an **EKS control plane** (hourly charge), **EC2 worker
nodes**, and a **NAT gateway**. Always destroy the lab when you're done:

```bash
terraform destroy
```

## Why I built this

A clean, readable reference for standing up EKS from first principles — the kind of base
I reach for when prototyping platform tooling, GitOps setups, or testing Kubernetes
manifests on real infrastructure.

## License

MIT
