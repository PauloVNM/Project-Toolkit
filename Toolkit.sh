#!/bin/bash

# ==========================================
# Helper Functions
# ==========================================

print_header() {
    clear
    echo "=============================="
    echo "   $1"
    echo "=============================="
}

print_separator() {
    echo "----------------------------------------"
}

pause_prompt() {
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}

check_git_repo() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Erro: Este diretório não tem um repositório Git."
        pause_prompt
        return 1
    fi
    return 0
}

setup_gitignore() {
    local script_name=$(basename "$0")
    
    if [[ ! -f .gitignore ]]; then
        touch .gitignore
        echo "[Proteção] Arquivo .gitignore criado."
    fi

    if ! grep -qF "# === Toolkit Protection ===" .gitignore; then
        {
            echo "# === Toolkit Protection ==="
            echo "$script_name"
            echo "ai-context-docs.txt"
            echo "ai-context-code.txt"
            echo "# =========================="
        } >> .gitignore
        echo "[Proteção] Bloco do Toolkit adicionado ao .gitignore."
    fi
}

# ==========================================
# Git Functions
# ==========================================

init_repository() {
    print_header "Iniciar Novo Repositório"
    echo "Configurando base local..."
    
    git init -b main
    
    echo "Repositório local iniciado na branch 'main'."
    echo "Pronto para o seu primeiro commit estrutural."
    pause_prompt
}

link_remote() {
    print_header "Vincular Repositório Remoto"
    
    check_git_repo || return

    while true; do
        local url
        read -p "Digite a URL remota (ou vazio para cancelar): " url
        
        if [ -z "$url" ]; then
            break
        fi
        
        if git ls-remote "$url" > /dev/null 2>&1; then
            if git remote | grep -q "^origin$"; then
                git remote set-url origin "$url"
            else
                git remote add origin "$url"
            fi
            echo "Repositório remoto vinculado."
            break
        else
            echo "Erro: Repositório inacessível."
        fi
    done
    
    pause_prompt
}

pull_updates() {
    print_header "Receber Atualizações"
    
    check_git_repo || return

    echo "Verificando e recebendo atualizações remotas..."
    print_separator
    
    # Executa a sincronização forçando a estratégia padrão de mesclagem (merge)
    # Isso evita o erro fatal de "divergent branches"
    if git pull --no-rebase origin HEAD; then
        print_separator
        echo "Atualizações recebidas e integradas com sucesso."
    else
        print_separator
        echo "Aviso: Ocorreu um erro ao sincronizar."
        echo "Isso geralmente acontece quando há conflitos de código (o mesmo arquivo"
        echo "foi alterado de formas diferentes no local e no remoto)."
        echo "Abra o VS Code, resolva os conflitos destacados nos arquivos e,"
        echo "em seguida, use a opção de 'Enviar Atualizações' para concluir."
    fi

    pause_prompt
}

push_updates() {
    print_header "Enviar Atualizações"
    
    check_git_repo || return

    git status -s
    
    local user_confirmation
    read -p "Deseja indexar e enviar as alterações? (y/N): " user_confirmation
    
    if [[ ! "$user_confirmation" =~ ^[Yy]$ ]]; then
        return
    fi

    echo "1. feat: (Novidades e melhorias)"
    echo "2. fix: (Correção de erros)"
    echo "3. docs: (Atualização de documentos)"
    echo "4. refactor: (Melhorias no código existente)"
    echo "5. perf: (Melhoria do desempenho)"
    echo "6. test: (Adição ou correção de testes automatizados)"

    local selection
    local commit_prefix
    while true; do
        echo -n "Escolha uma opção: "
        read -r -s -n 1 selection
        
        case $selection in
            1) commit_prefix="feat:"; echo ""; break ;;
            2) commit_prefix="fix:"; echo ""; break ;;
            3) commit_prefix="docs:"; echo ""; break ;;
            4) commit_prefix="refactor:"; echo ""; break ;;
            5) commit_prefix="perf:"; echo ""; break ;;
            6) commit_prefix="test:"; echo ""; break ;;
            *) echo -e "\nOpção inválida."; sleep 1 ;;
        esac
    done

    local commit_msg
    read -p "Digite a mensagem para '$commit_prefix' (vazio para data): " commit_msg
    
    local evaluated_message=${commit_msg:-"Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"}
    local final_msg="$commit_prefix $evaluated_message"
    
    git add .
    git commit -m "$final_msg"
    git push -u origin HEAD
    
    pause_prompt
}

