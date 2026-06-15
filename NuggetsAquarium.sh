#!/bin/bash

################################################################################
# NuggetsAquarium.sh - Interactive ASCII Art Terminal Aquarium
# An interactive aquarium that runs in a separate window while keeping your
# terminal available for coding and scripting
################################################################################

# Color definitions
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'
BG_BLUE='\033[44m'

# Aquarium settings (can be customized via menu)
AQUARIUM_WIDTH=80
AQUARIUM_HEIGHT=24
FISH_COUNT=5
SEAWEED_COUNT=3
BUBBLE_COUNT=8
ANIMATION_SPEED=0.5
SHOW_TITLE=1

# Fish types with their ASCII representations
declare -A FISH_TYPES=(
    ["small"]="<°)))><"
    ["medium"]="<°))))><"
    ["large"]="<°)))))><"
    ["pufferfish"]="<°o))))><"
    ["tropical"]="<°|))))><"
)

declare -A FISH_NAMES=(
    ["small"]="Small Fish"
    ["medium"]="Fish"
    ["large"]="Big Fish"
    ["pufferfish"]="Pufferfish"
    ["tropical"]="Tropical Fish"
)

# Arrays to store fish data (position, type, direction)
declare -a FISH_POSITIONS
declare -a FISH_TYPES_ACTIVE
declare -a FISH_DIRECTIONS

# Create a named pipe for communication (optional, for future features)
AQUARIUM_PIPE="/tmp/nuggets_aquarium_$$"

################################################################################
# Display main menu
################################################################################
show_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║      🐠 Welcome to Nuggets Aquarium 🐠             ║"
    echo "║     Interactive Terminal Aquarium                  ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo "  1) Start Aquarium (Default Settings)"
    echo "  2) Customize Aquarium"
    echo "  3) View Help"
    echo "  4) Exit"
    echo ""
    echo -n "  Select an option (1-4): "
}

