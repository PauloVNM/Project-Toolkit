# Database: Project Toolkit

## Overview
O **Project Toolkit** é um utilitário CLI em shell script e **não utiliza** bancos de dados relacionais (SQL), bancos baseados em documentos (NoSQL) ou mecanismos de persistência em memória (Redis/Memcached)[cite: 1]. 

A persistência de dados e estado da ferramenta é estritamente delegada ao **sistema de arquivos local do sistema operacional (Debian/Linux)** e à base interna de controle de versão mantida pelo **Git** (`.git/`)[cite: 1].

---

## Schema
- **Status:** Não Aplicável (N/A).
- **Justificativa:** A ferramenta não possui tabelas, entidades relacionais, coleções ou colunas físicas. O estado transitório e as configurações de autor (`user.name`, `user.email`) e ramificações (`branch`, `remote origin`) são persistidos diretamente na configuração local do Git (`.git/config`)[cite: 1].
- **Arquivos Físicos de Persistência em Disco:**
  - `.gitignore`: Armazena regras de exclusão de artefatos locais do Toolkit[cite: 1].
  - `README.md`: Documento raiz gerado e mantido no diretório do projeto[cite: 1].
  - `docs/*.md`: Arquivos de documentação estrutural do projeto em desenvolvimento[cite: 1].
  - `development-method.md`: Metodologia de trabalho gerada na raiz[cite: 1].
  - `ai-context-docs.txt` e `ai-context-code.txt`: Buffers consolidados gerados em texto puro para consumo por LLMs[cite: 1].

---

### Diagram: ER (Entidade-Relacionamento)
> **Nota de Arquitetura:** Não aplicável devido à ausência de esquemas de tabelas ou modelos de dados relacionais. A rastreabilidade desta decisão estrutural está documentada em `decisions.md` sob a seção de decisões arquiteturais.

---

## Procedures
- **Status:** Não Aplicável (N/A).
- **Justificativa:** Não existem lógicas de negócio armazenadas em banco de dados (*stored procedures* ou funções SQL). Toda a lógica e validações de execução são implementadas proceduralmente nas funções do próprio script Bash (`Toolkit.sh`)[cite: 1].

---

## Triggers
- **Status:** Não Aplicável (N/A).
- **Justificativa:** O projeto não utiliza gatilhos de banco de dados (*database triggers*). As rotinas de proteção e verificação de ambiente (como validação de work tree via `check_git_repo` e injeção no `.gitignore` via `setup_gitignore`) são acionadas como pré-condições nas rotinas de fluxo do script[cite: 1].

---

## Migrations & Seed Data
- **Status:** Não Aplicável (N/A).
- **Justificativa:** Por não possuir esquemas tabulares ou banco relacional, o sistema dispensa ferramentas de migração de banco (como Flyway, Liquibase, Prisma ou Knex) e scripts de *seed* de dados. A inicialização de dados limita-se à criação idempotente da estrutura de diretórios e arquivos de documentação vazios através da função `init_documentation()`[cite: 1].