#!/bin/bash

# Carregar as variáveis do arquivo .env
export $(grep -v '^#' .env | xargs)

# Executar o contêiner com as variáveis carregadas
docker run -d --privileged \
  -e AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID" \
  -e AWS_REGION="$AWS_REGION" \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  witektools/powered-dind:latest

# docker exec -it 40d1663e65be2c3a0608540c2f257547183544e04c9755a0db472b61cf54bd46 /bin/bash
