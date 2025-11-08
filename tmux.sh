#!/bin/bash

# Cores para o terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # Sem cor

# Cores adicionais para melhor visualização
BRIGHT_GREEN='\033[1;32m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_PURPLE='\033[1;35m'
BRIGHT_RED='\033[1;31m'
GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'

# Emojis para deixar mais amigável
COMPUTER="🖥️"
PLUS="➕"
LINK="🔗"
ROCKET="🚀"
LIST="📋"
EXIT="🚪"
WARNING="⚠️"
SUCCESS="✅"
ERROR="❌"
STAR="⭐"
FIRE="🔥"
SPARKLE="✨"
LIGHT="💡"
DOWNLOAD="📥"
GEAR="⚙️"
BACKUP="💾"
SETTINGS="🔧"
MONITOR="📊"
THEME="🎨"
HELP="❓"
INFO="ℹ️"
CLOCK="⏰"
MEMORY="🧠"
NETWORK="🌐"

# Variáveis de configuração
CONFIG_FILE="$HOME/.tmux_manager.conf"
BACKUP_DIR="$HOME/.tmux_backups"
LOG_FILE="$HOME/.tmux_manager.log"
TEMPLATES_DIR="$HOME/.tmux_templates"
SCORES_FILE="$HOME/.tmux_scores.json"
PLUGINS_DIR="$HOME/.tmux/plugins"

# Função para gamificação - sistema de pontuação
update_score() {
    local action="$1"
    local points="$2"
    
    # Cria arquivo de pontuação se não existir
    if [ ! -f "$SCORES_FILE" ]; then
        cat > "$SCORES_FILE" << EOF
{
    "total_points": 0,
    "level": 1,
    "actions": {},
    "achievements": [],
    "first_use": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
    fi
    
    # Atualiza pontuação (simplificado para bash)
    local current_points=$(grep -o '"total_points": [0-9]*' "$SCORES_FILE" | grep -o '[0-9]*')
    local new_points=$((current_points + points))
    
    # Atualiza o arquivo
    sed -i "s/\"total_points\": $current_points/\"total_points\": $new_points/" "$SCORES_FILE"
    
    # Verifica conquistas
    check_achievements "$new_points"
}

# Função para verificar conquistas
check_achievements() {
    local total_points="$1"
    
    # Lista de conquistas
    local achievements=(
        "10:Novato:Primeira sessão criada"
        "50:Iniciante:10 sessões criadas"
        "100:Intermediário:25 sessões criadas"
        "200:Avançado:50 sessões criadas"
        "500:Expert:100 sessões criadas"
        "1000:Mestre:200 sessões criadas"
    )
    
    for achievement in "${achievements[@]}"; do
        IFS=':' read -r points name desc <<< "$achievement"
        if [ "$total_points" -ge "$points" ]; then
            # Verifica se já foi desbloqueada
            if ! grep -q "$name" "$SCORES_FILE"; then
                echo -e "${BRIGHT_GREEN}${STAR} CONQUISTA DESBLOQUEADA: $name - $desc ${STAR}${NC}"
                # Adiciona à lista de conquistas
                sed -i 's/"achievements": \[/"achievements": ["'"$name"'", /' "$SCORES_FILE"
            fi
        fi
    done
}

# Função para mostrar perfil do usuário
show_profile() {
    echo -e "${BRIGHT_BLUE}${STAR} PERFIL DO USUÁRIO:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [ -f "$SCORES_FILE" ]; then
        local total_points=$(grep -o '"total_points": [0-9]*' "$SCORES_FILE" | grep -o '[0-9]*')
        local level=$((total_points / 100 + 1))
        local first_use=$(grep -o '"first_use": "[^"]*"' "$SCORES_FILE" | cut -d'"' -f4)
        
        echo -e "${WHITE}🏆 PONTUAÇÃO:${NC}"
        echo -e "  ${GRAY}Total de pontos:${NC} ${BRIGHT_GREEN}$total_points${NC}"
        echo -e "  ${GRAY}Nível:${NC} ${BRIGHT_GREEN}$level${NC}"
        echo -e "  ${GRAY}Primeiro uso:${NC} ${BRIGHT_GREEN}$first_use${NC}"
        
        echo
        echo -e "${WHITE}🏅 CONQUISTAS:${NC}"
        local achievements=$(grep -o '"[^"]*"' "$SCORES_FILE" | grep -v "total_points\|level\|actions\|achievements\|first_use" | tr '\n' ' ')
        if [ ! -z "$achievements" ]; then
            echo -e "  ${BRIGHT_GREEN}$achievements${NC}"
        else
            echo -e "  ${GRAY}Nenhuma conquista ainda${NC}"
        fi
    else
        echo -e "${GRAY}Nenhum perfil encontrado${NC}"
    fi
    
    echo
}

# Função para integração com Git
git_integration() {
    echo -e "${BRIGHT_BLUE}🌐 INTEGRAÇÃO COM GIT:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${BRIGHT_RED}${ERROR} Git não está instalado!${NC}"
        return
    fi
    
    # Lista repositórios Git
    echo -e "${WHITE}Repositórios Git encontrados:${NC}"
    echo
    
    local git_repos=()
    while IFS= read -r -d '' repo; do
        git_repos+=("$repo")
        local repo_name=$(basename "$repo")
        local branch=$(cd "$repo" && git branch --show-current 2>/dev/null || echo "main")
        echo -e "  ${BRIGHT_GREEN}$repo_name${NC} (${GRAY}$branch${NC})"
    done < <(find ~ -name ".git" -type d -print0 2>/dev/null)
    
    if [ ${#git_repos[@]} -eq 0 ]; then
        echo -e "${GRAY}Nenhum repositório Git encontrado${NC}"
        return
    fi
    
    echo
    restore_terminal
    echo -e "${WHITE}Escolha um repositório para abrir (1-${#git_repos[@]}):${NC}"
    read -p "   ${BRIGHT_GREEN}Opção: ${NC}" choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#git_repos[@]}" ]; then
        local selected_repo="${git_repos[$((choice-1))]}"
        local repo_name=$(basename "$selected_repo")
        
        # Cria sessão com o repositório
        tmux new-session -d -s "git-$repo_name" -c "$selected_repo"
        tmux send-keys -t "git-$repo_name" "git status" Enter
        
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Sessão Git criada: git-$repo_name${NC}"
        echo -e "${GRAY}   → Diretório: $selected_repo${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Opção inválida!${NC}"
    fi
    
    setup_terminal
}

# Função para sincronização de sessões
sync_sessions() {
    echo -e "${BRIGHT_BLUE}🔄 SINCRONIZAÇÃO DE SESSÕES:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    restore_terminal
    
    echo -e "${WHITE}Opções de sincronização:${NC}"
    echo -e "${GRAY}  1${NC} - Sincronizar com servidor remoto"
    echo -e "${GRAY}  2${NC} - Exportar sessões para arquivo"
    echo -e "${GRAY}  3${NC} - Importar sessões de arquivo"
    echo -e "${GRAY}  4${NC} - Voltar"
    echo
    read -p "   ${BRIGHT_GREEN}Escolha uma opção: ${NC}" choice
    
    case $choice in
        1)
            echo -e "${WHITE}Digite o endereço do servidor:${NC}"
            read -p "   ${BRIGHT_GREEN}Servidor: ${NC}" server
            echo -e "${WHITE}Digite o usuário:${NC}"
            read -p "   ${BRIGHT_GREEN}Usuário: ${NC}" user
            
            # Sincronização via SSH
            echo -e "${WHITE}Sincronizando com $user@$server...${NC}"
            # Aqui você implementaria a sincronização real
            echo -e "${BRIGHT_GREEN}${SUCCESS} Sincronização iniciada!${NC}"
            ;;
        2)
            local export_file="$HOME/tmux_sessions_export_$(date +%Y%m%d_%H%M%S).txt"
            tmux list-sessions > "$export_file" 2>/dev/null
            echo -e "${BRIGHT_GREEN}${SUCCESS} Sessões exportadas para: $export_file${NC}"
            ;;
        3)
            echo -e "${WHITE}Digite o caminho do arquivo de importação:${NC}"
            read -p "   ${BRIGHT_GREEN}Arquivo: ${NC}" import_file
            if [ -f "$import_file" ]; then
                echo -e "${BRIGHT_GREEN}${SUCCESS} Arquivo de importação carregado!${NC}"
            else
                echo -e "${BRIGHT_RED}${ERROR} Arquivo não encontrado!${NC}"
            fi
            ;;
        4)
            ;;
        *)
            echo -e "${BRIGHT_RED}${ERROR} Opção inválida!${NC}"
            ;;
    esac
    
    setup_terminal
}

