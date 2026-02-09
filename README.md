# infra-ops-automation-toolkit

Projeto de portfólio DevOps construído de forma incremental em um servidor **Ubuntu 22.04 na AWS (EC2)**, demonstrando práticas reais de automação, observabilidade básica, backups, conteinerização, CI e provisionamento com Ansible.

---

## 🎯 Objetivo do projeto

Demonstrar, na prática:

* Automação com **Bash + cron + logrotate**
* Execução de aplicações em **Docker + Docker Compose**
* Serviço com **healthcheck**
* Banco de dados (**PostgreSQL**) com **backup automatizado e retenção**
* **CI com GitHub Actions**
* Provisionamento **idempotente com Ansible (localhost)**

O projeto é organizado seguindo um padrão comum de “**repo (código) vs runtime (servidor)**”.

---

## 🏗️ Arquitetura (conceitual)

```
📁 REPOSITÓRIO (/opt/infra-ops-automation-toolkit)
│
├── scripts/              # Automação em Bash (versionada)
├── cron/                 # Arquivos de cron versionados
├── logrotate/            # Configuração de rotação de logs
├── docker/               # Stack Docker Compose
├── ansible/              # Provisionamento automatizado
└── docs/                 # Documentação técnica

📁 RUNTIME NO SERVIDOR (/opt/infra-ops)
│
├── logs/                 # Logs de execução dos scripts
├── backups/
│   └── postgres/         # Dumps automáticos do banco
├── scripts/              # Scripts executados pelo sistema
└── app/docker/           # Stack Docker em execução
```

---

## ✅ Fase 1 — Automação básica (Bash + Cron + Logrotate)

### Scripts implementados

* **Healthcheck de disco**

  ```
  scripts/health/disk_usage_check.sh
  ```

* **Limpeza de backups antigos**

  ```
  scripts/maintenance/cleanup_backups.sh
  ```

### Agendamentos (cron)

Arquivo versionado em:

```
cron/cronjobs.d/infra-ops
```

Instalado em:

```
/etc/cron.d/infra-ops
```

### Rotação de logs (logrotate)

Arquivo versionado em:

```
logrotate/infra-ops.conf
```

Instalado em:

```
/etc/logrotate.d/infra-ops
```

---

## 🐳 Fase 2 — Docker Compose + Healthcheck

Stack em:

```
docker/compose.yml
```

Serviços:

* `app`: servidor HTTP simples em Python com **HEALTHCHECK**
* `postgres`: PostgreSQL 16 (Alpine) com **healthcheck interno**

Rodar manualmente no servidor:

```bash
cd /opt/infra-ops/app/docker
docker compose up -d --build
```

Validar:

```bash
docker ps
curl -I http://localhost:8080
```

---

## 💾 Fase 2.5 — PostgreSQL + Backup Automatizado

Script de backup versionado em:

```
scripts/backup/backup_postgres.sh
```

Executa:

* `pg_dump` dentro do container
* Compressão (`gzip`)
* Retenção automática (7 dias por padrão)
* Logs em `/opt/infra-ops/logs/backup_postgres.log`

Teste manual:

```bash
sudo /opt/infra-ops/scripts/backup/backup_postgres.sh
ls -lh /opt/infra-ops/backups/postgres
```

Agendado via cron diariamente às 03:00.

---

## 🤖 Fase 3 — Provisionamento com Ansible (localhost)

Playbook principal:

```
ansible/site.yml
```

Roles implementadas:

| Role                     | Responsabilidade                       |
| ------------------------ | -------------------------------------- |
| `infra_ops_base`         | Criação de diretórios base             |
| `docker_engine`          | Validação do Docker existente          |
| `infra_ops_runtime`      | Copiar scripts, cron e logrotate       |
| `docker_compose_runtime` | Sincronizar compose e subir containers |

### Executar provisionamento (uma linha)

```bash
cd ansible
sudo ansible-playbook -c local -i inventory.ini site.yml
```

> O playbook é **idempotente** — rodar múltiplas vezes não “quebra” o sistema.

---

## 🚀 CI — GitHub Actions

Arquivo:

```
.github/workflows/ci.yml
```

O pipeline executa automaticamente em `dev` e `main`:

* ✅ **ShellCheck** em todos os scripts Bash
* ✅ Validação do `docker compose`

---

## 🔐 Boas práticas adotadas

* PostgreSQL **não exposto publicamente por padrão**
* Uso de volumes nomeados para persistência
* Logs centralizados e rotacionados
* Scripts com validações (`set -euo pipefail`)
* Provisionamento repetível com Ansible

---

## 🧪 Como validar tudo rapidamente

```bash
docker ps
curl -I http://localhost:8080
ls -lh /opt/infra-ops/backups/postgres
sudo cat /etc/cron.d/infra-ops
```

---

## 🗺️ Roadmap (próximos passos)

* **Terraform** para criar a EC2 automaticamente na AWS
* Variáveis de ambiente para segredos (Vault / SSM)
* Alertas por e-mail ou Slack em falhas
* Testes automatizados para os scripts Bash

---

## 📌 Autor

Projeto desenvolvido como portfólio DevOps prático e incremental.
