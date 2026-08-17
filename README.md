# Project Toolkit

Utilitário de linha de comando (CLI) em Bash projetado para padronizar, acelerar e orquestrar o fluxo de desenvolvimento de software em ambientes Linux/Debian[cite: 1]. Centraliza a gestão simplificada de Git com Conventional Commits, estruturação de documentação arquitetural e extração automatizada de contextos de código e documentação para consumo por Modelos de Linguagem (LLMs/IAs)[cite: 1].

---

## Pré-requisitos e Dependências

A ferramenta e seu fluxo de documentação dependem exclusivamente de utilitários nativos e pacotes padrão do ecossistema Linux[cite: 1]:

- **Sistema Operacional:** Linux (Debian, Ubuntu ou distribuições compatíveis com POSIX)[cite: 1].
- **Shell:** GNU Bash (versão 4.0 ou superior)[cite: 1].
- **Binários do Sistema:**
  - `git` (v2.x+): Controle de versão e histórico do repositório[cite: 1].
  - `curl`: Download de atualizações e scripts remotos[cite: 1].
  - `coreutils` (`cat`, `mkdir`, `touch`, `chmod`, `mv`, `grep`, `date`): Utilitários nativos do sistema[cite: 1].

### Instalação das Dependências no Debian/Ubuntu

Execute o comando abaixo para garantir que todas as ferramentas do sistema estejam instaladas:

```bash
sudo apt update && sudo apt install -y bash git curl coreutils
```

---

## Instalação Rápida

Para instalar o executável globalmente no diretório local do seu usuário (`~/.local/bin/toolkit`), execute:

```bash
mkdir -p ~/.local/bin && curl -sSL [https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh](https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh) -o ~/.local/bin/toolkit && chmod +x ~/.local/bin/toolkit
```

### Configuração do PATH (Opcional)
Se o diretório `~/.local/bin` ainda não estiver no seu `$PATH`, adicione a linha abaixo ao seu `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Em seguida, recarregue a sessão do terminal:

```bash
source ~/.bashrc
```

---

## Como Utilizar

Após a instalação, navegue até a pasta de qualquer projeto no terminal e execute:

```bash
toolkit
```

Ou, caso esteja executando diretamente a partir do arquivo clonado no repositório local:

```bash
chmod +x Toolkit.sh
./Toolkit.sh
```

---

## Principais Funcionalidades

- **Gerenciamento Git Simplificado:**
  - Inicialização de repositórios locais na branch `main` e clonagem guiada[cite: 1].
  - Sincronização remota defensiva (`git pull --no-rebase origin HEAD`)[cite: 1].
  - Staging e envio de alterações com seleção forçada de Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `perf:`, `test:`)[cite: 1].
  - Painel de inspeção de estado (commits à frente/atrás do remote) e troca/criação de branches[cite: 1].
- **Automação e Scaffolding de Documentação:**
  - Criação automática e idempotente do diretório `docs/`, `README.md` e dos 10 arquivos estruturais de arquitetura[cite: 1].
  - Injeção de proteção no `.gitignore` (`# === Toolkit Protection ===`) para evitar versionamento de artefatos locais[cite: 1].
  - Emissão do arquivo de metodologia operacional `development-method.md`[cite: 1].
- **Extração de Contexto para Inteligência Artificial:**
  - `ai-context-docs.txt`: Consolida a árvore de arquivos e toda a documentação Markdown em um único arquivo de texto para LLMs[cite: 1].
  - `ai-context-code.txt`: Consolida a árvore do repositório, `.gitignore` e o código-fonte de `src/`, `source/` ou `public/` em um único arquivo de texto para LLMs[cite: 1].
- **Auto-Atualização:**
  - Atualização autônoma do script diretamente da branch principal do GitHub com reinicialização limpa do processo (`exec`)[cite: 1].

---

## Mapa da Documentação (Docs Index)

A documentação detalhada do projeto está estruturada no diretório `docs/` e serve como referência tanto para desenvolvedores quanto para chats de IA em fluxos de descoberta e desenvolvimento:

| Arquivo | Descrição |
| :--- | :--- |
| [`docs/product.md`](docs/product.md) | Visão, escopo do MVP, atores, regras de negócio e requisitos funcionais/não-funcionais. |
| [`docs/features.md`](docs/features.md) | Mapeamento formal de módulos, backlog de features, critérios de pronto (DoD) e raio de impacto. |
| [`docs/architecture.md`](docs/architecture.md) | Visão macro da arquitetura procedural, componentes, fluxos e considerações de segurança. |
| [`docs/infrastructure.md`](docs/infrastructure.md) | Requisitos de ambiente (Debian/Linux), dependências, especificações e modelo de auto-atualização. |
| [`docs/domain.md`](docs/domain.md) | Modelagem conceitual das entidades de domínio, enumerações e casos de uso do sistema. |
| [`docs/database.md`](docs/database.md) | Documentação da persistência orientada ao sistema de arquivos local e metadados do Git. |
| [`docs/backend.md`](docs/backend.md) | Estrutura interna em Bash, interceptadores de fluxo e rotinas de tratamento defensivo de erros. |
| [`docs/api.md`](docs/api.md) | Especificação das chamadas de rede externas (Git CLI e download HTTPS via cURL). |
| [`docs/frontend.md`](docs/frontend.md) | Especificação da interface textual (TUI), renderização de telas e captura de teclado. |
| [`docs/decisions.md`](docs/decisions.md) | Registro de decisões arquiteturais (ADRs), trade-offs aceitos, simplificações e ideias descartadas. |