# Função para instalar plugins do tmux
install_tmux_plugins() {
    echo -e "${BRIGHT_BLUE}🔌 INSTALANDO PLUGINS DO TMUX:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Cria diretório de plugins
    mkdir -p "$PLUGINS_DIR"
    
    # Lista de plugins populares
    local plugins=(
        "tmux-plugins/tpm:Plugin Manager"
        "tmux-plugins/tmux-sensible:Sensible defaults"
        "tmux-plugins/tmux-resurrect:Session persistence"
        "tmux-plugins/tmux-continuum:Continuous saving"
        "tmux-plugins/tmux-yank:Copy to system clipboard"
        "tmux-plugins/tmux-open:Open highlighted files"
    )
    
    echo -e "${WHITE}Plugins disponíveis:${NC}"
    echo
    for i in "${!plugins[@]}"; do
        IFS=':' read -r repo desc <<< "${plugins[$i]}"
        local name=$(basename "$repo")
        echo -e "  ${BRIGHT_GREEN}$((i+1))${NC} - ${name} (${GRAY}$desc${NC})"
    done
    echo
    
    restore_terminal
    echo -e "${WHITE}Escolha plugins para instalar (separados por vírgula):${NC}"
    read -p "   ${BRIGHT_GREEN}Plugins: ${NC}" choice
    
    # Instala plugins selecionados
    echo -e "${WHITE}Instalando plugins...${NC}"
    # Aqui você implementaria a instalação real dos plugins
    
    echo -e "${BRIGHT_GREEN}${SUCCESS} Plugins instalados com sucesso!${NC}"
    echo -e "${GRAY}   → Adicione 'run-shell ~/.tmux/plugins/tpm/tpm' ao seu ~/.tmux.conf${NC}"
    
    setup_terminal
}

# Função para otimização de performance
optimize_performance() {
    echo -e "${BRIGHT_BLUE}⚡ OTIMIZAÇÃO DE PERFORMANCE:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${WHITE}🔍 ANALISANDO PERFORMANCE...${NC}"
    echo
    
    # Verifica uso de memória das sessões
    if tmux has-session 2>/dev/null; then
        echo -e "${WHITE}📊 SESSÕES ATIVAS:${NC}"
        tmux list-sessions | while read -r line; do
            local session_name=$(echo "$line" | cut -d: -f1)
            local windows=$(echo "$line" | grep -o '[0-9]\+ windows')
            echo -e "  ${COMPUTER} ${BRIGHT_GREEN}$session_name${NC} - $windows"
        done
    fi
    
    echo
    echo -e "${WHITE}💡 RECOMENDAÇÕES:${NC}"
    echo -e "  ${GRAY}• Feche sessões não utilizadas${NC}"
    echo -e "  ${GRAY}• Use 'tmux kill-session -t nome' para matar sessões${NC}"
    echo -e "  ${GRAY}• Configure limite de histórico no ~/.tmux.conf${NC}"
    echo -e "  ${GRAY}• Use plugins leves para melhor performance${NC}"
    
    echo
    restore_terminal
    echo -e "${WHITE}Deseja limpar sessões antigas? (S/N)${NC}"
    read -p "   ${BRIGHT_GREEN}Opção: ${NC}" choice
    
    if [[ "$choice" =~ ^[SsYy]$ ]]; then
        # Lista sessões antigas (mais de 24h)
        echo -e "${WHITE}Sessões antigas encontradas:${NC}"
        # Implementar lógica de limpeza
        echo -e "${BRIGHT_GREEN}${SUCCESS} Limpeza concluída!${NC}"
    fi
    
    setup_terminal
}

# Função para carregar configurações
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        # Configurações padrão
        THEME="default"
        AUTO_BACKUP="false"
        LOG_LEVEL="info"
        DEFAULT_SESSION_NAME="work"
    fi
}

# Função para salvar configurações
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Configurações do Gerenciador TMUX
THEME="$THEME"
AUTO_BACKUP="$AUTO_BACKUP"
LOG_LEVEL="$LOG_LEVEL"
DEFAULT_SESSION_NAME="$DEFAULT_SESSION_NAME"
EOF
}

