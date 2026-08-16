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
            echo "development-method.md"
            echo "ai-context-docs.txt"
            echo "ai-context-code.txt"
            echo "# =========================="
        } >> .gitignore
        echo "[Proteção] Bloco do Toolkit adicionado ao .gitignore."
    fi
}

# ==========================================
# Maintenance Functions
# ==========================================

update_toolkit() {
    print_header "Atualizar Ferramenta"
    
    echo "Buscando atualizações no GitHub..."
    print_separator
    
    local temp_file="/tmp/toolkit_update.sh"
    local url="https://raw.githubusercontent.com/PauloVNM/Project-Toolkit/main/Toolkit.sh"
    
    # Baixa o arquivo silenciosamente, mas mostra erros se falhar (-sSLf)
    if curl -sSLf "$url" -o "$temp_file"; then
        # Substitui o script em execução ($0) pelo novo arquivo baixado
        mv "$temp_file" "$0"
        chmod +x "$0"
        
        echo "Atualização concluída com sucesso!"
        echo "O Toolkit será reiniciado automaticamente."
        sleep 2
        
        # O comando 'exec' substitui o processo atual pelo novo script, 
        # reiniciando a ferramenta de forma limpa.
        exec "$0" "$@"
    else
        echo "Erro: Falha ao tentar conectar com o GitHub ou baixar a atualização."
        echo "Verifique sua conexão de rede."
        pause_prompt
    fi
}

# ==========================================
# Git Functions
# ==========================================

init_repository() {
    print_header "Iniciar Novo Repositório"

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Aviso: Este diretório já possui um repositório Git iniciado."
        pause_prompt
        return
    fi

    echo "Configurando base local..."
    
    git init -b main
    
    echo "Repositório local iniciado na branch 'main'."
    echo "Pronto para o seu primeiro commit estrutural."
    pause_prompt
}

clone_repository() {
    print_header "Clonar Repositório Remoto"

    # Verifica se já estamos dentro de um repositório, pois não devemos clonar um projeto dentro de outro.
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Aviso: Você já está dentro de um repositório Git."
        echo "Saia deste diretório (use 'cd ..') para clonar um novo projeto."
        pause_prompt
        return
    fi

    local url
    read -p "Digite a URL do repositório (ou vazio para cancelar): " url

    if [ -z "$url" ]; then
        return
    fi

    echo "Clonando repositório..."
    print_separator

    if git clone "$url"; then
        print_separator
        echo "Repositório clonado com sucesso."
        echo "IMPORTANTE: Lembre-se de acessar a nova pasta gerada (cd nome-do-projeto) antes de continuar."
    else
        print_separator
        echo "Erro: Falha ao clonar o repositório."
        echo "Verifique a URL, permissões de acesso e sua conexão de rede."
    fi

    pause_prompt
}

pull_updates() {
    print_header "Receber Atualizações"
    
    check_git_repo || return

    if [ -z "$(git config --get remote.origin.url)" ]; then
        echo "Erro: Nenhum repositório remoto vinculado. Use a opção de vincular repositório primeiro."
        pause_prompt
        return
    fi

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
    
    local has_remote
    has_remote=$(git config --get remote.origin.url)
    
    local user_confirmation
    if [ -n "$has_remote" ]; then
        read -p "Deseja indexar e enviar as alterações ao servidor? (y/N): " user_confirmation
    else
        read -p "Nenhum repositório remoto vinculado. Deseja indexar e salvar as alterações APENAS LOCALMENTE? (y/N): " user_confirmation
    fi
    
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
    
    if [ -n "$has_remote" ]; then
        git push -u origin HEAD
    fi
    
    pause_prompt
}

