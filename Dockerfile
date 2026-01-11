# Imagem base Debian
FROM debian:bookworm-slim

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instala as dependências necessárias
# - curl: para baixar o script de instalação
# - ca-certificates: para conexões HTTPS
# - git: necessário para operações do OpenCode com repositórios
# - unzip: pode ser necessário para extrair binários
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instala o OpenCode usando o script oficial
RUN curl -fsSL https://opencode.ai/install | bash

# Adiciona o binário ao PATH (o script instala em ~/.local/bin por padrão)
ENV PATH="/root/.local/bin:${PATH}"

# Define o diretório de trabalho
WORKDIR /workspace

# Comando padrão
CMD ["opencode"]
