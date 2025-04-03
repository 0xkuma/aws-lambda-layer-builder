# Deploying AWS Lambda Layer with Docker

[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-web-services&logoColor=white)](#)

This project provides a Docker-based solution for creating and deploying AWS Lambda Layers. It consists of a shell script (`deploy_layer.sh`) and a `Dockerfile` that automates the process of packaging and publishing a Lambda Layer to AWS.

## Prerequisites

Before using this setup, ensure you have the following installed:

- Docker
- AWS CLI (for local testing, though it is installed inside the container)
- An AWS account with the necessary permissions to publish Lambda layers

## Files Overview

### `deploy_layer.sh`

This shell script automates the process of creating an AWS Lambda Layer:

1. Creates a temporary directory.
2. Installs the specified Python library into the correct directory structure.
3. Packages the installation into a ZIP file.
4. Publishes the layer using AWS CLI.
5. Cleans up temporary files.

#### Usage

```sh
./deploy_layer.sh <lib_name> [runtime] [description] [region]
```

- `<lib_name>`: Name of the Python library to install.
- `[runtime]` (optional, default: `python3.13`): Compatible AWS Lambda runtime.
- `[description]` (optional): Description of the Lambda Layer.
- `[region]` (optional, default: `us-west-2`): AWS region for deployment.

### `Dockerfile`

This Dockerfile creates a minimal container for deploying AWS Lambda Layers:

1. Uses a slim Python base image.
2. Installs required system dependencies (`zip`).
3. Copies and sets execution permissions for `deploy_layer.sh`.
4. Installs AWS CLI.
5. Sets the entry point to execute `deploy_layer.sh` inside the container.

#### Building the Docker Image

```sh
docker build -t lambda-layer-deployer .
```

#### Running the Docker Container

To deploy a Lambda Layer, run the following command:

```sh
docker run --rm lambda-layer-deployer <lib_name> [runtime] [description] [region]
```

Example:

```sh
docker run --rm lambda-layer-deployer requests python3.13 "Lambda layer for requests" us-east-1
```

## Notes

- Ensure your AWS credentials are configured properly in your environment.
- The script automatically cleans up temporary files after deployment.

## License

This project is released under the MIT License.
