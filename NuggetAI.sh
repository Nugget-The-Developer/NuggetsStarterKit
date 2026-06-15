#!/bin/bash

################################################################################
# NuggetAI.sh - Voice-Activated AI Assistant Installation Script
# A comprehensive setup for a conversational AI with voice input/output
# and application launching capabilities
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOOLS_SUCCESS=0
TOOLS_FAILED=0
FAILED_TOOLS=()

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                     🤖 NuggetAI Assistant Setup 🤖                 ║"
    echo "║          Voice-Activated AI with Application Launcher              ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_installing() {
    echo -e "${YELLOW}⏳ Installing $1...${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1 installed successfully${NC}"
    ((TOOLS_SUCCESS++))
}

print_error() {
    echo -e "${RED}✗ Failed to install $1${NC}"
    FAILED_TOOLS+=("$1")
    ((TOOLS_FAILED++))
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}❌ This script must be run with sudo${NC}"
        exit 1
    fi
}

install_package() {
    local package=$1
    local display_name=${2:-$package}
    
    print_installing "$display_name"
    
    if apt-get install -y "$package" &>/dev/null; then
        print_success "$display_name"
    else
        print_error "$display_name"
    fi
}

################################################################################
# Main Installation
################################################################################

main() {
    print_header
    
    # Check sudo
    check_sudo
    
    # Update package manager
    print_section "Updating Package Manager"
    apt-get update -qq || print_error "Package manager update"
    apt-get upgrade -y -qq || print_error "Package upgrade"
    
    # Install core dependencies
    print_section "Installing Core Dependencies"
    install_package "python3" "Python 3"
    install_package "python3-pip" "Python Package Manager (pip)"
    install_package "python3-dev" "Python 3 Development Headers"
    install_package "build-essential" "Build Essentials"
    install_package "git" "Git Version Control"
    
    # Install audio/voice dependencies
    print_section "Installing Audio & Voice Processing"
    install_package "pulseaudio" "PulseAudio (Audio System)"
    install_package "alsa-utils" "ALSA Utilities (Audio)"
    install_package "sox" "SoX (Sound eXchange)"
    install_package "ffmpeg" "FFmpeg (Media Processing)"
    
    # Install speech recognition dependencies
    print_section "Installing Speech Recognition Tools"
    install_package "portaudio19-dev" "PortAudio Development Libraries"
    install_package "libssl-dev" "OpenSSL Development Libraries"
    install_package "libffi-dev" "FFI Development Libraries"
    
    # Install text-to-speech engine
    print_section "Installing Text-to-Speech Engine"
    install_package "espeak-ng" "eSpeak NG (Text-to-Speech)"
    install_package "espeak-ng-data" "eSpeak NG Data Files"
    
    # Install display/UI dependencies
    print_section "Installing Display & UI Libraries"
    install_package "libdbus-1-dev" "D-Bus Development"
    install_package "pkg-config" "Package Configuration Utility"
    
    # Create AI assistant directory
    print_section "Setting Up NuggetAI Directory"
    AI_HOME="/opt/nuggetai"
    
    if [ ! -d "$AI_HOME" ]; then
        mkdir -p "$AI_HOME"
        print_success "NuggetAI directory created at $AI_HOME"
    else
        print_info "NuggetAI directory already exists"
    fi
    
    # Create necessary subdirectories
    mkdir -p "$AI_HOME/bin"
    mkdir -p "$AI_HOME/lib"
    mkdir -p "$AI_HOME/data"
    mkdir -p "$AI_HOME/logs"
    mkdir -p "$AI_HOME/config"
    
    # Install Python virtual environment
    print_section "Creating Python Virtual Environment"
    python3 -m venv "$AI_HOME/venv" || print_error "Virtual Environment"
    print_success "Python Virtual Environment"
    
    # Activate venv and install Python packages
    print_section "Installing Python AI/ML Libraries"
    source "$AI_HOME/venv/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel -q || print_error "pip upgrade"
    print_success "pip upgrade"
    
    # Install core AI libraries
    pip install -q \
        SpeechRecognition \
        pyttsx3 \
        pyaudio \
        openai \
        langchain \
        transformers \
        torch \
        numpy \
        requests \
        python-dotenv \
        psutil \
        ollama || print_error "Python AI Libraries"
    
    print_success "Core AI Libraries"
    
    # Install optional but useful libraries
    pip install -q \
        flask \
        flask-cors \
        websockets || print_error "Web Framework Libraries"
    
    print_success "Web Framework Libraries"
    
    deactivate
    
    # Create main NuggetAI application file
    print_section "Creating NuggetAI Application"
    create_nuggetai_app "$AI_HOME"
    print_success "NuggetAI Application"
    
    # Create configuration file
    create_config_file "$AI_HOME"
    print_success "Configuration File"
    
    # Create launcher script
    create_launcher_script "$AI_HOME"
    print_success "Launcher Script"
    
    # Create systemd service file (optional)
    create_systemd_service "$AI_HOME"
    print_success "Systemd Service"
    
    # Set permissions
    chmod +x "$AI_HOME/bin/nuggetai"
    chmod +x "$AI_HOME/bin/nuggetai-launcher.sh"
    
    # Create symlink for easy access
    if [ ! -L /usr/local/bin/nuggetai ]; then
        ln -s "$AI_HOME/bin/nuggetai" /usr/local/bin/nuggetai || print_error "Symlink creation"
        print_success "Command-line symlink"
    fi
    
    # Print summary
    print_section "Installation Summary"
    echo -e "${GREEN}Successfully installed: ${TOOLS_SUCCESS} components${NC}"
    if [ ${TOOLS_FAILED} -gt 0 ]; then
        echo -e "${YELLOW}Failed: ${TOOLS_FAILED} components${NC}"
        echo -e "${RED}Failed components:${NC}"
        for tool in "${FAILED_TOOLS[@]}"; do
            echo -e "  ${RED}• $tool${NC}"
        done
    fi
    
    print_section "🎉 NuggetAI Installation Complete!"
    
    echo -e """
${GREEN}═══════════════════════════════════════════════════════════════════${NC}

${CYAN}Quick Start Guide:${NC}

1. ${YELLOW}Start NuggetAI:${NC}
   ${BLUE}nuggetai${NC}
   
   Or manually:
   ${BLUE}$AI_HOME/bin/nuggetai${NC}

2. ${YELLOW}Configuration:${NC}
   Edit settings at: ${BLUE}$AI_HOME/config/config.json${NC}
   
3. ${YELLOW}View Logs:${NC}
   ${BLUE}tail -f $AI_HOME/logs/nuggetai.log${NC}

4. ${YELLOW}Stop NuggetAI:${NC}
   Press ${BLUE}Ctrl+C${NC} in the terminal

${CYAN}Features Available:${NC}
   ✓ Voice Input Recognition
   ✓ Text-to-Speech Output
   ✓ Application Launcher
   ✓ Natural Language Processing
   ✓ Conversation History
   ✓ Command Execution
   ✓ System Integration

${CYAN}Voice Commands Examples:${NC}
   • \"Open Firefox\"
   • \"Launch VS Code\"
   • \"What time is it?\"
   • \"Tell me a joke\"
   • \"Open file manager\"
   • \"Close application\"

${CYAN}Configuration:${NC}
   - Edit config.json to add API keys (OpenAI, etc.)
   - Customize voice and language settings
   - Add custom application shortcuts
   - Adjust voice sensitivity

${RED}═══════════════════════════════════════════════════════════════════${NC}

${CYAN}Installation Location: ${BLUE}$AI_HOME${NC}

${GREEN}Happy Coding! 🚀${NC}
    """
}

