#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GrocerEase Repository Installation${NC}"
echo "======================================"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

# Load repository configurations
CONFIG_FILE="$SCRIPT_DIR/repos.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${YELLOW}⚠️  Configuration file not found at $CONFIG_FILE${NC}"
    echo -e "${YELLOW}Using default repository URLs...${NC}"
fi

# Repository configurations (with fallbacks)
REPOS_GROCER_EASE_CHATBOT="${GROCER_EASE_CHATBOT_URL:-https://github.com/your-org/grocer-ease-chatbot.git}"
REPOS_GROCER_EASE_UI="${GROCER_EASE_UI_URL:-https://github.com/your-org/grocer-ease-ui.git}"
REPOS_ROOMBA_MAPPING="${ROOMBA_MAPPING_URL:-https://github.com/your-org/roomba-mapping.git}"

# Function to get repository URL
get_repo_url() {
    local repo_name="$1"
    case "$repo_name" in
        "grocer-ease-chatbot")
            echo "$REPOS_GROCER_EASE_CHATBOT"
            ;;
        "grocer-ease-ui")
            echo "$REPOS_GROCER_EASE_UI"
            ;;
        "roomba_mapping")
            echo "$REPOS_ROOMBA_MAPPING"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to get all repository names
get_all_repos() {
    echo "grocer-ease-chatbot grocer-ease-ui roomba_mapping"
}

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed. Please install Git and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Git is available${NC}"
}

# Function to check if a directory exists and is a git repository
is_git_repo() {
    local dir="$1"
    if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
        return 0
    else
        return 1
    fi
}

# Function to clone a repository
clone_repo() {
    local repo_name="$1"
    local repo_url="$2"
    local target_dir="$REPOS_DIR/$repo_name"
    
    echo -e "${BLUE}📦 Installing $repo_name...${NC}"
    
    if [ -d "$target_dir" ]; then
        if is_git_repo "$target_dir"; then
            echo -e "${YELLOW}⚠️  Repository $repo_name already exists.${NC}"
            read -p "Do you want to update it? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}🔄 Updating $repo_name...${NC}"
                cd "$target_dir"
                git fetch origin
                git reset --hard origin/$DEFAULT_BRANCH
                cd "$REPOS_DIR"
                echo -e "${GREEN}✅ $repo_name updated successfully${NC}"
            else
                echo -e "${YELLOW}⏭️  Skipping $repo_name${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Directory $repo_name exists but is not a git repository.${NC}"
            read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}📦 Backing up existing directory...${NC}"
                mv "$target_dir" "${target_dir}_backup_$(date +%Y%m%d_%H%M%S)"
                git clone "$repo_url" "$target_dir"
                echo -e "${GREEN}✅ $repo_name cloned successfully${NC}"
            else
                echo -e "${YELLOW}⏭️  Skipping $repo_name${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}📥 Cloning $repo_name from $repo_url...${NC}"
        git clone "$repo_url" "$target_dir"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $repo_name cloned successfully${NC}"
        else
            echo -e "${RED}❌ Failed to clone $repo_name${NC}"
            return 1
        fi
    fi
}

