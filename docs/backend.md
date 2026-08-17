# Backend Implementation: Project Toolkit

## Structure
O motor interno do **Project Toolkit** é implementado em um arquivo de script único (`Toolkit.sh`), estruturado proceduralmente em seções funcionais bem delimitadas para garantir baixo acoplamento e manutenção direta sem dependências externas[cite: 1]:

- **`Helper Functions` (Utilitários Globais):** Funções transversais de terminal (`print_header`, `print_separator`, `pause_prompt`), validação de repositório (`check_git_repo`) e injeção idempotente de regras de proteção (`setup_gitignore`)[cite: 1].
- **`Maintenance Functions` (Auto-Manutenção):** Rotina de atualização e reinicialização de processo (`update_toolkit`)[cite: 1].
- **`Git Functions` (Operações Git):** Funções especialistas de controle de versão (`init_repository`, `clone_repository`, `pull_updates`, `push_updates`, `manage_state`)[cite: 1].
- **`Documentation Functions` (Automação Documental):** Scaffolding de diretórios (`init_documentation`, `update_project_gitignore`), emissor de metodologia (`generate_development_method`) e extratores de contexto para IA (`generate_docs_context`, `generate_code_context`)[cite: 1].
- **`Submenus & Main Menu` (Controladores de Navegação):** Controladores de menu (`git_menu`, `docs_menu`, `main_menu`) que recebem entradas do usuário e despacham as rotinas correspondentes[cite: 1].

---

## Routing
O roteamento no Project Toolkit substitui rotas HTTP tradicionais por laços interativos controlados por menus textuais baseados na estrutura de controle `case`[cite: 1].

- **Captura de Entrada Sem Buffer:** Utiliza `read -r -s -n 1` para interceptar comandos instantaneamente sem necessidade do [ENTER][cite: 1].
- **Tratamento de Escape Sequence:** Avalia o caractere `\e` (ESC) seguido por leitura rápida temporizada (`read -r -s -t 0.05 -n 2`) para distinguir a tecla `ESC` isolada (retorno de menu) de sequências estendidas de navegação do terminal[cite: 1].

---

### Diagram: Sequence (Ciclo de Vida do Roteamento e Execução de Comando)

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Operador
    participant Menu as Menu Controller (docs_menu)
    participant Guard as Guard / Middleware (check_git_repo)
    participant Service as Service Function (generate_docs_context)
    participant OS as Sistema Operacional / Git CLI

    Dev->>Menu: Digita '4' (Gerar Contexto de Docs)
    Menu->>Service: Invoca generate_docs_context()
    
    Service->>Guard: Executa check_git_repo
    Guard->>OS: git rev-parse --is-inside-work-tree
    
    alt Fora de um repositório Git
        OS-->>Guard: Exit Code != 0
        Guard-->>Dev: Exibe "Erro: Este diretório não tem um repositório Git."
        Guard-->>Service: return 1 (Interrompe fluxo)
        Service-->>Menu: Retorna ao loop do submenu
    else Repositório Git Válido
        OS-->>Guard: Exit Code == 0
        Guard-->>Service: return 0 (Prossegue)
        Service->>OS: git ls-files > ai-context-docs.txt
        Service->>OS: cat README.md docs/*.md >> ai-context-docs.txt
        Service-->>Dev: Exibe "Sucesso! Arquivo 'ai-context-docs.txt' gerado na raiz."
        Service->>Menu: pause_prompt (Aguarda ENTER) e retorna
    end