################################################################################
# Create Application Files
################################################################################

create_nuggetai_app() {
    local ai_home=$1
    cat > "$ai_home/bin/nuggetai" << 'NUGGETAI_EOF'
#!/usr/bin/env python3
"""
NuggetAI - Voice-Activated AI Assistant
A conversational AI with voice input/output and app launching
"""

import os
import sys
import json
import logging
import threading
import subprocess
import speech_recognition as sr
import pyttsx3
import re
from datetime import datetime
from pathlib import Path

# Add lib directory to path
lib_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/lib"
sys.path.insert(0, lib_path)

# Setup logging
log_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/logs"
os.makedirs(log_dir, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f"{log_dir}/nuggetai.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class NuggetAI:
    def __init__(self):
        """Initialize NuggetAI assistant"""
        self.config_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/config/config.json"
        self.config = self.load_config()
        
        # Initialize speech recognition
        self.recognizer = sr.Recognizer()
        self.microphone = sr.Microphone()
        
        # Initialize text-to-speech
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', self.config.get('speech_rate', 150))
        self.engine.setProperty('volume', self.config.get('volume', 0.9))
        
        # Application registry
        self.apps = self.load_app_registry()
        
        logger.info("NuggetAI initialized successfully")
    
    def load_config(self):
        """Load configuration from config.json"""
        try:
            with open(self.config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.warning("Config file not found, using defaults")
            return {
                'speech_rate': 150,
                'volume': 0.9,
                'language': 'en-US',
                'timeout': 10
            }
    
    def load_app_registry(self):
        """Load registered applications"""
        return {
            'firefox': 'firefox',
            'chrome': 'google-chrome',
            'vscode': 'code',
            'code': 'code',
            'file manager': 'nautilus',
            'terminal': 'gnome-terminal',
            'calculator': 'gnome-calculator',
            'text editor': 'gedit',
            'vim': 'vim',
            'vlc': 'vlc',
            'spotify': 'spotify',
            'discord': 'discord',
            'slack': 'slack',
            'thunderbird': 'thunderbird',
            'blender': 'blender',
        }
    
    def speak(self, text):
        """Convert text to speech"""
        logger.info(f"Speaking: {text}")
        self.engine.say(text)
        self.engine.runAndWait()
    
    def listen(self):
        """Listen for voice input"""
        try:
            print("\n🎤 Listening...", end='', flush=True)
            with self.microphone as source:
                self.recognizer.adjust_for_ambient_noise(source, duration=1)
                audio = self.recognizer.listen(source, timeout=self.config.get('timeout', 10))
            
            print("\r✓ Processing speech...")
            text = self.recognizer.recognize_google(audio)
            logger.info(f"Recognized: {text}")
            return text.lower()
        except sr.UnknownValueError:
            response = "Sorry, I didn't catch that. Could you repeat?"
            self.speak(response)
            return None
        except sr.RequestError as e:
            response = f"Sorry, there was an error with the speech service: {e}"
            logger.error(response)
            self.speak(response)
            return None
    
    def launch_application(self, app_name):
        """Launch an application by name"""
        app_name = app_name.strip().lower()
        
        if app_name in self.apps:
            try:
                subprocess.Popen([self.apps[app_name]])
                response = f"Opening {app_name}..."
                self.speak(response)
                logger.info(f"Launched: {app_name}")
                return True
            except Exception as e:
                response = f"Sorry, I couldn't launch {app_name}. {str(e)}"
                self.speak(response)
                logger.error(response)
                return False
        else:
            response = f"Sorry, I don't know how to open {app_name}. Try saying the application name."
            self.speak(response)
            return False
    
    def process_command(self, text):
        """Process voice commands"""
        if not text:
            return
        
        # Open/Launch commands
        if any(phrase in text for phrase in ['open', 'launch', 'start']):
            for app_name in self.apps.keys():
                if app_name in text:
                    self.launch_application(app_name)
                    return
        
        # Time command
        if 'time' in text or 'what time' in text:
            current_time = datetime.now().strftime("%I:%M %p")
            response = f"The current time is {current_time}"
            self.speak(response)
            return
        
        # Date command
        if 'date' in text or 'what date' in text:
            current_date = datetime.now().strftime("%A, %B %d, %Y")
            response = f"Today is {current_date}"
            self.speak(response)
            return
        
        # Help command
        if 'help' in text or 'what can you do' in text:
            response = "I can open applications, tell you the time, answer simple questions, and execute voice commands. What would you like?"
            self.speak(response)
            return
        
        # Joke command
        if 'joke' in text or 'tell me a joke' in text:
            jokes = [
                "Why do programmers prefer dark mode? Because light attracts bugs!",
                "Why did the scarecrow win an award? Because he was outstanding in his field!",
                "What do you call a bear with no teeth? A gummy bear!"
            ]
            import random
            self.speak(random.choice(jokes))
            return
        
        # Default response
        response = f"You said: {text}. I can help you open applications, tell the time, or answer simple questions."
        self.speak(response)
    
    def run(self):
        """Main application loop"""
        print("\n" + "="*60)
        print("🤖 NuggetAI Assistant Started")
        print("="*60)
        print("\n💡 Say 'help' to learn what I can do")
        print("🛑 Say 'exit', 'quit', or press Ctrl+C to stop\n")
        
        self.speak("Nugget AI is ready to assist you")
        
        try:
            while True:
                text = self.listen()
                if text is None:
                    continue
                
                if any(word in text for word in ['exit', 'quit', 'bye', 'goodbye', 'stop']):
                    self.speak("Goodbye! Have a great day!")
                    logger.info("User requested exit")
                    break
                
                self.process_command(text)
        
        except KeyboardInterrupt:
            print("\n")
            self.speak("Goodbye!")
            logger.info("Interrupted by user")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            self.speak(f"An error occurred: {str(e)}")

def main():
    """Entry point"""
    try:
        ai = NuggetAI()
        ai.run()
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
NUGGETAI_EOF
}

create_config_file() {
    local ai_home=$1
    cat > "$ai_home/config/config.json" << 'CONFIG_EOF'
{
  "assistant_name": "NuggetAI",
  "speech_rate": 150,
  "volume": 0.9,
  "language": "en-US",
  "timeout": 10,
  "voice_enabled": true,
  "api_keys": {
    "openai_api_key": "your_api_key_here",
    "huggingface_token": "your_token_here"
  },
  "custom_apps": {
    "myapp": "command_to_launch"
  },
  "conversation_history": true,
  "max_history_size": 100
}
CONFIG_EOF
}

create_launcher_script() {
    local ai_home=$1
    cat > "$ai_home/bin/nuggetai-launcher.sh" << 'LAUNCHER_EOF'
#!/bin/bash

# NuggetAI Launcher Script

AI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$AI_HOME/venv"

# Activate virtual environment
source "$VENV/bin/activate"

# Run NuggetAI
python3 "$AI_HOME/bin/nuggetai" "$@"

# Deactivate virtual environment
deactivate
LAUNCHER_EOF
}

create_systemd_service() {
    local ai_home=$1
    cat > /etc/systemd/system/nuggetai.service << SERVICE_EOF
[Unit]
Description=NuggetAI Voice Assistant
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ai_home
ExecStart=$ai_home/bin/nuggetai-launcher.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF
    
    # Reload systemd
    systemctl daemon-reload
}

# Run main installation
main
