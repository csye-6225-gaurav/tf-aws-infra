# tf-aws-infra

This repository contains the infrastructure setup for the AWS related infrastructure components using Terraform

## Prerequisites

Before you begin, ensure you have the following:

- An AWS account with the necessary permissions.
- AWS CLI installed and configured.
- Terraform installed


## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/csye-6225-gaurav/tf-aws-infra.git
```

### 2. Install SSL certificate to ACM

use the following command to install the SSL certificate in certificate manager
```bash
aws acm import-certificate \
    --certificate file://path/to/certificate.crt \
    --private-key file://path/to/private.key \
    --certificate-chain file://path/to/intermediate.crt
```
### 3. Provision Infrastructure

Use Terraform to provision the infrastructure. Navigate to the Terraform directory and initialize Terraform.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Cleanup

To tear down the infrastructure, use Terraform to destroy the resources.

```bash
terraform destroy
```