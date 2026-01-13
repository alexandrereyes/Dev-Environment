#!/bin/bash

# Inicia o serviço cron em background
service cron start

# Atualiza o OpenCode para a versão mais recente
echo "Atualizando OpenCode..."
curl -fsSL https://opencode.ai/install | OPENCODE_INSTALL_DIR=/opt/opencode bash 2>/dev/null \
    && echo "OpenCode atualizado com sucesso!" \
    || echo "Aviso: Não foi possível atualizar o OpenCode."

# Configura o GitHub CLI com Git se existir autenticação válida
if [ -f "$HOME/.config/gh/hosts.yml" ] && [ -s "$HOME/.config/gh/hosts.yml" ]; then
    echo "Credenciais do GitHub encontradas. Configurando integração com Git..."
    gh auth setup-git 2>/dev/null && echo "GitHub CLI configurado com sucesso!" \
        || echo "Aviso: Não foi possível configurar o GitHub CLI com Git."
fi

# Executa o comando passado para o container
exec "$@"