show_overview() {
    print_header "Visão Geral"

    local current_dir
    current_dir=$(pwd)
    echo "Diretório Atual: $current_dir"
    print_separator

    local user_name
    local user_email
    user_name=$(git config user.name)
    user_email=$(git config user.email)

    echo "Usuário Git:      ${user_name:-'Não configurado'}"
    echo "E-mail Git:       ${user_email:-'Não configurado'}"

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        local current_branch
        local remote_url
        current_branch=$(git branch --show-current)
        remote_url=$(git config --get remote.origin.url)

        local last_commit
        last_commit=$(git log -1 --format="%s (%cr)" 2>/dev/null)
        if [[ -z "$last_commit" ]]; then
            last_commit="Nenhum commit encontrado."
        fi

        git fetch -q 2>/dev/null

        local sync_status
        if git rev-parse "@{u}" > /dev/null 2>&1; then
            local ahead
            local behind
            ahead=$(git rev-list --count @{u}..HEAD)
            behind=$(git rev-list --count HEAD..@{u})

            if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
                sync_status="Sincronizado com os commits do servidor"
            elif [[ "$ahead" -gt 0 && "$behind" -eq 0 ]]; then
                sync_status="Adiantado: $ahead commit(s) (Use Push)"
            elif [[ "$ahead" -eq 0 && "$behind" -gt 0 ]]; then
                sync_status="Atrasado: $behind commit(s) (Use Pull)"
            else
                sync_status="Divergente: $ahead adiantado(s) e $behind atrasado(s)"
            fi
        else
            sync_status="Sem ramificação remota configurada."
        fi

        echo "Branch Ativa:     ${current_branch:-'Nenhuma branch ativa (HEAD destacada)'}"
        echo "Remoto (origin):  ${remote_url:-'Nenhum repositório remoto vinculado'}"
        echo "Status Sincronia: $sync_status"
        echo "Último Commit:    $last_commit"
    else
        echo "Status Git:       Este diretório NÃO é um repositório Git."
    fi
    print_separator
    
    pause_prompt
}

# ==========================================
# Documentation Functions
# ==========================================

init_documentation() {
    print_header "Iniciar Documentação"
    echo "Verificando estrutura do projeto..."
    print_separator

    # Passo 1: Checagem do README.md na raiz
    if [ ! -f README.md ]; then
        touch README.md
        echo "[+] README.md criado na raiz."
    else
        echo "[=] README.md já existe."
    fi

    # Passo 2: Checagem do diretório docs/
    if [ ! -d docs ]; then
        mkdir docs
        echo "[+] Diretório 'docs/' criado."
    else
        echo "[=] Diretório 'docs/' já existe."
    fi

    # Passo 3: Criação dos arquivos .md dentro de docs/
    local docs_files=(
        "product.md"
        "architecture.md"
        "domain.md"
        "database.md"
        "backend.md"
        "api.md"
        "frontend.md"
        "decisions.md"
    )

    echo "Verificando arquivos internos..."
    for file in "${docs_files[@]}"; do
        if [ ! -f "docs/$file" ]; then
            touch "docs/$file"
            echo "  -> Criado: docs/$file"
        else
            echo "  -> Já existe: docs/$file"
        fi
    done

    print_separator
    echo "Estrutura de documentação validada e pronta."
    setup_gitignore
    pause_prompt
}

update_project_gitignore() {
    print_header "Atualizar .gitignore do Projeto"
    check_git_repo || return
    setup_gitignore
    pause_prompt
}