manage_state() {
    while true; do
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

        echo "1. Alterar Usuário Git"
        echo "2. Alterar E-mail Git"
        echo "3. Alterar Repositório Remoto"
        echo "4. Trocar ou Criar Branch"
        echo "[ESC] Voltar"
        
        local selection
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
            1)
                echo ""
                local new_name
                read -p "Novo Nome: " new_name
                if [[ -n "$new_name" ]]; then
                    git config --local user.name "$new_name"
                fi
                ;;
            2)
                echo ""
                local new_email
                read -p "Novo E-mail: " new_email
                if [[ -n "$new_email" ]]; then
                    git config --local user.email "$new_email"
                fi
                ;;
            3)
                echo ""
                if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                    local new_url
                    read -p "Nova URL remota (vazio para cancelar): " new_url
                    if [[ -n "$new_url" ]]; then
                        # Verifica se a origem existe para atualizar, senão adiciona
                        if git remote | grep -q "^origin$"; then
                            git remote set-url origin "$new_url"
                        else
                            git remote add origin "$new_url"
                        fi
                        echo "URL do repositório remoto atualizada."
                        sleep 1
                    fi
                else
                    echo "Erro: Você precisa estar dentro de um repositório Git."
                    sleep 1
                fi
                ;;
            4)
                echo ""
                if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
                    local branches
                    mapfile -t branches < <(git branch --format="%(refname:short)")
                    
                    local i=1
                    for b in "${branches[@]}"; do
                        echo "$i) $b"
                        ((i++))
                    done
                    echo "N) Criar Nova Branch"
                    
                    local branch_choice
                    read -p "Escolha a branch: " branch_choice
                    
                    if [[ "$branch_choice" == "N" || "$branch_choice" == "n" ]]; then
                        local new_b
                        read -p "Nome da nova branch: " new_b
                        if [[ -n "$new_b" ]]; then
                            git switch -c "$new_b" 2>/dev/null
                        fi
                    elif [[ "$branch_choice" =~ ^[0-9]+$ ]] && [ "$branch_choice" -ge 1 ] && [ "$branch_choice" -le "${#branches[@]}" ]; then
                        git switch "${branches[$((branch_choice-1))]}" 2>/dev/null
                    else
                        echo "Opção inválida."
                        sleep 1
                    fi
                else
                    echo "Erro: Este comando exige um repositório Git ativo."
                    sleep 1
                fi
                ;;
            *)
                echo -e "\nOpção inválida."
                sleep 1
                ;;
        esac
    done
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
        "features.md"
        "infrastructure.md"
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

