# Features Backlog: Project Toolkit

## Modules Registry

- **`MOD-01` Helper & Navigation Engine:** Funções utilitárias de terminal, controle de fluxo de menus, captura de teclas de caractere único (`read -s -n 1`), tratamento de sequências de escape (`ESC`) e checagem de estado do repositório Git[cite: 1].
- **`MOD-02` Maintenance & Self-Update:** Mecanismo autônomo de download, substituição de arquivo local e reinicialização de processo do script via GitHub[cite: 1].
- **`MOD-03` Git Management:** Rotinas de ciclo de vida do Git, incluindo inicialização, clonagem, pull defensivo, Conventional Commits e inspeção/configuração do repositório[cite: 1].
- **`MOD-04` Documentation & Context Extraction:** Scaffolding da arquitetura de documentação, injeção de regras no `.gitignore`, emissão do arquivo de metodologia e consolidadores de contexto (`.txt`) para LLMs[cite: 1].
- **`MOD-05` CLI TUI Controller:** Menu principal e roteamento dos submenus interativos[cite: 1].

---

## Feature Backlog

### `FEAT-01` Inicialização e Clonagem de Repositórios Git
- **Requirements Mapping:** `RF-01`, `RF-02`, `RNF-01`, `RNF-03`, `RNF-04`
- **Target Modules:** `MOD-01`, `MOD-03`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção das opções `1` ("Iniciar Repositório Local") ou `2` ("Clonar Repositório Remoto") dentro do submenu Git[cite: 1].
  - **Critério de Pronto (DoD):** Repositório local criado com a branch inicial `main` ou projeto remoto clonado com sucesso via URL, emitindo mensagens de erro e bloqueando a execução caso o diretório já esteja sob controle de versão[cite: 1].
