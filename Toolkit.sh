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
    
    if [ ! -f README.md ]; then
        touch README.md
    fi
    
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
    
    # Executa a sincronização trazendo os dados do remoto para a branch atual
    if git pull origin HEAD; then
        echo "----------------------------------------"
        echo "Atualizações recebidas e integradas com sucesso."
    else
        echo "----------------------------------------"
        echo "Aviso: Ocorreu um erro ao sincronizar."
        echo "Isso pode acontecer por conflitos de mesclagem (merge) que precisam"
        echo "ser resolvidos manualmente no VS Code, ou caso o histórico remoto seja"
        echo "completamente diferente do local."
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
        echo "1. Exemplo de ferramenta (Em breve)"
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
            1)
                echo -e "\nEspaço reservado para a nova lógica de documentação."
                sleep 2
                ;;
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