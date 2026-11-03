#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE - Solo Leveling Edition                                  │
# │  Enter your dungeon. Awaken your environment.                   │
# │  https://github.com/yourusername/arise                          │
# └─────────────────────────────────────────────────────────────────┘
# Works in bash 4+ and zsh. This file should be sourced, not executed.

# Configuration
ARISE_VERSION="2.0.0"
ARISE_CONFIG_DIR="${HOME}/.config/arise"
ARISE_CONFIG_FILE="${ARISE_CONFIG_DIR}/config"
ARISE_DEFAULT_EFFECT="shadow"
ARISE_DEFAULT_VENV_DIR=".venv"
ARISE_EFFECTS="shadow system gate monarch instant stealth levelup exchange rank none"

# Color definitions
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[38;5;39m"      # System-window blue
C_PURPLE="\e[38;5;93m"    # Shadow purple
C_VIOLET="\e[38;5;135m"   # Light shadow glow
C_GOLD="\e[38;5;220m"     # S-Rank gold
C_CYAN="\e[36m"
C_WHITE="\e[37m"
C_GRAY="\e[38;5;242m"
C_BOLD="\e[1m"

# ─────────────────────────────────────────────────────────────────
# HELPERS (shared by effects)
# ─────────────────────────────────────────────────────────────────

# Integer sin/cos table (x100) in 15-degree steps, 24 entries, 4 chars each.
# Avoids any dependency on `bc`.
_arise_trig_init() {
    [[ -n "$ARISE_COS" ]] && return 0
    local v
    ARISE_COS=""
    ARISE_SIN=""
    for v in 100 97 87 71 50 26 0 -26 -50 -71 -87 -97 -100 -97 -87 -71 -50 -26 0 26 50 71 87 97; do
        ARISE_COS+=$(printf '%4d' "$v")
    done
    for v in 0 26 50 71 87 97 100 97 87 71 50 26 0 -26 -50 -71 -87 -97 -100 -97 -87 -71 -50 -26; do
        ARISE_SIN+=$(printf '%4d' "$v")
    done
}

_arise_begin() { tput smcup; tput civis; clear; }
_arise_end()   { tput rmcup; tput cnorm; }

# Print centered text:  _arise_center <row> <text> <style>
_arise_center() {
    local row="$1" text="$2" style="${3:-}" cols
    cols=$(tput cols)
    tput cup "$row" $(( (cols - ${#text}) / 2 ))
    printf "%b%s\e[0m" "$style" "$text"
}

# Typewriter text:  _arise_type <row> <col> <text> <style> [delay]
_arise_type() {
    local row="$1" col="$2" text="$3" style="$4" delay="${5:-0.012}" i
    tput cup "$row" "$col"
    printf "%b" "$style"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    printf "\e[0m"
}

# Repeat a character:  _arise_rep <char> <count>
_arise_rep() {
    local s
    s=$(printf '%*s' "$2" '')
    printf "%s" "${s// /$1}"
}

# Draw a box:  _arise_box <top> <left> <width> <height> <style>
_arise_box() {
    local top="$1" left="$2" w="$3" h="$4" style="$5" r
    tput cup "$top" "$left"
    printf "%b┌%s┐\e[0m" "$style" "$(_arise_rep ─ $((w-2)))"
    for ((r=1; r<h-1; r++)); do
        tput cup $((top+r)) "$left"
        printf "%b│%*s│\e[0m" "$style" $((w-2)) ""
    done
    tput cup $((top+h-1)) "$left"
    printf "%b└%s┘\e[0m" "$style" "$(_arise_rep ─ $((w-2)))"
}

# Static System window used for the landing message:
#   _arise_window <title> <line> [line...]
_arise_window() {
    local title="$1" line w=0 tl
    shift
    for line in "$@"; do
        (( ${#line} > w )) && w=${#line}
    done
    tl=$(( ${#title} + 4 ))
    (( w < tl )) && w=$tl
    w=$((w + 2))
    printf "%b┌─ %s ─%s┐%b\n" "$C_BLUE" "$title" "$(_arise_rep ─ $((w - ${#title} - 2)))" "$C_RESET"
    for line in "$@"; do
        printf "%b│%b %-*s %b│%b\n" "$C_BLUE" "$C_RESET" "$w" "$line" "$C_BLUE" "$C_RESET"
    done
    printf "%b└%s┘%b\n" "$C_BLUE" "$(_arise_rep ─ $((w + 2)))" "$C_RESET"
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Shadow Extraction (default) - "ARISE"
# Purple shadow smoke rises, then the shadow soldier answers the call
# ─────────────────────────────────────────────────────────────────
effect_shadow() {
    local cols rows frame k x y color smoke ch word i
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    smoke="░▒▓"

    for ((frame=1; frame<=18; frame++)); do
        for ((k=0; k<cols/3; k++)); do
            x=$((RANDOM % cols))
            y=$(( rows - 1 - (frame * rows / 18) + RANDOM % 4 ))
            (( y < 0 )) && y=0
            (( y >= rows )) && y=$((rows - 1))
            color=$((90 + RANDOM % 5))
            ch="${smoke:$((RANDOM % 3)):1}"
            tput cup "$y" "$x"
            printf "\e[38;5;%sm%s\e[0m" "$color" "$ch"
        done
        sleep 0.03
    done

    printf "\e[?5h"; sleep 0.05; printf "\e[?5l"
    clear

    word="A R I S E"
    for ((i=1; i<=${#word}; i++)); do
        _arise_center $((rows / 2)) "${word:0:$i}" "\e[1;38;5;135m"
        sleep 0.09
    done
    _arise_center $((rows / 2 + 2)) "[ SHADOW EXTRACTION: SUCCESS ]" "$C_PURPLE"
    sleep 0.6
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: System - The blue System window, a Daily Quest completes
# ─────────────────────────────────────────────────────────────────
effect_system() {
    local cols rows w h left mid top i bar
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)

    if (( cols < 48 || rows < 12 )); then
        _arise_center $((rows / 2)) "[ SYSTEM ] Quest complete." "$C_BLUE"
        sleep 0.5; _arise_end; return
    fi

    w=44; h=9
    left=$(( (cols - w) / 2 )); mid=$((rows / 2))

    # Window opens vertically
    for ((i=3; i<=h; i+=2)); do
        _arise_box $((mid - i/2)) "$left" "$w" "$i" "$C_BLUE"
        sleep 0.05
    done
    top=$((mid - h/2))

    tput cup "$top" $((left + 2)); printf "%b[ SYSTEM ]%b" "\e[1;38;5;39m" "$C_RESET"
    _arise_type $((top + 2)) $((left + 3)) "Daily Quest: Activate the environment" "$C_WHITE" 0.012

    for ((i=0; i<=10; i++)); do
        bar="$(_arise_rep '█' $i)$(_arise_rep '░' $((10 - i)))"
        tput cup $((top + 4)) $((left + 3))
        printf "%bProgress [%s] %3d%%%b" "$C_BLUE" "$bar" $((i * 10)) "$C_RESET"
        sleep 0.04
    done

    printf "\e[?5h"; sleep 0.03; printf "\e[?5l"
    _arise_type $((top + 6)) $((left + 3)) "Quest complete. Welcome, Player." "\e[1;38;5;220m" 0.015
    sleep 0.5
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Gate - A spiral dimensional portal tears open
# ─────────────────────────────────────────────────────────────────
effect_gate() {
    local cols rows cx cy t arm a x y color maxr
    _arise_trig_init
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    cx=$((cols / 2)); cy=$((rows / 2))
    maxr=$((cols / 3))

    for ((t=1; t<=maxr; t++)); do
        for ((arm=0; arm<3; arm++)); do
            a=$(( (t + arm * 8) % 24 ))
            x=$(( cx + t * $(( ${ARISE_COS:$((a*4)):4} )) / 100 ))
            y=$(( cy + t * $(( ${ARISE_SIN:$((a*4)):4} )) / 200 ))
            if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                color=$((27 + (RANDOM % 4) * 6))
                tput cup "$y" "$x"
                printf "\e[38;5;%sm◉\e[0m" "$color"
            fi
        done
        sleep 0.012
    done

    printf "\e[?5h"; sleep 0.04; printf "\e[?5l"
    clear
    _arise_center "$cy" "[ A GATE HAS APPEARED ]" "\e[1;38;5;39m"
    _arise_center $((cy + 2)) "Rank: S" "$C_GOLD"
    sleep 0.6
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Monarch - Shadow Monarch's aura radiates outward
# ─────────────────────────────────────────────────────────────────
effect_monarch() {
    local cols rows cx cy r pass a x y color
    _arise_trig_init
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    cx=$((cols / 2)); cy=$((rows / 2))

    for ((pass=0; pass<2; pass++)); do
        for ((r=2; r<=cols/3; r+=2)); do
            for ((a=0; a<24; a++)); do
                x=$(( cx + r * $(( ${ARISE_COS:$((a*4)):4} )) / 100 ))
                y=$(( cy + r * $(( ${ARISE_SIN:$((a*4)):4} )) / 200 ))
                if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                    color=$((90 + (r / 2 + pass) % 5))
                    tput cup "$y" "$x"
                    printf "\e[38;5;%sm●\e[0m" "$color"
                fi
            done
            sleep 0.012
        done
        printf "\e[?5h"; sleep 0.02; printf "\e[?5l"
    done

    clear
    _arise_center "$cy" "◈ SHADOW MONARCH ◈" "\e[1;38;5;135m"
    _arise_center $((cy + 2)) "Kneel." "$C_GRAY"
    sleep 0.6
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Instant - The System glitches; an Instant Dungeon spawns
# ─────────────────────────────────────────────────────────────────
effect_instant() {
    local cols rows mid glitch_chars frame i x y w j color ch msg
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    mid=$((rows / 2))
    glitch_chars="█▓▒░╔╗╚╝║═╬┼├┤┬┴"

    for ((frame=0; frame<8; frame++)); do
        for ((i=0; i<20; i++)); do
            x=$((RANDOM % cols))
            y=$((RANDOM % rows))
            w=$((RANDOM % 15 + 5))
            case $((RANDOM % 3)) in
                0) color=196 ;;
                1) color=93 ;;
                *) color=39 ;;
            esac
            tput cup "$y" "$x"
            for ((j=0; j<w && x+j<cols; j++)); do
                ch="${glitch_chars:$((RANDOM % ${#glitch_chars})):1}"
                printf "\e[38;5;%sm%s\e[0m" "$color" "$ch"
            done
        done
        sleep 0.05
        if ((frame % 2 == 0)); then
            printf "\e[?5h"; sleep 0.02; printf "\e[?5l"
        fi
    done

    clear
    msg="▌ WARNING: INSTANT DUNGEON GENERATED ▐"
    _arise_center "$mid" "$msg" "\e[1;38;5;196m"
    _arise_center $((mid + 2)) "Escape route: arise --retreat" "$C_GRAY"
    sleep 0.7
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Stealth - Quiet, minimal. Shadows fade you in
# ─────────────────────────────────────────────────────────────────
effect_stealth() {
    local cols rows mid text shade
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    mid=$((rows / 2))
    text="· · ·  stealth  · · ·"

    for shade in 233 236 240 244 248 252; do
        _arise_center "$mid" "$text" "\e[38;5;${shade}m"
        sleep 0.06
    done
    sleep 0.25
    for shade in 248 244 240 236 233; do
        _arise_center "$mid" "$text" "\e[38;5;${shade}m"
        sleep 0.04
    done
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Level Up - Stat allocation boot sequence
# ─────────────────────────────────────────────────────────────────
effect_levelup() {
    local cols rows col row stat
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    col=$(( (cols - 34) / 2 ))
    (( col < 2 )) && col=2
    row=$(( rows / 2 - 3 ))
    (( row < 1 )) && row=1

    _arise_type "$row" "$col" "[SYSTEM] LEVEL UP!" "\e[1;38;5;220m" 0.02
    row=$((row + 1))
    for stat in "STR  +5" "AGI  +5" "INT  +5" "VIT  +5"; do
        row=$((row + 1))
        _arise_type "$row" "$((col + 2))" "$stat" "$C_WHITE" 0.015
        sleep 0.06
    done
    row=$((row + 2))
    _arise_type "$row" "$col" "[SYSTEM] Environment synchronized" "$C_BLUE" 0.01
    row=$((row + 1))
    _arise_type "$row" "$col" "[SYSTEM] ARISE." "\e[1;38;5;135m" 0.04

    sleep 0.5
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Exchange - Shadow Exchange teleport streaks
# ─────────────────────────────────────────────────────────────────
effect_exchange() {
    local cols rows cx cy frame star a dist x y
    _arise_trig_init
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    cx=$((cols / 2)); cy=$((rows / 2))

    for ((frame=0; frame<20; frame++)); do
        for ((star=0; star<30; star++)); do
            a=$((RANDOM % 24))
            dist=$((frame * 2 + RANDOM % 3))
            x=$(( cx + dist * $(( ${ARISE_COS:$((a*4)):4} )) / 100 ))
            y=$(( cy + dist * $(( ${ARISE_SIN:$((a*4)):4} )) / 200 ))
            if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                tput cup "$y" "$x"
                if ((dist > 15)); then
                    printf "\e[1;38;5;135m─\e[0m"
                elif ((dist > 8)); then
                    printf "\e[38;5;93m•\e[0m"
                else
                    printf "\e[38;5;54m·\e[0m"
                fi
            fi
        done
        sleep 0.03
    done

    clear
    _arise_center "$cy" "✦ SHADOW EXCHANGE ✦" "\e[1;38;5;135m"
    sleep 0.5
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: Rank - Hunter ranking scan, E-Rank all the way up to S
# ─────────────────────────────────────────────────────────────────
effect_rank() {
    local cols rows mid y start i letters colors letter col
    _arise_begin
    cols=$(tput cols); rows=$(tput lines)
    mid=$((rows / 2))

    # Blue scanline sweep
    for ((y=0; y<rows; y++)); do
        tput cup "$y" 0
        printf "\e[48;5;24m%*s\e[0m" "$cols" ""
        sleep 0.01
        tput cup "$y" 0
        printf "%*s" "$cols" ""
    done

    # Ranks, dim first
    start=$(( (cols - 21) / 2 ))
    letters="EDCBAS"
    for ((i=0; i<6; i++)); do
        tput cup "$mid" $((start + i * 4))
        printf "\e[38;5;238m%s\e[0m" "${letters:$i:1}"
    done
    # Light them up one by one
    for ((i=0; i<6; i++)); do
        case $i in
            0) col=245 ;;
            1) col=34 ;;
            2) col=37 ;;
            3) col=33 ;;
            4) col=129 ;;
            *) col=220 ;;
        esac
        tput cup "$mid" $((start + i * 4))
        printf "\e[1;38;5;%sm%s\e[0m" "$col" "${letters:$i:1}"
        sleep 0.12
    done

    _arise_center $((mid + 2)) "[ RANK UP: S ]" "\e[1;38;5;220m"
    sleep 0.6
    _arise_end
}

# ─────────────────────────────────────────────────────────────────
# EFFECT: None - No animation, instant activation
# ─────────────────────────────────────────────────────────────────
effect_none() {
    :
}

# ─────────────────────────────────────────────────────────────────
# UTILITY FUNCTIONS
# ─────────────────────────────────────────────────────────────────

# Map effect names from older (pre-Solo Leveling) versions to new ones
_arise_migrate_effect() {
    case "$1" in
        zone)     echo "shadow" ;;
        matrix)   echo "gate" ;;
        pulse)    echo "monarch" ;;
        glitch)   echo "instant" ;;
        minimal)  echo "stealth" ;;
        cyber)    echo "levelup" ;;
        warp)     echo "exchange" ;;
        neon)     echo "system" ;;
        scanline) echo "rank" ;;
        *)        echo "$1" ;;
    esac
}

# Load configuration
load_config() {
    if [[ -f "$ARISE_CONFIG_FILE" ]]; then
        source "$ARISE_CONFIG_FILE"
    fi
    ARISE_EFFECT="$(_arise_migrate_effect "${ARISE_EFFECT:-$ARISE_DEFAULT_EFFECT}")"
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
        echo -e "${C_YELLOW}!${C_RESET} A dungeon already exists here: ${C_BLUE}${target_dir}${C_RESET}"
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

    echo -e "${C_BLUE}→${C_RESET} A Gate is opening: ${C_VIOLET}${target_dir}${C_RESET}"
    "$python_cmd" -m venv "$target_dir"

    if [[ ! -f "./${target_dir}/bin/activate" ]]; then
        echo -e "${C_RED}✗${C_RESET} The Gate collapsed. Failed to create ${target_dir}"
        return 1
    fi

    echo -e "${C_GREEN}✓${C_RESET} Dungeon generated: ${C_VIOLET}${target_dir}${C_RESET}"
}

# Check if terminal supports full-screen effects
can_render_effects() {
    [[ -t 1 ]] || return 1
    [[ -n "${TERM:-}" && "${TERM}" != "dumb" ]] || return 1
    command -v tput >/dev/null 2>&1 || return 1

    return 0
}

# List available effects
list_effects() {
    echo -e "${C_BLUE}${C_BOLD}[ SYSTEM ] Available Effects${C_RESET}\n"
    echo -e "  ${C_WHITE}shadow${C_RESET}    - ${C_GRAY}Shadow extraction: smoke rises, the soldier answers (default)${C_RESET}"
    echo -e "  ${C_WHITE}system${C_RESET}    - ${C_GRAY}The System window: a Daily Quest completes${C_RESET}"
    echo -e "  ${C_WHITE}gate${C_RESET}      - ${C_GRAY}A spiral dimensional Gate tears open${C_RESET}"
    echo -e "  ${C_WHITE}monarch${C_RESET}   - ${C_GRAY}The Shadow Monarch's aura radiates outward${C_RESET}"
    echo -e "  ${C_WHITE}instant${C_RESET}   - ${C_GRAY}The System glitches, an Instant Dungeon spawns${C_RESET}"
    echo -e "  ${C_WHITE}stealth${C_RESET}   - ${C_GRAY}Quiet and minimal; the shadows fade you in${C_RESET}"
    echo -e "  ${C_WHITE}levelup${C_RESET}   - ${C_GRAY}Level up! Stat allocation boot sequence${C_RESET}"
    echo -e "  ${C_WHITE}exchange${C_RESET}  - ${C_GRAY}Shadow Exchange teleport streaks${C_RESET}"
    echo -e "  ${C_WHITE}rank${C_RESET}      - ${C_GRAY}Hunter ranking scan, E-Rank up to S-Rank${C_RESET}"
    echo -e "  ${C_WHITE}none${C_RESET}      - ${C_GRAY}No animation${C_RESET}"
}

# Set effect
set_effect() {
    local effect
    effect="$(_arise_migrate_effect "$1")"

    if [[ " $ARISE_EFFECTS " == *" $effect "* ]]; then
        ARISE_EFFECT="$effect"
        save_config
        echo -e "${C_GREEN}✓${C_RESET} Awakening style set to: ${C_VIOLET}${effect}${C_RESET}"
    else
        echo -e "${C_RED}✗${C_RESET} Unknown effect: $1"
        echo -e "  Run ${C_BLUE}arise --list${C_RESET} to see available effects"
        return 1
    fi
}

# Preview effect
preview_effect() {
    local effect func
    effect="$(_arise_migrate_effect "${1:-$ARISE_EFFECT}")"
    func="effect_${effect}"

    if declare -f "$func" > /dev/null; then
        if can_render_effects; then
            "$func"
        else
            echo -e "${C_YELLOW}!${C_RESET} Terminal does not support visual effects in this session"
        fi
        echo -e "\n${C_GRAY}Previewed effect: ${C_VIOLET}${effect}${C_RESET}"
    else
        echo -e "${C_RED}✗${C_RESET} Unknown effect: $1"
        return 1
    fi
}

# Landing flavor line per effect
_arise_landing_line() {
    case "$1" in
        shadow)   echo "Shadow extraction successful." ;;
        system)   echo "Welcome, Player." ;;
        gate)     echo "You have entered the dungeon." ;;
        monarch)  echo "The Shadow Monarch has awakened." ;;
        instant)  echo "Instant Dungeon: access granted." ;;
        stealth)  echo "Stealth active." ;;
        levelup)  echo "Level up! Environment synchronized." ;;
        exchange) echo "Shadow Exchange complete." ;;
        rank)     echo "Rank confirmed: S." ;;
        *)        echo "Environment active." ;;
    esac
}