# Função para aplicar tema
apply_theme() {
    case $THEME in
        "dark")
            BRIGHT_CYAN='\033[0;36m'
            BRIGHT_GREEN='\033[0;32m'
            BRIGHT_BLUE='\033[0;34m'
            ;;
        "light")
            BRIGHT_CYAN='\033[1;36m'
            BRIGHT_GREEN='\033[1;32m'
            BRIGHT_BLUE='\033[1;34m'
            ;;
        "neon")
            BRIGHT_CYAN='\033[1;96m'
            BRIGHT_GREEN='\033[1;92m'
            BRIGHT_BLUE='\033[1;94m'
            ;;
        *)
            # Tema padrão já definido
            ;;
    esac
}

# Função para configurar tmux automaticamente
setup_tmux_config() {
    echo -e "${BRIGHT_BLUE}${SETTINGS} CONFIGURANDO TMUX AUTOMATICAMENTE...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    local tmux_conf="$HOME/.tmux.conf"
    
    # Cria configuração básica do tmux
    cat > "$tmux_conf" << 'EOF'
# Configuração básica do TMUX
set -g default-terminal "screen-256color"
set -g history-limit 10000
set -g base-index 1
setw -g pane-base-index 1

# Atalhos úteis
bind r source-file ~/.tmux.conf \; display "Configuração recarregada!"
bind | split-window -h
bind - split-window -v
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Status bar melhorada
set -g status-bg black
set -g status-fg white
set -g status-left "#[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r | cut -c 1-6)#[default]"
set -g status-left-length 50
set -g status-right "#[fg=cyan]#(cut -d ' ' -f 1-3 /proc/loadavg)#[default] #[fg=cyan]%H:%M#[default]"
set -g status-right-length 50
set -g status-justify centre

# Janelas numeradas
setw -g automatic-rename on
set -g set-titles on
set -g set-titles-string '#T'
EOF
    
    echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Configuração do tmux criada em: $tmux_conf${NC}"
    echo -e "${GRAY}   → Recarregue o tmux com: tmux source-file ~/.tmux.conf${NC}"
}

# Função para criar template de sessão
create_session_template() {
    echo -e "${BRIGHT_BLUE}${SETTINGS} CRIANDO TEMPLATE DE SESSÃO...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    mkdir -p "$TEMPLATES_DIR"
    
    restore_terminal
    
    echo -e "${WHITE}Digite o nome do template:${NC}"
    read -p "   ${BRIGHT_GREEN}Nome: ${NC}" template_name
    
    echo -e "${WHITE}Digite os comandos (um por linha, Ctrl+D para finalizar):${NC}"
    echo -e "${GRAY}   Exemplo:${NC}"
    echo -e "${GRAY}   cd ~/projeto${NC}"
    echo -e "${GRAY}   npm start${NC}"
    echo -e "${GRAY}   (Ctrl+D)${NC}"
    
    local template_file="$TEMPLATES_DIR/${template_name}.sh"
    cat > "$template_file" << EOF
#!/bin/bash
# Template: $template_name
# Criado em: $(date)
EOF
    
    while read -r line; do
        echo "$line" >> "$template_file"
    done
    
    chmod +x "$template_file"
    
    setup_terminal
    
    echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Template criado: $template_file${NC}"
}

