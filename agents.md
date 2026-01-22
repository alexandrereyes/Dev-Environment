# DevEnvironment

Este projeto configura a infraestrutura core do ambiente de desenvolvimento do Alexandre.

## Arquitetura de Rede

### Visao Geral da Topologia

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TWINGATE (Zero Trust)                          │
│                                                                             │
│  ┌─────────────┐      ┌─────────────────────────────────────────────────┐  │
│  │   Mac Ale   │      │                    HOSTS                        │  │
│  │  (Cliente)  │◄────►│  ┌─────────┐  ┌─────────┐  ┌─────────┐         │  │
│  └─────────────┘      │  │ host-6  │  │ host-N  │  │  ...    │         │  │
│                       │  │(Swarm)  │  │         │  │         │         │  │
│                       │  └────┬────┘  └─────────┘  └─────────┘         │  │
│                       │       │         (Rede local entre hosts)        │  │
│                       └───────┼─────────────────────────────────────────┘  │
│                               │                                             │
└───────────────────────────────┼─────────────────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   Docker Swarm        │
                    │   Rede: public        │
                    │                       │
                    │  ┌─────────────────┐  │
                    │  │ Este Container  │  │
                    │  │   (opencode)    │  │
                    │  │ docker -> host  │  │
                    │  └─────────────────┘  │
                    │                       │
                    │  ┌─────────────────┐  │
                    │  │ postgres-svc    │  │
                    │  │ redis-svc       │  │
                    │  │ rabbitmq-svc    │  │
                    │  │ minio-svc       │  │
                    │  │ seq-svc         │  │
                    │  │ twingate-ctrl   │  │
                    │  └─────────────────┘  │
                    └───────────────────────┘
```

### Componentes

| Componente | Localizacao | Funcao |
|------------|-------------|--------|
| **Este Container (opencode)** | Rede Swarm `public` | Ambiente de dev onde os clientes conectam |
| **Docker CLI** | Container -> Host | O comando `docker` aponta para o Docker do host-6 |
| **Twingate Controller (Swarm)** | Rede Swarm `public` | Permite acesso aos servicos do Swarm pelo nome (DNS do Swarm) |
| **Twingate Controller (Host)** | Um dos hosts | Permite acesso a rede de hosts |
| **Twingate Client** | Mac Ale | Cliente que conecta na rede zero trust |

### Fluxo de Acesso

1. **Devs (ex: Mac Ale)** conectam neste container `opencode` para desenvolver
2. **Servicos do Swarm** sao acessiveis pelo nome (ex: `postgres-svc`) gracas ao DNS do Swarm
3. **Acesso externo** (do Mac) aos servicos do Swarm e feito via Twingate resources
4. **Comandos Docker** executados aqui rodam no host-6 (socket mapeado)

### Twingate Resources

Com o cliente Twingate ligado no Mac, e possivel acessar diretamente:
- `postgres-svc` - Banco PostgreSQL
- `redis-svc` - Redis
- Outros servicos da rede Swarm pelo nome do servico

## Stack de Infraestrutura

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
