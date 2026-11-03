#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE Installer - Solo Leveling Edition                        │
# │  Installs arise to your shell configuration                     │
# └─────────────────────────────────────────────────────────────────┘

set -e

# Colors
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[38;5;39m"
C_PURPLE="\e[38;5;93m"
C_VIOLET="\e[38;5;135m"
C_GRAY="\e[38;5;242m"
C_BOLD="\e[1m"

# Installation paths
INSTALL_DIR="${HOME}/.local/share/arise"
SCRIPT_NAME="arise.sh"
ARISE_BLOCK_START="# >>> arise initialize >>>"
ARISE_BLOCK_END="# <<< arise initialize <<<"

echo -e "${C_PURPLE}${C_BOLD}"
echo "    ___    ____  _________ ______"
echo "   /   |  / __ \/  _/ ___// ____/"
echo "  / /| | / /_/ // / \__ \/ __/   "
echo " / ___ |/ _, _// / ___/ / /___   "
echo "/_/  |_/_/ |_/___//____/_____/   "
echo -e "${C_RESET}"
echo -e "${C_GRAY}Enter the dungeon. Awaken your environment.${C_RESET}\n"
echo -e "${C_BLUE}[ SYSTEM ]${C_RESET} You have been chosen as a Player. Beginning installation...\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if arise.sh exists
if [[ ! -f "${SCRIPT_DIR}/${SCRIPT_NAME}" ]]; then
    echo -e "${C_RED}✗${C_RESET} Error: ${SCRIPT_NAME} not found in ${SCRIPT_DIR}"
    exit 1
fi

# Create installation directory
echo -e "${C_BLUE}→${C_RESET} Preparing the dungeon..."
mkdir -p "$INSTALL_DIR"

# Copy the script
echo -e "${C_BLUE}→${C_RESET} Binding the shadow to your terminal..."
cp "${SCRIPT_DIR}/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

# Detect shell and rc file
detect_shell_rc() {
    local shell_name
    shell_name=$(basename "$SHELL")
    case "$shell_name" in
        bash)
            if [[ -f "${HOME}/.bashrc" ]]; then
                echo "${HOME}/.bashrc"
            elif [[ -f "${HOME}/.bash_profile" ]]; then
                echo "${HOME}/.bash_profile"
            else
                echo "${HOME}/.bashrc"
            fi
            ;;
        zsh)
            echo "${HOME}/.zshrc"
            ;;
        *)
            echo ""
            ;;
    esac
}

SHELL_RC=$(detect_shell_rc)
SOURCE_LINE="source \"${INSTALL_DIR}/${SCRIPT_NAME}\""

# Add to shell rc if not already present
if [[ -n "$SHELL_RC" ]]; then
    touch "$SHELL_RC"

    if grep -Fq "$ARISE_BLOCK_START" "$SHELL_RC"; then
        echo -e "${C_YELLOW}!${C_RESET} Arise is already configured in ${SHELL_RC}"
    elif grep -q "arise.sh" "$SHELL_RC"; then
        echo -e "${C_YELLOW}!${C_RESET} Existing arise config detected in ${SHELL_RC}"
        echo -e "  ${C_GRAY}Keeping current shell config unchanged${C_RESET}"
    else
        echo -e "${C_BLUE}→${C_RESET} Writing the contract into ${SHELL_RC}..."
        {
            echo ""
            echo "$ARISE_BLOCK_START"
            echo "# Arise - Shadow Monarch's virtual environment activator"
            echo "$SOURCE_LINE"
            echo "$ARISE_BLOCK_END"
        } >> "$SHELL_RC"
        echo -e "${C_GREEN}✓${C_RESET} Added to ${SHELL_RC}"
    fi
else
    echo -e "${C_YELLOW}!${C_RESET} Could not detect shell configuration file"
    echo -e "  Add this line to your shell rc file manually:"
    echo -e "  ${C_BLUE}${SOURCE_LINE}${C_RESET}"
fi

# Create config directory
mkdir -p "${HOME}/.config/arise"

# Success message
echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Awakening complete!${C_RESET}\n"
echo -e "To start using arise, either:"
echo -e "  ${C_VIOLET}1.${C_RESET} Restart your terminal"
if [[ -n "$SHELL_RC" ]]; then
    echo -e "  ${C_VIOLET}2.${C_RESET} Run: ${C_BLUE}source ${SHELL_RC}${C_RESET}"
fi
echo ""
echo -e "Then walk into a Python project with a .venv and say the word:"
echo -e "  ${C_VIOLET}arise${C_RESET}\n"
echo -e "No dungeon yet? Open a Gate:"
echo -e "  ${C_VIOLET}arise --create${C_RESET}\n"
echo -e "To see all options:"
echo -e "  ${C_VIOLET}arise --help${C_RESET}\n"
echo -e "${C_GRAY}Arise. ⚔${C_RESET}"