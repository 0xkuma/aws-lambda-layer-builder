FROM python:3.13-slim

# Update apt and install zip with minimal extra packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends zip && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the deployment script and set execute permissions
COPY deploy_layer.sh /app/
RUN chmod +x deploy_layer.sh

# Install AWS CLI without caching installation files
RUN pip install --no-cache-dir awscli

# Set the container to run the deployment script upon start
ENTRYPOINT ["sh", "deploy_layer.sh"]
