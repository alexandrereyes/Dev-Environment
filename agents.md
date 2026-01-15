# DevEnvironment

Este projeto configura a infraestrutura core do ambiente de desenvolvimento do Alexandre.

## Visao Geral

A stack de infra (`infra.yml`) contem os servicos essenciais para desenvolvimento:

- **PostgreSQL** (pgvector) - Banco de dados relacional com suporte a vetores
- **Redis** - Cache e message broker
- **RabbitMQ** - Message queue com management UI
- **MinIO** - Object storage compativel com S3
- **Seq** - Centralizador de logs

## Instrucoes para Agentes

### Deploy do Docker Compose Stack (Swarm)

Quando o usuario pedir para fazer **deploy do `infra.yml`**, siga este processo:

1. **Copie o arquivo `infra.yml` para o host-6:**
   ```bash
   scp infra.yml brs@brs.host-6:~/infra.yml
   ```
2. **Conecte no host-6** (Docker Swarm manager) via SSH/TMux
3. **Remova a stack existente:**
   ```bash
   docker stack rm infra
   ```
4. **Aguarde a remocao completa** (alguns segundos para os containers serem removidos)
5. **Faca o deploy da nova stack:**
   ```bash
   docker stack deploy -c infra.yml infra
   ```

#### Verificacao

Apos o deploy, verifique se os servicos estao rodando:

```bash
docker stack services infra
```

### Portas dos Servicos

| Servico    | Porta(s)        | Credenciais                     |
|------------|-----------------|--------------------------------|
| PostgreSQL | 5433            | postgres / postgres            |
| Redis      | 6380            | senha: redis                   |
| RabbitMQ   | 5672, 15672     | rabbit / rabbit                |
| MinIO      | 9000, 9001      | minioAdmin / minioAdmin        |
| Seq        | 5342, 5343      | sem autenticacao               |
