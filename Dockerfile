FROM python:slim

# 更新 apt 並安裝 zip 工具
RUN apt-get update && apt-get install -y zip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 複製部署腳本至容器
COPY deploy_layer.sh /app/deploy_layer.sh
RUN chmod +x /app/deploy_layer.sh

# 安裝 AWS CLI（利用 pip）
RUN pip install awscli

# 設定容器啟動後執行部署腳本
ENTRYPOINT ["sh", "/app/deploy_layer.sh"]