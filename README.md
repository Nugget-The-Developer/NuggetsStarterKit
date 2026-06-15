# NuggetsStarterKit

A comprehensive Ubuntu 26 Noble setup script that installs essential development and system tools in one command.

![Status](https://img.shields.io/badge/status-active-success.svg)
![Ubuntu](https://img.shields.io/badge/Ubuntu-26%20Noble-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🚀 Quick Start

```bash
git clone https://github.com/Nugget-The-Developer/NuggetsStarterKit.git
cd NuggetsStarterKit
sudo bash install_tools.sh
```

## 📦 Tools Installed

### Development Tools
- **git** - Version control system
- **python3** - Python runtime environment
- **python3-pip** - Python package manager
- **build-essential** - Compilers and build utilities

### Shell & Terminal
- **fish** - User-friendly shell with enhanced autocompletion
- **tmux** - Terminal multiplexer for managing multiple sessions
- **nano** - Simple text editor

### System Utilities
- **curl** - Command-line tool for downloading files and making API requests
- **wget** - Alternative downloader for files
- **htop** - Interactive system process monitor
- **aptitude** - Advanced package manager
- **apt-utils** - APT utilities and tools
- **openssh-client** - SSH client for remote connections
- **ca-certificates** - SSL/TLS certificate authority bundle

### Mobile Integration
- **kdeconnect** - Connect your phone to your desktop for:
  - File sharing
  - Notification syncing
  - Remote input control
  - And much more!

## ✨ Features

- ✅ **Automatic Updates** - Updates package manager before installing tools
- ✅ **Error Handling** - Continues installation even if some tools fail
- ✅ **Color-Coded Output** - Easy-to-read installation feedback
- ✅ **Progress Tracking** - Shows how many tools succeeded/failed
- ✅ **ASCII Art** - Celebratory completion message
- ✅ **Sudo Check** - Verifies sudo privileges before running
- ✅ **Fast & Reliable** - Optimized for Ubuntu 26 Noble

## 📋 Requirements

- Ubuntu 26 Noble (Oracular Oriole)
- sudo privileges
- Internet connection

## 🔧 Usage

Simply run the script with sudo:

```bash
sudo bash install_tools.sh
```

The script will:
1. Check for sudo privileges
2. Update your package manager
3. Install all tools with progress feedback
4. Display a completion message

## 🎯 What You Can Do After Installation

After running this script, you'll be ready to:
- Develop with Python
- Manage version control with Git
- Use an enhanced shell experience with Fish
- Monitor system performance with htop
- Connect your phone with KDE Connect
- Use advanced terminal sessions with tmux
- And much more!

## 📝 Example: Switching to Fish Shell

After installation, you can switch to the Fish shell:

```bash
fish
```

Or set it as your default shell:

```bash
chsh -s /usr/bin/fish
```

## 📱 KDE Connect Setup

To use KDE Connect:

1. **On your desktop:** Launch KDE Connect
2. **On your phone:** Install KDE Connect from your app store
3. **Connect:** Both devices will auto-discover each other on the same network

## 🐛 Troubleshooting

If a tool fails to install:
- The script will continue installing other tools
- Check your internet connection
- Some packages may not be available in your region

To see which tools were installed:
```bash
which git python3 fish tmux curl wget
```

## 📄 License

MIT License - Feel free to use and modify this script

## 👤 Author

Created by Nugget-The-Developer

## 🤝 Contributing

Feel free to fork, modify, and submit pull requests!

## 💬 Support

If you encounter any issues:
1. Check that you're using Ubuntu 26 Noble
2. Ensure you have sudo privileges
3. Run the script with a stable internet connection
4. Open an issue on GitHub if problems persist

---

**Happy coding! 🎉**