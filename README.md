# Project Toolkit

Utilitário de linha de comando (CLI) em Bash projetado para padronizar, acelerar e orquestrar o fluxo de desenvolvimento de software em ambientes Linux (Debian/Ubuntu) e Windows (via Git Bash). Centraliza a gestão simplificada de Git com Conventional Commits, estruturação de documentação arquitetural e extração automatizada de contextos de código e documentação para consumo por Modelos de Linguagem (LLMs/IAs).

---

## Pré-requisitos e Dependências

A ferramenta depende exclusivamente de utilitários nativos e pacotes padrão do ecossistema POSIX:

- **Linux:** GNU Bash (v4.0+), `git`, `curl` e `coreutils`.
- **Windows:** [Git for Windows](https://git-scm.com/download/win) instalado (fornece o ambiente **Git Bash** com todos os binários Unix necessários nativamente).

### Instalação das Dependências no Debian/Ubuntu

```bash
sudo apt update && sudo apt install -y bash git curl coreutils
```

### Instalação das Dependências no Windows

1. Baixe e instale o **Git for Windows**.
2. Durante a instalação, mantenha a opção padrão de integração do Git Bash no terminal.
3. Todas as dependências (`bash`, `curl`, `git`, `cat`, etc.) já vêm incluídas no pacote.

---

## Instalação Rápida

### Opção 1: Linux (Debian / Ubuntu)

No Linux, adotamos o padrão *XDG Base Directory* instalando o binário em `~/.local/bin/toolkit`:

```bash
mkdir -p ~/.local/bin && curl -sSL [https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh](https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh) -o ~/.local/bin/toolkit && chmod +x ~/.local/bin/toolkit
```

#### Configuração do PATH no Linux (se necessário)
Se o diretório `~/.local/bin` ainda não estiver no seu `$PATH`, adicione a linha abaixo ao seu `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Em seguida, recarregue o terminal:

```bash
source ~/.bashrc
```

---

### Opção 2: Windows (Git Bash)

No Git Bash, a pasta `~/bin` (localizada em `C:\Users\<SeuUsuario>\bin`) já é incluída automaticamente na variável de ambiente `$PATH` pelo perfil padrão do shell. 

Abra o terminal do **Git Bash** (ou use o perfil Git Bash no terminal integrado do VS Code) e execute:

```bash
mkdir -p ~/bin && curl -sSL https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh -o ~/bin/toolkit
```

#### Configuração do PATH no Windows (se necessário)
Caso seu terminal Git Bash não reconheça o comando imediatamente, garanta a exportação adicionando a instrução ao arquivo `~/.bash_profile`:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

> **Nota sobre quebras de linha (Windows):** O script requer o padrão de final de linha Unix (**LF**). Ao clonar ou editar o repositório localmente no Windows, certifique-se de que o VS Code esteja configurado para salvar arquivos com quebra de linha em **LF**.

---

## Como Utilizar

Após a instalação, navegue até o diretório de qualquer projeto no terminal (no Linux ou no Git Bash do Windows) e execute:

```bash
toolkit
```

Ou, caso prefira executar diretamente a partir do arquivo clonado no repositório:

```bash
chmod +x Toolkit.sh
./Toolkit.sh
```

---

## Principais Funcionalidades

- **Gerenciamento Git Simplificado:**
  - Inicialização de repositórios locais na branch `main` e clonagem guiada.
  - Sincronização remota defensiva (`git pull --no-rebase origin HEAD`).
  - Staging e envio de alterações com seleção forçada de Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `perf:`, `test:`).
  - Painel de inspeção de estado (commits à frente/atrás do remote) e troca/criação de branches.
- **Automação e Scaffolding de Documentação:**
  - Criação automática e idempotente do diretório `docs/`, `README.md` e dos 10 arquivos estruturais de arquitetura.
  - Injeção de proteção no `.gitignore` (`# === Toolkit Protection ===`) para evitar versionamento acidental de artefatos locais.
  - Emissão do arquivo de metodologia operacional `development-method.md`.
- **Extração de Contexto para Inteligência Artificial:**
  - `ai-context-docs.txt`: Consolida a árvore de arquivos e toda a documentação Markdown em um único arquivo de texto para LLMs.
  - `ai-context-code.txt`: Consolida a árvore do repositório, `.gitignore` e o código-fonte de `src/`, `source/` ou `public/` em um único arquivo de texto para LLMs.
- **Auto-Atualização:**
  - Atualização autônoma do script diretamente da branch principal do GitHub com reinicialização limpa do processo (`exec`).

---

## Mapa da Documentação (Docs Index)

A documentação detalhada do projeto está estruturada no diretório `docs/` e serve como referência tanto para desenvolvedores quanto para chats de IA em fluxos de descoberta e desenvolvimento:

| Arquivo | Descrição |
| :--- | :--- |
| [`docs/product.md`](docs/product.md) | Visão, escopo do MVP, atores, regras de negócio e requisitos funcionais/não-funcionais. |
| [`docs/features.md`](docs/features.md) | Mapeamento formal de módulos, backlog de features, critérios de pronto (DoD) e raio de impacto. |
| [`docs/architecture.md`](docs/architecture.md) | Visão macro da arquitetura procedural, componentes, fluxos e considerações de segurança. |
| [`docs/infrastructure.md`](docs/infrastructure.md) | Requisitos de ambiente (Debian/Linux e Windows Git Bash), dependências, especificações e modelo de auto-atualização. |
| [`docs/domain.md`](docs/domain.md) | Modelagem conceitual das entidades de domínio, enumerações e casos de uso do sistema. |
| [`docs/database.md`](docs/database.md) | Documentação da persistência orientada ao sistema de arquivos local e metadados do Git. |
| [`docs/backend.md`](docs/backend.md) | Estrutura interna em Bash, interceptadores de fluxo e rotinas de tratamento defensivo de erros. |
| [`docs/api.md`](docs/api.md) | Especificação das chamadas de rede externas (Git CLI e download HTTPS via cURL). |
| [`docs/frontend.md`](docs/frontend.md) | Especificação da interface textual (TUI), renderização de telas e captura de teclado. |
| [`docs/decisions.md`](docs/decisions.md) | Registro de decisões arquiteturais (ADRs), trade-offs aceitos, simplificações e ideias descartadas. |
