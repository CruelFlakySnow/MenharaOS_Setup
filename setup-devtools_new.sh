#!/bin/bash
# ============================================
# MenheraOS DevEdition - First Boot Auto Setup
# ============================================
# This script automatically installs development tools
# after MenheraOS installation on first boot
# ============================================

set -e

# ============================================
# Configuration
# ============================================

LOGFILE="/var/log/menheraos-devsetup.log"
FLAGFILE="/var/lib/menheraos-devsetup-done"
BACKUP_DIR="/var/backup/menheraos-devsetup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# Helper Functions
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

print_header() {
    echo -e "${PINK}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log "WARNING: $1"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
    log "INFO: $1"
}

print_step() {
    echo -e "${BLUE}[$1/$2] $3${NC}"
    log "STEP $1/$2: $3"
}

# Show notification (if in graphical session)
notify() {
    if [ -n "$DISPLAY" ]; then
        notify-send "MenheraOS DevEdition" "$1" -i system-software-install 2>/dev/null || true
    fi
}

# ============================================
# Pre-flight Checks
# ============================================

check_already_run() {
    if [ -f "$FLAGFILE" ]; then
        print_warning "Setup already completed!"
        print_info "To run again, delete: $FLAGFILE"
        exit 0
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root!"
        print_info "Run as regular user with sudo privileges"
        exit 1
    fi
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_error "User does not have sudo privileges"
        exit 1
    fi
}

check_internet() {
    print_info "Checking internet connection..."
    if ! ping -c 1 archlinux.org &>/dev/null; then
        print_error "No internet connection!"
        print_info "Please connect to internet and try again"
        exit 1
    fi
    print_success "Internet connection OK"
}

check_disk_space() {
    print_info "Checking disk space..."
    local available=$(df / | tail -1 | awk '{print $4}')
    local required=$((5 * 1024 * 1024)) # 5GB in KB
    
    if [ "$available" -lt "$required" ]; then
        print_error "Insufficient disk space!"
        print_info "Required: 5GB, Available: $((available / 1024 / 1024))GB"
        exit 1
    fi
    print_success "Disk space OK"
}

# ============================================
# Main Installation Functions
# ============================================

update_system() {
    print_step 1 7 "🔄 Updating system..."
    
    log "Updating pacman database"
    sudo pacman -Sy --noconfirm
    
    log "Upgrading packages"
    sudo pacman -Syu --noconfirm
    
    print_success "System updated"
    notify "System updated successfully"
}

install_core_dev() {
    print_step 2 7 "🛠️  Installing core development tools..."
    
    local packages=(
        # C/C++ development
        "base-devel"  # Includes gcc, g++, make, etc.
        "cmake"
        
        # Python development
        "python"
        "python-pip"
        "python-virtualenv"
        
        # JavaScript development
        "nodejs"
        "npm"
        
        # Java development
        "jdk-openjdk"
        
        # Version control
        "git"
        "git-lfs"
        "github-cli"
        
        # Bonus utilities
        "wget"
        "curl"
        "tree"
        "htop"
    )
    
    log "Installing core packages: ${packages[*]}"
    
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            print_info "Installing $pkg..."
            sudo pacman -S --noconfirm --needed "$pkg" || {
                print_warning "Failed to install $pkg, skipping..."
                log "Failed to install $pkg"
            }
        else
            print_info "$pkg already installed, skipping"
        fi
    done
    
    print_success "Core development tools installed"
    notify "Core development tools installed"
}

install_yay() {
    print_step 3 7 "📦 Installing AUR helper (yay)..."
    
    if command -v yay &>/dev/null; then
        print_info "yay already installed"
        return 0
    fi
    
    log "Installing yay from AUR"
    
    # Save current directory
    local cwd=$(pwd)
    
    cd /tmp
    rm -rf yay
    
    print_info "Cloning yay repository..."
    git clone https://aur.archlinux.org/yay.git || {
        print_error "Failed to clone yay"
        cd "$cwd"
        return 1
    }
    
    cd yay
    
    print_info "Building yay..."
    makepkg -si --noconfirm || {
        print_error "Failed to build yay"
        cd "$cwd"
        return 1
    }
    
    cd "$cwd"
    rm -rf /tmp/yay
    
    print_success "yay installed"
    notify "AUR helper installed"
}

install_editors() {
    print_step 4 7 "💻 Installing IDEs and editors..."
    
    # Install VS Code
    if ! pacman -Q visual-studio-code-bin &>/dev/null; then
        print_info "Installing Visual Studio Code..."
        yay -S --noconfirm --needed visual-studio-code-bin || {
            print_warning "Failed to install Visual Studio Code"
            log "Visual Studio Code installation failed"
        }
    else
        print_info "Visual Studio Code already installed"
    fi
    
    # Install micro
    if ! pacman -Q micro &>/dev/null; then
        print_info "Installing micro editor..."
        sudo pacman -S --noconfirm --needed micro || {
            print_warning "Failed to install micro"
            log "Micro installation failed"
        }
    else
        print_info "micro already installed"
    fi
    
    print_success "IDEs and editors installed"
    notify "IDEs and editors installed"
}

