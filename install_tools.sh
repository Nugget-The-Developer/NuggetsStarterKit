#!/bin/bash

# Ubuntu 26 Noble - Basic Tools Installation Script
# This script installs essential development and system tools
# Run with: sudo bash install_tools.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run with sudo"
    exit 1
fi

log_info "Starting Ubuntu 26 Noble basic tools installation..."
log_info "Updating package manager..."

# Update package manager
apt update
apt upgrade -y

log_info "Package manager updated successfully"

# Array of tools to install
tools=(
    "curl"
    "git"
    "wget"
    "build-essential"
    "nano"
    "htop"
    "tmux"
    "openssh-client"
    "apt-utils"
    "ca-certificates"
    "aptitude"
    "python3"
    "python3-pip"
    "fish"
    "kdeconnect"
)

# Track installation results
installed=0
failed=0

log_info "Installing essential tools..."
echo "=================================================="

# Install each tool with error handling
for tool in "${tools[@]}"; do
    if apt install -y "$tool" 2>/dev/null; then
        log_info "✓ $tool installed successfully"
        ((installed++))
    else
        log_warn "✗ Failed to install $tool (package may not exist or error occurred)"
        ((failed++))
    fi
done

echo "=================================================="
log_info "Installation complete!"
log_info "Successfully installed: $installed tools"

if [ $failed -gt 0 ]; then
    log_warn "Failed to install: $failed tools"
fi

# ASCII Art Completion Message
echo ""
echo -e "${BLUE}"
cat << "EOF"
  ╔═══════════════════════════════════════════╗
  ║                                           ║
  ║   ✓ Ubuntu 26 Noble Setup Complete! ✓    ║
  ║                                           ║
  ║         Your system is ready to go!       ║
  ║                                           ║
  ║    ████████╗ ██████╗  ██████╗ ██╗███████╗║
  ║    ╚══██╔══╝██╔═══██╗██╔═══██╗██║██╔════╝║
  ║       ██║   ██║   ██║██║   ██║██║███████╗║
  ║       ██║   ██║   ██║██║   ██║██║╚════██║║
  ║       ██║   ╚██████╔╝╚██████╔╝██║███████║║
  ║       ╚═╝    ╚═════╝  ╚═════╝ ╚═╝╚══════╝║
  ║                                           ║
  ║     Ready for development! Happy coding   ║
  ║                                           ║
  ╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "All available tools have been installed"
log_info "You can now use: curl, git, wget, nano, htop, tmux, python3, pip, fish, kdeconnect, aptitude, and more"

exit 0