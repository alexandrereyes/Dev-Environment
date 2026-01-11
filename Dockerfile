# Imagem base Debian
FROM debian:bookworm-slim

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instala as dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    unzip \
    gnupg \
    lsb-release \
    apt-transport-https \
    chromium \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Variáveis de ambiente para Chromium headless
ENV CHROME_BIN=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Instala .NET 10 (preview)
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet \
    && rm dotnet-install.sh \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet"

# Instala GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Instala Docker CLI + Buildx
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/*

# Instala o OpenCode em /opt/opencode/bin
# IMPORTANTE: NÃO instalar em /root/.opencode/bin (padrão) porque volumes Docker
# montados em /root sobrescrevem o diretório e o binário desaparece em runtime
RUN curl -fsSL https://opencode.ai/install | bash \
    && mkdir -p /opt/opencode/bin \
    && mv /root/.opencode/bin/opencode /opt/opencode/bin/ \
    && rm -rf /root/.opencode

# Adiciona o binário ao PATH
ENV PATH="/opt/opencode/bin:${PATH}"

# Define o diretório de trabalho padrão
WORKDIR /workspace

# Copia e configura o entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Configura o cron job para rebuild diário da imagem às 3h
COPY crontab /etc/cron.d/devenv-cron
RUN chmod 0644 /etc/cron.d/devenv-cron && crontab /etc/cron.d/devenv-cron

# Entrypoint para inicialização (cron, github cli)
ENTRYPOINT ["/entrypoint.sh"]

# Comando padrão: abre o OpenCode TUI no diretório atual
CMD ["opencode"]