generate_development_method() {
    print_header "Gerar Documento de Metodologia"
    
    local file_name="development-method.md"

    if [ -f "$file_name" ]; then
        echo "[=] O arquivo '$file_name' já existe na raiz do projeto."
    else
        echo "Criando '$file_name'..."
        
        cat << 'EOF' > "$file_name"
# Development Method

Este documento define o método de desenvolvimento utilizado pelo projeto e funciona como contexto operacional para chats que participam de descoberta, documentação, viabilidade, desenvolvimento e auditoria.

As regras abaixo têm precedência operacional sobre interpretações implícitas dos diagramas. Os diagramas representam o fluxo visual; as instruções complementam o comportamento esperado de cada etapa.

## Regras Gerais

- O operador é a autoridade final sobre requisitos, decisões, arquitetura, implementação e mudanças no projeto.
- A IA deve distinguir fatos fornecidos, decisões validadas, hipóteses e pontos ainda não definidos. Não deve preencher lacunas com invenções.
- Quando uma nova informação entrar em conflito com documentação ou decisão já validada, o conflito deve ser explicitado antes de qualquer alteração relevante.
- A documentação estrutural deve manter rastreabilidade entre regras de negócio, requisitos, features e áreas afetadas do sistema sempre que essa relação existir.
- O idioma de conversação primária entre operador e IA é português, salvo instrução explícita em contrário.

---

# 1. Documentation Model

```text
project/
│
├── README.md                           # Entrada principal do projeto (comandos básicos, atalhos para docs e mapa de leitura para IAs)
│
├── docs/                               # Documentação central do projeto
│   ├── product.md                      # O produto e o problema de negócio (O Porquê)
│   │   ├── vision                      # O propósito do projeto e a dor que ele resolve
│   │   ├── scope                       # O que o sistema faz (MVP) e o que não faz
│   │   ├── actors                      # Quem interage com o sistema (usuários, sistemas externos)
│   │   ├── glossary                    # Dicionário de termos do negócio (Linguagem Ubíqua)
│   │   ├── business-rules              # Regras puras do mundo real (ex: BR-01, BR-02), independentes de tecnologia
│   │   ├── requirements                # Requisitos Funcionais indexados (ex: RF-01, RF-02) e Não Funcionais (ex: RNF-01, RNF-02)
│   │       ├── diagram: use-case       # Diagrama de Caso de Uso (Atores x Use Cases)
│   │       └── diagram: flowchart      # Diagrama de Fluxograma da Jornada (User Flow)
│   │
│   ├── features.md                     # Rastreabilidade de Entregas, Limites de Escopo e Raio de Impacto (A Execução)
│   │   ├── modules-registry            # Mapeamento formal dos Módulos do sistema (ex: auth, billing, notification)
│   │   └── feature-backlog             # Detalhamento por Feature (ex: FEAT-01, FEAT-02):
│   │       ├── requirements-mapping    # IDs exatos dos requisitos atendidos (ex: RF-01, RF-02, RNF-04)
│   │       ├── target-modules          # Módulos do código afetados diretamente pela entrega
│   │       ├── scope-boundaries        # Gatilho de início (Trigger) e Critério de término (Definition of Done) para cada Feature
│   │       ├── impact-radius           # Locais exatos tocados (tabelas em database.md, rotas/classes em backend.md, telas em frontend.md)
│   │       └── git-guidelines          # Nome da branch recomendada (ex: feature/FEAT-01-login) e mensagens de commit atômicos
│   │
│   ├── architecture.md                 # Arquitetura do sistema (Visão MACRO) — ver também: database.md, backend.md, frontend.md, infrastructure.md (MICRO)
│   │   ├── overview                    # Resumo arquitetural em alto nível
│   │   │   ├── diagram: component      # Diagrama em texto dos grandes blocos do sistema
│   │   │   └── diagram: sequence       # Fluxo macro de comunicação entre os blocos
│   │   ├── stack                       # Tecnologias principais (Linguagens, Frameworks, Cloud)
│   │   ├── backend                     # O papel do servidor no contexto geral (MACRO; detalhe técnico em backend.md)
│   │   ├── frontend                    # O papel da interface no contexto geral (MACRO; detalhe técnico em frontend.md)
│   │   ├── database                    # O tipo de banco escolhido e o motivo em alto nível (MACRO; detalhe técnico em database.md)
│   │   ├── security                    # Estratégia geral de proteção do sistema
│   │   └── infrastructure              # Estratégia geral de hospedagem e CI/CD (MACRO; detalhe técnico em infrastructure.md)
│   │
│   ├── infrastructure.md               # Operação, Servidor e CI/CD (Visão MICRO de architecture.md > infrastructure)
│   │   ├── environment                 # Tipo de ambiente (VPS, Bare Metal, Cloud, Container)
│   │   ├── hardware-specs              # Especificações de recursos (CPU, RAM, Disco, Rede)
│   │   ├── system-software             # Sistema Operacional (ex: Debian), runtime, servidores web (Nginx), Docker, etc.
│   │   ├── pipeline                    # Esteira de CI/CD (Gatilhos, etapas de Build, Testes e Deploy)
│   │   │   └── diagram: sequence       # Fluxo da esteira (Push -> Runner -> Build -> Server)
│   │   ├── environment-variables       # Lista de variáveis necessárias (sem expor segredos/senhas)
│   │   ├── logs-and-monitoring         # Onde encontrar logs do sistema/aplicação e checagens de status
│   │   └── rollback                    # Procedimento manual ou automático para reverter versões com falha
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
│   │   ├── structure                   # Organização física de páginas, components e assets
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
```

## Purpose

O bloco abaixo é o modelo estrutural que o Chat de Documentação deve utilizar como base para construir a documentação do projeto.

A estrutura não deve ser tratada como uma sugestão genérica. Ela define os artefatos esperados para o projeto e deve ser respeitada durante a construção documental.

## Documentation Generation Rules

1. Cada arquivo `.md` deve ser gerado individualmente.
2. Todos os tópicos definidos no modelo devem ser preenchidos sempre que houver informação suficiente para isso.
3. Quando um tópico não puder ser preenchido com segurança, sua ausência deve ser justificada em `decisions.md`. A IA não deve inventar informações apenas para eliminar uma seção vazia.
4. A documentação deve ser escrita em inglês somente na versão final.
5. Durante a descoberta, discussão e validação, a documentação primária permanece em português.
6. A tradução para inglês ocorre somente depois que o operador considerar o conteúdo validado.
7. Preserve os identificadores já existentes e mantenha consistência entre referências cruzadas.
8. Quando uma informação estiver relacionada a um requisito, regra, feature ou decisão já identificada, utilize seu identificador correspondente.
9. Ao produzir qualquer estrutura que contenha Fenced Code Blocks, envolva a resposta completa em um bloco externo de quatro crases, usando blocos internos de três crases para os conteúdos individuais.

## Documentation Flow

O Chat de Documentação recebe o contexto inicial da conversa com o cliente e o modelo estrutural completo. Ele é responsável por transformar a discussão em documentação progressivamente estruturada.

O Chat de Viabilidade/Stack não recebe automaticamente o contexto documental completo. Ele permanece como apoio técnico para esclarecer dúvidas, avaliar viabilidade, discutir tecnologias e auxiliar o operador na tomada de decisões técnicas. Suas conclusões só passam a integrar a documentação quando forem validadas pelo operador e incorporadas ao fluxo documental.

O conteúdo abaixo representa o fluxo esperado.

```mermaid
flowchart TD
    %% Definição de Estilos para simplicidade e clareza
    classDef dev fill:#2d3436,stroke:#dfe6e9,stroke-width:2px,color:#fff;
    classDef input fill:#0984e3,stroke:#74b9ff,stroke-width:2px,color:#fff;
    classDef chatDoc fill:#6c5ce7,stroke:#a29bfe,stroke-width:2px,color:#fff;
    classDef chatTech fill:#e84393,stroke:#fd79a8,stroke-width:2px,color:#fff;
    classDef chatDecision fill:#d63031,stroke:#ff7675,stroke-width:2px,color:#fff;
    classDef docs fill:#00b894,stroke:#55efc4,stroke-width:2px,color:#fff;

    %% Atores e Artefatos
    Dev((Desenvolvedor)):::dev
    Contexto[/Conversa com o Cliente / Contexto Inicial/]:::input
    Modelos[(Modelos de Documentação\nToolkit)]:::docs

    %% Fluxo de Descoberta
    subgraph Fluxo_Descoberta [Fluxo de Descoberta e Planejamento]
        direction TB

        ChatDoc["📝 Chat de Documentação\n(Foco no negócio, regras e\npreenchimento iterativo da documentação)"]:::chatDoc

        ChatTech["🛠️ Chat de Stack e Viabilidade\n(Foco técnico, viabilidade, arquitetura\ne decisões de tecnologia)"]:::chatTech

        ChatDecision["🧠 Chat de Decisions\n(Consolidação das decisões e seus motivos\na partir das conversações de descoberta)"]:::chatDecision
    end

    %% Relações e Fluxos de Informação
    Contexto -->|"Fornece a base do problema"| Dev
    Modelos -.->|"Fornece os modelos necessários"| Dev

    %% Entrada nos chats de descoberta
    Dev -->|"1. Insere contexto e discute o negócio"| ChatDoc
    Dev -->|"2. Insere contexto e debate a solução técnica"| ChatTech

    %% Produção documental
    ChatDoc -->|"3. Retorna documentação de descoberta\n(product, features, architecture, etc.)"| Dev
    ChatTech -->|"4. Retorna análises, viabilidade e decisões técnicas"| Dev

    %% Consolidação das decisões
    ChatDoc -.->|"Fornece a conversação completa"| ChatDecision
    ChatTech -.->|"Fornece a conversação completa"| ChatDecision

    ChatDecision -->|"5. Extrai decisões, justificativas,\ntrade-offs e alternativas rejeitadas"| Decisions
    Decisions["decisions.md"]:::docs
```

---

# 2. Development Flow Documentation

## Purpose

O fluxo abaixo representa o processo operacional utilizado para transformar uma ideia validada em uma alteração implementável.

O processo deve seguir convenções amplamente utilizadas em ambientes profissionais de desenvolvimento, priorizando legibilidade, consistência, manutenção, rastreabilidade e baixo acoplamento desnecessário.

## Development Rules

1. Ao gerar código, estruturas de projeto ou exemplos técnicos, utilize convenções amplamente adotadas no mercado.
2. Utilize inglês para nomes de variáveis, funções, classes, arquivos, tabelas, APIs, commits de exemplo e demais elementos técnicos, salvo quando houver motivo explícito para outro idioma.
3. Comentários de código também devem permanecer em inglês.
4. Tudo que será efetivamente exibido ao usuário final deve permanecer em português. Isso inclui textos de interface, mensagens do sistema, notificações, mensagens externas, e-mails, alertas e demais textos apresentados ao usuário.
5. O código deve priorizar clareza, previsibilidade, manutenção e aderência às convenções do ecossistema utilizado.
6. O operador permanece responsável pela validação da implementação. O chat de execução não substitui revisão humana.

## Flow Context

O fluxo recebe a documentação já construída e validada como base de contexto. O operador conduz a conversa de desenvolvimento conforme o diagrama abaixo.

O Chat de Conversação possui visão completa do projeto e é utilizado para debate, arquitetura, segurança, alternativas e ideias de implementação.

O Chat de Impacto recebe uma ideia já validada pelo operador e transforma essa ideia em análise de impacto, rastreabilidade e prompt de execução.

O Chat de Execução possui contexto deliberadamente restrito. Ele deve atuar de maneira estrita sobre o prompt recebido e o contexto técnico fornecido, sem assumir contexto global que não tenha sido explicitamente disponibilizado.

O fluxo visual abaixo define a sequência operacional.

```mermaid
flowchart TD
    %% Definição de Estilos para simplicidade e clareza
    classDef dev fill:#2d3436,stroke:#dfe6e9,stroke-width:2px,color:#fff;
    classDef project fill:#0984e3,stroke:#74b9ff,stroke-width:2px,color:#fff;
    classDef chatConv fill:#00b894,stroke:#55efc4,stroke-width:2px,color:#fff;
    classDef chatImp fill:#d63031,stroke:#ff7675,stroke-width:2px,color:#fff;
    classDef chatExec fill:#e17055,stroke:#fab1a0,stroke-width:2px,color:#fff;

    %% Atores Principais
    Dev((Desenvolvedor)):::dev
    Project[(Repositório)]:::project

    %% Os Três Chats
    subgraph Fluxo_Tri_Chat [Fluxo de Desenvolvimento Isolado]
        direction TB
        
        ChatConv["💬 Chat de Conversação\n(Visão Externa, Segurança, Ideias de Implementação)\n[Tem Contexto Total]"]:::chatConv
        
        ChatImp["🛡️ Chat de Impacto\n(Análise de Risco, Rastreabilidade, Criação de Prompt)\n[Tem Contexto Total]"]:::chatImp
        
        ChatExec["⚙️ Chat de Execução\n(Apenas Código, Obediência Estrita)\n[Zero Contexto Global]\n[Ou 'ai-context-code.txt' apenas] "]:::chatExec
    end

    %% Relações e Fluxos de Informação
    Dev <-->|"1. Debate possibilidades e validação arquitetura"| ChatConv
    
    Dev -->|"2. Submete ideia validada (Toolkit)"| ChatImp
    ChatImp -->|"3. Retorna Relatório de Impacto + Prompt"| Dev
    
    Dev -->|"4. Copia e cola o Prompt"| ChatExec
    ChatExec -->|"5. Retorna o Código exato"| Dev
    
    Dev -->|"6. Implementa, realiza testes locais e commita"| Project
```

---

# 3. Development Documentation Loop

## Purpose

O loop de documentação existe para verificar continuamente se a implementação permanece alinhada à documentação e às decisões válidas do projeto.

Ele deve ser executado após a conclusão do fluxo médio de desenvolvimento, utilizando os contextos consolidados de documentação e código gerados pelo Toolkit.

## Loop Rules

1. O Toolkit deve consolidar o contexto documental e o contexto de código antes da auditoria.
2. O Chat de Validação e Auditoria recebe o contexto completo necessário para comparar documentação e implementação.
3. A auditoria deve identificar divergências, inconsistências, lacunas ou alterações não refletidas entre documentação e código.
4. Quando a documentação estiver desatualizada, ela deve ser ajustada ao estado real do código, desde que não exista decisão validada que determine o contrário.
5. Quando o código estiver desalinhado com a documentação validada, a implementação deve retornar ao fluxo de desenvolvimento para nova análise de impacto e execução.
6. O loop só termina quando o operador considerar que implementação e documentação estão sincronizadas.
7. O retorno ao fluxo de desenvolvimento deve preservar o contexto necessário para que a nova alteração seja tratada como uma mudança consciente, e não como uma correção silenciosa.

O diagrama abaixo representa o fechamento do ciclo.

```mermaid
flowchart TD
    %% Definição de Estilos
    classDef dev fill:#2d3436,stroke:#dfe6e9,stroke-width:2px,color:#fff;
    classDef toolkit fill:#0984e3,stroke:#74b9ff,stroke-width:2px,color:#fff;
    classDef chatAudit fill:#e84393,stroke:#fd79a8,stroke-width:2px,color:#fff;
    classDef decision fill:#fdcb6e,stroke:#e17055,stroke-width:2px,color:#000;
    classDef endFlow fill:#00b894,stroke:#55efc4,stroke-width:2px,color:#fff;
    classDef loopFlow fill:#d63031,stroke:#ff7675,stroke-width:2px,color:#fff;

    %% Atores e Ferramentas
    Dev((Desenvolvedor)):::dev
    Toolkit["🛠️ Toolkit.sh\n(generate_docs_context +\ngenerate_code_context)"]:::toolkit

    %% Chat Principal da Etapa
    ChatAudit["🔍 Chat de Validação e Auditoria\n[Recebe Contexto Total: Código + Documentação]\nAnálise comparativa de alinhamento"]:::chatAudit

    %% Decisões e Fins
    DecisaoAlinhamento{"Código e Documentação\nestão 100% alinhados?"}:::decision
    DecisaoAjuste{"Quem deve se adequar?"}:::decision
    
    Fim["✅ Fim do Fluxo\n(Aplicação e Documentação Sincronizadas)"]:::endFlow
    
    NovoFluxo["🔄 Retorno ao Fluxo Médio\n(Chat atual vira Novo Chat de Impacto;\nCria-se Novo Chat Executor e Conversação)"]:::loopFlow

    %% Fluxo de Execução
    Dev -->|"1. Executa extração após finalizar o fluxo medio"| Toolkit
    Toolkit -->|"2. Alimenta com os .txt consolidados"| ChatAudit
    ChatAudit -->|"3. Analisa relatório de divergências"| DecisaoAlinhamento
    
    DecisaoAlinhamento -->|"Sim (Tudo pronto)"| Fim
    DecisaoAlinhamento -->|"Não (IA identificou desvios)"| DecisaoAjuste
    
    DecisaoAjuste -->|"Opção A: Documentação se adequa ao Código\n(O próprio Chat de Auditoria ajusta os .md)"| Fim
    DecisaoAjuste -->|"Opção B: Código se adequa à Documentação\n(Necessário refatorar a aplicação)"| NovoFluxo
```

---

# Operational Intent

Este documento deve ser tratado pelos chats como uma definição de método de trabalho, e não como uma documentação específica de um projeto.

O objetivo é manter consistência entre:

`business context -> documentation -> technical discussion -> impact analysis -> implementation -> human validation -> audit -> synchronization`

A IA deve apoiar o processo sem substituir o operador como autoridade sobre as decisões do projeto.
EOF
        
        echo "[+] Arquivo '$file_name' criado com sucesso."
        
        # Garante a proteção no .gitignore logo após a criação
        setup_gitignore
    fi
    
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
        echo "2. Clonar Repositório Remoto"
        echo "3. Receber Atualizações (Pull)"
        echo "4. Enviar Atualizações (Push)"
        echo "5. Gerenciar Estado do Repositório"
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
            2) clone_repository ;;  # <<< ATUALIZADO AQUI
            3) pull_updates ;;
            4) push_updates ;;
            5) manage_state ;;
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
        echo "3. Gerar Documento de Metodologia"
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
            3) generate_development_method ;;
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
        echo "3. Atualizar Ferramenta"
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
            3) update_toolkit ;;
            *) echo -e "\nOpção inválida."; sleep 1 ;;
        esac
    done
}

# Inicia o programa executando o menu principal
main_menu