# VM Performance Testing on AWS

This directory contains the GitHub Actions workflow and scripts for executing Thunder performance tests on AWS virtual machines.

## Overview

The VM performance testing workflow provisions AWS infrastructure, deploys Thunder, and executes performance tests using Apache JMeter. The workflow is designed to be triggered manually via GitHub Actions workflow dispatch.

## Usage

### Triggering the Workflow

1. Navigate to the **Actions** tab in the GitHub repository
2. Select **VM Performance Test on AWS** from the workflows list
3. Click **Run workflow**
4. Configure the input parameters as needed

### Workflow Parameters

| Parameter Name | Description | Default Value | Accepted Values |
|---------------|-------------|---------------|-----------------|
| THUNDER_PACK_URL | URL to download Thunder distribution pack | (required) | Any valid URL |
| DEPLOYMENT | Deployment type | `single-node` | `single-node` |
| CPU_CORES | Number of CPU cores for the instance | `4` | `2`, `4`, `8` |
| ADDITIONAL_PARAMS_TO_RUN_PERFORMANCE_SCRIPT | Additional parameters passed to performance script | `-d 15 -w 5 -x false -y JWT` | Any valid parameters |
| PERFORMANCE_REPO | Repository containing performance test scripts | `https://github.com/asgardeo/thunder-performance` | Any valid Git repository URL |
| BRANCH | Branch to checkout from performance repository | `main` | Any valid branch name |
| MODE | Testing mode | `PUBLISH` | `PUBLISH`, `FULL` |
| USE_DELAYS | Enable delays in testing | (empty) | Any string value |
| CONCURRENCY | Concurrency pattern for load testing | `50-500` | `50-500`, `500-3000`, `1000-3000`, `50-3000`, `50-50`, `50-1000`, `50-1500` |
| DB_TYPE | Database type | `postgres` | `postgres` |

### Required GitHub Secrets

The following secrets must be configured in the repository:

- `AWS_ACCESS_KEY_ID`: AWS access key for provisioning infrastructure
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `JWT_TOKEN_CLIENT_SECRET`: JWT token client secret for authentication tests
- `JWT_TOKEN_USER_PASSWORD`: JWT token user password for authentication tests

### Workflow Steps

1. **Checkout repository**: Checks out the workflow repository
2. **Configure AWS credentials**: Sets up AWS credentials for infrastructure provisioning
3. **Setup Java**: Installs Java 17 (Temurin distribution)
4. **Setup Maven**: Installs Maven 3.9.5
5. **Set up workspace**: Creates necessary workspace directories
6. **Execute VM Performance Test**: Runs the performance test script
7. **Upload test results**: Uploads test results as workflow artifacts

### Test Results

Test results are automatically uploaded as GitHub Actions artifacts and also copied to the S3 bucket `s3://performance-is-resources/Thunder/Results/{BUILD_NUMBER}`.

## Scripts

### run-vm-performance.sh

The main performance test execution script that:

1. Downloads the Thunder distribution pack
2. Clones the performance test repository
3. Downloads required dependencies (Apache JMeter, SSH keys)
4. Determines the appropriate AWS instance type based on CPU_CORES
5. Builds the test project using Maven
6. Executes the performance tests via `start-performance.sh`
7. Copies results to workspace and uploads to S3

### CPU Core to Instance Type Mapping

| CPU Cores | AWS Instance Type |
|-----------|-------------------|
| 2 | c6i.large |
| 4 | c6i.xlarge |
| 8 | c6i.2xlarge |

## Architecture

The workflow provisions the following AWS infrastructure:

- Thunder application instances (single-node deployment)
- PostgreSQL RDS database
- Bastion host for secure access
- JMeter load generation instances

The infrastructure is automatically created during test execution and can be managed through the CloudFormation stacks.

## Notes

- The workflow runs on Ubuntu latest GitHub-hosted runners
- Test results are retained for 30 days in GitHub Actions artifacts
- AWS infrastructure credentials are stored in AWS Secrets Manager
- The workflow uses the existing `perf-scripts/single-node/start-performance.sh` script for test execution