install_containers() {
    print_step 5 7 "🐋 Installing containers..."
    
    local packages=(
        "docker"
        "docker-compose"
        "podman"
        "podman-compose"
    )
    
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            print_info "Installing $pkg..."
            sudo pacman -S --noconfirm --needed "$pkg" || {
                print_warning "Failed to install $pkg"
                log "Failed to install $pkg"
            }
        else
            print_info "$pkg already installed"
        fi
    done
    
    # Enable Docker service
    print_info "Enabling Docker service..."
    sudo systemctl enable docker || print_warning "Failed to enable docker service"
    sudo systemctl start docker || print_warning "Failed to start docker service"
    
    # Add user to docker group
    print_info "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER" || print_warning "Failed to add user to docker group"
    
    print_success "Containers installed"
    notify "Containers installed"
}

configure_environment() {
    print_step 6 7 "⚙️  Configuring development environment..."
    
    # Create project directories
    print_info "Creating project directories..."
    mkdir -p "$HOME"/{Projects,Workspace,Documents/Code}
    mkdir -p "$HOME/Projects"/{python,nodejs,java,go,rust,web}
    
    # Configure Git
    print_info "Configuring Git..."
    if ! git config --global user.name &>/dev/null; then
        git config --global init.defaultBranch main
        git config --global core.editor micro
        git config --global color.ui auto
        print_info "Git configured (user name/email not set - do it manually)"
    fi
    
    # Pre-configured VS Code
    if [ -d "$HOME/.config/Code/User" ] || mkdir -p "$HOME/.config/Code/User" 2>/dev/null; then
        print_info "Configuring VS Code..."
        cat > "$HOME/.config/Code/User/settings.json" << 'EOF'
{
    "workbench.colorTheme": "Default Dark+",
    "editor.fontSize": 14,
    "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
    "editor.fontLigatures": true,
    "editor.minimap.enabled": true,
    "editor.formatOnSave": true,
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.shell.linux": "/bin/zsh",
    "files.autoSave": "afterDelay",
    "git.autofetch": true
}
EOF
    fi
    
    # Docker configuration
    print_info "Configuring Docker..."
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF
    
    print_success "Environment configured"
    notify "Environment configured"
}

finalize_setup() {
    print_step 7 7 "🎉 Finalizing setup..."
    
    # Create completion flag
    sudo mkdir -p "$(dirname "$FLAGFILE")"
    sudo touch "$FLAGFILE"
    
    # Save installation info
    sudo tee "$FLAGFILE" > /dev/null << EOF
MenheraOS DevEdition Setup
Completed: $(date)
User: $USER
Hostname: $(hostname)
EOF
    
    print_success "Setup finalized"
}

# ============================================
# Show Summary
# ============================================

show_summary() {
    clear
    print_header "MenheraOS DevEdition Setup Complete!"
    
    echo -e "${CYAN}"
    echo "✨ Installation Summary ✨"
    echo ""
    echo "Installed Tools:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show versions
    echo -e "${GREEN}Core Development:${NC}"
    command -v gcc &>/dev/null && echo "  • GCC/G++: $(gcc --version | head -n1)"
    command -v python &>/dev/null && echo "  • Python: $(python --version 2>&1)"
    command -v node &>/dev/null && echo "  • Node.js: $(node --version)"
    command -v java &>/dev/null && echo "  • Java: $(java --version 2>&1 | head -n1)"
    command -v git &>/dev/null && echo "  • Git: $(git --version)"
    command -v gh &>/dev/null && echo "  • GitHub CLI: $(gh --version | head -n1)"
    
    echo ""
    echo -e "${GREEN}IDEs & Editors:${NC}"
    command -v code &>/dev/null && echo "  • Visual Studio Code: $(code --version | head -n1)"
    command -v micro &>/dev/null && echo "  • micro: $(micro --version)"
    
    echo ""
    echo -e "${GREEN}Containers:${NC}"
    command -v docker &>/dev/null && echo "  • Docker: $(docker --version)"
    command -v podman &>/dev/null && echo "  • Podman: $(podman --version)"
    
    echo ""
    echo -e "${GREEN}Bonus Utilities:${NC}"
    command -v wget &>/dev/null && echo "  • wget: $(wget --version | head -n1)"
    command -v curl &>/dev/null && echo "  • curl: $(curl --version | head -n1)"
    command -v tree &>/dev/null && echo "  • tree: $(tree --version)"
    command -v htop &>/dev/null && echo "  • htop: $(htop --version | head -n1)"
    
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${PINK}Next Steps:${NC}"
    echo "  1. Reboot your system: ${CYAN}sudo reboot${NC}"
    echo "  2. After reboot, Docker will be ready to use"
    echo "  3. Configure Git with your info:"
    echo "     ${CYAN}git config --global user.name \"Your Name\"${NC}"
    echo "     ${CYAN}git config --global user.email \"your@email.com\"${NC}"
    echo "  4. Start coding! 💻"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Project directories created at:${NC}"
    echo "  ~/Projects/     - Your projects"
    echo "  ~/Workspace/    - Workspace"
    echo ""
    echo -e "${CYAN}Quick Start Commands:${NC}"
    echo "  ${GREEN}code .${NC}              - Open VS Code"
    echo "  ${GREEN}docker ps${NC}           - List containers"
    echo "  ${GREEN}python --version${NC}    - Check Python"
    echo "  ${GREEN}node --version${NC}      - Check Node.js"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${PINK}Made with 💖 for MenheraOS DevEdition${NC}"
    echo ""
    
    log "Setup completed successfully"
    notify "MenheraOS DevEdition setup complete! 🎉"
}

