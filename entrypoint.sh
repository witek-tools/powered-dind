#!/bin/bash

# Ensure that necessary environment variables are set
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: AWS_ACCOUNT_ID, AWS_REGION, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY must be set"
  exit 1
fi

# Define the ECR registry URI using environment variables
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Create the Docker config.json dynamically
mkdir -p ~/.docker
cat > ~/.docker/config.json <<EOF
{
  "credHelpers": {
    "public.ecr.aws": "ecr-login",
    "${ECR_URI}": "ecr-login"
  }
}
EOF

# Proceed with the rest of the entrypoint (start the Docker daemon or other commands)
exec "$@"
