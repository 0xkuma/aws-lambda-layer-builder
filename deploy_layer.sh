#!/bin/bash
set -e

# Ask for user input interactively

# Prompt for the library name (required)
read -p "Enter library name: " LIB_NAME
if [ -z "$LIB_NAME" ]; then
  echo "Error: Library name is required." >&2
  exit 1
fi

# Prompt for runtime (optional, default: python3.13)
read -p "Enter runtime [default: python3.13]: " RUNTIME
if [ -z "$RUNTIME" ]; then
  RUNTIME="python3.13"
fi

# Prompt for description (optional, default: Lambda layer for $LIB_NAME)
read -p "Enter description [default: Lambda layer for ${LIB_NAME}]: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
  DESCRIPTION="Lambda layer for ${LIB_NAME}"
fi

# Prompt for region (optional, default: us-west-2)
read -p "Enter region [default: us-east-1]: " REGION
if [ -z "$REGION" ]; then
  REGION="us-east-1"
fi

LAYER_NAME="${LIB_NAME}-layer"
ZIP_FILE="${LIB_NAME}_layer.zip"

# Create a temporary directory and ensure it's removed on exit
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
echo "Created temporary directory: $TMPDIR"

# Create the python directory structure required by AWS Lambda layer
mkdir -p "$TMPDIR/python"

# Use pip to install the specified library into the python directory
echo "Installing ${LIB_NAME} into ${TMPDIR}/python..."
pip install "$LIB_NAME" -t "$TMPDIR/python"

# Package it into a zip file; ensure the zip contains only one top-level python folder
echo "Packaging layer into ${ZIP_FILE}..."
(
  cd "$TMPDIR"
  zip -r "/app/${ZIP_FILE}" python
)

# Publish the layer using AWS CLI
echo "Publishing layer ${LAYER_NAME}..."
aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "$DESCRIPTION" \
  --zip-file "fileb:///app/${ZIP_FILE}" \
  --compatible-runtimes "$RUNTIME" \
  --region "$REGION"

echo "Layer deployed successfully!"
