#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE Uninstaller - Solo Leveling Edition                      │
# │  Returns the shadows to the void                                │
# └─────────────────────────────────────────────────────────────────┘

# Colors
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[38;5;39m"
C_VIOLET="\e[38;5;135m"
C_GRAY="\e[38;5;242m"

INSTALL_DIR="${HOME}/.local/share/arise"
CONFIG_DIR="${HOME}/.config/arise"
ARISE_BLOCK_START="# >>> arise initialize >>>"
ARISE_BLOCK_END="# <<< arise initialize <<<"

echo -e "${C_BLUE}[ SYSTEM ]${C_RESET} Dismissing the shadow...\n"

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${C_BLUE}→${C_RESET} Removing ${INSTALL_DIR}..."
    rm -rf "$INSTALL_DIR"
    echo -e "${C_GREEN}✓${C_RESET} Removed installation directory"
else
    echo -e "${C_YELLOW}!${C_RESET} Installation directory not found"
fi

# Remove config directory
if [[ -d "$CONFIG_DIR" ]]; then
    echo -e "${C_BLUE}→${C_RESET} Removing ${CONFIG_DIR}..."
    rm -rf "$CONFIG_DIR"
    echo -e "${C_GREEN}✓${C_RESET} Removed config directory"
else
    echo -e "${C_YELLOW}!${C_RESET} Config directory not found"
fi

# Remove shell configuration entries
cleanup_shell_rc() {
    local rc_file="$1"
    local tmp_file

    if [[ ! -f "$rc_file" ]]; then
        return
    fi

    if grep -Fq "$ARISE_BLOCK_START" "$rc_file"; then
        tmp_file=$(mktemp)
        awk -v start="$ARISE_BLOCK_START" -v end="$ARISE_BLOCK_END" '
            $0 == start { in_block = 1; next }
            $0 == end { in_block = 0; next }
            !in_block { print }
        ' "$rc_file" > "$tmp_file"
        mv "$tmp_file" "$rc_file"
        echo -e "${C_GREEN}✓${C_RESET} Removed managed Arise block from ${rc_file}"
    elif grep -q "arise.sh" "$rc_file"; then
        tmp_file=$(mktemp)
        awk '
            $0 ~ /arise\.sh/ { next }
            $0 == "# Arise - Virtual environment activator with style" { next }
            $0 == "# Arise - Shadow Monarch'"'"'s virtual environment activator" { next }
            { print }
        ' "$rc_file" > "$tmp_file"
        mv "$tmp_file" "$rc_file"
        echo -e "${C_GREEN}✓${C_RESET} Removed legacy Arise source line from ${rc_file}"
    fi
}

echo -e "${C_BLUE}→${C_RESET} Cleaning shell startup files..."
cleanup_shell_rc "${HOME}/.bashrc"
cleanup_shell_rc "${HOME}/.bash_profile"
cleanup_shell_rc "${HOME}/.zshrc"

echo ""
echo -e "${C_GREEN}✓ Arise has been uninstalled${C_RESET}"
echo -e "${C_GRAY}The shadows return to the void. Restart your terminal to finish.${C_RESET}"