# Function to install all repositories
install_all_repos() {
    echo -e "${BLUE}🔧 Installing all repositories...${NC}"
    
    local failed_repos=()
    
    for repo_name in $(get_all_repos); do
        local repo_url=$(get_repo_url "$repo_name")
        if ! clone_repo "$repo_name" "$repo_url"; then
            failed_repos+=("$repo_name")
        fi
    done
    
    if [ ${#failed_repos[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories installed successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to install the following repositories:${NC}"
        for repo in "${failed_repos[@]}"; do
            echo -e "${RED}   - $repo${NC}"
        done
        return 1
    fi
}

# Function to install a specific repository
install_specific_repo() {
    local repo_name="$1"
    local repo_url=$(get_repo_url "$repo_name")
    
    if [ -z "$repo_url" ]; then
        echo -e "${RED}❌ Unknown repository: $repo_name${NC}"
        echo -e "${YELLOW}Available repositories:${NC}"
        for repo in $(get_all_repos); do
            echo -e "${GREEN}   - $repo${NC}"
        done
        return 1
    fi
    
    clone_repo "$repo_name" "$repo_url"
}

# Function to show repository status
show_status() {
    echo -e "${BLUE}📊 Repository Status:${NC}"
    echo "======================"
    
    for repo_name in $(get_all_repos); do
        local target_dir="$REPOS_DIR/$repo_name"
        
        if [ -d "$target_dir" ]; then
            if is_git_repo "$target_dir"; then
                cd "$target_dir"
                local current_branch=$(git branch --show-current 2>/dev/null)
                local remote_url=$(git config --get remote.origin.url 2>/dev/null)
                local last_commit=$(git log -1 --format="%h - %s (%cr)" 2>/dev/null)
                
                echo -e "${GREEN}✅ $repo_name${NC}"
                echo -e "   Branch: ${BLUE}$current_branch${NC}"
                echo -e "   Remote: ${YELLOW}$remote_url${NC}"
                echo -e "   Last commit: ${YELLOW}$last_commit${NC}"
                cd "$REPOS_DIR"
            else
                echo -e "${YELLOW}⚠️  $repo_name (not a git repository)${NC}"
            fi
        else
            echo -e "${RED}❌ $repo_name (not installed)${NC}"
        fi
        echo
    done
}

# Function to update all repositories
update_all_repos() {
    echo -e "${BLUE}🔄 Updating all repositories...${NC}"
    
    local failed_updates=()
    
    for repo_name in $(get_all_repos); do
        local target_dir="$REPOS_DIR/$repo_name"
        
        if [ -d "$target_dir" ] && is_git_repo "$target_dir"; then
            echo -e "${YELLOW}🔄 Updating $repo_name...${NC}"
            cd "$target_dir"
            git fetch origin
            git reset --hard origin/$DEFAULT_BRANCH
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ $repo_name updated successfully${NC}"
            else
                echo -e "${RED}❌ Failed to update $repo_name${NC}"
                failed_updates+=("$repo_name")
            fi
            cd "$REPOS_DIR"
        else
            echo -e "${YELLOW}⚠️  $repo_name is not a git repository, skipping...${NC}"
        fi
    done
    
    if [ ${#failed_updates[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All repositories updated successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to update the following repositories:${NC}"
        for repo in "${failed_updates[@]}"; do
            echo -e "${RED}   - $repo${NC}"
        done
        return 1
    fi
}

# Function to configure repository URLs
configure_repos() {
    echo -e "${BLUE}⚙️  Repository Configuration${NC}"
    echo "=========================="
    
    echo -e "${YELLOW}Current repository URLs:${NC}"
    for repo_name in $(get_all_repos); do
        local repo_url=$(get_repo_url "$repo_name")
        echo -e "${GREEN}$repo_name:${NC} $repo_url"
    done
    
    echo
    echo -e "${YELLOW}To customize repository URLs, edit the repos.conf file.${NC}"
    echo -e "${YELLOW}Or set environment variables:${NC}"
    echo -e "  export GROCER_EASE_CHATBOT_URL=your-custom-url"
    echo -e "  export GROCER_EASE_UI_URL=your-custom-url"
    echo -e "  export ROOMBA_MAPPING_URL=your-custom-url"
}

# Function to show help
show_help() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}./install.sh${NC}                    - Install all repositories"
    echo -e "  ${GREEN}./install.sh all${NC}                - Install all repositories"
    echo -e "  ${GREEN}./install.sh <repo-name>${NC}        - Install specific repository"
    echo -e "  ${GREEN}./install.sh status${NC}             - Show repository status"
    echo -e "  ${GREEN}./install.sh update${NC}             - Update all repositories"
    echo -e "  ${GREEN}./install.sh config${NC}             - Show configuration"
    echo -e "  ${GREEN}./install.sh help${NC}               - Show this help"
    echo
    echo -e "${YELLOW}Available repositories:${NC}"
    for repo in $(get_all_repos); do
        echo -e "${GREEN}   - $repo${NC}"
    done
}

# Load custom URLs from environment variables if set
if [ ! -z "$GROCER_EASE_CHATBOT_URL" ]; then
    REPOS["grocer-ease-chatbot"]="$GROCER_EASE_CHATBOT_URL"
fi

if [ ! -z "$GROCER_EASE_UI_URL" ]; then
    REPOS["grocer-ease-ui"]="$GROCER_EASE_UI_URL"
fi

if [ ! -z "$ROOMBA_MAPPING_URL" ]; then
    REPOS["roomba_mapping"]="$ROOMBA_MAPPING_URL"
fi

# Main script logic
case "${1:-all}" in
    "all")
        check_git
        install_all_repos
        ;;
    "status")
        show_status
        ;;
    "update")
        check_git
        update_all_repos
        ;;
    "config")
        configure_repos
        ;;
    "help")
        show_help
        ;;
    *)
        if [ "$1" = "grocer-ease-chatbot" ] || [ "$1" = "grocer-ease-ui" ] || [ "$1" = "roomba_mapping" ]; then
            check_git
            install_specific_repo "$1"
        else
            echo -e "${RED}❌ Unknown command: $1${NC}"
            show_help
            exit 1
        fi
        ;;
esac 