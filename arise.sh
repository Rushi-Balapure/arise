#!/usr/bin/env bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE - Solo Leveling Edition                                  │
# │  Enter your dungeon. Awaken your environment.                   │
# │  https://github.com/yourusername/arise                          │
# └─────────────────────────────────────────────────────────────────┘
# Works in bash and zsh. This file must be sourced, not executed:
#     source arise.sh

# ── Refuse to run if executed instead of sourced ─────────────────
if [[ -n ${BASH_VERSION:-} ]]; then
    (return 0 2>/dev/null) || { echo "arise: source this file, don't execute it." >&2; exit 1; }
elif [[ -n ${ZSH_VERSION:-} ]]; then
    [[ $ZSH_EVAL_CONTEXT == *:file* ]] || { echo "arise: source this file, don't execute it." >&2; exit 1; }
fi

# ── Configuration ────────────────────────────────────────────────
ARISE_VERSION="2.1.0"
ARISE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/arise"
ARISE_CONFIG_FILE="${ARISE_CONFIG_DIR}/config"
ARISE_DEFAULT_EFFECT="shadow"
ARISE_DEFAULT_VENV_DIR=".venv"
ARISE_EFFECTS=(shadow system gate monarch instant stealth levelup exchange rank none)
ARISE_VENV_CANDIDATES=(.venv venv env .env)

# ── Colors (real escape bytes, so plain printf '%s' works everywhere) ──
_ESC=$'\e'
C_RESET=$'\e[0m'
C_RED=$'\e[31m'
C_GREEN=$'\e[32m'
C_YELLOW=$'\e[33m'
C_BLUE=$'\e[38;5;39m'      # System-window blue
C_PURPLE=$'\e[38;5;93m'    # Shadow purple
C_VIOLET=$'\e[38;5;135m'   # Light shadow glow
C_GOLD=$'\e[38;5;220m'     # S-Rank gold
C_WHITE=$'\e[37m'
C_GRAY=$'\e[38;5;242m'
C_BOLD=$'\e[1m'
C_BBLUE=$'\e[1;38;5;39m'
C_BVIOLET=$'\e[1;38;5;135m'
C_BGOLD=$'\e[1;38;5;220m'
C_BRED=$'\e[1;38;5;196m'

# ─────────────────────────────────────────────────────────────────
# DRAWING PRIMITIVES
#
# Big win vs. the original: no `tput` forks in the hot path. Every
# cursor move is a raw escape sequence appended to a buffer, and each
# animation frame is written with ONE printf.
# ─────────────────────────────────────────────────────────────────

# Integer sin/cos table (x100), 15° steps, 24 entries x 4 chars. No `bc`, no forks.
_arise_trig_init() {
    [[ -n ${ARISE_COS:-} ]] && return 0
    local v t
    ARISE_COS="" ARISE_SIN=""
    for v in 100 97 87 71 50 26 0 -26 -50 -71 -87 -97 -100 -97 -87 -71 -50 -26 0 26 50 71 87 97; do
        printf -v t '%4d' "$v"; ARISE_COS+=$t
    done
    for v in 0 26 50 71 87 97 100 97 87 71 50 26 0 -26 -50 -71 -87 -97 -100 -97 -87 -71 -50 -26; do
        printf -v t '%4d' "$v"; ARISE_SIN+=$t
    done
}

_arise_begin() {
    _AR_COLS=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
    _AR_ROWS=${LINES:-$(tput lines 2>/dev/null || echo 24)}
    _AR_BUF=""
    printf '\e[?1049h\e[?25l\e[2J\e[H'      # alt screen, hide cursor, clear
}
_arise_end()   { printf '\e[?25h\e[?1049l'; }   # show cursor, leave alt screen
_arise_clear() { printf '\e[2J\e[H'; }
_arise_flash() { printf '\e[?5h'; sleep "$1"; printf '\e[?5l'; }

# Append to frame buffer:  _arise_put <row> <col> <style> <text>
_arise_put() {
    _AR_BUF+="${_ESC}[$(( $1 + 1 ));$(( $2 + 1 ))H${3}${4}${C_RESET}"
}
_arise_flush() { printf '%s' "$_AR_BUF"; _AR_BUF=""; }

