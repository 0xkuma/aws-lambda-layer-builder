#!/bin/bash
set -e

# 檢查參數數量
if [ $# -lt 1 ]; then
  echo "Usage: $0 <lib_name> [runtime] [description] [region]"
  exit 1
fi

LIB_NAME="$1"
RUNTIME="${2:-python3.13}"
DESCRIPTION="${3:-Lambda layer for $LIB_NAME}"
REGION="${4:-us-west-2}"
LAYER_NAME="${LIB_NAME}-layer"
ZIP_FILE="${LIB_NAME}_layer.zip"

# 建立暫存資料夾
TMPDIR=$(mktemp -d)
echo "建立暫存資料夾：$TMPDIR"

# 建立符合 AWS Lambda layer 結構的 python 目錄
mkdir -p "$TMPDIR/python"

# 利用 pip 安裝指定的 library 至 python 目錄
echo "安裝 ${LIB_NAME} 至 ${TMPDIR}/python..."
pip install "$LIB_NAME" -t "$TMPDIR/python"

# 打包成 zip，須確保 zip 檔內只有一個頂層的 python 資料夾
echo "打包 layer 成 ${ZIP_FILE}..."
(
  cd "$TMPDIR"
  zip -r "/app/${ZIP_FILE}" python
)

# 使用 AWS CLI 發布 layer
echo "發佈 layer ${LAYER_NAME}..."
aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "$DESCRIPTION" \
  --zip-file "fileb:///app/${ZIP_FILE}" \
  --compatible-runtimes "$RUNTIME" \
  --region "$REGION"

echo "Layer 部署成功！"

# 清除暫存資料夾
rm -rf "$TMPDIR"