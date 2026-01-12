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

Este script:
- Carrega as credenciais do arquivo `.env` automaticamente
- Usa BuildKit para builds mais rápidos e eficientes
- Faz o push para o Docker Hub

#### Configuração de Credenciais

O arquivo `.env` (não versionado) contém as credenciais do Docker Hub:

```bash
DOCKER_TOKEN=<token>
DOCKER_USER=alexandremblah
```

**Imagem no Docker Hub:** https://hub.docker.com/r/alexandremblah/devenv

### Build Multi-Plataforma (amd64 + arm64)

A imagem **deve** ser publicada para múltiplas arquiteturas (amd64 para servidores Linux e arm64 para Mac M1/M2). Para isso, usar o buildx:

```bash
# Criar/usar builder multi-arch (primeira vez)
docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch

# Build e push para ambas plataformas
docker buildx build --platform linux/amd64,linux/arm64 -t alexandremblah/devenv:latest --push .
```

> **Importante:** O script `./publish-image.sh` faz build apenas para a arquitetura local. Para deploy em servidores x86_64, **sempre usar o comando buildx acima**.

### Notas sobre o Dockerfile

- O OpenCode é instalado em `/opt/opencode/bin` (não em `/root/.opencode/bin`) para evitar conflitos com volumes Docker que podem ser montados em `/root`
- A variável `OPENCODE_INSTALL_DIR` controla o diretório de instalação
- O entrypoint intercepta o comando `opencode` e usa o caminho absoluto para garantir execução

**Repositório do OpenCode:** https://github.com/anomalyco/opencode

### Deploy do Docker Compose Stack (Swarm)

Quando o usuário pedir para fazer **deploy do `docker-compose.yml`**, siga este processo:

1. **Copie o arquivo `docker-compose.yml` para o host-6:**
   ```bash
   scp docker-compose.yml brs@brs.host-6:~/docker-compose.yml
   ```
2. **Conecte no host-6** (Docker Swarm manager) via SSH/TMux
3. **Remova a stack existente:**
   ```bash
   docker stack rm opencode
   ```
4. **Aguarde a remoção completa** (alguns segundos para os containers serem removidos)
5. **Faça o deploy da nova stack:**
   ```bash
   docker stack deploy -c docker-compose.yml opencode
   ```

#### Verificação

Após o deploy, verifique se o serviço está rodando:

```bash
docker stack services opencode
docker service logs opencode_opencode
```
