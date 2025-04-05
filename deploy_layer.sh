#!/bin/bash
set -e

# Prompt for language selection (python/nodejs, default: python)
read -p "Deploy layer for which language? (python/nodejs, default: python): " LANG_TYPE
if [ -z "$LANG_TYPE" ]; then
  LANG_TYPE="python"
fi

# Set AWS region (default: us-east-1)
read -p "Enter region [default: us-east-1]: " REGION
if [ -z "$REGION" ]; then
  REGION="us-east-1"
fi

# For Python, prompt for library name and runtime
if [ "$LANG_TYPE" = "python" ]; then
    read -p "Enter Python library name: " PY_LIB
    if [ -z "$PY_LIB" ]; then
      echo "Error: Python library name is required." >&2
      exit 1
    fi
    read -p "Enter Python runtime [default: python3.13]: " PY_RUNTIME
    if [ -z "$PY_RUNTIME" ]; then
      PY_RUNTIME="python3.13"
    fi
fi

# For Node.js, prompt for package name and runtime
if [ "$LANG_TYPE" = "nodejs" ]; then
    read -p "Enter Node.js package name: " NODE_LIB
    if [ -z "$NODE_LIB" ]; then
      echo "Error: Node.js package name is required." >&2
      exit 1
    fi
    read -p "Enter Node.js runtime [default: nodejs22.x]: " NODE_RUNTIME
    if [ -z "$NODE_RUNTIME" ]; then
      NODE_RUNTIME="nodejs22.x"
    fi
fi

# Set default description based on selection
if [ "$LANG_TYPE" = "python" ]; then
  DEFAULT_DESC="Lambda layer for ${PY_LIB}"
elif [ "$LANG_TYPE" = "nodejs" ]; then
  DEFAULT_DESC="Lambda layer for ${NODE_LIB}"
fi
read -p "Enter description [default: $DEFAULT_DESC]: " DESCRIPTION
if [ -z "$DESCRIPTION" ]; then
  DESCRIPTION="$DEFAULT_DESC"
fi

# Set layer name and zip file name based on selection
if [ "$LANG_TYPE" = "python" ]; then
  LAYER_NAME="${PY_LIB}-layer"
  ZIP_FILE="${PY_LIB}_layer.zip"
elif [ "$LANG_TYPE" = "nodejs" ]; then
  LAYER_NAME="${NODE_LIB}-layer"
  ZIP_FILE="${NODE_LIB}_layer.zip"
fi

# Create a temporary directory for building the layer
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
echo "Created temporary directory: $TMPDIR"

# Build the Python layer if selected
if [ "$LANG_TYPE" = "python" ]; then
  mkdir -p "$TMPDIR/python"
  echo "Installing Python library ${PY_LIB} into ${TMPDIR}/python..."
  pip install "$PY_LIB" -t "$TMPDIR/python"
fi

# Build the Node.js layer if selected
if [ "$LANG_TYPE" = "nodejs" ]; then
  mkdir -p "$TMPDIR/nodejs"
  echo "Initializing Node.js project in ${TMPDIR}/nodejs..."
  (cd "$TMPDIR/nodejs" && npm init -y >/dev/null)
  echo "Installing Node.js package ${NODE_LIB} into ${TMPDIR}/nodejs..."
  (cd "$TMPDIR/nodejs" && npm install "$NODE_LIB" >/dev/null)
fi

# Package the layer: include the python or nodejs directory based on selection
echo "Packaging layer into ${ZIP_FILE}..."
(
  cd "$TMPDIR"
  if [ "$LANG_TYPE" = "python" ]; then
    zip -r "/app/${ZIP_FILE}" python
  elif [ "$LANG_TYPE" = "nodejs" ]; then
    zip -r "/app/${ZIP_FILE}" nodejs
  fi
)

# Set compatible runtimes based on selection
if [ "$LANG_TYPE" = "python" ]; then
  COMPATIBLE_RUNTIMES="$PY_RUNTIME"
elif [ "$LANG_TYPE" = "nodejs" ]; then
  COMPATIBLE_RUNTIMES="$NODE_RUNTIME"
fi

# Publish the layer using AWS CLI
echo "Publishing layer ${LAYER_NAME} with runtime: ${COMPATIBLE_RUNTIMES}..."
aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "$DESCRIPTION" \
  --zip-file "fileb:///app/${ZIP_FILE}" \
  --compatible-runtimes $COMPATIBLE_RUNTIMES \
  --region "$REGION" 1> /dev/null

echo "Layer deployed successfully!"
