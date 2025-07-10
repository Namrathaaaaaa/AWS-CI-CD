# AWS CI/CD Pipeline Demo

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A8?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

A comprehensive demonstration of implementing Continuous Integration and Continuous Deployment (CI/CD) using AWS services for a Python Flask application.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [1. GitHub Repository Setup](#1-github-repository-setup)
  - [2. AWS CodePipeline Configuration](#2-aws-codepipeline-configuration)
  - [3. AWS CodeBuild Setup](#3-aws-codebuild-setup)
  - [4. AWS CodeDeploy Configuration](#4-aws-codedeploy-configuration)
- [Local Development](#local-development)
- [Deployment Process](#deployment-process)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
- [Best Practices](#best-practices)
- [Contributing](#contributing)

## 🎯 Overview

This project demonstrates a complete CI/CD pipeline using AWS services to automatically build, test, and deploy a Python Flask application. The pipeline is triggered by code changes pushed to GitHub and handles the entire deployment process automatically.

### 🎬 Pipeline in Action

![AWS CodePipeline Success](https://user-images.githubusercontent.com/placeholder/aws-codepipeline-success.png)

_Example of a successful CI pipeline execution showing the Source and Build stages completing successfully. The green checkmarks indicate that code was successfully pulled from GitHub and built using AWS CodeBuild._

### Key Features

- **Automated Testing**: Runs unit tests on every commit
- **Docker Containerization**: Packages the application in Docker containers
- **Multi-Environment Support**: Supports development, staging, and production environments
- **Rollback Capability**: Easy rollback to previous versions if deployment fails
- **Security**: Secure handling of credentials using AWS Parameter Store

## 🏗️ Architecture

```
GitHub Repository
       ↓
AWS CodePipeline
       ↓
AWS CodeBuild (Build & Test)
       ↓
Docker Registry (ECR)
       ↓
AWS CodeDeploy
       ↓
EC2 Instances / ECS / Lambda
```

## 📋 Prerequisites

Before you begin, ensure you have the following:

- **AWS Account** with appropriate permissions
- **GitHub Account** with a repository
- **AWS CLI** configured with your credentials
- **Docker** installed locally (for testing)
- **Python 3.8+** installed locally
- **Basic knowledge** of AWS services, Docker, and Python

## 📁 Project Structure

```
aws-ci-cd/
├── README.md
└── simple-python-app/
    ├── app.py                 # Flask application
    ├── requirements.txt       # Python dependencies
    ├── Dockerfile            # Docker configuration
    ├── buildspec.yaml        # CodeBuild specifications
    ├── appspec.yaml          # CodeDeploy specifications
    ├── start_container.sh    # Container startup script
    └── stop_container.sh     # Container shutdown script
```

## 🚀 Setup Instructions

### 1. GitHub Repository Setup

Set up a GitHub repository to store your Python application's source code:

1. **Create a new repository:**

   - Go to [github.com](https://github.com) and sign in to your account
   - Click the "+" button in the top-right corner and select "New repository"
   - Name your repository (e.g., `aws-cicd-demo`)
   - Add a description and choose visibility settings
   - Initialize with a README file
   - Click "Create repository"

2. **Clone and populate:**
   ```bash
   git clone https://github.com/yourusername/aws-cicd-demo.git
   cd aws-cicd-demo
   # Copy the simple-python-app folder to your repository
   git add .
   git commit -m "Initial commit with Flask app"
   git push origin main
   ```

✅ **Checkpoint**: Your repository should now contain all the necessary files for the CI/CD pipeline.

### 2. AWS CodePipeline Configuration

Create an AWS CodePipeline to automate the CI/CD process:

1. **Navigate to CodePipeline:**

   - Go to the AWS Management Console
   - Search for and select "CodePipeline"
   - Click "Create pipeline"

2. **Pipeline Settings:**

   - **Pipeline name**: `python-flask-cicd-pipeline`
   - **Service role**: Create a new service role or use existing
   - **Artifact store**: Default location or specify custom S3 bucket
   - Click "Next"

3. **Source Stage:**

   - **Source provider**: GitHub (Version 2) - recommended
   - **Connection**: Create a new connection to GitHub
   - **Repository name**: Select your repository
   - **Branch**: `main` (or your default branch)
   - **Output artifacts**: `SourceOutput`
   - Click "Next"

4. **Build Stage:**

   - **Build provider**: AWS CodeBuild
   - **Project name**: Create new project `python-flask-build`
   - **Environment**:
     - Operating system: `Ubuntu`
     - Runtime: `Standard`
     - Image: `aws/codebuild/standard:5.0`
     - Privileged: ✅ (required for Docker builds)
   - **Buildspec**: Use a buildspec file (`buildspec.yaml`)
   - Click "Next"

5. **Deploy Stage (Optional):**

   - **Deploy provider**: AWS CodeDeploy, ECS, or skip for now
   - Configure based on your deployment target
   - Click "Next"

6. **Review and Create:**
   - Review all settings
   - Click "Create pipeline"

✅ **Checkpoint**: Your pipeline should be created and may attempt its first run.

### 3. AWS CodeBuild Setup

Configure AWS CodeBuild to build and test your Python application:

1. **Build Project Configuration:**

   - **Project name**: `python-flask-build`
   - **Description**: "Build project for Python Flask CI/CD demo"

2. **Environment:**

   - **Environment image**: Managed image
   - **Operating system**: Ubuntu
   - **Runtime**: Standard
   - **Image**: `aws/codebuild/standard:5.0`
   - **Image version**: Always use the latest
   - **Privileged**: ✅ Enable (required for Docker commands)

3. **Service Role:**

   - Create a new service role or use existing
   - Ensure the role has permissions for:
     - CodeBuild basic execution
     - ECR (if pushing to ECR)
     - Parameter Store (for accessing secrets)

4. **Buildspec:**

   - **Build specifications**: Use a buildspec file
   - **Buildspec name**: `buildspec.yaml` (in root directory)

5. **Environment Variables (Optional):**
   Add any required environment variables or use Parameter Store for secrets:
   ```
   DOCKER_REGISTRY_URL (from Parameter Store)
   DOCKER_REGISTRY_USERNAME (from Parameter Store)
   DOCKER_REGISTRY_PASSWORD (from Parameter Store)
   ```

✅ **Checkpoint**: CodeBuild project should be created and linked to your pipeline.

### 4. AWS CodeDeploy Configuration

Set up CodeDeploy for automated application deployment:

1. **Create Application:**

   - **Application name**: `python-flask-app`
   - **Compute platform**: EC2/On-premises

2. **Create Deployment Group:**

   - **Deployment group name**: `production`
   - **Service role**: CodeDeploy service role
   - **Environment configuration**:
     - Amazon EC2 instances or Auto Scaling groups
     - Configure tags to identify target instances

3. **Deployment Configuration:**
   - **Deployment type**: In-place or Blue/green
   - **Load balancer**: Configure if using ALB/ELB

✅ **Checkpoint**: CodeDeploy application and deployment group should be configured.

## 💻 Local Development

### Running the Application Locally

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/aws-cicd-demo.git
   cd aws-cicd-demo/simple-python-app
   ```

2. **Set up virtual environment:**

   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application:**

   ```bash
   python app.py
   ```

5. **Test the application:**
   Open your browser and navigate to `http://localhost:5000`

### Running with Docker

1. **Build the Docker image:**

   ```bash
   docker build -t python-flask-app .
   ```

2. **Run the container:**
   ```bash
   docker run -p 5000:5000 python-flask-app
   ```

## 🚀 Deployment Process

### 📸 CI Pipeline Execution

The following image shows a successful execution of the CI (Continuous Integration) portion of our pipeline:

![CI Pipeline Success](assets/ci-pipeline-success.png)

**What's happening in this CI pipeline:**

1. **Source Stage (✅ Completed):**

   - Pipeline automatically detects new commits from GitHub
   - Downloads the latest source code (commit: `4970df7c`)
   - Status: "All actions succeeded"
   - Execution ID: `6fa553b2-7760-45b6-afc8-bdb8d8be8b4a`

2. **Build Stage (✅ Completed):**
   - AWS CodeBuild processes the source code
   - Executes commands defined in `buildspec.yaml`
   - Installs Python dependencies
   - Builds Docker image
   - Pushes image to registry
   - Status: "All actions succeeded"
   - Build completed at: Jul 10, 2025 6:56 PM (UTC+5:30)

This demonstrates the **first part of CI/CD** - the **Continuous Integration** process where code changes are automatically integrated, built, and validated.

### Automated Deployment Flow

1. **Code Push**: Developer pushes code to GitHub
2. **Pipeline Trigger**: CodePipeline detects changes and starts execution
3. **Source Stage**: Downloads latest code from GitHub
4. **Build Stage**: CodeBuild executes the build process:
   - Installs Python dependencies
   - Runs tests (if configured)
   - Builds Docker image
   - Pushes image to registry
5. **Deploy Stage**: CodeDeploy deploys the application:
   - Pulls latest Docker image
   - Stops old containers
   - Starts new containers
   - Runs health checks

### Manual Deployment

You can also trigger deployments manually:

1. Go to AWS CodePipeline console
2. Select your pipeline
3. Click "Release change"

## 📊 Monitoring and Troubleshooting

### CloudWatch Logs

Monitor your pipeline execution:

- **CodeBuild Logs**: Check build process logs
- **CodeDeploy Logs**: Monitor deployment status
- **Application Logs**: View application runtime logs

### Common Issues and Solutions

1. **Build Failures:**

   - Check `buildspec.yaml` syntax
   - Verify dependencies in `requirements.txt`
   - Ensure Docker daemon is running (for Docker builds)

2. **Permission Issues:**

   - Verify IAM roles have necessary permissions
   - Check Parameter Store access for secrets

3. **Deployment Failures:**
   - Verify `appspec.yaml` configuration
   - Check target instance health
   - Review security group settings

## 🎯 Best Practices

### Security

- **Secrets Management**: Store sensitive data in AWS Parameter Store or Secrets Manager
- **IAM Roles**: Use least privilege principle for service roles
- **Network Security**: Configure security groups and NACLs appropriately

### Performance

- **Caching**: Use build caching to speed up builds
- **Parallel Builds**: Configure parallel build stages where possible
- **Resource Optimization**: Right-size CodeBuild compute resources

### Reliability

- **Health Checks**: Implement proper application health checks
- **Rollback Strategy**: Configure automatic rollback on deployment failures
- **Testing**: Include comprehensive test suites in your build process

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [troubleshooting section](#monitoring-and-troubleshooting)
2. Review AWS service documentation
3. Open an issue in this repository

---

**Happy Coding! 🚀**
