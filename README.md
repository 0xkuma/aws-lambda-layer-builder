# Deploying AWS Lambda Layer with Docker

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-web-services&logoColor=white)](#)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node-dot-js&logoColor=fff)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)

This project provides a Docker-based solution for creating and deploying AWS Lambda Layers for both Python and Node.js projects. It consists of an interactive shell script (`deploy_layer.sh`) and a `Dockerfile` that automates the process of packaging and publishing a Lambda Layer to AWS.

## Features

- **Language Selection:** Supports deploying Lambda layers for Python or Node.js.
- **Interactive Prompts:** The script prompts for necessary inputs such as:
  - Language type (default: Python)
  - AWS region (default: `us-east-1`)
  - For Python:
    - Library name (required)
    - Runtime (default: `python3.13`)
  - For Node.js:
    - Package name (required)
    - Runtime (default: `nodejs22.x`)
- **Automated Packaging:** Creates a temporary directory, installs the required dependencies, and packages them into a ZIP file.
- **Deployment:** Publishes the Lambda Layer using AWS CLI.
- **Dockerized Environment:** The provided Dockerfile sets up a minimal container with necessary tools (Python, Node.js, npm, zip, and AWS CLI) for deployment.

## Prerequisites

Before using this setup, ensure you have the following installed:

- Docker
- An AWS account with the necessary permissions to publish Lambda Layers
- Properly configured AWS credentials (either in your environment or via an AWS credentials file)

> **Note:** When running the container, use interactive mode (`-it`) so that the script can prompt you for input.

## Files Overview

### `deploy_layer.sh`

This shell script automates the process of creating an AWS Lambda Layer. It starts by prompting for the language selection (Python or Node.js) and then gathers the required inputs accordingly:

#### For Python:

1. **Python Library Name (required):** The Python package you wish to include.
2. **Python Runtime (optional):** Defaults to `python3.13`.
3. **Description (optional):** Defaults to "Lambda layer for `<library name>`".

#### For Node.js:

1. **Node.js Package Name (required):** The Node.js package you wish to include.
2. **Node.js Runtime (optional):** Defaults to `nodejs22.x`.
3. **Description (optional):** Defaults to "Lambda layer for `<package name>`".

Additionally, it prompts for the AWS region (default: `us-east-1`).

After gathering the input, the script:

- Creates a temporary directory.
- Sets up the proper directory structure for a Lambda layer:
  - For Python, creates a `python` directory and installs the library using `pip`.
  - For Node.js, creates a `nodejs` directory, initializes a Node.js project, and installs the package using `npm`.
- Packages the respective directory into a ZIP file.
- Publishes the layer using AWS CLI.
- Automatically cleans up temporary files upon exit.

#### Usage

Since the script is interactive, simply run it without arguments:

```sh
./deploy_layer.sh
```

You will then be prompted to enter:

- **Deploy layer for which language?** _(python/nodejs, default: python)_
- **Enter region** _(press Enter to use default `us-east-1`)_
- For **Python**:
  - **Enter Python library name:** _(e.g., requests)_
  - **Enter Python runtime:** _(press Enter to use default `python3.13`)_
- For **Node.js**:
  - **Enter Node.js package name:** _(e.g., lodash)_
  - **Enter Node.js runtime:** _(press Enter to use default `nodejs22.x`)_
- **Enter description:** _(press Enter to use the default description)_

### `Dockerfile`

The provided Dockerfile builds a minimal container designed to deploy AWS Lambda Layers for both Python and Node.js:

1. **Base Image:** Uses the `python:3.13-alpine` image.
2. **Dependencies:** Installs Node.js, npm, zip, and AWS CLI.
3. **Script Setup:** Copies the `deploy_layer.sh` script into the container and sets its execution permissions.
4. **Entrypoint:** Configures the container to execute the `deploy_layer.sh` script on startup.

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

This command will start the container and prompt you for the required information interactively.

## Additional Notes

- **Interactive Input:** Both the local and containerized versions of the script require interactive input. Running the container without the `-it` flag will cause the script to exit immediately since no terminal is attached.
- **Automation:** If you prefer non-interactive automation in the future, consider modifying the script to accept command-line arguments or environment variables.
- **Cleanup:** The script automatically cleans up temporary files after deployment.

## License

This project is released under the MIT License.
