# DevEnvironment

Este é o projeto que configura o ambiente de desenvolvimento do Alexandre.

## Visão Geral

O `Dockerfile` é a imagem base desse ambiente de desenvolvimento, que sempre vai rodar dockerizado. A imagem é baseada em Debian e inclui as ferramentas essenciais como curl, git e o OpenCode CLI.

## Instruções para Agentes

### Deploy e Teste da Imagem Docker

Quando forem feitas mudanças no `Dockerfile`, o agente **deve** fazer deploy da imagem para testar.

#### Critério de Aceite

O teste é considerado bem-sucedido quando:

1. O container Docker subir corretamente
2. O servidor OpenCode web expor a porta 4096
3. Responder a um `curl` nessa porta com o HTML do OpenCode

#### Comandos para Teste

```bash
# Build da imagem
docker build -t devenv .

# Rodar o container com o servidor OpenCode web (porta padrão 4096)
docker run -d -p 4096:4096 --name devenv-test devenv opencode web --hostname 0.0.0.0

# Testar se responde corretamente (deve retornar HTML)
curl http://localhost:4096

# Limpar após o teste
docker stop devenv-test && docker rm devenv-test
```

> **Importante:** Após o deploy e teste, **sempre remover o container** criado para teste. Isso evita acúmulo de containers desnecessários e mantém o ambiente limpo.

### Publicar a Imagem

Quando o usuário pedir para **publicar a imagem**, execute o script:

```bash
./publish-image.sh
```

Este script faz o build da imagem e push para o Docker Hub automaticamente.

**Imagem no Docker Hub:** https://hub.docker.com/r/alexandremblah/devenv
