# Architecture Decisions & Trade-offs: Project Toolkit

## Stack

- **`DEC-STK-01` Adoção de GNU Bash Puro (Sem Runtimes Pesados):**
  - **Contexto:** Necessidade de um utilitário para automação de Git, scaffolding de documentação e extração de contexto para IA no ambiente de desenvolvimento local (Debian/Linux)[cite: 1].
  - **Decisão:** Escrever toda a ferramenta em um único script Bash (`#!/bin/bash`)[cite: 1].
  - **Justificativa:** O Bash está nativamente disponível em distribuições Linux, eliminando a sobrecarga de gerenciar interpretadores e ambientes virtuais (Node.js/npm, Python/pip, Ruby, etc.) ou compilação de binários.
  - **Consequências:** Inicialização instantânea, portabilidade total no ecossistema POSIX/Linux e zero dependências de pacotes externos[cite: 1].

- **`DEC-STK-02` Utilização de Binários Nativos (`git`, `curl`, `coreutils`):**
  - **Contexto:** Operações de controle de versão, download remoto e manipulação de arquivos[cite: 1].
  - **Decisão:** Orquestrar diretamente os utilitários de linha de comando padrão do sistema operacional[cite: 1].
  - **Justificativa:** Aproveita a maturidade, estabilidade e performance das ferramentas padrão da comunidade Unix em vez de reimplementar clientes de rede ou bibliotecas de manipulação de Git.

---

## Architecture

- **`DEC-ARC-01` Estrutura Monolítica em Script Único (*Single-File Utility*):**
  - **Contexto:** Facilidade de distribuição, portabilidade e atualização em diferentes máquinas.
  - **Decisão:** Manter todas as rotinas em um único arquivo `Toolkit.sh` organizado proceduralmente por seções funcionais[cite: 1].
  - **Justificativa:** Permite que a ferramenta seja copiada, movida ou atualizada via download direto de arquivo único (`curl`), sem necessidade de gerenciar múltiplos módulos ou caminhos de importação no filesystem[cite: 1].

- **`DEC-ARC-02` Persistência Exclusiva no Sistema de Arquivos e Metadados Git:**
  - **Contexto:** Registro do estado do projeto, documentação e configurações de versão[cite: 1].
  - **Decisão:** Dispensar qualquer banco de dados relacional ou NoSQL (`docs/database.md` N/A)[cite: 1].
  - **Justificativa:** O estado do projeto pertence naturalmente à árvore de arquivos e ao repositório `.git/`[cite: 1]. Introduzir um banco de dados criaria complexidade desnecessária (*over-engineering*) incompatível com a natureza de um utilitário local.

- **`DEC-ARC-03` Interface Textual Interativa (TUI) com Navegação por Caractere Único:**
  - **Contexto:** Agilidade operacional no fluxo diário de desenvolvimento.
  - **Decisão:** Construir uma TUI baseada em `read -s -n 1` com captura de sequência de escape (`ESC`)[cite: 1].
  - **Justificativa:** Elimina a fricção de digitar comandos longos ou pressionar [ENTER] repetidamente para seleções de menu, integrando-se nativamente ao terminal integrado do VS Code ou shell do sistema[cite: 1].

---

## Abstractions

- **`DEC-ABS-01` Dispensa de Servidor Web e Endpoints de API (`docs/api.md` N/A):**
  - **Decisão:** O Toolkit não atua como serviço de rede nem implementa rotas HTTP/REST/GraphQL[cite: 1].
  - **Motivo:** A interação é estritamente local via stdin/stdout e invocação de subshells, não havendo requisitos de comunicação cliente-servidor externa além dos comandos Git e download raw[cite: 1].

- **`DEC-ABS-02` Dispensa de Frameworks Web de Frontend (`docs/frontend.md` N/A):**
  - **Decisão:** Interface desenhada proceduralmente no terminal usando caracteres ASCII e comandos nativos (`clear`, `echo`)[cite: 1].
  - **Motivo:** Uma interface gráfica (Web/Desktop) adicionaria dependências desnecessárias (Electron, navegadores, servidores locais), violando o princípio de simplicidade e baixo consumo de recursos.

