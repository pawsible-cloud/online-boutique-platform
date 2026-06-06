#!/bin/bash

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
BUCKET_NAME="online-boutique-tf-state-${ACCOUNT_ID}"

echo "Creating S3 state bucket: ${BUCKET_NAME}"

aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}"

aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

echo "✅ Done!"
echo "Bucket: ${BUCKET_NAME}"
