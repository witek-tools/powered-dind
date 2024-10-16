#!/bin/bash

# Carregar as variáveis do arquivo .env
export $(grep -v '^#' .env | xargs)

VERSION=2.0.0

# Executar o contêiner com as variáveis carregadas
docker run -d --privileged \
  -e AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID" \
  -e AWS_REGION="$AWS_REGION" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  witektools/powered-dind:$VERSION
