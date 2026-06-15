#!/bin/bash

################################################################################
# NuggetsSandbox.sh
# A comprehensive script to install VirtualBox, extension packs, and clone
# the NuggetsStarterKit repository
################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Nugget-The-Developer/NuggetsStarterKit.git"
SANDBOX_DIR="NuggetsStarterKit"
VBOX_VERSION="7.0"

################################################################################
# Helper Functions
################################################################################

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${PURPLE}=================================================================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}=================================================================================${NC}\n"
}

# Check if running with sudo
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo privileges!"
        echo "Usage: sudo bash NuggetsSandbox.sh"
        exit 1
    fi
    print_success "Sudo privileges verified"
}

# Check internet connection
check_internet() {
    print_info "Checking internet connection..."
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        print_success "Internet connection available"
        return 0
    else
        print_error "No internet connection detected"
        return 1
    fi
}

# Update system packages
update_system() {
    print_info "Updating system packages..."
    apt-get update -qq
    if [ $? -eq 0 ]; then
        print_success "System packages updated"
    else
        print_error "Failed to update system packages"
        return 1
    fi
}

################################################################################
# VirtualBox Installation
################################################################################

# Install VirtualBox dependencies
install_virtualbox_deps() {
    print_info "Installing VirtualBox dependencies..."
    
    local deps=(
        "build-essential"
        "dkms"
        "linux-headers-generic"
        "gcc"
        "make"
        "perl"
        "curl"
        "wget"
    )
    
    for dep in "${deps[@]}"; do
        apt-get install -y "$dep" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_success "$dep installed"
        else
            print_warning "Failed to install $dep (may already be installed)"
        fi
    done
}

# Add VirtualBox repository
add_virtualbox_repo() {
    print_info "Adding VirtualBox repository..."
    
    # Detect Ubuntu version
    ubuntu_version=$(lsb_release -sc)
    
    # Add VirtualBox GPG key
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - >/dev/null 2>&1
    
    # Add VirtualBox repository
    echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $ubuntu_version contrib" | \
        tee /etc/apt/sources.list.d/virtualbox.list >/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "VirtualBox repository added"
        apt-get update -qq
    else
        print_error "Failed to add VirtualBox repository"
        return 1
    fi
}

# Install VirtualBox
install_virtualbox() {
    print_section "Installing VirtualBox"
    
    print_info "Installing VirtualBox..."
    apt-get install -y virtualbox-7.0 >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "VirtualBox installed successfully"
        virtualbox -v
    else
        print_error "Failed to install VirtualBox"
        print_warning "Attempting alternative installation method..."
        apt-get install -y virtualbox >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_success "VirtualBox installed (generic version)"
        else
            print_error "Failed to install VirtualBox via alternative method"
            return 1
        fi
    fi
}

# Install VirtualBox Extension Pack
install_extension_pack() {
    print_section "Installing VirtualBox Extension Pack"
    
    print_info "Downloading VirtualBox Extension Pack..."
    
    local ext_pack_file="/tmp/Oracle_VM_VirtualBox_Extension_Pack.vbox-extpack"
    local ext_pack_url="https://download.virtualbox.org/virtualbox/7.0.20/Oracle_VM_VirtualBox_Extension_Pack-7.0.20.vbox-extpack"
    
    # Download the latest extension pack
    wget -q "$ext_pack_url" -O "$ext_pack_file"
    
    if [ -f "$ext_pack_file" ]; then
        print_success "Extension pack downloaded"
        print_info "Installing Extension Pack..."
        
        # Install extension pack (non-interactive)
        VBoxManage extpack install --replace "$ext_pack_file" >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            print_success "VirtualBox Extension Pack installed successfully"
        else
            print_warning "Extension Pack installation had issues, but VirtualBox is functional"
        fi
        
        # Cleanup
        rm -f "$ext_pack_file"
    else
        print_warning "Failed to download Extension Pack"
        print_info "You can install it manually later from: https://www.virtualbox.org/wiki/Downloads"
    fi
}

################################################################################
# Repository Setup
################################################################################

# Clone NuggetsStarterKit repository
clone_repository() {
    print_section "Cloning NuggetsStarterKit Repository"
    
    print_info "Cloning repository from: $REPO_URL"
    
    # Check if directory already exists
    if [ -d "$SANDBOX_DIR" ]; then
        print_warning "Directory $SANDBOX_DIR already exists"
        read -p "Do you want to remove it and clone fresh? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Removing existing directory..."
            rm -rf "$SANDBOX_DIR"
        else
            print_warning "Using existing directory"
            return 0
        fi
    fi
    
    git clone "$REPO_URL" "$SANDBOX_DIR"
    
    if [ $? -eq 0 ]; then
        print_success "Repository cloned successfully to ./$SANDBOX_DIR"
        cd "$SANDBOX_DIR"
        print_info "Repository contents:"
        ls -la
        cd ..
    else
        print_error "Failed to clone repository"
        return 1
    fi
}

