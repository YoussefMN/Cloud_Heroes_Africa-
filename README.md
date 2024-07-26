# AWS Infrastructure Setup with Terraform

This Terraform script sets up an AWS infrastructure including a VPC, subnets, an internet gateway, route tables, security groups, an EC2 instance, and an RDS instance. Below is a detailed explanation of each component and instructions on how to use the script.

## Components

### Provider

- **AWS Provider**: Specifies the AWS region (`eu-west-1`) where the resources will be created.

### VPC

- **VPC**: Creates a Virtual Private Cloud with a CIDR block of `10.0.0.0/24` and enables DNS hostnames.

### Internet Gateway

- **Internet Gateway**: Creates an Internet Gateway and attaches it to the VPC.

### Subnets

- **Public Subnet**: Creates a public subnet with a CIDR block of `10.0.0.128/26`.
- **Private Subnets**: Creates two private subnets in different availability zones:
  - `10.0.0.192/26` in `eu-west-1a`
  - `10.0.0.64/26` in `eu-west-1b`

### Route Tables

- **Public Route Table**: Creates a route table for public subnets with a route to the Internet Gateway.
- **Route Table Association**: Associates the public route table with the public subnet.

### Security Groups

- **Web Security Group**: Allows HTTP (port 80) and all outbound traffic.
- **RDS Security Group**: Allows MySQL (port 3306) traffic only from the web server and all outbound traffic.

### Instances

- **EC2 Instance**: Launches an EC2 instance in the public subnet with a specified AMI, instance type, security group, and user data script (`web.sh`).
- **RDS Instance**: Launches an RDS instance in the private subnet with specified storage, engine, instance class, security group, and other parameters.

## Usage

1. **Install Terraform**: Make sure you have Terraform installed. You can download it from [terraform.io](https://www.terraform.io/downloads.html).

2. **Initialize Terraform**: Run `terraform init` to initialize the working directory.

3. **Plan**: Run `terraform plan` to see what resources will be created.

4. **Apply**: Run `terraform apply` to create the resources.

5. **Destroy**: Run `terraform destroy` to remove all the resources created by this script.

## Improvements

### Use of Modules, Variables, and Outputs

- **Modules**: Break down the script into reusable modules for better organization and reusability.
- **Variables**: Use variables to avoid hardcoding values and improve flexibility.
- **Outputs**: Define output values for important resources to easily reference them.
- **Backend**: Add backend configuration to push tfstate file in remote location S3 bucket

### High Availability and Security

- **High Availability**: Implement Multi-AZ deployments for the RDS instance and use auto-scaling groups for the EC2 instances.
- **Security**: Implement additional security measures such as:
  - Use private subnets for EC2 instances.
  - Restrict SSH access using security groups.
  - Use IAM roles and policies for fine-grained access control.

### Monitoring and Backup

- **Monitoring**: Integrate CloudWatch for monitoring EC2 and RDS instances.
- **Backup**: Implement automated backups for RDS and snapshots for EC2 instances.

### Additional Suggestions

- **Logging**: Enable VPC flow logs for network traffic monitoring.
- **Cost Management**: Use cost management tools to monitor and optimize the cost of the resources.

## Notes

- The provided script is a basic setup and can be extended based on specific requirements.
- Ensure that the necessary permissions are granted for the IAM user/role executing this script.