show_documentation_model() {
    clear
    echo "================================================================="
    echo "                 Modelo Estrutural de Documentação"
    echo "================================================================="
cat << 'EOF'
project/
│
├── README.md                           # Entrada principal do projeto (comandos básicos e atalho para a doc)
│
├── docs/                               # Documentação central do projeto
│   ├── product.md                      # O produto e o problema de negócio (O Porquê)
│   │   ├── vision                      # O propósito do projeto e a dor que ele resolve
│   │   ├── scope                       # O que o sistema faz (MVP) e o que não faz
│   │   ├── actors                      # Quem interage com o sistema (usuários, sistemas externos)
│   │   ├── glossary                    # Dicionário de termos do negócio (Linguagem Ubíqua)
│   │   ├── business-rules              # Regras puras do mundo real, independentes da tecnologia (existem mesmo que o sistema não existisse)
│   │   ├── requirements                # Requisitos Funcionais (RF) e Não Funcionais (RNF)
│   │       ├── diagram: use-case       # Diagrama de Caso de Uso (Atores x Use Cases)
│   │       └── diagram: flowchart      # Diagrama de Fluxograma da Jornada (User Flow)
│   │
│   ├── architecture.md                 # Arquitetura do sistema (Visão MACRO) — ver também: database.md, backend.md, frontend.md (MICRO)
│   │   ├── overview                    # Resumo arquitetural em alto nível
│   │   │   ├── diagram: component      # Diagrama em texto dos grandes blocos do sistema
│   │   │   └── diagram: sequence       # Fluxo macro de comunicação entre os blocos
│   │   ├── stack                       # Tecnologias principais (Linguagens, Frameworks, Cloud)
│   │   ├── backend                     # O papel do servidor no contexto geral (MACRO; detalhe técnico em backend.md)
│   │   ├── frontend                    # O papel da interface no contexto geral (MACRO; detalhe técnico em frontend.md)
│   │   ├── database                    # O tipo de banco escolhido e o motivo em alto nível (MACRO; detalhe técnico em database.md)
│   │   ├── security                    # Estratégia geral de proteção do sistema
│   │   └── deployment                  # Onde e como o sistema é publicado
│   │
│   ├── domain.md                       # Modelo de domínio (As Peças do Tabuleiro)
│   │   ├── entities                    # Os objetos principais do negócio
│   │   │   └── diagram: class          # Diagrama estrutural das entidades e seus atributos
│   │   ├── relationships               # Como as entidades se conectam
│   │   ├── enums                       # Valores fixos e categóricos
│   │   └── use-cases                   # As lógicas de aplicação permitidas (como o sistema orquestra as business-rules)
│   │       └── diagram: activity        # Fluxo de estados complexos e ciclos de vida
│   │
│   ├── database.md                     # Manual técnico da persistência (Visão MICRO de architecture.md > database)
│   │   ├── schema                      # Detalhamento físico das tabelas, colunas e tipos
│   │   │   └── diagram: er             # Diagrama Entidade-Relacionamento técnico
│   │   ├── procedures                  # Lógicas armazenadas diretamente no banco (se houver)
│   │   ├── triggers                    # Gatilhos automáticos (se houver)
│   │   └── migrations                  # Ferramenta de migração e como executá-las
│   │       └── seed-data               # Scripts para popular o banco com dados locais de teste
│   │
│   ├── backend.md                      # Motor interno do sistema (Visão MICRO de architecture.md > backend)
│   │   ├── structure                   # Organização física das camadas dentro de src/
│   │   ├── routing                     # Como as rotas são mapeadas para os controladores
│   │   │   └── diagram: sequence       # Ciclo de Vida da Requisição
│   │   ├── api-contract                # Como o contrato de API é implementado no código
│   │   ├── services                    # Onde e como as regras de negócio são transformadas em código
│   │   ├── data-access                 # Padrões de consulta e comunicação com o banco (ORMs, queries)
│   │   ├── middlewares                 # Interceptadores globais (validação, logs, CORS)
│   │   └── error-handling              # Captura e padronização de exceções internas
│   │
│   ├── api.md                          # A ponte externa / Contrato de comunicação
│   │   ├── overview                    # URL base e padrão de comunicação
│   │   ├── authentication              # Método de autenticação exigido pelo servidor
│   │   │   └── diagram: sequence       # Fluxo de autenticação
│   │   ├── endpoints-admin             # Lista de rotas restritas e seus payloads
│   │   ├── endpoints-public            # Lista de rotas abertas
│   │   ├── errors                      # Formato padrão de erro retornado pela API
│   │   └── examples                    # Exemplos práticos de chamadas (usando dados fictícios)
│   │
│   ├── frontend.md                     # Estrutura visual e interface (Visão MICRO de architecture.md > frontend)
│   │   ├── structure                   # Organização física de páginas, componentes e assets
│   │   ├── routing                     # Navegação do cliente e proteção de rotas visuais
│   │   ├── components                  # Regras, nomenclatura e responsabilidade de componentes
│   │   ├── state-management            # Onde informações temporárias são guardadas (local vs global)
│   │   │   └── diagram: data-flow      # Fluxo de Dados (Data Flow)
│   │   ├── styling                     # Convenções de CSS, uso de temas e bibliotecas
│   │   └── api-integration             # Configuração de clientes HTTP, loadings e erros da API
│   │
│   └── decisions.md                    # Registro das principais escolhas técnicas do projeto
│       ├── stack                       # Por que tecnologias, bibliotecas ou ferramentas específicas foram escolhidas ou preteridas
│       ├── architecture                # Justificativas para padrões estruturais adotados (ex: por que manter um monolito simples)
│       ├── abstractions                # Decisões sobre o que foi deliberadamente simplificado, deixado de fora ou não abstraído
│       ├── security-tradeoffs          # Riscos aceitos, proteções ignoradas e cenários onde atalhos temporários foram assumidos
│       └── rejected-ideas              # Alternativas que foram consideradas e descartadas, poupando o tempo de reavaliá-las no futuro
EOF
    pause_prompt
}