# ============================================
# Error Handler
# ============================================

error_handler() {
    print_error "An error occurred during setup!"
    print_info "Check log file: $LOGFILE"
    
    log "Setup failed at line $1"
    
    notify "Setup failed! Check logs."
    
    exit 1
}

trap 'error_handler ${LINENO}' ERR

# ============================================
# Main Execution
# ============================================

main() {
    # Initialize log
    sudo mkdir -p "$(dirname "$LOGFILE")"
    sudo touch "$LOGFILE"
    sudo chmod 666 "$LOGFILE"
    
    log "=========================================="
    log "MenheraOS DevEdition Setup Started"
    log "=========================================="
    
    clear
    
    # Show welcome banner
    echo -e "${PINK}"
    cat << "EOF"
   ███╗   ███╗███████╗███╗   ██╗██╗  ██╗███████╗██████╗  █████╗ 
   ████╗ ████║██╔════╝████╗  ██║██║  ██║██╔════╝██╔══██╗██╔══██╗
   ██╔████╔██║█████╗  ██╔██╗ ██║███████║█████╗  ██████╔╝███████║
   ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██╔══██║██╔══╝  ██╔══██╗██╔══██║
   ██║ ╚═╝ ██║███████╗██║ ╚████║██║  ██║███████╗██║  ██║██║  ██║
   ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
   
         ██████╗ ███████╗██╗   ██╗    ███████╗██████╗ ██╗████████╗██╗ ██████╗ ███╗   ██╗
         ██╔══██╗██╔════╝██║   ██║    ██╔════╝██╔══██╗██║╚══██╔══╝██║██╔═══██╗████╗  ██║
         ██║  ██║█████╗  ██║   ██║    █████╗  ██║  ██║██║   ██║   ██║██║   ██║██╔██╗ ██║
         ██║  ██║██╔══╝  ╚██╗ ██╔╝    ██╔══╝  ██║  ██║██║   ██║   ██║██║   ██║██║╚██╗██║
         ██████╔╝███████╗ ╚████╔╝     ███████╗██████╔╝██║   ██║   ██║╚██████╔╝██║ ╚████║
         ╚═════╝ ╚══════╝  ╚═══╝      ╚══════╝╚═════╝ ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                          
                      🎀 First Boot Auto Setup 💻
EOF
    echo -e "${NC}"
    echo ""
    
    print_header "Starting Development Environment Setup"
    
    echo -e "${YELLOW}This will install:${NC}"
    echo "  • Core Dev Tools (gcc/g++, python, nodejs, java, git)"
    echo "  • IDEs (Visual Studio Code, micro)"
    echo "  • Containers (Docker, Podman)"
    echo "  • Bonus Tools (wget, curl, tree, htop)"
    echo ""
    echo -e "${CYAN}Estimated time: 20-30 minutes${NC}"
    echo -e "${YELLOW}Please ensure stable internet connection${NC}"
    echo ""
    
    # Wait a moment
    sleep 3
    
    # Pre-flight checks
    print_header "Running Pre-flight Checks"
    check_already_run
    check_root
    check_sudo
    check_internet
    check_disk_space
    
    print_success "All pre-flight checks passed"
    echo ""
    
    # Show countdown
    for i in {3..1}; do
        echo -ne "\r${CYAN}Starting in $i seconds... ${NC}"
        sleep 1
    done
    echo ""
    echo ""
    
    # Main installation
    print_header "Installing Development Tools"
    
    update_system
    install_core_dev
    install_yay
    install_editors
    install_containers
    configure_environment
    finalize_setup
    
    # Show summary
    show_summary
    
    log "=========================================="
    log "Setup completed successfully"
    log "=========================================="
    
    # Ask for reboot
    echo ""
    read -p "Reboot now? (recommended) [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Rebooting..."
        sudo reboot
    else
        print_warning "Please reboot manually to complete setup"
        print_info "Run: sudo reboot"
    fi
}

# Run main function
main "$@"