################################################################################
# System Configuration
################################################################################

# Add current user to vboxusers group
configure_user_permissions() {
    print_section "Configuring User Permissions"
    
    # Get the user who ran sudo
    if [ -n "$SUDO_USER" ]; then
        print_info "Adding $SUDO_USER to vboxusers group..."
        usermod -aG vboxusers "$SUDO_USER"
        
        if [ $? -eq 0 ]; then
            print_success "User $SUDO_USER added to vboxusers group"
            print_warning "Note: User may need to log out and back in for group changes to take effect"
        else
            print_error "Failed to add user to vboxusers group"
        fi
    fi
}

# Install additional utilities
install_utilities() {
    print_section "Installing Additional Utilities"
    
    local utilities=(
        "net-tools"
        "openssh-client"
        "curl"
        "wget"
    )
    
    for util in "${utilities[@]}"; do
        apt-get install -y "$util" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_success "$util installed"
        else
            print_warning "Could not install $util"
        fi
    done
}

################################################################################
# Verification
################################################################################

# Verify installations
verify_installations() {
    print_section "Verifying Installations"
    
    print_info "Checking VirtualBox installation..."
    if command -v VBoxManage &> /dev/null; then
        vbox_version=$(VBoxManage --version)
        print_success "VirtualBox found: $vbox_version"
    else
        print_error "VirtualBox not found in PATH"
    fi
    
    print_info "Checking Git installation..."
    if command -v git &> /dev/null; then
        git_version=$(git --version)
        print_success "$git_version"
    else
        print_error "Git not found in PATH"
    fi
    
    print_info "Checking repository..."
    if [ -d "$SANDBOX_DIR" ]; then
        print_success "Repository directory found at ./$SANDBOX_DIR"
        print_info "Repository contents:"
        ls -la "$SANDBOX_DIR" | head -20
    else
        print_error "Repository directory not found"
    fi
}

################################################################################
# Display Summary
################################################################################

display_summary() {
    print_section "Installation Summary"
    
    cat << EOF
${GREEN}✓${NC} VirtualBox Installation Complete!

${BLUE}What was installed:${NC}
  • VirtualBox 7.0
  • VirtualBox Extension Pack
  • Required dependencies (build-essential, dkms, linux-headers)
  • NuggetsStarterKit repository (cloned to ./$SANDBOX_DIR)
  • Additional utilities (curl, wget, net-tools, ssh-client)

${BLUE}Quick Start Commands:${NC}
  • View VirtualBox version: VBoxManage --version
  • Start VirtualBox GUI: virtualbox
  • Access repository: cd $SANDBOX_DIR
  • Run installation tools: sudo bash $SANDBOX_DIR/install_tools.sh

${BLUE}Repository Location:${NC}
  ./$SANDBOX_DIR

${BLUE}Next Steps:${NC}
  1. Log out and back in for group permissions to take effect
  2. Launch VirtualBox: virtualbox
  3. Create a new virtual machine
  4. Install your preferred OS
  5. Use NuggetsStarterKit for development setup

${YELLOW}For more information:${NC}
  • VirtualBox Docs: https://www.virtualbox.org/wiki/Documentation
  • NuggetsStarterKit: https://github.com/Nugget-The-Developer/NuggetsStarterKit

EOF
}

################################################################################
# Error Handling
################################################################################

# Cleanup on error
cleanup_on_error() {
    print_error "Script encountered an error!"
    print_warning "Attempting to clean up..."
    # Add any cleanup logic here
}

trap cleanup_on_error ERR

################################################################################
# Main Execution
################################################################################

main() {
    clear
    
    # Print banner
    cat << "EOF"
    
    ╔════════════════════════════════════════════════════════════╗
    ║        Welcome to NuggetsSandbox Setup Script             ║
    ║                                                            ║
    ║   Installing VirtualBox, Extensions, and Repository      ║
    ╚════════════════════════════════════════════════════════════╝
    
EOF
    
    print_section "Pre-Installation Checks"
    
    # Run checks
    check_sudo || exit 1
    check_internet || exit 1
    update_system || exit 1
    
    # Install VirtualBox
    install_virtualbox_deps
    add_virtualbox_repo || print_warning "Could not add official repository, using default"
    install_virtualbox || exit 1
    install_extension_pack
    
    # Setup repository
    clone_repository || exit 1
    
    # Configure system
    configure_user_permissions
    install_utilities
    
    # Verify
    verify_installations
    
    # Display summary
    display_summary
    
    print_success "NuggetsSandbox setup completed successfully!"
    
}

# Run main function
main "$@"

exit $?
