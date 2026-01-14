# DevEnvironment

Este projeto configura o ambiente de desenvolvimento do Alexandre usando a imagem oficial do OpenCode.

## Visao Geral

A infra usa a imagem `alexandremblah/opencode:latest` publicada automaticamente pelo fork do OpenCode em https://github.com/anomalyco/opencode

A imagem e atualizada diariamente as 3h BRT via GitHub Actions (sync com upstream + build Docker).

**Imagem no Docker Hub:** https://hub.docker.com/r/alexandremblah/opencode

## Instrucoes para Agentes

### Deploy do Docker Compose Stack (Swarm)

Quando o usuario pedir para fazer **deploy do `docker-compose.yml`**, siga este processo:

1. **Copie o arquivo `docker-compose.yml` para o host-6:**
   ```bash
   scp docker-compose.yml brs@brs.host-6:~/docker-compose.yml
   ```
2. **Conecte no host-6** (Docker Swarm manager) via SSH/TMux
3. **Remova a stack existente:**
   ```bash
   docker stack rm opencode
   ```
4. **Aguarde a remocao completa** (alguns segundos para os containers serem removidos)
5. **Faca o deploy da nova stack:**
   ```bash
   docker stack deploy -c docker-compose.yml opencode
   ```

#### Verificacao

Apos o deploy, verifique se o servico esta rodando:

```bash
docker stack services opencode
docker service logs opencode_opencode
```

### Forcar Atualizacao da Imagem

Para forcar o pull da imagem mais recente e redeployar:

```bash
docker service update --force --image alexandremblah/opencode:latest opencode_opencode
```
