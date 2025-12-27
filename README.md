

# Kubernetes on AWS

This repository contains Terraform code for creating and managing an AWS EKS cluster and its associated resources.

## Restrictions

Please note that this repository is based on the Kodekloud AWS Cloud Playground, which has the following restrictions:

* The cluster name must be "demo-eks"
* The cluster role name must be "eksClusterRole"
* The node role name must be "eksWorkerNodeRole"
* The policy role name must be "eksPolicy"
* The cluster cannot use managed nodes.
* The cluster must use the configmap auth method. and other........

## Creating an EKS Cluster in Dev Environment

To create an EKS cluster in the dev environment, follow these steps:

1. Navigate to the `./envs/dev` directory.
2. Run `terraform init` to initialize the Terraform configuration.
3. Run `terraform plan` to see a preview of the changes that will be made.
4. Run `terraform apply -auto-approve` to create the demo_eks cluster in the dev environment.

This will create an EKS cluster, self-managed nodes in an Auto Scaling Group, and a Kubernetes auth config map to add nodes to the EKS cluster.

## Prerequisites

Before you can run Terraform, make sure you have the following:

- An AWS account with the necessary permissions
- Terraform installed on your machine

