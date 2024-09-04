# Cloud Infrastructure Setup

## Overview
This repository provides Terraform configurations for setting up a scalable and secure cloud infrastructure on AWS. The setup includes a combination of services to ensure efficient routing, traffic management, security, and connectivity for a web application deployment.


The CloudFront distribution URL is: [https://d3gdt86wyl5f50.cloudfront.net](https://d3gdt86wyl5f50.cloudfront.net)

## Components

### CloudFront Distribution
A CloudFront distribution is provisioned to serve content with low latency. The origin server for the distribution is an Application Load Balancer (ALB), which handles incoming traffic. This setup helps improve global access to the application while ensuring secure and optimized delivery of content.

### Application Load Balancer (ALB)
The ALB is configured to distribute incoming traffic across multiple targets, ensuring high availability and scalability. Proper security group settings ensure that traffic flows securely between CloudFront and the ALB.

### Amazon Elastic Kubernetes Service (EKS)
An EKS cluster is deployed in the AWS eu-west-1 region to host a web server. This Kubernetes-based setup allows for the orchestration and scaling of containerized applications. The web server can handle incoming API requests efficiently.

### VPC Connectivity
To ensure seamless networking, multiple VPCs are connected using a VPC private link. This allows secure communication between EC2 instances located in separate VPCs. Connectivity is verified through various networking tools.

### Security and Monitoring
To enhance security:
- Network ACLs and security groups are used to control traffic flow between different components.
- AWS WAF is employed to protect the infrastructure from web exploits.
- Encryption is enabled for data both in transit and at rest.
- IAM roles and policies are implemented to manage access to resources.
- Logging and monitoring are enabled using AWS CloudWatch and CloudTrail to provide visibility into the infrastructure’s operations.
<img width="1728" alt="Screenshot 2024-09-04 at 13 26 48" src="https://github.com/user-attachments/assets/e675f3ac-24b4-4538-a33f-0de35cce5183">
<img width="1726" alt="Screenshot 2024-09-04 at 13 27 17" src="https://github.com/user-attachments/assets/0c2cec78-e5ee-4ba5-adaa-7c69a1e39176">
[infra.pdf](https://github.com/user-attachments/files/16868780/infra.pdf)
