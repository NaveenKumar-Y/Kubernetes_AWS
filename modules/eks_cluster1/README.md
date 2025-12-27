This module is derived from the Kodekloud reference repository, with the primary goal of testing the deployment of an EKS cluster utilizing predefined and mandatory naming conventions, in conjunction with CloudFormation stacks and Terraform.

The learning and setup processes have been refactored into the eks_cluster module, which now includes:


* A properly configured ASG group
* An auth configmap for onboarding unmanaged nodes directly

This refactoring aims to improve the overall efficiency and scalability of the EKS cluster deployment process.

