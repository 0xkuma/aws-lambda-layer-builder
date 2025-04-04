# Deploying AWS Lambda Layer with Docker

[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-web-services&logoColor=white)](#)

This project provides a Docker-based solution for creating and deploying AWS Lambda Layers. It consists of an interactive shell script (`deploy_layer.sh`) and a `Dockerfile` that automates the process of packaging and publishing a Lambda Layer to AWS.

## Prerequisites

Before using this setup, ensure you have the following installed:

- Docker
- An AWS account with the necessary permissions to publish Lambda Layers
- Properly configured AWS credentials (either in your environment or via an AWS credentials file)

> **Note:** When running the container, use interactive mode (`-it`) to ensure the script can prompt you for input.

## Files Overview

### `deploy_layer.sh`

This shell script automates the process of creating an AWS Lambda Layer. It prompts the user for the required inputs:

1. **Library Name (required):** The Python library you wish to package.
2. **Runtime (optional):** Defaults to `python3.13` if not provided.
3. **Description (optional):** Defaults to "Lambda layer for `<library name>`".
4. **Region (optional):** Defaults to `us-east-1` if not provided.

After gathering the input, the script:

- Creates a temporary directory.
- Sets up the proper Python directory structure for a Lambda layer.
- Installs the specified library into that structure.
- Packages the contents into a ZIP file.
- Publishes the layer using AWS CLI.
- Cleans up temporary files automatically.

#### Usage

Since the script is interactive, simply run it without arguments:

```sh
./deploy_layer.sh
```

You will then be prompted to enter:

- **Library Name:** _(e.g., requests)_
- **Runtime:** _(press Enter to use default `python3.13`)_
- **Description:** _(press Enter to use the default description)_
- **Region:** _(press Enter to use default `us-east-1`)_

### `Dockerfile`

This Dockerfile builds a minimal container designed to deploy AWS Lambda Layers:

1. **Base Image:** Uses a slim Python base image.
2. **Dependencies:** Installs only the necessary system package (`zip`).
3. **Script Setup:** Copies the `deploy_layer.sh` script into the container and sets its execution permissions.
4. **AWS CLI:** Installs AWS CLI using pip without caching installation files.
5. **Entrypoint:** Sets the container to run the `deploy_layer.sh` script upon startup.

#### Building the Docker Image

Build the Docker image with:

```sh
docker build -t lambda-layer-deployer .
```

#### Running the Docker Container

To deploy a Lambda Layer, run the Docker container in interactive mode:

```sh
docker run -it --rm lambda-layer-deployer
```

This command will start the container, and you will be prompted to enter the required information interactively.

## Additional Notes

- **Interactive Input:** Both the local and containerized versions of the script require interactive input. Running the container without the `-it` flag will cause the script to exit immediately since there is no terminal attached.
- **Automation:** If you prefer non-interactive automation in the future, consider modifying the script to accept command-line arguments or environment variables.
- **Cleanup:** The script automatically cleans up temporary files after deployment.

## License

This project is released under the MIT License.
