FROM python:3.13-alpine

# 安裝最新可用的 Node.js 和 npm
RUN apk add --no-cache nodejs npm zip aws-cli

WORKDIR /app
COPY deploy_layer.sh /app/
RUN chmod +x deploy_layer.sh

ENTRYPOINT ["sh", "deploy_layer.sh"]