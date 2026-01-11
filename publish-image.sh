#!/bin/bash

# Script para build e push da imagem Docker para o Docker Hub

set -e

# Carrega variáveis do .env se existir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
fi

IMAGE_NAME="devenv"
DOCKER_USER="${DOCKER_USER:-alexandremblah}"
DOCKER_TOKEN="${DOCKER_TOKEN:-}"

echo "==> Fazendo build da imagem..."
docker build -t $IMAGE_NAME .

echo "==> Autenticando no Docker Hub..."
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin

echo "==> Taggeando imagem..."
docker tag $IMAGE_NAME $DOCKER_USER/$IMAGE_NAME:latest

echo "==> Fazendo push para o Docker Hub..."
docker push $DOCKER_USER/$IMAGE_NAME:latest

echo "==> Imagem publicada com sucesso: $DOCKER_USER/$IMAGE_NAME:latest"