# Centered text (buffered):  _arise_center <row> <text> <style>
_arise_center() {
    local col=$(( (_AR_COLS - ${#2}) / 2 ))
    (( col < 0 )) && col=0
    _arise_put "$1" "$col" "$3" "$2"
}

# Typewriter (immediate):  _arise_type <row> <col> <text> <style> [delay]
_arise_type() {
    local text=$3 delay=${5:-0.012} i
    printf '%s[%d;%dH%s' "$_ESC" $(( $1 + 1 )) $(( $2 + 1 )) "$4"
    for ((i=0; i<${#text}; i++)); do
        printf '%s' "${text:i:1}"
        sleep "$delay"
    done
    printf '%s' "$C_RESET"
}

# Repeat a character, result in $_AR_R (no subshell):  _arise_rep <char> <count>
_arise_rep() {
    local s n=$2
    (( n < 0 )) && n=0
    printf -v s '%*s' "$n" ''
    _AR_R=${s// /$1}
}

# Box (buffered):  _arise_box <top> <left> <width> <height> <style>
_arise_box() {
    local top=$1 left=$2 w=$3 h=$4 style=$5 r pad hl
    _arise_rep ─ $(( w - 2 )); hl=$_AR_R
    printf -v pad '%*s' $(( w - 2 )) ''
    _arise_put "$top" "$left" "$style" "┌${hl}┐"
    for ((r=1; r<h-1; r++)); do
        _arise_put $(( top + r )) "$left" "$style" "│${pad}│"
    done
    _arise_put $(( top + h - 1 )) "$left" "$style" "└${hl}┘"
}

# Static System window for the landing message:  _arise_window <title> <line>...
_arise_window() {
    local title=$1 line w=0 tl
    shift
    for line in "$@"; do (( ${#line} > w )) && w=${#line}; done
    tl=$(( ${#title} + 4 ))
    (( w < tl )) && w=$tl
    w=$(( w + 2 ))
    _arise_rep ─ $(( w - ${#title} - 2 ))
    printf '%s┌─ %s ─%s┐%s\n' "$C_BLUE" "$title" "$_AR_R" "$C_RESET"
    for line in "$@"; do
        printf '%s│%s %-*s %s│%s\n' "$C_BLUE" "$C_RESET" "$w" "$line" "$C_BLUE" "$C_RESET"
    done
    _arise_rep ─ $(( w + 2 ))
    printf '%s└%s┘%s\n' "$C_BLUE" "$_AR_R" "$C_RESET"
}

# ─────────────────────────────────────────────────────────────────
# EFFECTS  (_arise_begin/_arise_end are handled by _arise_run_effect)
# ─────────────────────────────────────────────────────────────────

# Shadow extraction (default)
_arise_fx_shadow() {
    local cols=$_AR_COLS rows=$_AR_ROWS frame k x y i ch word smoke="░▒▓"
    local per=$(( cols / 3 ))
    for ((frame=1; frame<=18; frame++)); do
        for ((k=0; k<per; k++)); do
            x=$(( RANDOM % cols ))
            y=$(( rows - 1 - frame * rows / 18 + RANDOM % 4 ))
            (( y < 0 )) && y=0
            (( y >= rows )) && y=$(( rows - 1 ))
            ch=${smoke:$(( RANDOM % 3 )):1}
            _arise_put "$y" "$x" "${_ESC}[38;5;$(( 90 + RANDOM % 5 ))m" "$ch"
        done
        _arise_flush; sleep 0.03
    done
    _arise_flash 0.05
    _arise_clear

    word="A R I S E"
    for ((i=1; i<=${#word}; i++)); do
        _arise_center $(( rows / 2 )) "${word:0:i}" "$C_BVIOLET"
        _arise_flush; sleep 0.09
    done
    _arise_center $(( rows / 2 + 2 )) "[ SHADOW EXTRACTION: SUCCESS ]" "$C_PURPLE"
    _arise_flush; sleep 0.6
}

# The blue System window
_arise_fx_system() {
    local cols=$_AR_COLS rows=$_AR_ROWS w=44 h=9 left mid top i bar_on bar_off
    if (( cols < 48 || rows < 12 )); then
        _arise_center $(( rows / 2 )) "[ SYSTEM ] Quest complete." "$C_BLUE"
        _arise_flush; sleep 0.5; return
    fi
    left=$(( (cols - w) / 2 )); mid=$(( rows / 2 )); top=$(( mid - h / 2 ))

    for ((i=3; i<=h; i+=2)); do
        _arise_box $(( mid - i / 2 )) "$left" "$w" "$i" "$C_BLUE"
        _arise_flush; sleep 0.05
    done

    _arise_put "$top" $(( left + 2 )) "$C_BBLUE" "[ SYSTEM ]"
    _arise_flush
    _arise_type $(( top + 2 )) $(( left + 3 )) "Daily Quest: Activate the environment" "$C_WHITE" 0.012

    for ((i=0; i<=10; i++)); do
        _arise_rep '█' "$i";        bar_on=$_AR_R
        _arise_rep '░' $(( 10 - i )); bar_off=$_AR_R
        printf -v _AR_R 'Progress [%s%s] %3d%%' "$bar_on" "$bar_off" $(( i * 10 ))
        _arise_put $(( top + 4 )) $(( left + 3 )) "$C_BLUE" "$_AR_R"
        _arise_flush; sleep 0.04
    done

    _arise_flash 0.03
    _arise_type $(( top + 6 )) $(( left + 3 )) "Quest complete. Welcome, Player." "$C_BGOLD" 0.015
    sleep 0.5
}

# Spiral dimensional gate
_arise_fx_gate() {
    local cols=$_AR_COLS rows=$_AR_ROWS cx cy maxr t arm a x y
    _arise_trig_init
    cx=$(( cols / 2 )); cy=$(( rows / 2 )); maxr=$(( cols / 3 ))
    for ((t=1; t<=maxr; t++)); do
        for ((arm=0; arm<3; arm++)); do
            a=$(( (t + arm * 8) % 24 ))
            x=$(( cx + t * ${ARISE_COS:$((a*4)):4} / 100 ))
            y=$(( cy + t * ${ARISE_SIN:$((a*4)):4} / 200 ))
            if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                _arise_put "$y" "$x" "${_ESC}[38;5;$(( 27 + (RANDOM % 4) * 6 ))m" "◉"
            fi
        done
        _arise_flush; sleep 0.012
    done
    _arise_flash 0.04
    _arise_clear
    _arise_center "$cy" "[ A GATE HAS APPEARED ]" "$C_BBLUE"
    _arise_center $(( cy + 2 )) "Rank: S" "$C_GOLD"
    _arise_flush; sleep 0.6
}

# Monarch's aura
_arise_fx_monarch() {
    local cols=$_AR_COLS rows=$_AR_ROWS cx cy r pass a x y
    _arise_trig_init
    cx=$(( cols / 2 )); cy=$(( rows / 2 ))
    for ((pass=0; pass<2; pass++)); do
        for ((r=2; r<=cols/3; r+=2)); do
            for ((a=0; a<24; a++)); do
                x=$(( cx + r * ${ARISE_COS:$((a*4)):4} / 100 ))
                y=$(( cy + r * ${ARISE_SIN:$((a*4)):4} / 200 ))
                if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                    _arise_put "$y" "$x" "${_ESC}[38;5;$(( 90 + (r / 2 + pass) % 5 ))m" "●"
                fi
            done
            _arise_flush; sleep 0.012
        done
        _arise_flash 0.02
    done
    _arise_clear
    _arise_center "$cy" "◈ SHADOW MONARCH ◈" "$C_BVIOLET"
    _arise_center $(( cy + 2 )) "Kneel." "$C_GRAY"
    _arise_flush; sleep 0.6
}

# Instant Dungeon glitch
_arise_fx_instant() {
    local cols=$_AR_COLS rows=$_AR_ROWS mid=$(( _AR_ROWS / 2 ))
    local glitch="█▓▒░╔╗╚╝║═╬┼├┤┬┴" n frame i x y w j color seg
    n=${#glitch}
    for ((frame=0; frame<8; frame++)); do
        for ((i=0; i<20; i++)); do
            x=$(( RANDOM % cols )); y=$(( RANDOM % rows ))
            w=$(( RANDOM % 15 + 5 ))
            (( x + w > cols )) && w=$(( cols - x ))
            case $(( RANDOM % 3 )) in 0) color=196;; 1) color=93;; *) color=39;; esac
            seg=""
            for ((j=0; j<w; j++)); do seg+=${glitch:$(( RANDOM % n )):1}; done
            _arise_put "$y" "$x" "${_ESC}[38;5;${color}m" "$seg"
        done
        _arise_flush; sleep 0.05
        (( frame % 2 == 0 )) && _arise_flash 0.02
    done
    _arise_clear
    _arise_center "$mid" "▌ WARNING: INSTANT DUNGEON GENERATED ▐" "$C_BRED"
    _arise_center $(( mid + 2 )) "Escape route: arise --retreat" "$C_GRAY"
    _arise_flush; sleep 0.7
}

# Stealth fade
_arise_fx_stealth() {
    local mid=$(( _AR_ROWS / 2 )) text="· · ·  stealth  · · ·" shade
    for shade in 233 236 240 244 248 252 252 248 244 240 236 233; do
        _arise_center "$mid" "$text" "${_ESC}[38;5;${shade}m"
        _arise_flush
        (( shade == 252 )) && sleep 0.2 || sleep 0.05
    done
}

# Level up
_arise_fx_levelup() {
    local col=$(( (_AR_COLS - 34) / 2 )) row=$(( _AR_ROWS / 2 - 3 )) stat
    (( col < 2 )) && col=2
    (( row < 1 )) && row=1
    _arise_type "$row" "$col" "[SYSTEM] LEVEL UP!" "$C_BGOLD" 0.02
    row=$(( row + 1 ))
    for stat in "STR  +5" "AGI  +5" "INT  +5" "VIT  +5"; do
        row=$(( row + 1 ))
        _arise_type "$row" $(( col + 2 )) "$stat" "$C_WHITE" 0.015
        sleep 0.06
    done
    row=$(( row + 2 ))
    _arise_type "$row" "$col" "[SYSTEM] Environment synchronized" "$C_BLUE" 0.01
    row=$(( row + 1 ))
    _arise_type "$row" "$col" "[SYSTEM] ARISE." "$C_BVIOLET" 0.04
    sleep 0.5
}

# Shadow Exchange streaks
_arise_fx_exchange() {
    local cols=$_AR_COLS rows=$_AR_ROWS cx cy frame star a dist x y
    _arise_trig_init
    cx=$(( cols / 2 )); cy=$(( rows / 2 ))
    for ((frame=0; frame<20; frame++)); do
        for ((star=0; star<30; star++)); do
            a=$(( RANDOM % 24 ))
            dist=$(( frame * 2 + RANDOM % 3 ))
            x=$(( cx + dist * ${ARISE_COS:$((a*4)):4} / 100 ))
            y=$(( cy + dist * ${ARISE_SIN:$((a*4)):4} / 200 ))
            if (( x >= 0 && x < cols && y >= 0 && y < rows )); then
                if   (( dist > 15 )); then _arise_put "$y" "$x" $'\e[1;38;5;135m' "─"
                elif (( dist > 8 ));  then _arise_put "$y" "$x" $'\e[38;5;93m'    "•"
                else                       _arise_put "$y" "$x" $'\e[38;5;54m'    "·"
                fi
            fi
        done
        _arise_flush; sleep 0.03
    done
    _arise_clear
    _arise_center "$cy" "✦ SHADOW EXCHANGE ✦" "$C_BVIOLET"
    _arise_flush; sleep 0.5
}

# Hunter rank scan
_arise_fx_rank() {
    local cols=$_AR_COLS rows=$_AR_ROWS mid=$(( _AR_ROWS / 2 )) y i start blank col
    local letters="EDCBAS"
    printf -v blank '%*s' "$cols" ''
    for ((y=0; y<rows; y++)); do
        _arise_put "$y" 0 $'\e[48;5;24m' "$blank"; _arise_flush; sleep 0.01
        _arise_put "$y" 0 "" "$blank";             _arise_flush
    done
    start=$(( (cols - 21) / 2 )); (( start < 0 )) && start=0
    for ((i=0; i<6; i++)); do
        _arise_put "$mid" $(( start + i * 4 )) $'\e[38;5;238m' "${letters:i:1}"
    done
    _arise_flush
    for ((i=0; i<6; i++)); do
        case $i in 0) col=245;; 1) col=34;; 2) col=37;; 3) col=33;; 4) col=129;; *) col=220;; esac
        _arise_put "$mid" $(( start + i * 4 )) "${_ESC}[1;38;5;${col}m" "${letters:i:1}"
        _arise_flush; sleep 0.12
    done
    _arise_center $(( mid + 2 )) "[ RANK UP: S ]" "$C_BGOLD"
    _arise_flush; sleep 0.6
}

# Run an effect in a subshell: variables don't leak, and Ctrl-C both skips the
# animation AND restores the terminal (original left it in the alt screen with
# a hidden cursor).
_arise_run_effect() {
    local fn="_arise_fx_$1" _advance
    declare -f "$fn" >/dev/null || fn=_arise_fx_shadow
    _advance=$RANDOM    # advance parent RNG so subshell animations differ each run
    (
        trap '_arise_end; exit 130' INT TERM
        _arise_begin
        "$fn"
        _arise_end
    )
}

# ─────────────────────────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────────────────────────

_arise_is_effect() { [[ " ${ARISE_EFFECTS[*]} " == *" $1 "* ]]; }

# Map pre-Solo-Leveling effect names. Result in $_AR_R (no subshell).
_arise_migrate_effect() {
    case "$1" in
        zone) _AR_R=shadow;;   matrix) _AR_R=gate;;      pulse) _AR_R=monarch;;
        glitch) _AR_R=instant;; minimal) _AR_R=stealth;;  cyber) _AR_R=levelup;;
        warp) _AR_R=exchange;; neon) _AR_R=system;;      scanline) _AR_R=rank;;
        *) _AR_R=$1;;
    esac
}

# Load config ONCE per shell. Parsed, never `source`d, so a tampered config
# file can't execute code.
_arise_load_config() {
    [[ -n ${_ARISE_LOADED:-} ]] && return 0
    local k v
    if [[ -r $ARISE_CONFIG_FILE ]]; then
        while IFS='=' read -r k v || [[ -n $k ]]; do
            [[ $k == ARISE_EFFECT ]] && ARISE_EFFECT=${v//[\"\']/}
        done < "$ARISE_CONFIG_FILE"
    fi
    _arise_migrate_effect "${ARISE_EFFECT:-$ARISE_DEFAULT_EFFECT}"
    ARISE_EFFECT=$_AR_R
    _arise_is_effect "$ARISE_EFFECT" || ARISE_EFFECT=$ARISE_DEFAULT_EFFECT
    _ARISE_LOADED=1
}

_arise_save_config() {
    mkdir -p "$ARISE_CONFIG_DIR" && printf 'ARISE_EFFECT="%s"\n' "$ARISE_EFFECT" > "$ARISE_CONFIG_FILE"
}

# Find first venv activate script. Result in $_AR_R.
_arise_resolve_venv() {
    local c
    for c in "${ARISE_VENV_CANDIDATES[@]}"; do
        if [[ -f ./$c/bin/activate ]]; then _AR_R=./$c/bin/activate; return 0; fi
    done
    return 1
}

_arise_create_venv() {
    local dir=${1:-$ARISE_DEFAULT_VENV_DIR} py
    if [[ -f ./$dir/bin/activate ]]; then
        printf '%s!%s A dungeon already exists here: %s%s%s\n' "$C_YELLOW" "$C_RESET" "$C_BLUE" "$dir" "$C_RESET"
        return 0
    fi
    if   command -v python3 >/dev/null 2>&1; then py=python3
    elif command -v python  >/dev/null 2>&1; then py=python
    else
        printf '%s✗%s Python not found (requires python3 or python)\n' "$C_RED" "$C_RESET"; return 1
    fi
    printf '%s→%s A Gate is opening: %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_VIOLET" "$dir" "$C_RESET"
    "$py" -m venv "$dir" || true
    if [[ ! -f ./$dir/bin/activate ]]; then
        printf '%s✗%s The Gate collapsed. Failed to create %s\n' "$C_RED" "$C_RESET" "$dir"; return 1
    fi
    printf '%s✓%s Dungeon generated: %s%s%s\n' "$C_GREEN" "$C_RESET" "$C_VIOLET" "$dir" "$C_RESET"
}

_arise_can_render() {
    [[ -t 1 && -z ${ARISE_NO_EFFECTS:-} && -n ${TERM:-} && $TERM != dumb ]]
}

_arise_describe() {
    case "$1" in
        shadow)   _AR_R="Shadow extraction: smoke rises, the soldier answers (default)";;
        system)   _AR_R="The System window: a Daily Quest completes";;
        gate)     _AR_R="A spiral dimensional Gate tears open";;
        monarch)  _AR_R="The Shadow Monarch's aura radiates outward";;
        instant)  _AR_R="The System glitches, an Instant Dungeon spawns";;
        stealth)  _AR_R="Quiet and minimal; the shadows fade you in";;
        levelup)  _AR_R="Level up! Stat allocation boot sequence";;
        exchange) _AR_R="Shadow Exchange teleport streaks";;
        rank)     _AR_R="Hunter ranking scan, E-Rank up to S-Rank";;
        none)     _AR_R="No animation";;
    esac
}

