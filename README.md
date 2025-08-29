# TechHealth Infrastructure Migration Stack

<p align="center">
<img src="https://i.imgur.com/4WAvjz2.png"/>
</p>

A secure, healthcare-compliant AWS infrastructure built with AWS CDK and TypeScript, migrating from manual console management to Infrastructure as Code.

## 🏥 Project Background

TechHealth Inc., a healthcare technology company, built their AWS infrastructure manually through the AWS Console 5 years ago for their patient portal web application. This project modernizes and migrates their infrastructure to Infrastructure as Code (IaC) to address critical operational and security challenges.

### The Challenge
**Legacy Infrastructure Issues:**
- All infrastructure created manually via AWS Console with no version control
- Difficult to replicate environments and track changes
- No automated testing or proper documentation
- Basic VPC setup with all resources in public subnets (security risk)
- Manual security group configurations without proper network segmentation
- Resources spread across multiple availability zones without organization

**Previous Architecture:**
- Web application on EC2 instances (public subnets)
- MySQL RDS database storing patient data (public subnets - security concern)
- No Infrastructure as Code or change management processes

### The Solution
This CDK stack transforms the legacy infrastructure into a modern, secure, and maintainable solution with proper network segmentation, automated credential management, and compliance-ready architecture.

## 🏗️ Architecture Overview

This stack deploys a multi-tier architecture with proper network segmentation for a healthcare patient portal:

