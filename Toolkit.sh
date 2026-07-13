#!/bin/bash

# ==========================================
# Helper Functions
# ==========================================

setup_gitignore() {
    local script_name
    script_name=$(basename "$0")
    
    if [ -f .gitignore ]; then
        if ! grep -qF "$script_name" .gitignore; then
            echo "$script_name" >> .gitignore
            echo "[Proteção] Script '$script_name' anexado ao .gitignore existente."
        else
            echo "[Proteção] Script '$script_name' já estava protegido no .gitignore."
        fi
    else
        echo "$script_name" > .gitignore
        echo "[Proteção] Arquivo .gitignore criado e configurado com sucesso."
    fi
}

# ==========================================
# Git Functions
# ==========================================

init_repository() {
    clear
    echo "=============================="
    echo "   Iniciar Novo Repositório"
    echo "=============================="
    echo "Configurando base local..."
    
    git init -b main
    
    echo ""
    setup_gitignore
    echo ""

    echo "Repositório local iniciado na branch 'main'."
    echo "Pronto para o seu primeiro commit estrutural."
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}

link_remote() {
    clear
    echo "=============================="
    echo "   Vincular Repositório Remoto"
    echo "=============================="

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Erro: Este diretório não tem um repositório Git."
        read -p "Pressione [ENTER] para voltar..."
        return
    fi

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
    
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}

pull_updates() {
    clear
    echo "=============================="
    echo "     Receber Atualizações"
    echo "=============================="

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Erro: Este diretório não tem um repositório Git."
        echo ""
        read -p "Pressione [ENTER] para voltar..."
        return
    fi

    echo "Verificando e recebendo atualizações remotas..."
    echo "----------------------------------------"
    
    # Executa a sincronização forçando a estratégia padrão de mesclagem (merge)
    # Isso evita o erro fatal de "divergent branches"
    if git pull --no-rebase origin HEAD; then
        echo "----------------------------------------"
        echo "Atualizações recebidas e integradas com sucesso."
    else
        echo "----------------------------------------"
        echo "Aviso: Ocorreu um erro ao sincronizar."
        echo "Isso geralmente acontece quando há conflitos de código (o mesmo arquivo"
        echo "foi alterado de formas diferentes no local e no remoto)."
        echo "Abra o VS Code, resolva os conflitos destacados nos arquivos e,"
        echo "em seguida, use a opção de 'Enviar Atualizações' para concluir."
    fi

    echo ""
    read -p "Pressione [ENTER] para voltar ao menu..."
}

push_updates() {
    clear
    echo "=============================="
    echo "      Enviar Atualizações"
    echo "=============================="

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Erro: Este diretório não tem um repositório Git."
        read -p "Pressione [ENTER] para voltar..."
        return
    fi

    git status -s
    
    local user_confirmation
    read -p "Deseja indexar e enviar as alterações? (y/N): " user_confirmation
    
    if [[ ! "$user_confirmation" =~ ^[Yy]$ ]]; then
        return
    fi

    local commit_msg
    read -p "Digite a mensagem do commit (vazio para data): " commit_msg
    local final_msg=${commit_msg:-"Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"}
    
    git add .
    git commit -m "$final_msg"
    git push -u origin HEAD
    
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}

show_overview() {
    clear
    echo "=============================="
    echo "         Visão Geral"
    echo "=============================="

    local current_dir
    current_dir=$(pwd)
    echo "Diretório Atual: $current_dir"
    echo "----------------------------------------"

    local user_name
    local user_email
    user_name=$(git config user.name)
    user_email=$(git config user.email)

    echo "Usuário Git:    ${user_name:-'Não configurado'}"
    echo "E-mail Git:     ${user_email:-'Não configurado'}"

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        local current_branch
        local remote_url
        current_branch=$(git branch --show-current)
        remote_url=$(git config --get remote.origin.url)

        echo "Branch Ativa:   ${current_branch:-'Nenhuma branch ativa (HEAD destacada)'}"
        echo "Remoto (origin): ${remote_url:-'Nenhum repositório remoto vinculado'}"
    else
        echo "Status Git:     Este diretório NÃO é um repositório Git."
    fi
    echo "----------------------------------------"
    
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}

# ==========================================
# Documentation Functions
# ==========================================

init_documentation() {
    clear
    echo "=============================="
    echo "    Iniciar Documentação"
    echo "=============================="
    echo "Verificando estrutura do projeto..."
    echo "----------------------------------------"

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

    echo "----------------------------------------"
    echo "Estrutura de documentação validada e pronta."
    echo ""
    read -p "Pressione [ENTER] para voltar..."
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
    echo ""
    read -p "Pressione [ENTER] para voltar..."
}


# ==========================================
# Submenus
# ==========================================

git_menu() {
    local selection
    while true; do
        clear
        echo "=============================="
        echo "       Git Management"
        echo "=============================="
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
        clear
        echo "=============================="
        echo "    Documentation Tools"
        echo "=============================="
        echo "1. Iniciar Documentação"
        echo "2. Exibir Modelo de Referência"
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
            2) show_documentation_model ;;
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
        clear
        echo "=============================="
        echo "       Project Toolkit"
        echo "=============================="
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