_arise_landing_line() {
    case "$1" in
        shadow)   _AR_R="Shadow extraction successful.";;
        system)   _AR_R="Welcome, Player.";;
        gate)     _AR_R="You have entered the dungeon.";;
        monarch)  _AR_R="The Shadow Monarch has awakened.";;
        instant)  _AR_R="Instant Dungeon: access granted.";;
        stealth)  _AR_R="Stealth active.";;
        levelup)  _AR_R="Level up! Environment synchronized.";;
        exchange) _AR_R="Shadow Exchange complete.";;
        rank)     _AR_R="Rank confirmed: S.";;
        *)        _AR_R="Environment active.";;
    esac
}

_arise_list_effects() {
    local e
    printf '%s[ SYSTEM ] Available Effects%s\n\n' "$C_BBLUE" "$C_RESET"
    for e in "${ARISE_EFFECTS[@]}"; do
        _arise_describe "$e"
        printf '  %s%-9s%s - %s%s%s\n' "$C_WHITE" "$e" "$C_RESET" "$C_GRAY" "$_AR_R" "$C_RESET"
    done
}

_arise_set_effect() {
    local effect
    _arise_migrate_effect "$1"; effect=$_AR_R
    if _arise_is_effect "$effect"; then
        ARISE_EFFECT=$effect
        _arise_save_config
        printf '%s✓%s Awakening style set to: %s%s%s\n' "$C_GREEN" "$C_RESET" "$C_VIOLET" "$effect" "$C_RESET"
    else
        printf '%s✗%s Unknown effect: %s\n  Run %sarise --list%s to see available effects\n' \
            "$C_RED" "$C_RESET" "$1" "$C_BLUE" "$C_RESET"
        return 1
    fi
}