- **VPC**: Multi-AZ setup with public and private subnets
- **EC2**: Web application servers in public subnets
- **RDS**: MySQL database in private isolated subnets
- **Security**: Zero SSH access, AWS Secrets Manager integration
- **Access**: AWS Systems Manager Session Manager for secure server access

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Software
- **Node.js** (v16 or later)
- **AWS CDK CLI** (v2.x) - Install with `npm install -g aws-cdk`
- **AWS CLI** (v2.x) - [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Git** - For version control

### AWS Account Setup
- AWS Account with appropriate permissions
- AWS CLI configured with credentials (`aws configure`)
- CDK bootstrapped in your target region (`cdk bootstrap`)

### Required AWS Permissions
Your AWS user/role needs permissions for:
- EC2 (VPC, Security Groups, Instances)
- RDS (Database instances, Subnet groups)
- IAM (Roles, Policies)
- Secrets Manager
- CloudFormation
- Systems Manager

## 🚀 Quick Start

### 1. Clone and Setup
```bash
# Clone the repository (if using git)
git clone <your-repo-url>
cd techhealth-migration-stack

# Install dependencies
npm install

# Verify CDK installation
cdk --version
```

### 2. Configure AWS Environment
```bash
# Configure AWS credentials if not already done
aws configure

# Set your default region (e.g., us-east-1)
export AWS_DEFAULT_REGION=us-east-1

# Bootstrap CDK (one-time setup per region)
cdk bootstrap
```

### 3. Review and Deploy
```bash
# Review what will be created
cdk diff

# Deploy the stack
cdk deploy TechhealthMigrationStack

# Follow the prompts and confirm deployment
```

### 4. Verify Deployment
After successful deployment, you'll see outputs including:

<p>
<img src=https://i.imgur.com/gr68bU5.png/>
</p>

- `RDSEndpoint`: Database connection endpoint
- `RDSSecretArn`: ARN of the database credentials in Secrets Manager

## 📁 Project Structure

```
techhealth-migration-stack/
├── lib/
│   └── techhealth-migration-stack.ts    # Main CDK stack definition
├── bin/
│   └── techhealth-migration-stack.ts    # CDK app entry point
├── test/                                # Unit tests (if any)
├── package.json                         # Node.js dependencies
├── tsconfig.json                        # TypeScript configuration
├── cdk.json                            # CDK configuration
└── README.md                           # This file
```

### Stack Parameters
The stack includes these configurable options (modify in the code):

- **VPC CIDR**: Default cidrMask /24
- **Instance Types**: EC2 t3.micro, RDS db.t3.micro
- **Database Storage**: 20 GB allocated storage
- **Database Engine**: MySQL 8.0

## 🛡️ Security Features

### Network Security
- **Private Subnets**: RDS instances have no internet access
- **Security Groups**: Least privilege access rules
- **No SSH**: Eliminated SSH access for improved security

### Access Management
- **IAM Roles**: EC2 instances use roles instead of access keys
- **Session Manager**: Secure shell access without SSH
- **Secrets Manager**: Automated credential management and rotation

### Compliance
- **Audit Trail**: All infrastructure changes tracked in git
- **Reproducible**: Identical environments through IaC
- **Healthcare Ready**: Designed for HIPAA compliance requirements

## 🔗 Accessing Your Infrastructure

### Connect to EC2 Instances
```bash
# List your EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' --output table

# Connect via Session Manager (no SSH required)
aws ssm start-session --target i-1234567890abcdef0
```

### Access Database Credentials
```bash
# Get the secret ARN from stack outputs
aws cloudformation describe-stacks --stack-name TechhealthMigrationStack --query 'Stacks[0].Outputs'

# Retrieve database credentials
aws secretsmanager get-secret-value --secret-id techhealth/rds/credentials
```

### Connect to RDS
From your EC2 instance, you can connect to RDS using:
```bash
# Install MySQL client
sudo yum update -y
sudo yum install mysql -y

# Get credentials from Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id techhealth/rds/credentials --query SecretString --output text)
USERNAME=$(echo $SECRET_JSON | jq -r .username)
PASSWORD=$(echo $SECRET_JSON | jq -r .password)
ENDPOINT="<RDS_ENDPOINT_FROM_OUTPUTS>"

# Connect to database
mysql -h "$ENDPOINT" -u "$USERNAME" -p"$PASSWORD"
```

<p>
<img src=https://i.imgur.com/pr3pqLt.png/>
</p>

## 🧪 Testing

### Connectivity Testing
1. **EC2 to RDS**: Verify MySQL connection from EC2 to RDS - test script available in helper-scripts folder
2. **Security Groups**: Confirm only authorized traffic is allowed
3. **Network Isolation**: Ensure RDS has no internet access
4. **Session Manager**: Test secure access to EC2 instances

## 💰 Cost Considerations

### Current Configuration Costs (approximate)
- **EC2 t3.micro**: ~$8.50/month (free tier eligible)
- **RDS db.t3.micro**: ~$15/month (20GB storage)
- **VPC**: No additional cost
- **Secrets Manager**: ~$0.40/month per secret
- **Session Manager**: No additional cost

### Cost Optimization Tips
- Use free tier resources where possible
- Destroy development environments when not in use
- Monitor usage with AWS Cost Explorer
- Set up billing alerts

## 🗑️ Cleanup

To avoid ongoing charges, destroy the stack when no longer needed:

<p>
<img src=https://i.imgur.com/1GpvL8j.png/>
</p>

```bash
# Destroy all resources
cdk destroy TechhealthMigrationStack

# Confirm deletion when prompted
```

**⚠️ Warning**: This will permanently delete all resources, including the RDS database. Ensure you have backups if needed.

## 🐛 Troubleshooting

### Common Issues

#### CDK Bootstrap Error
```bash
# Re-run bootstrap with explicit region
cdk bootstrap aws://ACCOUNT-NUMBER/REGION
```

#### Permission Denied
- Verify your AWS credentials have necessary permissions
- Check IAM policies for EC2, RDS, and CloudFormation access

#### RDS Connection Issues
- Verify security group rules allow traffic from EC2
- Check RDS endpoint and port (3306 for MySQL)
- Ensure credentials are correctly retrieved from Secrets Manager

#### Session Manager Connection Failed
- Verify EC2 instance has SSM agent installed and running
- Check IAM role has `AmazonSSMManagedInstanceCore` policy
- Ensure instance is in running state

### Useful Commands

```bash
# View stack resources
aws cloudformation describe-stack-resources --stack-name TechhealthMigrationStack

# Check CDK version
cdk --version

# View available CDK commands
cdk --help

# Check AWS CLI configuration
aws configure list
```

## 📚 Additional Resources

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [AWS CDK TypeScript Reference](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib-readme.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)
- [Healthcare on AWS](https://aws.amazon.com/health/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request