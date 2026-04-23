#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE - Activate Python Virtual Environments with Style       │
# │  https://github.com/yourusername/arise                         │
# └─────────────────────────────────────────────────────────────────┘

# Configuration
ARISE_CONFIG_DIR="${HOME}/.config/arise"
ARISE_CONFIG_FILE="${ARISE_CONFIG_DIR}/config"
ARISE_DEFAULT_EFFECT="zone"
ARISE_DEFAULT_VENV_DIR=".venv"

# Color definitions
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[34m"
C_MAGENTA="\e[35m"
C_CYAN="\e[36m"
C_WHITE="\e[37m"
C_GRAY="\e[38;5;242m"
C_BOLD="\e[1m"

# ─────────────────────────────────────────────────────────────────
# EFFECT: Zone (Original) - Horizontal line expansion with flash
# ─────────────────────────────────────────────────────────────────
effect_zone() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))

    # Ignition - Rapid horizontal line expansion
    for ((i=1; i<=cols/2; i+=5)); do
        tput cup $mid $((cols/2 - i))
        printf "\e[48;5;51m%$(($i*2))s\e[0m" " "
        sleep 0.003
    done

    # Neural Flash
    printf "\e[?5h"; sleep 0.04; printf "\e[?5l"

    # Centered "Zone" Text with flicker
    tput cup $mid $(( (cols - 22) / 2 ))
    echo -e "\e[1;37;40m  ENTERING THE ZONE  \e[0m"
    sleep 0.1
    tput cup $mid $(( (cols - 22) / 2 ))
    echo -e "\e[1;30;107m  ENTERING THE ZONE  \e[0m"
    sleep 0.5

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Matrix - Digital rain cascade
# ─────────────────────────────────────────────────────────────────
effect_matrix() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    chars="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン01"
    
    # Rain effect
    for ((frame=0; frame<15; frame++)); do
        for ((col=0; col<cols; col+=3)); do
            row=$((RANDOM % lines))
            char="${chars:$((RANDOM % ${#chars})):1}"
            tput cup $row $col
            if ((RANDOM % 3 == 0)); then
                printf "\e[1;97m%s\e[0m" "$char"  # Bright white
            else
                printf "\e[32m%s\e[0m" "$char"    # Green
            fi
        done
        sleep 0.05
    done
    
    # Flash and reveal
    clear
    mid=$((lines / 2))
    text="◤ SYSTEM ACTIVATED ◢"
    tput cup $mid $(( (cols - ${#text}) / 2 ))
    echo -e "\e[1;32m${text}\e[0m"
    sleep 0.6

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Pulse - Concentric circle pulse from center
# ─────────────────────────────────────────────────────────────────
effect_pulse() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    cx=$((cols / 2))
    cy=$((lines / 2))

    # Expanding rings
    for ((r=1; r<=$((cols/3)); r+=2)); do
        for ((angle=0; angle<360; angle+=15)); do
            x=$(echo "scale=0; $cx + $r * c($angle * 3.14159 / 180)" | bc -l 2>/dev/null || echo $cx)
            y=$(echo "scale=0; $cy + ($r/2) * s($angle * 3.14159 / 180)" | bc -l 2>/dev/null || echo $cy)
            x=${x%.*}
            y=${y%.*}
            if ((x >= 0 && x < cols && y >= 0 && y < lines)); then
                tput cup $y $x
                printf "\e[38;5;$((51 + r % 5))m●\e[0m"
            fi
        done
        sleep 0.02
    done

    # Center text
    clear
    tput cup $cy $(( (cols - 16) / 2 ))
    echo -e "\e[1;96m◉ ZONE LOCKED ◉\e[0m"
    sleep 0.5

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Glitch - Corrupted screen effect
# ─────────────────────────────────────────────────────────────────
effect_glitch() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))
    glitch_chars="█▓▒░╔╗╚╝║═╬┼├┤┬┴"

    # Glitch frames
    for ((frame=0; frame<8; frame++)); do
        # Random glitch blocks
        for ((i=0; i<20; i++)); do
            x=$((RANDOM % cols))
            y=$((RANDOM % lines))
            w=$((RANDOM % 15 + 5))
            color=$((RANDOM % 7 + 31))
            tput cup $y $x
            for ((j=0; j<w && x+j<cols; j++)); do
                char="${glitch_chars:$((RANDOM % ${#glitch_chars})):1}"
                printf "\e[${color}m%s\e[0m" "$char"
            done
        done
        sleep 0.05
        
        # Flash
        if ((frame % 2 == 0)); then
            printf "\e[?5h"; sleep 0.02; printf "\e[?5l"
        fi
    done

    clear
    # Stabilize with message
    tput cup $mid $(( (cols - 24) / 2 ))
    echo -e "\e[1;33m▌▌ SIGNAL STABILIZED ▐▐\e[0m"
    sleep 0.4

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Minimal - Clean, professional fade-in
# ─────────────────────────────────────────────────────────────────
effect_minimal() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))
    text="▸ activated"

    # Fade in effect using grayscale
    for shade in 236 240 244 248 252 255; do
        tput cup $mid $(( (cols - ${#text}) / 2 ))
        printf "\e[38;5;${shade}m%s\e[0m" "$text"
        sleep 0.06
    done
    sleep 0.3

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Cyber - Cyberpunk-style boot sequence
# ─────────────────────────────────────────────────────────────────
effect_cyber() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    
    boot_msgs=(
        "[SYS] Initializing neural interface..."
        "[NET] Establishing secure tunnel..."
        "[ENV] Loading virtual environment..."
        "[ACK] Environment synchronized"
        "[RDY] ACCESS GRANTED"
    )

    row=2
    for msg in "${boot_msgs[@]}"; do
        tput cup $row 2
        # Type effect
        for ((i=0; i<${#msg}; i++)); do
            char="${msg:$i:1}"
            if [[ "$msg" == *"ACCESS GRANTED"* ]]; then
                printf "\e[1;35m%s\e[0m" "$char"
            elif [[ "$char" == "[" ]] || [[ "$char" == "]" ]]; then
                printf "\e[36m%s\e[0m" "$char"
            else
                printf "\e[38;5;219m%s\e[0m" "$char"
            fi
            sleep 0.008
        done
        echo
        ((row++))
        sleep 0.1
    done

    sleep 0.4
    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Warp - Star warp speed effect
# ─────────────────────────────────────────────────────────────────
effect_warp() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    cx=$((cols / 2))
    cy=$((lines / 2))

    # Star positions (from center)
    for ((frame=0; frame<20; frame++)); do
        for ((star=0; star<30; star++)); do
            # Random angle and distance from center
            angle=$((RANDOM % 360))
            dist=$((frame * 2 + RANDOM % 3))
            
            x=$(echo "scale=0; $cx + $dist * c($angle * 3.14159 / 180)" | bc -l 2>/dev/null || echo $cx)
            y=$(echo "scale=0; $cy + ($dist/2) * s($angle * 3.14159 / 180)" | bc -l 2>/dev/null || echo $cy)
            x=${x%.*}
            y=${y%.*}
            
            if ((x >= 0 && x < cols && y >= 0 && y < lines)); then
                tput cup $y $x
                if ((dist > 15)); then
                    printf "\e[1;97m─\e[0m"
                elif ((dist > 8)); then
                    printf "\e[37m•\e[0m"
                else
                    printf "\e[90m·\e[0m"
                fi
            fi
        done
        sleep 0.03
    done

    clear
    tput cup $cy $(( (cols - 18) / 2 ))
    echo -e "\e[1;97m★ DESTINATION: DEV ★\e[0m"
    sleep 0.4

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Neon - Neon sign flicker
# ─────────────────────────────────────────────────────────────────
effect_neon() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))
    
    text="◈ ARISE ◈"
    pos=$(( (cols - ${#text}) / 2 ))

    # Neon flicker effect
    colors=(196 201 51 46 226)  # Red, Magenta, Cyan, Green, Yellow
    
    for ((flicker=0; flicker<12; flicker++)); do
        color=${colors[$((RANDOM % ${#colors[@]}))]}
        tput cup $mid $pos
        
        if ((RANDOM % 4 == 0)); then
            # Off state
            printf "\e[38;5;236m%s\e[0m" "$text"
        else
            # On state with glow
            printf "\e[1;38;5;${color}m%s\e[0m" "$text"
        fi
        sleep 0.08
    done

    # Final stable state
    tput cup $mid $pos
    printf "\e[1;38;5;51m%s\e[0m" "$text"
    sleep 0.4

    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Scanline - Retro CRT scanline
# ─────────────────────────────────────────────────────────────────
effect_scanline() {
    tput smcup
    tput civis
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))

    # Scanline sweep
    for ((y=0; y<lines; y++)); do
        tput cup $y 0
        printf "\e[42m%${cols}s\e[0m" " "
        sleep 0.015
        tput cup $y 0
        printf "%${cols}s" " "
    done

    # Reveal text with CRT effect
    text="[ ONLINE ]"
    tput cup $mid $(( (cols - ${#text}) / 2 ))
    echo -e "\e[1;32m${text}\e[0m"
    
    # Add scanline overlay feel
    for ((y=0; y<lines; y+=2)); do
        tput cup $y 0
        printf "\e[38;5;22m"
        for ((x=0; x<cols; x+=2)); do
            printf "░"
        done
        printf "\e[0m"
    done
    
    sleep 0.5
    tput rmcup
    tput cnorm
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: None - No animation, instant activation
# ─────────────────────────────────────────────────────────────────
effect_none() {
    : # Do nothing
}

# ─────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────

# Load configuration
load_config() {
    if [[ -f "$ARISE_CONFIG_FILE" ]]; then
        source "$ARISE_CONFIG_FILE"
    fi
    ARISE_EFFECT="${ARISE_EFFECT:-$ARISE_DEFAULT_EFFECT}"
}

# Save configuration
save_config() {
    mkdir -p "$ARISE_CONFIG_DIR"
    echo "ARISE_EFFECT=\"$ARISE_EFFECT\"" > "$ARISE_CONFIG_FILE"
}

# Find first available virtual environment activation script
resolve_venv_path() {
    local candidate

    for candidate in ".venv" "venv" "env" ".env"; do
        if [[ -f "./${candidate}/bin/activate" ]]; then
            echo "./${candidate}/bin/activate"
            return 0
        fi
    done

    return 1
}

# Create a virtual environment in current directory
create_venv() {
    local target_dir="${1:-$ARISE_DEFAULT_VENV_DIR}"
    local python_cmd

    if [[ -f "./${target_dir}/bin/activate" ]]; then
        echo -e "${C_YELLOW}!${C_RESET} Virtual environment already exists: ${C_CYAN}${target_dir}${C_RESET}"
        return 0
    fi

    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        echo -e "${C_RED}✗${C_RESET} Python not found (requires python3 or python)"
        return 1
    fi

    echo -e "${C_CYAN}→${C_RESET} Creating virtual environment: ${C_CYAN}${target_dir}${C_RESET}"
    "$python_cmd" -m venv "$target_dir"

    if [[ ! -f "./${target_dir}/bin/activate" ]]; then
        echo -e "${C_RED}✗${C_RESET} Failed to create virtual environment in ${target_dir}"
        return 1
    fi

    echo -e "${C_GREEN}✓${C_RESET} Created virtual environment: ${C_CYAN}${target_dir}${C_RESET}"
}

# List available effects
list_effects() {
    echo -e "${C_CYAN}${C_BOLD}Available Effects:${C_RESET}\n"
    echo -e "  ${C_WHITE}zone${C_RESET}      - ${C_GRAY}Horizontal ignition with neural flash (default)${C_RESET}"
    echo -e "  ${C_WHITE}matrix${C_RESET}    - ${C_GRAY}Digital rain cascade${C_RESET}"
    echo -e "  ${C_WHITE}pulse${C_RESET}     - ${C_GRAY}Concentric circle expansion${C_RESET}"
    echo -e "  ${C_WHITE}glitch${C_RESET}    - ${C_GRAY}Corrupted screen effect${C_RESET}"
    echo -e "  ${C_WHITE}minimal${C_RESET}   - ${C_GRAY}Clean fade-in${C_RESET}"
    echo -e "  ${C_WHITE}cyber${C_RESET}     - ${C_GRAY}Cyberpunk boot sequence${C_RESET}"
    echo -e "  ${C_WHITE}warp${C_RESET}      - ${C_GRAY}Star warp speed${C_RESET}"
    echo -e "  ${C_WHITE}neon${C_RESET}      - ${C_GRAY}Neon sign flicker${C_RESET}"
    echo -e "  ${C_WHITE}scanline${C_RESET}  - ${C_GRAY}Retro CRT scanline${C_RESET}"
    echo -e "  ${C_WHITE}none${C_RESET}      - ${C_GRAY}No animation${C_RESET}"
}

# Set effect
set_effect() {
    local effect="$1"
    local valid_effects="zone matrix pulse glitch minimal cyber warp neon scanline none"
    
    if [[ " $valid_effects " =~ " $effect " ]]; then
        ARISE_EFFECT="$effect"
        save_config
        echo -e "${C_GREEN}✓${C_RESET} Effect set to: ${C_CYAN}${effect}${C_RESET}"
    else
        echo -e "${C_RED}✗${C_RESET} Unknown effect: ${effect}"
        echo -e "  Run ${C_CYAN}arise --list${C_RESET} to see available effects"
        return 1
    fi
}

# Preview effect
preview_effect() {
    local effect="${1:-$ARISE_EFFECT}"
    local func="effect_${effect}"
    
    if declare -f "$func" > /dev/null; then
        $func
        echo -e "\n${C_GRAY}Previewed effect: ${C_CYAN}${effect}${C_RESET}"
    else
        echo -e "${C_RED}✗${C_RESET} Unknown effect: ${effect}"
        return 1
    fi
}

# Show help
show_help() {
    echo -e "${C_CYAN}${C_BOLD}"
    echo "    ___    ____  _________ ______"
    echo "   /   |  / __ \/  _/ ___// ____/"
    echo "  / /| | / /_/ // / \__ \/ __/   "
    echo " / ___ |/ _, _// / ___/ / /___   "
    echo "/_/  |_/_/ |_/___//____/_____/   "
    echo -e "${C_RESET}"
    echo -e "${C_GRAY}Activate Python virtual environments with style${C_RESET}\n"
    
    echo -e "${C_BOLD}USAGE:${C_RESET}"
    echo -e "  ${C_WHITE}arise${C_RESET}                    Activate a local virtual environment"
    echo -e "  ${C_WHITE}arise --create [name]${C_RESET}   Create and activate a virtual environment"
    echo -e "  ${C_WHITE}arise --set <effect>${C_RESET}     Set the activation effect"
    echo -e "  ${C_WHITE}arise --list${C_RESET}             List available effects"
    echo -e "  ${C_WHITE}arise --preview [effect]${C_RESET} Preview an effect"
    echo -e "  ${C_WHITE}arise --current${C_RESET}          Show current effect"
    echo -e "  ${C_WHITE}arise --help${C_RESET}             Show this help message"
    echo -e "  ${C_WHITE}arise --version${C_RESET}          Show version\n"
    
    echo -e "${C_BOLD}EXAMPLES:${C_RESET}"
    echo -e "  ${C_GRAY}# Activate with current effect${C_RESET}"
    echo -e "  ${C_WHITE}arise${C_RESET}\n"
    echo -e "  ${C_GRAY}# Switch to matrix effect${C_RESET}"
    echo -e "  ${C_WHITE}arise --set matrix${C_RESET}\n"
    echo -e "  ${C_GRAY}# Preview the cyber effect${C_RESET}"
    echo -e "  ${C_WHITE}arise --preview cyber${C_RESET}\n"
    echo -e "  ${C_GRAY}# Create and activate a new virtual environment${C_RESET}"
    echo -e "  ${C_WHITE}arise --create${C_RESET}\n"
}

# Show version
show_version() {
    echo -e "${C_CYAN}arise${C_RESET} v1.0.0"
}

# ─────────────────────────────────────────────────────────────────
# MAIN FUNCTION
# ─────────────────────────────────────────────────────────────────
arise() {
    load_config

    local requested_venv_path=""

    # Parse arguments
    case "$1" in
        --help|-h)
            show_help
            return 0
            ;;
        --version|-v)
            show_version
            return 0
            ;;
        --list|-l)
            list_effects
            return 0
            ;;
        --set|-s)
            if [[ -z "$2" ]]; then
                echo -e "${C_RED}✗${C_RESET} Please specify an effect"
                echo -e "  Run ${C_CYAN}arise --list${C_RESET} to see available effects"
                return 1
            fi
            set_effect "$2"
            return $?
            ;;
        --preview|-p)
            preview_effect "$2"
            return $?
            ;;
        --current|-c)
            echo -e "Current effect: ${C_CYAN}${ARISE_EFFECT}${C_RESET}"
            return 0
            ;;
        --create)
            local target_dir="${2:-$ARISE_DEFAULT_VENV_DIR}"
            if [[ "$target_dir" == -* ]]; then
                target_dir="$ARISE_DEFAULT_VENV_DIR"
            fi

            create_venv "$target_dir" || return 1
            requested_venv_path="./${target_dir}/bin/activate"
            ;;
        "")
            # Default: activate venv
            ;;
        *)
            echo -e "${C_RED}✗${C_RESET} Unknown option: $1"
            echo -e "  Run ${C_CYAN}arise --help${C_RESET} for usage"
            return 1
            ;;
    esac

    # ─────────────────────────────────────────────────────────────
    # VIRTUAL ENVIRONMENT ACTIVATION
    # ─────────────────────────────────────────────────────────────

    local VENV_PATH="$requested_venv_path"

    if [[ -z "$VENV_PATH" ]]; then
        VENV_PATH=$(resolve_venv_path)
    fi

    # Check if venv exists
    if [[ ! -f "$VENV_PATH" ]]; then
        echo -e "${C_RED}[!] No virtual environment found in $(pwd)${C_RESET}"
        echo -e "${C_GRAY}(Looked for .venv, venv, env, and .env)${C_RESET}"
        echo -e "${C_GRAY}(Tip: run ${C_CYAN}arise --create${C_RESET}${C_GRAY} to create one)${C_RESET}"
        return 1
    fi

    # Run the selected effect
    local effect_func="effect_${ARISE_EFFECT}"
    if declare -f "$effect_func" > /dev/null; then
        $effect_func
    else
        effect_zone  # Fallback
    fi

    # Activate the virtual environment
    source "$VENV_PATH"

    # Update terminal title
    printf "\033]2;⚡ ARISE (%s)\007" "$(basename "$(pwd)")"

    # Clear and show landing message
    clear
    
    # Landing message based on effect style
    case "$ARISE_EFFECT" in
        matrix)
            echo -e "${C_GREEN}// SYSTEM_ONLINE${C_RESET}"
            ;;
        cyber)
            echo -e "${C_MAGENTA}[SYS] Environment ready${C_RESET}"
            ;;
        minimal)
            echo -e "${C_WHITE}▸ ready${C_RESET}"
            ;;
        neon)
            echo -e "${C_CYAN}◈ Arise complete${C_RESET}"
            ;;
        scanline)
            echo -e "${C_GREEN}[ SYSTEMS NOMINAL ]${C_RESET}"
            ;;
        *)
            echo -e "${C_CYAN}// ZONE_ACCESS_GRANTED${C_RESET}"
            ;;
    esac
    
    echo -e "${C_GRAY}Environment: $(basename "$(pwd)") | $(python --version 2>&1)${C_RESET}"
}

# Export the function so it's available in the shell
# (This file should be sourced, not executed)