_arise_preview() {
    local effect
    _arise_migrate_effect "${1:-$ARISE_EFFECT}"; effect=$_AR_R
    if ! _arise_is_effect "$effect"; then
        printf '%s✗%s Unknown effect: %s\n' "$C_RED" "$C_RESET" "$1"; return 1
    fi
    if [[ $effect != none ]]; then
        if _arise_can_render; then
            _arise_run_effect "$effect"
        else
            printf '%s!%s Terminal does not support visual effects in this session\n' "$C_YELLOW" "$C_RESET"
        fi
    fi
    printf '\n%sPreviewed effect: %s%s%s\n' "$C_GRAY" "$C_VIOLET" "$effect" "$C_RESET"
}

_arise_opt() { printf '  %s%-26s%s %s\n' "$C_WHITE" "$1" "$C_RESET" "$2"; }

_arise_help() {
    printf '%s%s' "$C_PURPLE" "$C_BOLD"
    cat <<'EOF'
    ___    ____  _________ ______
   /   |  / __ \/  _/ ___// ____/
  / /| | / /_/ // / \__ \/ __/
 / ___ |/ _, _// / ___/ / /___
/_/  |_/_/ |_/___//____/_____/
EOF
    printf '%s%sEnter the dungeon. Awaken your environment. (Solo Leveling edition)%s\n\n' "$C_RESET" "$C_GRAY" "$C_RESET"
    printf '%sUSAGE:%s\n' "$C_BOLD" "$C_RESET"
    _arise_opt "arise"                    "Enter the dungeon (activate the venv)"
    _arise_opt "arise --create [name]"    "Open a new Gate (create + activate a venv)"
    _arise_opt "arise --retreat"          "Leave the dungeon (deactivate)"
    _arise_opt "arise --set <effect>"     "Set your awakening style"
    _arise_opt "arise --list"             "List available effects"
    _arise_opt "arise --preview [effect]" "Preview an effect"
    _arise_opt "arise --current"          "Show current effect"
    _arise_opt "arise --help"             "Show this help message"
    _arise_opt "arise --version"          "Show version"
    printf '\n%sENVIRONMENT:%s\n' "$C_BOLD" "$C_RESET"
    _arise_opt "ARISE_NO_EFFECTS=1"       "Skip all animations (Ctrl-C also skips one)"
    printf '\n'
}