- **Impact Radius:**
  - Script: Funções `init_repository()`, `clone_repository()` e `check_git_repo()` em `Toolkit.sh`[cite: 1].
  - Arquivos gerados: Diretório `.git/` e arquivos clonados no sistema de arquivos local[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-01-git-init-clone`
  - **Commit Sugerido:** `feat: implement local repository initialization and cloning workflows`

---

### `FEAT-02` Sincronização e Commits Padronizados (Pull & Push)
- **Requirements Mapping:** `RF-03`, `RF-04`, `BR-03`, `BR-04`, `BR-05`, `RNF-03`, `RNF-04`
- **Target Modules:** `MOD-01`, `MOD-03`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção das opções `3` ("Receber Atualizações") ou `4` ("Enviar Atualizações") no submenu Git[cite: 1].
  - **Critério de Pronto (DoD):** Sincronização executada com a política `--no-rebase origin HEAD`, ou staging total (`git add .`) associado a menu de seleção de tipo Conventional Commit (`feat:`, `fix:`, `docs:`, `refactor:`, `perf:`, `test:`), geração de mensagem padrão com timestamp caso vazia, commit local e push condicional para o remoto[cite: 1].
- **Impact Radius:**
  - Script: Funções `pull_updates()` e `push_updates()` em `Toolkit.sh`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-02-git-sync`
  - **Commit Sugerido:** `feat: add pull with merge strategy and conventional commit push workflow`

---

### `FEAT-03` Painel de Inspeção e Gestão de Estado Git
- **Requirements Mapping:** `RF-05`, `RNF-03`, `RNF-04`
- **Target Modules:** `MOD-01`, `MOD-03`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção da opção `5` ("Gerenciar Estado do Repositório") no submenu Git[cite: 1].
  - **Critério de Pronto (DoD):** Renderização de painel com diretório corrente, usuário/e-mail configurados, branch ativa, URL de origem remota, último commit e status de divergência contra upstream (`ahead`/`behind`), além de menu para alterar autor, alterar e-mail, alterar/vincular URL remota, listar branches e criar/trocar de branch via `git switch`[cite: 1].
- **Impact Radius:**
  - Script: Função `manage_state()` em `Toolkit.sh`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-03-git-state-manager`
  - **Commit Sugerido:** `feat: implement repository state inspection and branch manager`

---

### `FEAT-04` Estruturação Documental e Proteção do Repositório
- **Requirements Mapping:** `RF-06`, `RF-07`, `BR-01`, `RNF-01`, `RNF-03`
- **Target Modules:** `MOD-01`, `MOD-04`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção das opções `1` ("Iniciar Documentação") ou `2` ("Atualizar .gitignore") no submenu de Documentação[cite: 1].
  - **Critério de Pronto (DoD):** Validação e criação idempotente do arquivo `README.md`, do diretório `docs/` e dos 10 arquivos estruturais em `docs/`, seguida da injeção do bloco `# === Toolkit Protection ===` no `.gitignore` sem sobrescrever regras prévias[cite: 1].
- **Impact Radius:**
  - Script: Funções `init_documentation()`, `setup_gitignore()` e `update_project_gitignore()` em `Toolkit.sh`[cite: 1].
  - Arquivos gerados: `README.md`, `docs/*.md` e `.gitignore`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-04-doc-scaffolding`
  - **Commit Sugerido:** `feat: implement doc structure scaffolding and gitignore protection`

---

### `FEAT-05` Emissão da Metodologia de Desenvolvimento
- **Requirements Mapping:** `RF-08`, `RNF-01`
- **Target Modules:** `MOD-01`, `MOD-04`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção da opção `3` ("Gerar Documento de Metodologia") no submenu de Documentação[cite: 1].
  - **Critério de Pronto (DoD):** Geração do arquivo `development-method.md` na raiz do projeto contendo as regras e diagramas dos fluxos de Descoberta, Desenvolvimento Isolado e Auditoria, garantindo a proteção do arquivo no `.gitignore`[cite: 1].
- **Impact Radius:**
  - Script: Função `generate_development_method()` em `Toolkit.sh`[cite: 1].
  - Arquivos gerados: `development-method.md`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-05-dev-methodology-generator`
  - **Commit Sugerido:** `feat: add development method template generator`

---

### `FEAT-06` Consolidador de Contextos para Inteligência Artificial
- **Requirements Mapping:** `RF-09`, `RF-10`, `RNF-01`, `RNF-02`
- **Target Modules:** `MOD-01`, `MOD-04`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção das opções `4` ("Gerar Contexto para IA (Documentação)") ou `5` ("Gerar Contexto para IA (Código)") no submenu de Documentação[cite: 1].
  - **Critério de Pronto (DoD):** Criação dos arquivos `ai-context-docs.txt` (árvore do projeto + `README.md` + `docs/*.md`) e `ai-context-code.txt` (árvore do projeto + `.gitignore` + conteúdo não ignorado de `src/`, `source/` ou `public/`) na raiz do projeto[cite: 1].
- **Impact Radius:**
  - Script: Funções `generate_docs_context()` e `generate_code_context()` em `Toolkit.sh`[cite: 1].
  - Arquivos gerados: `ai-context-docs.txt` e `ai-context-code.txt`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-06-ai-context-builders`
  - **Commit Sugerido:** `feat: add ai context extractors for docs and source code`

---

### `FEAT-07` Auto-Atualização Autônoma do Toolkit
- **Requirements Mapping:** `RF-11`, `BR-06`, `RNF-01`, `RNF-02`
- **Target Modules:** `MOD-01`, `MOD-02`[cite: 1]
- **Scope Boundaries:**
  - **Gatilho (Trigger):** Seleção da opção `3` ("Atualizar Ferramenta") no menu principal[cite: 1].
  - **Critério de Pronto (DoD):** Download via `curl` da versão raw mais recente hospedada no GitHub para arquivo temporário, substituição do executável corrente `$0`, aplicação de permissão de execução (`chmod +x`) e reinicialização limpa do processo via `exec "$0" "$@"`[cite: 1].
- **Impact Radius:**
  - Script: Função `update_toolkit()` em `Toolkit.sh`[cite: 1].
- **Git Guidelines:**
  - **Branch:** `feature/FEAT-07-self-updater`
  - **Commit Sugerido:** `feat: add github self update and clean reexec mechanism`