# Show help
show_help() {
    echo -e "${C_PURPLE}${C_BOLD}"
    echo "    ___    ____  _________ ______"
    echo "   /   |  / __ \/  _/ ___// ____/"
    echo "  / /| | / /_/ // / \__ \/ __/   "
    echo " / ___ |/ _, _// / ___/ / /___   "
    echo "/_/  |_/_/ |_/___//____/_____/   "
    echo -e "${C_RESET}"
    echo -e "${C_GRAY}Enter the dungeon. Awaken your environment. (Solo Leveling edition)${C_RESET}\n"

    echo -e "${C_BOLD}USAGE:${C_RESET}"
    echo -e "  ${C_WHITE}arise${C_RESET}                     Enter the dungeon (activate the venv)"
    echo -e "  ${C_WHITE}arise --create [name]${C_RESET}     Open a new Gate (create + activate a venv)"
    echo -e "  ${C_WHITE}arise --retreat${C_RESET}           Leave the dungeon (deactivate)"
    echo -e "  ${C_WHITE}arise --set <effect>${C_RESET}      Set your awakening style"
    echo -e "  ${C_WHITE}arise --list${C_RESET}              List available effects"
    echo -e "  ${C_WHITE}arise --preview [effect]${C_RESET}  Preview an effect"
    echo -e "  ${C_WHITE}arise --current${C_RESET}           Show current effect"
    echo -e "  ${C_WHITE}arise --help${C_RESET}              Show this help message"
    echo -e "  ${C_WHITE}arise --version${C_RESET}           Show version\n"

    echo -e "${C_BOLD}EXAMPLES:${C_RESET}"
    echo -e "  ${C_GRAY}# Enter the dungeon${C_RESET}"
    echo -e "  ${C_WHITE}arise${C_RESET}\n"
    echo -e "  ${C_GRAY}# Switch to the Gate effect${C_RESET}"
    echo -e "  ${C_WHITE}arise --set gate${C_RESET}\n"
    echo -e "  ${C_GRAY}# Preview the Level Up sequence${C_RESET}"
    echo -e "  ${C_WHITE}arise --preview levelup${C_RESET}\n"
    echo -e "  ${C_GRAY}# Open a new Gate and step inside${C_RESET}"
    echo -e "  ${C_WHITE}arise --create${C_RESET}\n"
}