_arise_retreat() {
    if declare -f deactivate >/dev/null; then
        deactivate
        printf '\n'
        _arise_window "SYSTEM" "You have left the dungeon." "Return anytime: arise"
        printf '\033]2;%s\007' "Terminal"
    else
        printf '%s!%s You are not inside a dungeon.\n' "$C_YELLOW" "$C_RESET"
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────
arise() {
    _arise_load_config

    local venv_path="" target_dir project

    case "${1:-}" in
        --help|-h)    _arise_help; return 0 ;;
        --version|-v) printf '%sarise%s v%s %s(Solo Leveling edition)%s\n' \
                          "$C_VIOLET" "$C_RESET" "$ARISE_VERSION" "$C_GRAY" "$C_RESET"; return 0 ;;
        --list|-l)    _arise_list_effects; return 0 ;;
        --set|-s)
            if [[ -z ${2:-} ]]; then
                printf '%s✗%s Please specify an effect\n  Run %sarise --list%s to see available effects\n' \
                    "$C_RED" "$C_RESET" "$C_BLUE" "$C_RESET"
                return 1
            fi
            _arise_set_effect "$2"; return $? ;;
        --preview|-p) _arise_preview "${2:-}"; return $? ;;
        --current|-c) printf 'Current effect: %s%s%s\n' "$C_VIOLET" "$ARISE_EFFECT" "$C_RESET"; return 0 ;;
        --retreat|--leave) _arise_retreat; return $? ;;
        --create)
            target_dir=${2:-$ARISE_DEFAULT_VENV_DIR}
            [[ $target_dir == -* ]] && target_dir=$ARISE_DEFAULT_VENV_DIR
            _arise_create_venv "$target_dir" || return 1
            venv_path=./${target_dir}/bin/activate ;;
        "") ;;
        *)
            printf '%s✗%s Unknown option: %s\n  Run %sarise --help%s for usage\n' \
                "$C_RED" "$C_RESET" "$1" "$C_BLUE" "$C_RESET"
            return 1 ;;
    esac

    if [[ -z $venv_path ]]; then
        _arise_resolve_venv && venv_path=$_AR_R
    fi

    if [[ -z $venv_path || ! -f $venv_path ]]; then
        printf '%s[!] No Gate found in %s%s\n' "$C_RED" "$PWD" "$C_RESET"
        printf '%s(Looked for %s)%s\n' "$C_GRAY" "${ARISE_VENV_CANDIDATES[*]}" "$C_RESET"
        printf '%s(Tip: run %sarise --create%s%s to open one)%s\n' "$C_GRAY" "$C_BLUE" "$C_RESET" "$C_GRAY" "$C_RESET"
        return 1
    fi

    # Already inside this exact dungeon? Don't replay the animation.
    if [[ -n ${VIRTUAL_ENV:-} && $VIRTUAL_ENV -ef ${venv_path%/bin/activate} ]]; then
        printf '%s!%s You are already inside this dungeon.\n' "$C_YELLOW" "$C_RESET"
        return 0
    fi

    if [[ $ARISE_EFFECT != none ]] && _arise_can_render; then
        _arise_run_effect "$ARISE_EFFECT"
    fi

    # shellcheck disable=SC1090
    source "$venv_path"

    project=${PWD##*/}
    printf '\033]2;⚔ ARISE (%s)\007' "$project"

    _arise_clear
    _arise_landing_line "$ARISE_EFFECT"
    _arise_window "SYSTEM" \
        "$_AR_R" \
        "Dungeon : ${project}" \
        "Class   : $(python -V 2>&1)"
}