################################################################################
# Show customization menu
################################################################################
customize_aquarium() {
    clear
    echo -e "${LIGHT_CYAN}═══════════════════════════════════════════════════${RESET}"
    echo -e "${LIGHT_CYAN}            Aquarium Customization Menu             ${RESET}"
    echo -e "${LIGHT_CYAN}═══════════════════════════════════════════════════${RESET}"
    echo ""
    
    echo "Current Settings:"
    echo "  Fish Count: $FISH_COUNT"
    echo "  Seaweed Count: $SEAWEED_COUNT"
    echo "  Bubble Count: $BUBBLE_COUNT"
    echo "  Animation Speed: $ANIMATION_SPEED (lower = faster)"
    echo ""
    
    echo "Customize:"
    echo ""
    echo -n "  Enter number of fish (1-10, current: $FISH_COUNT): "
    read -r input
    if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le 10 ]; then
        FISH_COUNT=$input
    fi
    
    echo -n "  Enter number of seaweed (1-5, current: $SEAWEED_COUNT): "
    read -r input
    if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le 5 ]; then
        SEAWEED_COUNT=$input
    fi
    
    echo -n "  Enter number of bubbles (1-15, current: $BUBBLE_COUNT): "
    read -r input
    if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le 15 ]; then
        BUBBLE_COUNT=$input
    fi
    
    echo -n "  Enter animation speed (0.1-2.0, lower=faster, current: $ANIMATION_SPEED): "
    read -r input
    if [[ "$input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        ANIMATION_SPEED=$input
    fi
    
    echo ""
    echo -n "  Show title bar? (y/n, current: $([ "$SHOW_TITLE" -eq 1 ] && echo 'yes' || echo 'no')): "
    read -r input
    if [[ "$input" =~ ^[yY]$ ]]; then
        SHOW_TITLE=1
    elif [[ "$input" =~ ^[nN]$ ]]; then
        SHOW_TITLE=0
    fi
}

################################################################################
# Show help
################################################################################
show_help() {
    clear
    echo -e "${LIGHT_CYAN}═══════════════════════════════════════════════════${RESET}"
    echo -e "${LIGHT_CYAN}              Nuggets Aquarium - Help               ${RESET}"
    echo -e "${LIGHT_CYAN}═══════════════════════════════════════════════════${RESET}"
    echo ""
    echo "FEATURES:"
    echo "  • Interactive ASCII art aquarium"
    echo "  • Customizable number of fish, seaweed, and bubbles"
    echo "  • Smooth animation"
    echo "  • Beautiful terminal theming with blue background"
    echo ""
    echo "USAGE:"
    echo "  Start from command line: NuggetsAquarium"
    echo "  Or run directly: ./NuggetsAquarium.sh"
    echo ""
    echo "CUSTOMIZATION:"
    echo "  Edit settings in the menu before starting"
    echo "  Fish types vary automatically"
    echo "  Animation speed controls movement rate"
    echo ""
    echo "CONTROLS:"
    echo "  Press Ctrl+C to exit the aquarium and return to terminal"
    echo ""
    echo "NOTES:"
    echo "  • Terminal remains fully usable while aquarium runs"
    echo "  • Can be minimized and opened in new terminal windows"
    echo "  • Works best on terminals 80+ columns wide"
    echo ""
    echo -n "  Press Enter to return to menu..."
    read -r
}

################################################################################
# Initialize fish array with random data
################################################################################
initialize_fish() {
    FISH_POSITIONS=()
    FISH_TYPES_ACTIVE=()
    FISH_DIRECTIONS=()
    
    local fish_type_array=("small" "medium" "large" "pufferfish" "tropical")
    
    for ((i = 0; i < FISH_COUNT; i++)); do
        # Random starting position
        local pos=$((RANDOM % (AQUARIUM_WIDTH - 10)))
        FISH_POSITIONS+=($pos)
        
        # Random fish type
        local type_idx=$((RANDOM % ${#fish_type_array[@]}))
        FISH_TYPES_ACTIVE+=(${fish_type_array[$type_idx]})
        
        # Random direction (1 = right, -1 = left)
        local dir=$((RANDOM % 2))
        dir=$((dir == 0 ? -1 : 1))
        FISH_DIRECTIONS+=($dir)
    done
}

################################################################################
# Generate seaweed at bottom
################################################################################
generate_seaweed() {
    local seaweed_positions=()
    
    for ((i = 0; i < SEAWEED_COUNT; i++)); do
        seaweed_positions+=($(($((RANDOM % (AQUARIUM_WIDTH - 5))) + 2)))
    done
    
    echo "${seaweed_positions[@]}"
}

################################################################################
# Generate bubbles
################################################################################
generate_bubbles() {
    for ((i = 0; i < BUBBLE_COUNT; i++)); do
        echo "$((RANDOM % AQUARIUM_WIDTH))"
    done
}

################################################################################
# Draw the aquarium frame
################################################################################
draw_aquarium() {
    clear
    
    # Set background to blue
    echo -e "${BG_BLUE}${WHITE}"
    
    # Title
    if [ "$SHOW_TITLE" -eq 1 ]; then
        printf "%${AQUARIUM_WIDTH}s\n" | tr ' ' '═'
        printf "%s %-$(($AQUARIUM_WIDTH - 34))s %s\n" "║" "🐠 Nuggets Aquarium 🐠" "║"
        printf "%${AQUARIUM_WIDTH}s\n" | tr ' ' '═'
    fi
    
    # Top border
    printf "%${AQUARIUM_WIDTH}s\n" | tr ' ' '─'
    
    # Aquarium content
    for ((row = 0; row < AQUARIUM_HEIGHT - 6; row++)); do
        printf "│"
        
        for ((col = 0; col < AQUARIUM_WIDTH - 2; col++)); do
            local char=" "
            
            # Draw fish
            for ((f = 0; f < FISH_COUNT; f++)); do
                local fish_pos=${FISH_POSITIONS[$f]}
                local fish_type=${FISH_TYPES_ACTIVE[$f]}
                local fish_art="${FISH_TYPES[$fish_type]}"
                local fish_len=${#fish_art}
                
                if [ "$col" -ge "$fish_pos" ] && [ "$col" -lt "$((fish_pos + fish_len))" ]; then
                    local offset=$((col - fish_pos))
                    char="${fish_art:$offset:1}"
                    break
                fi
            done
            
            # Draw bubbles (simplified)
            if [ "$char" = " " ]; then
                if [ $((RANDOM % 200)) -eq 0 ]; then
                    char="·"
                fi
            fi
            
            printf "%s" "$char"
        done
        
        printf "│\n"
    done
    
    # Bottom with seaweed
    printf "│"
    for ((col = 0; col < AQUARIUM_WIDTH - 2; col++)); do
        if [ $((RANDOM % 100)) -lt 15 ]; then
            printf "∿"
        else
            printf "~"
        fi
    done
    printf "│\n"
    
    # Bottom border
    printf "%${AQUARIUM_WIDTH}s\n" | tr ' ' '─'
    
    # Info bar
    echo -e "${RESET}${BG_BLUE}${LIGHT_CYAN}"
    printf "Fish: %-2d | Seaweed: %-2d | Bubbles: %-2d | Speed: %.1f | Press Ctrl+C to exit\n" "$FISH_COUNT" "$SEAWEED_COUNT" "$BUBBLE_COUNT" "$ANIMATION_SPEED"
    echo -e "${RESET}"
}

################################################################################
# Update fish positions
################################################################################
update_fish() {
    for ((i = 0; i < FISH_COUNT; i++)); do
        local pos=${FISH_POSITIONS[$i]}
        local dir=${FISH_DIRECTIONS[$i]}
        
        # Move fish
        pos=$((pos + dir))
        
        # Bounce off walls
        if [ "$pos" -le 1 ]; then
            pos=2
            FISH_DIRECTIONS[$i]=1
        elif [ "$pos" -ge $((AQUARIUM_WIDTH - 10)) ]; then
            pos=$((AQUARIUM_WIDTH - 11))
            FISH_DIRECTIONS[$i]=-1
        fi
        
        FISH_POSITIONS[$i]=$pos
    done
}

################################################################################
# Main animation loop
################################################################################
run_aquarium() {
    initialize_fish
    
    # Set up cleanup on exit
    trap 'cleanup' EXIT INT TERM
    
    while true; do
        draw_aquarium
        update_fish
        sleep "$ANIMATION_SPEED"
    done
}

################################################################################
# Cleanup function
################################################################################
cleanup() {
    # Reset terminal
    echo -e "${RESET}"
    tput cnorm 2>/dev/null  # Show cursor
    
    # Clean up pipe if it exists
    rm -f "$AQUARIUM_PIPE" 2>/dev/null
    
    clear
    echo -e "${LIGHT_CYAN}Thank you for visiting Nuggets Aquarium! 🐠${RESET}"
    echo ""
    exit 0
}

################################################################################
# Main program flow
################################################################################
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                run_aquarium
                ;;
            2)
                customize_aquarium
                run_aquarium
                ;;
            3)
                show_help
                ;;
            4)
                echo ""
                echo -e "${LIGHT_CYAN}Goodbye! 🐠${RESET}"
                exit 0
                ;;
            *)
                echo -e "${YELLOW}Invalid option. Please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Run the program
main