# Show version
show_version() {
    echo -e "${C_VIOLET}arise${C_RESET} v${ARISE_VERSION} ${C_GRAY}(Solo Leveling edition)${C_RESET}"
}

# Leave the dungeon
retreat() {
    if declare -f deactivate > /dev/null; then
        deactivate
        echo
        _arise_window "SYSTEM" "You have left the dungeon." "Return anytime: arise"
        printf "\033]2;%s\007" "Terminal"
    else
        echo -e "${C_YELLOW}!${C_RESET} You are not inside a dungeon."
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────
# MAIN FUNCTION
# ─────────────────────────────────────────────────────────────────
arise() {
    load_config

    local requested_venv_path=""
    local target_dir VENV_PATH effect_func project

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
                echo -e "  Run ${C_BLUE}arise --list${C_RESET} to see available effects"
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
            echo -e "Current effect: ${C_VIOLET}${ARISE_EFFECT}${C_RESET}"
            return 0
            ;;
        --retreat|--leave)
            retreat
            return $?
            ;;
        --create)
            target_dir="${2:-$ARISE_DEFAULT_VENV_DIR}"
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
            echo -e "  Run ${C_BLUE}arise --help${C_RESET} for usage"
            return 1
            ;;
    esac

    # ─────────────────────────────────────────────────────────────
    # DUNGEON ENTRY (VIRTUAL ENVIRONMENT ACTIVATION)
    # ─────────────────────────────────────────────────────────────

    VENV_PATH="$requested_venv_path"

    if [[ -z "$VENV_PATH" ]]; then
        VENV_PATH=$(resolve_venv_path)
    fi

    # Check if venv exists
    if [[ -z "$VENV_PATH" || ! -f "$VENV_PATH" ]]; then
        echo -e "${C_RED}[!] No Gate found in $(pwd)${C_RESET}"
        echo -e "${C_GRAY}(Looked for .venv, venv, env, and .env)${C_RESET}"
        echo -e "${C_GRAY}(Tip: run ${C_BLUE}arise --create${C_RESET}${C_GRAY} to open one)${C_RESET}"
        return 1
    fi

    # Run the selected effect
    effect_func="effect_${ARISE_EFFECT}"
    if can_render_effects; then
        if declare -f "$effect_func" > /dev/null; then
            "$effect_func"
        else
            effect_shadow
        fi
    fi

    # Activate the virtual environment
    source "$VENV_PATH"

    project="$(basename "$(pwd)")"

    # Update terminal title
    printf "\033]2;⚔ ARISE (%s)\007" "$project"

    # Clear and show landing System window
    clear
    _arise_window "SYSTEM" \
        "$(_arise_landing_line "$ARISE_EFFECT")" \
        "Dungeon : ${project}" \
        "Class   : $(python --version 2>&1)"
}

# Export the function so it's available in the shell
# (This file should be sourced, not executed)