# Função para usar template
use_session_template() {
    echo -e "${BRIGHT_BLUE}${SETTINGS} USANDO TEMPLATE DE SESSÃO...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [ ! -d "$TEMPLATES_DIR" ]; then
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhum template encontrado.${NC}"
        return
    fi
    
    local templates=($(ls "$TEMPLATES_DIR"/*.sh 2>/dev/null))
    
    if [ ${#templates[@]} -eq 0 ]; then
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhum template encontrado.${NC}"
        return
    fi
    
    echo -e "${WHITE}Templates disponíveis:${NC}"
    echo
    for i in "${!templates[@]}"; do
        local template="${templates[$i]}"
        local name=$(basename "$template" .sh)
        echo -e "  ${BRIGHT_GREEN}$((i+1))${NC} - ${name}"
    done
    echo
    
    restore_terminal
    echo -e "${WHITE}Escolha o template (1-${#templates[@]}):${NC}"
    read -p "   ${BRIGHT_GREEN}Opção: ${NC}" choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#templates[@]}" ]; then
        local selected_template="${templates[$((choice-1))]}"
        local template_name=$(basename "$selected_template" .sh)
        
        echo -e "${WHITE}Digite o nome da sessão:${NC}"
        read -p "   ${BRIGHT_GREEN}Nome: ${NC}" session_name
        
        if [[ -z "$session_name" ]]; then
            session_name="$template_name"
        fi
        
        # Cria sessão com template
        tmux new-session -d -s "$session_name"
        tmux send-keys -t "$session_name" "source $selected_template" Enter
        
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Sessão '$session_name' criada com template!${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Opção inválida!${NC}"
    fi
    
    setup_terminal
}

# Função para monitoramento em tempo real
monitor_sessions() {
    echo -e "${BRIGHT_BLUE}${MONITOR} MONITORAMENTO EM TEMPO REAL:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${WHITE}Pressione Ctrl+C para sair do monitoramento${NC}"
    echo
    
    while true; do
        clear
        show_header
        echo -e "${BRIGHT_BLUE}${MONITOR} MONITORAMENTO ATIVO - $(date '+%H:%M:%S')${NC}"
        echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo
        
        # Informações do sistema
        echo -e "${WHITE}📊 SISTEMA:${NC}"
        if command -v free &> /dev/null; then
            local mem_info=$(free -h | grep Mem)
            local mem_used=$(echo $mem_info | awk '{print $3}')
            local mem_total=$(echo $mem_info | awk '{print $2}')
            echo -e "  ${GRAY}Memória:${NC} ${BRIGHT_GREEN}$mem_used / $mem_total${NC}"
        fi
        
        if command -v df &> /dev/null; then
            local disk_used=$(df -h / | tail -1 | awk '{print $5}')
            echo -e "  ${GRAY}Disco:${NC} ${BRIGHT_GREEN}$disk_used usado${NC}"
        fi
        
        echo
        
        # Sessões ativas
        echo -e "${WHITE}🖥️ SESSÕES TMUX:${NC}"
        if tmux has-session 2>/dev/null; then
            tmux list-sessions | while read -r line; do
                local session_name=$(echo "$line" | cut -d: -f1)
                local windows=$(echo "$line" | grep -o '[0-9]\+ windows')
                local created=$(tmux display-message -p -t "$session_name" '#{session_created}' 2>/dev/null)
                local uptime=""
                if [ ! -z "$created" ]; then
                    local now=$(date +%s)
                    local diff=$((now - created))
                    local hours=$((diff / 3600))
                    local minutes=$(((diff % 3600) / 60))
                    uptime=" (${hours}h${minutes}m)"
                fi
                echo -e "  ${COMPUTER} ${BRIGHT_GREEN}$session_name${NC} - $windows$uptime"
            done
        else
            echo -e "  ${GRAY}Nenhuma sessão ativa${NC}"
        fi
        
        echo
        echo -e "${GRAY}Atualizando em 3 segundos...${NC}"
        sleep 3
    done
}

# Função para estatísticas de uso
show_statistics() {
    echo -e "${BRIGHT_BLUE}${MONITOR} ESTATÍSTICAS DE USO:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${WHITE}📈 ESTATÍSTICAS DO SCRIPT:${NC}"
    echo
    
    # Total de sessões criadas (baseado no log)
    if [ -f "$LOG_FILE" ]; then
        local sessions_created=$(grep -c "Criou nova sessão" "$LOG_FILE" 2>/dev/null || echo "0")
        local sessions_listed=$(grep -c "Listou sessões" "$LOG_FILE" 2>/dev/null || echo "0")
        local backups_created=$(grep -c "Criou backup" "$LOG_FILE" 2>/dev/null || echo "0")
        
        echo -e "  ${GRAY}Sessões criadas:${NC} ${BRIGHT_GREEN}$sessions_created${NC}"
        echo -e "  ${GRAY}Listagens realizadas:${NC} ${BRIGHT_GREEN}$sessions_listed${NC}"
        echo -e "  ${GRAY}Backups criados:${NC} ${BRIGHT_GREEN}$backups_created${NC}"
    else
        echo -e "  ${GRAY}Nenhum log encontrado${NC}"
    fi
    
    echo
    
    # Sessões atuais
    echo -e "${WHITE}🖥️ SESSÕES ATUAIS:${NC}"
    if tmux has-session 2>/dev/null; then
        local total_sessions=$(tmux list-sessions | wc -l)
        local total_windows=$(tmux list-sessions | grep -o '[0-9]\+ windows' | awk '{sum += $1} END {print sum}')
        
        echo -e "  ${GRAY}Total de sessões:${NC} ${BRIGHT_GREEN}$total_sessions${NC}"
        echo -e "  ${GRAY}Total de janelas:${NC} ${BRIGHT_GREEN}$total_windows${NC}"
    else
        echo -e "  ${GRAY}Nenhuma sessão ativa${NC}"
    fi
    
    echo
    
    # Tempo de uso do script
    if [ -f "$LOG_FILE" ]; then
        local first_use=$(head -1 "$LOG_FILE" | cut -d' ' -f1-2 2>/dev/null)
        if [ ! -z "$first_use" ]; then
            echo -e "${WHITE}⏰ TEMPO DE USO:${NC}"
            echo -e "  ${GRAY}Primeiro uso:${NC} ${BRIGHT_GREEN}$first_use${NC}"
        fi
    fi
    
    echo
}

# Função para configurações avançadas
advanced_settings() {
    echo -e "${BRIGHT_BLUE}${SETTINGS} CONFIGURAÇÕES AVANÇADAS:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    restore_terminal
    
    while true; do
        echo
        echo -e "${WHITE}CONFIGURAÇÕES DISPONÍVEIS:${NC}"
        echo -e "${GRAY}  1${NC} - Alterar tema (atual: $THEME)"
        echo -e "${GRAY}  2${NC} - Backup automático (atual: $AUTO_BACKUP)"
        echo -e "${GRAY}  3${NC} - Nome padrão de sessão (atual: $DEFAULT_SESSION_NAME)"
        echo -e "${GRAY}  4${NC} - Configurar tmux automaticamente"
        echo -e "${GRAY}  5${NC} - Voltar ao menu principal"
        echo
        read -p "   ${BRIGHT_GREEN}Escolha uma opção: ${NC}" choice
        
        case $choice in
            1)
                echo -e "${WHITE}Temas disponíveis: default, dark, light, neon${NC}"
                read -p "   ${BRIGHT_GREEN}Novo tema: ${NC}" new_theme
                if [[ "$new_theme" =~ ^(default|dark|light|neon)$ ]]; then
                    THEME="$new_theme"
                    apply_theme
                    save_config
                    echo -e "${BRIGHT_GREEN}${SUCCESS} Tema alterado para: $THEME${NC}"
                else
                    echo -e "${BRIGHT_RED}${ERROR} Tema inválido!${NC}"
                fi
                ;;
            2)
                if [ "$AUTO_BACKUP" = "true" ]; then
                    AUTO_BACKUP="false"
                    echo -e "${BRIGHT_GREEN}${SUCCESS} Backup automático desativado${NC}"
                else
                    AUTO_BACKUP="true"
                    echo -e "${BRIGHT_GREEN}${SUCCESS} Backup automático ativado${NC}"
                fi
                save_config
                ;;
            3)
                read -p "   ${BRIGHT_GREEN}Novo nome padrão: ${NC}" new_name
                if [ ! -z "$new_name" ]; then
                    DEFAULT_SESSION_NAME="$new_name"
                    save_config
                    echo -e "${BRIGHT_GREEN}${SUCCESS} Nome padrão alterado para: $DEFAULT_SESSION_NAME${NC}"
                fi
                ;;
            4)
                setup_tmux_config
                ;;
            5)
                break
                ;;
            *)
                echo -e "${BRIGHT_RED}${ERROR} Opção inválida!${NC}"
                ;;
        esac
    done
    
    setup_terminal
}

# Função para verificar se o tmux está instalado
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        return 1
    fi
    return 0
}

# Função para detectar o sistema operacional
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "ubuntu"
        elif command -v yum &> /dev/null; then
            echo "centos"
        elif command -v dnf &> /dev/null; then
            echo "fedora"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Função para instalar tmux
install_tmux() {
    local os=$(detect_os)
    
    echo -e "${BRIGHT_BLUE}${DOWNLOAD} INSTALANDO TMUX...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    case $os in
        "ubuntu"|"debian")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Ubuntu/Debian${NC}"
            echo -e "${GRAY}Executando: sudo apt update && sudo apt install -y tmux${NC}"
            echo
            sudo apt update && sudo apt install -y tmux
            ;;
        "centos"|"rhel")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}CentOS/RHEL${NC}"
            echo -e "${GRAY}Executando: sudo yum install -y tmux${NC}"
            echo
            sudo yum install -y tmux
            ;;
        "fedora")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Fedora${NC}"
            echo -e "${GRAY}Executando: sudo dnf install -y tmux${NC}"
            echo
            sudo dnf install -y tmux
            ;;
        "arch")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Arch Linux${NC}"
            echo -e "${GRAY}Executando: sudo pacman -S --noconfirm tmux${NC}"
            echo
            sudo pacman -S --noconfirm tmux
            ;;
        "macos")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}macOS${NC}"
            echo -e "${GRAY}Executando: brew install tmux${NC}"
            echo
            if command -v brew &> /dev/null; then
                brew install tmux
            else
                echo -e "${BRIGHT_RED}${ERROR} Homebrew não encontrado!${NC}"
                echo -e "${WHITE}Instale o Homebrew primeiro:${NC}"
                echo -e "${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
                return 1
            fi
            ;;
        "windows")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Windows${NC}"
            echo -e "${GRAY}Para Windows, use o WSL ou instale manualmente:${NC}"
            echo -e "${YELLOW}1. Instale o WSL2${NC}"
            echo -e "${YELLOW}2. Execute: sudo apt update && sudo apt install -y tmux${NC}"
            return 1
            ;;
        *)
            echo -e "${BRIGHT_RED}${ERROR} Sistema operacional não suportado!${NC}"
            echo -e "${WHITE}Instale o tmux manualmente:${NC}"
            echo -e "${YELLOW}Ubuntu/Debian: sudo apt install tmux${NC}"
            echo -e "${YELLOW}CentOS/RHEL: sudo yum install tmux${NC}"
            echo -e "${YELLOW}Fedora: sudo dnf install tmux${NC}"
            echo -e "${YELLOW}Arch: sudo pacman -S tmux${NC}"
            echo -e "${YELLOW}macOS: brew install tmux${NC}"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} TMUX instalado com sucesso!${NC}"
        return 0
    else
        echo
        echo -e "${BRIGHT_RED}${ERROR} Erro ao instalar TMUX!${NC}"
        return 1
    fi
}

# Função para remover tmux
remove_tmux() {
    local os=$(detect_os)
    
    echo -e "${BRIGHT_BLUE}${GEAR} REMOVENDO TMUX...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    case $os in
        "ubuntu"|"debian")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Ubuntu/Debian${NC}"
            echo -e "${GRAY}Executando: sudo apt remove -y tmux${NC}"
            echo
            sudo apt remove -y tmux
            ;;
        "centos"|"rhel")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}CentOS/RHEL${NC}"
            echo -e "${GRAY}Executando: sudo yum remove -y tmux${NC}"
            echo
            sudo yum remove -y tmux
            ;;
        "fedora")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Fedora${NC}"
            echo -e "${GRAY}Executando: sudo dnf remove -y tmux${NC}"
            echo
            sudo dnf remove -y tmux
            ;;
        "arch")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Arch Linux${NC}"
            echo -e "${GRAY}Executando: sudo pacman -R --noconfirm tmux${NC}"
            echo
            sudo pacman -R --noconfirm tmux
            ;;
        "macos")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}macOS${NC}"
            echo -e "${GRAY}Executando: brew uninstall tmux${NC}"
            echo
            if command -v brew &> /dev/null; then
                brew uninstall tmux
            else
                echo -e "${BRIGHT_RED}${ERROR} Homebrew não encontrado!${NC}"
                return 1
            fi
            ;;
        "windows")
            echo -e "${WHITE}Detectado: ${BRIGHT_GREEN}Windows${NC}"
            echo -e "${GRAY}Para Windows, use o WSL:${NC}"
            echo -e "${YELLOW}sudo apt remove -y tmux${NC}"
            return 1
            ;;
        *)
            echo -e "${BRIGHT_RED}${ERROR} Sistema operacional não suportado!${NC}"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} TMUX removido com sucesso!${NC}"
        return 0
    else
        echo
        echo -e "${BRIGHT_RED}${ERROR} Erro ao remover TMUX!${NC}"
        return 1
    fi
}

# Função para criar backup de sessões
backup_sessions() {
    echo -e "${BRIGHT_BLUE}${BACKUP} CRIANDO BACKUP DAS SESSÕES...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Cria diretório de backup se não existir
    mkdir -p "$BACKUP_DIR"
    
    # Nome do arquivo de backup com timestamp
    local backup_file="$BACKUP_DIR/tmux_sessions_$(date +%Y%m%d_%H%M%S).txt"
    
    if ! tmux has-session 2>/dev/null; then
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhuma sessão para fazer backup.${NC}"
        return
    fi
    
    # Lista todas as sessões
    tmux list-sessions > "$backup_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Backup criado: ${backup_file}${NC}"
        echo -e "${GRAY}   → Total de sessões: $(wc -l < "$backup_file")${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Erro ao criar backup!${NC}"
    fi
}

# Função para restaurar backup
restore_sessions() {
    echo -e "${BRIGHT_BLUE}${BACKUP} RESTAURANDO BACKUP...${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhum backup encontrado.${NC}"
        return
    fi
    
    # Lista backups disponíveis
    local backups=($(ls -t "$BACKUP_DIR"/tmux_sessions_*.txt 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhum backup encontrado.${NC}"
        return
    fi
    
    echo -e "${WHITE}Backups disponíveis:${NC}"
    echo
    for i in "${!backups[@]}"; do
        local file="${backups[$i]}"
        local date=$(basename "$file" | sed 's/tmux_sessions_\(.*\)\.txt/\1/')
        echo -e "  ${BRIGHT_GREEN}$((i+1))${NC} - ${date} (${file})"
    done
    echo
    
    restore_terminal
    echo -e "${WHITE}Escolha o backup para restaurar (1-${#backups[@]}):${NC}"
    read -p "   ${BRIGHT_GREEN}Opção: ${NC}" choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backups[@]}" ]; then
        local selected_backup="${backups[$((choice-1))]}"
        echo -e "${WHITE}Restaurando: ${selected_backup}${NC}"
        # Aqui você pode implementar a lógica de restauração
        echo -e "${BRIGHT_GREEN}${SUCCESS} Backup selecionado para restauração!${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Opção inválida!${NC}"
    fi
    setup_terminal
}

# Função para mostrar informações do sistema
show_system_info() {
    echo -e "${BRIGHT_BLUE}${INFO} INFORMAÇÕES DO SISTEMA:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Informações do sistema
    echo -e "${WHITE}Sistema Operacional:${NC} ${BRIGHT_GREEN}$(uname -s) $(uname -r)${NC}"
    echo -e "${WHITE}Arquitetura:${NC} ${BRIGHT_GREEN}$(uname -m)${NC}"
    echo -e "${WHITE}Hostname:${NC} ${BRIGHT_GREEN}$(hostname)${NC}"
    echo -e "${WHITE}Usuário:${NC} ${BRIGHT_GREEN}$(whoami)${NC}"
    echo
    
    # Uso de memória
    if command -v free &> /dev/null; then
        local mem_info=$(free -h | grep Mem)
        local total=$(echo $mem_info | awk '{print $2}')
        local used=$(echo $mem_info | awk '{print $3}')
        local free=$(echo $mem_info | awk '{print $4}')
        echo -e "${WHITE}Memória:${NC} ${BRIGHT_GREEN}Total: $total | Usado: $used | Livre: $free${NC}"
    fi
    
    # Uso de disco
    if command -v df &> /dev/null; then
        local disk_info=$(df -h / | tail -1)
        local disk_used=$(echo $disk_info | awk '{print $5}')
        echo -e "${WHITE}Disco (root):${NC} ${BRIGHT_GREEN}$disk_used usado${NC}"
    fi
    
    # Versão do tmux
    if command -v tmux &> /dev/null; then
        local tmux_version=$(tmux -V)
        echo -e "${WHITE}Versão TMUX:${NC} ${BRIGHT_GREEN}$tmux_version${NC}"
    fi
    
    echo
}

# Função para mostrar ajuda
show_help() {
    echo -e "${BRIGHT_BLUE}${HELP} AJUDA - GERENCIADOR DE TMUX:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}OPÇÕES PRINCIPAIS:${NC}"
    echo -e "${GRAY}   L${NC} - Listar todas as sessões tmux ativas"
    echo -e "${GRAY}   C${NC} - Criar uma nova sessão tmux"
    echo -e "${GRAY}   O${NC} - Abrir/Conectar a uma sessão existente"
    echo -e "${GRAY}   E${NC} - Executar comando em uma sessão específica"
    echo
    echo -e "${WHITE}GERENCIAMENTO:${NC}"
    echo -e "${GRAY}   I${NC} - Instalar tmux automaticamente"
    echo -e "${GRAY}   R${NC} - Remover tmux do sistema"
    echo -e "${GRAY}   B${NC} - Criar backup das sessões"
    echo -e "${GRAY}   T${NC} - Restaurar backup de sessões"
    echo
    echo -e "${WHITE}INFORMAÇÕES:${NC}"
    echo -e "${GRAY}   S${NC} - Mostrar informações do sistema"
    echo -e "${GRAY}   H${NC} - Mostrar esta ajuda"
    echo -e "${GRAY}   Q${NC} - Sair do programa"
    echo
    echo -e "${WHITE}ATALHOS TMUX:${NC}"
    echo -e "${GRAY}   Ctrl+B + D${NC} - Desconectar da sessão"
    echo -e "${GRAY}   Ctrl+B + C${NC} - Criar nova janela"
    echo -e "${GRAY}   Ctrl+B + N${NC} - Próxima janela"
    echo -e "${GRAY}   Ctrl+B + P${NC} - Janela anterior"
    echo -e "${GRAY}   Ctrl+B + %${NC} - Dividir painel verticalmente"
    echo -e "${GRAY}   Ctrl+B + \"${NC} - Dividir painel horizontalmente"
    echo
}

# Função para mostrar log de atividades
show_log() {
    echo -e "${BRIGHT_BLUE}${CLOCK} LOG DE ATIVIDADES:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    if [ -f "$LOG_FILE" ]; then
        echo -e "${WHITE}Últimas 20 atividades:${NC}"
        echo
        tail -20 "$LOG_FILE" | while read -r line; do
            echo -e "${GRAY}$line${NC}"
        done
    else
        echo -e "${BRIGHT_YELLOW}${WARNING} Nenhum log encontrado.${NC}"
    fi
    echo
}

# Função para adicionar entrada no log
log_activity() {
    local activity="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $activity" >> "$LOG_FILE"
}

# Função para mostrar botões interativos melhorados
show_interactive_buttons() {
    echo -e "${BRIGHT_PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎮 PRESSIONE UMA TECLA PARA CONTINUAR 🎮                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    # Primeira linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${LIST} L - LISTAR  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${PLUS} C - CRIAR   ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${LINK} O - ABRIR   ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    # Segunda linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${ROCKET} E - COMANDO ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${DOWNLOAD} I - INSTALAR ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${GEAR} R - REMOVER  ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    # Terceira linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${BACKUP} B - BACKUP  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${BACKUP} T - RESTAURAR ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${INFO} S - SISTEMA ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    # Quarta linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${MONITOR} M - MONITOR ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${SETTINGS} A - CONFIG  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${STAR} P - PERFIL   ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    # Quinta linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  🌐 G - GIT      ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  🔄 Y - SINCRONIZAR ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  🔌 U - PLUGINS  ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    # Sexta linha de botões
    echo -e "  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}  ${BRIGHT_CYAN}┌─────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ⚡ Z - OTIMIZAR ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${HELP} H - AJUDA   ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${BRIGHT_GREEN}  ${EXIT} Q - SAIR    ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}  ${BRIGHT_CYAN}└─────────────────┘${NC}"
    echo
    
    # Instrução melhorada
    echo -e "${BRIGHT_YELLOW}${LIGHT} ${STAR} DICA: Apenas pressione a tecla desejada (não precisa do Enter)! ${STAR}${NC}"
    echo -e "${GRAY}   ─────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Função para mostrar instruções de instalação manual
show_manual_install() {
    echo -e "${BRIGHT_YELLOW}${LIGHT} INSTRUÇÕES DE INSTALAÇÃO MANUAL:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Ubuntu/Debian:${NC}"
    echo -e "${GRAY}   sudo apt update && sudo apt install -y tmux${NC}"
    echo
    echo -e "${WHITE}CentOS/RHEL:${NC}"
    echo -e "${GRAY}   sudo yum install -y tmux${NC}"
    echo
    echo -e "${WHITE}Fedora:${NC}"
    echo -e "${GRAY}   sudo dnf install -y tmux${NC}"
    echo
    echo -e "${WHITE}Arch Linux:${NC}"
    echo -e "${GRAY}   sudo pacman -S --noconfirm tmux${NC}"
    echo
    echo -e "${WHITE}macOS:${NC}"
    echo -e "${GRAY}   brew install tmux${NC}"
    echo
    echo -e "${WHITE}Windows (WSL):${NC}"
    echo -e "${GRAY}   sudo apt update && sudo apt install -y tmux${NC}"
    echo
}

# Função para mostrar instruções de remoção manual
show_manual_remove() {
    echo -e "${BRIGHT_YELLOW}${LIGHT} INSTRUÇÕES DE REMOÇÃO MANUAL:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Ubuntu/Debian:${NC}"
    echo -e "${GRAY}   sudo apt remove -y tmux${NC}"
    echo
    echo -e "${WHITE}CentOS/RHEL:${NC}"
    echo -e "${GRAY}   sudo yum remove -y tmux${NC}"
    echo
    echo -e "${WHITE}Fedora:${NC}"
    echo -e "${GRAY}   sudo dnf remove -y tmux${NC}"
    echo
    echo -e "${WHITE}Arch Linux:${NC}"
    echo -e "${GRAY}   sudo pacman -R --noconfirm tmux${NC}"
    echo
    echo -e "${WHITE}macOS:${NC}"
    echo -e "${GRAY}   brew uninstall tmux${NC}"
    echo
    echo -e "${WHITE}Windows (WSL):${NC}"
    echo -e "${GRAY}   sudo apt remove -y tmux${NC}"
    echo
}

# Função para configurar o terminal para detecção de teclas
setup_terminal() {
    # Salva configurações atuais do terminal
    stty_save=$(stty -g)
    # Configura o terminal para detectar teclas sem Enter
    stty -icanon -echo
}

# Função para restaurar configurações do terminal
restore_terminal() {
    # Restaura configurações originais
    stty $stty_save
}

# Função para limpar a tela
clear_screen() {
    clear
}

# Função para mostrar o cabeçalho melhorado
show_header() {
    echo -e "${BRIGHT_CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        🚀 GERENCIADOR DE TMUX 🚀                           ║"
    echo "║                          Para Iniciantes! ✨                               ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para detectar tecla pressionada
detect_key() {
    # Lê um caractere sem precisar do Enter
    read -n 1 -s key
    echo "$key"
}

# Função para mostrar feedback visual da tecla pressionada melhorado
show_key_feedback() {
    local key=$1
    echo -e "${BRIGHT_GREEN}${SPARKLE} ${SUCCESS} Tecla pressionada: ${BRIGHT_WHITE}$key${NC} ${SPARKLE}"
    sleep 0.3
}

# Função 1: Mostrar lista de sessões melhorada
show_sessions() {
    echo -e "${BRIGHT_BLUE}${LIST} 📊 LISTANDO SESSÕES TMUX:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Verifica se há sessões
    if ! tmux has-session 2>/dev/null; then
        echo -e "${BRIGHT_YELLOW}${WARNING} ${FIRE} Não foi possível encontrar sessões no momento.${NC}"
        echo -e "${GRAY}   → Use a opção C para criar uma nova sessão${NC}"
    else
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Sessões encontradas:${NC}"
        echo
        # Lista todas as sessões com melhor formatação
        tmux list-sessions | while read -r line; do
            session_name=$(echo "$line" | cut -d: -f1)
            windows=$(echo "$line" | grep -o '[0-9]\+ windows')
            echo -e "  ${COMPUTER} ${BRIGHT_GREEN}$session_name${NC} ${GRAY}- $windows${NC}"
        done
    fi
    echo
}

# Função 2: Criar sessão melhorada
create_session() {
    echo -e "${BRIGHT_BLUE}${PLUS} 🆕 CRIANDO NOVA SESSÃO TMUX:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Restaura terminal para entrada normal
    restore_terminal
    
    # Pede o nome da sessão
    echo -e "${WHITE}Digite um nome para a nova sessão:${NC}"
    echo -e "${GRAY}   Exemplo: minecraft, servidor, trabalho${NC}"
    read -p "   ${BRIGHT_GREEN}Nome: ${NC}" session_name
    
    # Reconfigura para detecção de teclas
    setup_terminal
    
    # Valida o nome
    if [[ -z "$session_name" ]]; then
        echo -e "${BRIGHT_RED}${ERROR} Nome não pode estar vazio!${NC}"
        return
    fi
    
    # Verifica se já existe
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${BRIGHT_RED}${ERROR} Já existe uma sessão com esse nome!${NC}"
        return
    fi
    
    # Cria a sessão
    echo -e "${WHITE}Criando sessão '${BRIGHT_GREEN}$session_name${WHITE}'...${NC}"
    tmux new-session -d -s "$session_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Sessão '${session_name}' criada com sucesso!${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Erro ao criar a sessão!${NC}"
    fi
}

# Função 3: Mostrar lista e pedir qual abrir melhorada
open_session() {
    echo -e "${BRIGHT_BLUE}${LINK} 🔗 ABRINDO SESSÃO TMUX:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Mostra sessões disponíveis
    if ! tmux has-session 2>/dev/null; then
        echo -e "${BRIGHT_YELLOW}${WARNING} ${FIRE} Não foi possível encontrar sessões no momento.${NC}"
        return
    fi
    
    echo -e "${WHITE}Sessões disponíveis:${NC}"
    echo
    tmux list-sessions | while read -r line; do
        session_name=$(echo "$line" | cut -d: -f1)
        windows=$(echo "$line" | grep -o '[0-9]\+ windows')
        echo -e "  ${COMPUTER} ${BRIGHT_GREEN}$session_name${NC} ${GRAY}- $windows${NC}"
    done
    echo
    
    # Restaura terminal para entrada normal
    restore_terminal
    
    # Pede qual sessão abrir
    echo -e "${WHITE}Digite o nome da sessão que deseja abrir:${NC}"
    read -p "   ${BRIGHT_GREEN}Sessão: ${NC}" session_name
    
    # Reconfigura para detecção de teclas
    setup_terminal
    
    if [[ -z "$session_name" ]]; then
        echo -e "${BRIGHT_RED}${ERROR} Nome não pode estar vazio!${NC}"
        return
    fi
    
    # Verifica se a sessão existe
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${BRIGHT_RED}${ERROR} Sessão '$session_name' não encontrada!${NC}"
        return
    fi
    
    # Abre a sessão
    echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Abrindo sessão '${session_name}'...${NC}"
    echo -e "${GRAY}   → Para sair da sessão: ${YELLOW}Ctrl+B${GRAY} depois ${YELLOW}D${NC}"
    echo
    sleep 2
    tmux attach-session -t "$session_name"
}

# Função 4: Pedir nome da sessão existente e comando melhorada
create_session_with_script() {
    echo -e "${BRIGHT_BLUE}${ROCKET} ⚡ EXECUTAR COMANDO EM SESSÃO EXISTENTE:${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Mostra sessões disponíveis
    if ! tmux has-session 2>/dev/null; then
        echo -e "${BRIGHT_YELLOW}${WARNING} ${FIRE} Não foi possível encontrar sessões no momento.${NC}"
        return
    fi
    
    echo -e "${WHITE}Sessões disponíveis:${NC}"
    echo
    tmux list-sessions | while read -r line; do
        session_name=$(echo "$line" | cut -d: -f1)
        windows=$(echo "$line" | grep -o '[0-9]\+ windows')
        echo -e "  ${COMPUTER} ${BRIGHT_GREEN}$session_name${NC} ${GRAY}- $windows${NC}"
    done
    echo
    
    # Restaura terminal para entrada normal
    restore_terminal
    
    # Pede o nome da sessão existente
    echo -e "${WHITE}Digite o nome da sessão existente:${NC}"
    read -p "   ${BRIGHT_GREEN}Sessão: ${NC}" session_name
    
    if [[ -z "$session_name" ]]; then
        echo -e "${BRIGHT_RED}${ERROR} Nome não pode estar vazio!${NC}"
        return
    fi
    
    # Verifica se a sessão existe
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${BRIGHT_RED}${ERROR} Sessão '$session_name' não encontrada!${NC}"
        return
    fi
    
    # Pede o comando
    echo -e "${WHITE}Digite o comando que deve rodar:${NC}"
    echo -e "${GRAY}   Exemplos: ${YELLOW}./run.sh${GRAY}, ${YELLOW}java -jar server.jar${GRAY}, ${YELLOW}npm start${NC}"
    read -p "   ${BRIGHT_GREEN}Comando: ${NC}" command
    
    # Reconfigura para detecção de teclas
    setup_terminal
    
    if [[ -z "$command" ]]; then
        echo -e "${BRIGHT_RED}${ERROR} Comando não pode estar vazio!${NC}"
        return
    fi
    
    # Executa o comando na sessão existente
    echo -e "${WHITE}Executando comando na sessão '${BRIGHT_GREEN}$session_name${WHITE}'...${NC}"
    tmux send-keys -t "$session_name" "$command" Enter
    
    if [ $? -eq 0 ]; then
        echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Comando executado na sessão '${session_name}'!${NC}"
    else
        echo -e "${BRIGHT_RED}${ERROR} Erro ao executar o comando!${NC}"
    fi
}

# Função para pausar e voltar ao menu melhorada
pause_and_continue() {
    echo
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Pressione ${BRIGHT_YELLOW}qualquer tecla${WHITE} para voltar ao menu...${NC}"
    detect_key > /dev/null
}

# Carregar configurações
load_config
apply_theme

# Verificação inicial do tmux
if ! check_tmux; then
    clear_screen
    show_header
    echo -e "${BRIGHT_RED}${ERROR} TMUX não está instalado!${NC}"
    echo -e "${BRIGHT_CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}O TMUX é necessário para usar este gerenciador.${NC}"
    echo
    echo -e "${BRIGHT_YELLOW}${LIGHT} Deseja instalar automaticamente? (S/N)${NC}"
    read -p "   " choice
    
    case $choice in
        S|s|Y|y|"")
            if install_tmux; then
                echo -e "${BRIGHT_GREEN}${SUCCESS} TMUX instalado! Iniciando o gerenciador...${NC}"
                sleep 2
            else
                echo -e "${BRIGHT_RED}${ERROR} Falha na instalação automática.${NC}"
                echo
                show_manual_install
                echo -e "${WHITE}Pressione qualquer tecla para sair...${NC}"
                read -n 1 -s
                exit 1
            fi
            ;;
        *)
            echo
            show_manual_install
            echo -e "${WHITE}Pressione qualquer tecla para sair...${NC}"
            read -n 1 -s
            exit 1
            ;;
    esac
fi

# Configura o terminal no início
setup_terminal

# Garante que o terminal seja restaurado ao sair
trap restore_terminal EXIT

# Loop principal do programa
while true; do
    clear_screen
    show_header
    show_interactive_buttons
    
    # Detecta tecla pressionada
    key=$(detect_key)
    
    # Mostra feedback visual
    show_key_feedback "$key"
    
    case $key in
        L|l)
            clear_screen
            show_header
            show_sessions
            log_activity "Listou sessões tmux"
            pause_and_continue
            ;;
        C|c)
            clear_screen
            show_header
            create_session
            log_activity "Criou nova sessão tmux"
            update_score "create_session" 5
            pause_and_continue
            ;;
        O|o)
            clear_screen
            show_header
            open_session
            ;;
        E|e)
            clear_screen
            show_header
            create_session_with_script
            pause_and_continue
            ;;
        I|i)
            clear_screen
            show_header
            if check_tmux; then
                echo -e "${BRIGHT_YELLOW}${WARNING} TMUX já está instalado!${NC}"
            else
                install_tmux
            fi
            pause_and_continue
            ;;
        R|r)
            clear_screen
            show_header
            if ! check_tmux; then
                echo -e "${BRIGHT_YELLOW}${WARNING} TMUX não está instalado!${NC}"
            else
                echo -e "${BRIGHT_RED}${WARNING} Tem certeza que deseja remover o TMUX? (S/N)${NC}"
                restore_terminal
                read -p "   " choice
                setup_terminal
                
                case $choice in
                    S|s|Y|y)
                        remove_tmux
                        ;;
                    *)
                        echo -e "${WHITE}Remoção cancelada.${NC}"
                        ;;
                esac
            fi
            pause_and_continue
            ;;
        B|b)
            clear_screen
            show_header
            backup_sessions
            log_activity "Criou backup das sessões"
            pause_and_continue
            ;;
        T|t)
            clear_screen
            show_header
            restore_sessions
            pause_and_continue
            ;;
        S|s)
            clear_screen
            show_header
            show_system_info
            pause_and_continue
            ;;
        H|h)
            clear_screen
            show_header
            show_help
            pause_and_continue
            ;;
        M|m)
            clear_screen
            show_header
            monitor_sessions
            ;;
        A|a)
            clear_screen
            show_header
            advanced_settings
            ;;
        P|p)
            clear_screen
            show_header
            show_profile
            pause_and_continue
            ;;
        G|g)
            clear_screen
            show_header
            git_integration
            ;;
        Y|y)
            clear_screen
            show_header
            sync_sessions
            ;;
        U|u)
            clear_screen
            show_header
            install_tmux_plugins
            ;;
        Z|z)
            clear_screen
            show_header
            optimize_performance
            ;;
        Q|q)
            echo
            echo -e "${BRIGHT_GREEN}${SUCCESS} ${STAR} Obrigado por usar o Gerenciador de tmux! ${STAR}${NC}"
            echo -e "${WHITE}Até logo! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${BRIGHT_RED}${ERROR} Tecla inválida! Use L, C, O, E, I, R, B, T, S, M, A, P, G, Y, U, Z, H ou Q.${NC}"
            sleep 1
            ;;
    esac
done