- **`DEC-ABS-03` Conventional Commits Estruturados por Menu Fixo (1 a 6):**
  - **Decisão:** Forçar a seleção de prefixos semânticos predefinidos (`feat:`, `fix:`, `docs:`, `refactor:`, `perf:`, `test:`)[cite: 1].
  - **Motivo:** Garante a padronização do histórico de commits sem a necessidade de instalar utilitários externos complexos como `commitlint` ou `commitizen`.

- **`DEC-ABS-04` Injeção Não-Destrutiva no `.gitignore` (`setup_gitignore`):**
  - **Decisão:** Utilizar verificação de bloco (`# === Toolkit Protection ===`) antes de anexar regras[cite: 1].
  - **Motivo:** Abstração simples e idempotente que evita duplicidade no arquivo `.gitignore` sem exigir parsers complexos de arquivos[cite: 1].

---

## Security Trade-offs

- **`DEC-SEC-01` Auto-Atualização Direta via URL Raw do GitHub sem Checagem Criptográfica:**
  - **Contexto:** Mecanismo de atualização automática da ferramenta (`update_toolkit` / `FEAT-07`)[cite: 1].
  - **Risco Aceito:** O script baixa o arquivo executável via HTTPS a partir da branch `main` do repositório remoto e substitui imediatamente o processo corrente sem verificar assinatura GPG ou hash SHA-256 fixo[cite: 1].
  - **Cenário de Inadequação:** Ambientes de produção corporativa com restrições rígidas de auditoria de código ou suscetíveis a comprometimento de conta no GitHub.
  - **Mitigação Atual:** O tráfego utiliza TLS/HTTPS (`curl -sSLf`) contra o repositório oficial do próprio desenvolvedor (`PauloVNM/Project-Toolkit`), sendo um atalho consciente e temporário para agilidade em projetos pessoais[cite: 1].

- **`DEC-SEC-02` Staging Global (`git add .`) no Envio de Atualizações:**
  - **Contexto:** Rotina simplificada de commit em `push_updates`[cite: 1].
  - **Risco Aceito:** Inclusão indiscriminada de todos os arquivos modificados na área de staging[cite: 1].
  - **Mitigação:** O Toolkit injeta compulsoriamente proteções no `.gitignore` contra arquivos sensíveis gerados pela ferramenta (`ai-context-*.txt`, `development-method.md`)[cite: 1], cabendo ao desenvolvedor manter arquivos de segredos (`.env`) listados no `.gitignore`.

---

## Rejected Ideas

- **`REJ-01` Reescrever a Ferramenta em Go ou Rust:**
  - *Motivo do Descarte:* Introduziria uma etapa obrigatória de compilação, necessidade de disponibilizar múltiplos binários para diferentes arquiteturas e gerenciamento de releases de binários no GitHub, contrariando a simplicidade de um script shell direto.
- **`REJ-02` Utilizar Python com Bibliotecas TUI (ex: `Rich`, `Textual`, `Curses`):**
  - *Motivo do Descarte:* Exigiria que a máquina host tivesse interpretador Python específico configurado e dependências instaladas globalmente ou em ambientes virtuais (`venv`), gerando atrito no uso em diferentes estações de trabalho.
- **`REJ-03` Criar um Dashboard Web Local para Gestão dos Documentos e Git:**
  - *Motivo do Descarte:* Considerado over-engineering severo para uma ferramenta que se destina a ser executada rapidamente dentro do terminal integrado do VS Code durante sessões de codificação.
- **`REJ-04` Utilizar Parsers JSON/YAML para os Contextos de IA:**
  - *Motivo do Descarte:* A consolidação em arquivos de texto plano com divisórias textuais claras (`ai-context-*.txt`) é mais leve, legível e consome menos tokens estruturais ao ser injetada em LLMs do que estruturas aninhadas JSON complexas[cite: 1].