generate_docs_context() {
    print_header "AI Context: Documentação"

    check_git_repo || return

    local context_file="ai-context-docs.txt"
    
    echo "Construindo árvore estrutural do projeto..."
    echo "================ PROJECT STRUCTURE ================" > "$context_file"
    git ls-files --cached --others --exclude-standard >> "$context_file"
    
    echo "" >> "$context_file"
    echo "Consolidando arquivos de documentação..."
    echo "================ DOCUMENTATION ====================" >> "$context_file"

    if [[ -f README.md ]]; then
        echo -e "\n--- File: README.md ---\n" >> "$context_file"
        cat README.md >> "$context_file"
    fi

    if [[ -d docs ]]; then
        shopt -s nullglob
        for md_file in docs/*.md; do
            if [[ -f "$md_file" ]]; then
                echo -e "\n--- File: $md_file ---\n" >> "$context_file"
                cat "$md_file" >> "$context_file"
            fi
        done
        shopt -u nullglob
    fi

    print_separator
    echo "Sucesso! Arquivo '$context_file' gerado na raiz."
    echo "Use-o para dar contexto de negócio/arquitetura para a IA."
    pause_prompt
}

generate_code_context() {
    print_header "AI Context: Código"

    check_git_repo || return

    # Identifica os diretórios de código-fonte e estáticos
    local target_dirs=()
    
    if [[ -d "public" ]]; then
    target_dirs+=("public")
    fi

    if [[ -d "src" ]]; then
        target_dirs+=("src")
    elif [[ -d "source" ]]; then
        target_dirs+=("source")
    fi

    if [[ ${#target_dirs[@]} -eq 0 ]]; then
        echo "Erro: Nenhum diretório 'src', 'source' ou 'public' encontrado."
        pause_prompt
        return
    fi

    local context_file="ai-context-code.txt"
    
    echo "Construindo árvore estrutural do projeto..."
    echo "================ PROJECT STRUCTURE ================" > "$context_file"
    git ls-files --cached --others --exclude-standard >> "$context_file"
    
    echo "" >> "$context_file"
    echo "Consolidando arquivos de código..."
    echo "================ SOURCE CODE ====================" >> "$context_file"

    # Inclui explicitamente o .gitignore para dar contexto sobre o ambiente (ex: .env, pastas de build)
    if [[ -f .gitignore ]]; then
        echo -e "\n--- File: .gitignore ---\n" >> "$context_file"
        cat .gitignore >> "$context_file"
    fi

    # Itera sobre os diretórios encontrados e captura arquivos não ignorados
    for dir in "${target_dirs[@]}"; do
        local files=($(git ls-files --cached --others --exclude-standard "$dir/"))
        
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "Nenhum arquivo válido encontrado em '$dir/'."
        else
            for file in "${files[@]}"; do
                if [[ -f "$file" ]]; then
                    echo -e "\n--- File: $file ---\n" >> "$context_file"
                    cat "$file" >> "$context_file"
                fi
            done
        fi
    done

    print_separator
    echo "Sucesso! Arquivo '$context_file' gerado na raiz."
    echo "Diretórios incluídos: ${target_dirs[*]}"
    echo "Use-o para dar contexto de implementação para a IA."
    pause_prompt
}

# ==========================================
# Submenus
# ==========================================

git_menu() {
    local selection
    while true; do
        print_header "Git Management"
        echo "1. Iniciar Repositório Local"
        echo "2. Vincular Repositório Remoto"
        echo "3. Receber Atualizações (Pull)"
        echo "4. Enviar Atualizações (Push)"
        echo "5. Visão Geral (Status)"
        echo "[ESC] Voltar ao Menu Principal"
        echo "=============================="
        echo -n "Escolha uma opção: "

        read -r -s -n 1 selection

        if [[ "$selection" == $'\e' ]]; then
            read -r -s -t 0.05 -n 2 extra_chars
            if [[ -z "$extra_chars" ]]; then
                return
            else
                continue
            fi
        fi

        case $selection in
            1) init_repository ;;
            2) link_remote ;;
            3) pull_updates ;;
            4) push_updates ;;
            5) show_overview ;;
            *) echo -e "\nOpção inválida."; sleep 1 ;;
        esac
    done
}

docs_menu() {
    local selection
    while true; do
        print_header "Documentation Tools"
        echo "1. Iniciar Documentação"
        echo "2. Atualizar .gitignore (Projetos Existentes)"
        echo "3. Exibir Modelo de Referência"
        echo "4. Gerar Contexto para IA (Documentação)"
        echo "5. Gerar Contexto para IA (Código)"
        echo "[ESC] Voltar ao Menu Principal"
        echo "=============================="
        echo -n "Escolha uma opção: "

        read -r -s -n 1 selection

        if [[ "$selection" == $'\e' ]]; then
            read -r -s -t 0.05 -n 2 extra_chars
            if [[ -z "$extra_chars" ]]; then
                return
            else
                continue
            fi
        fi

        case $selection in
            1) init_documentation ;;
            2) update_project_gitignore ;;
            3) show_documentation_model ;;
            4) generate_docs_context ;;
            5) generate_code_context ;;
            *) echo -e "\nOpção inválida."; sleep 1 ;;
        esac
    done
}

# ==========================================
# Main Menu
# ==========================================

main_menu() {
    local selection
    while true; do
        print_header "Project Toolkit"
        echo "1. Git Management"
        echo "2. Documentation Tools"
        echo "[ESC] Sair"
        echo "=============================="
        echo -n "Escolha uma opção: "

        read -r -s -n 1 selection

        if [[ "$selection" == $'\e' ]]; then
            read -r -s -t 0.05 -n 2 extra_chars
            if [[ -z "$extra_chars" ]]; then
                clear
                echo -e "\nSaindo..."
                sleep 1
                clear
                exit 0
            else
                continue
            fi
        fi

        case $selection in
            1) git_menu ;;
            2) docs_menu ;;
            *) echo -e "\nOpção inválida."; sleep 1 ;;
        esac
    done
}

# Inicia o programa executando o menu principal
main_menu