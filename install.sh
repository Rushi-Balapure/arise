#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE Installer                                                │
# │  Installs arise to your shell configuration                     │
# └─────────────────────────────────────────────────────────────────┘

set -e

# Colors
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_CYAN="\e[36m"
C_GRAY="\e[38;5;242m"
C_BOLD="\e[1m"

# Installation paths
INSTALL_DIR="${HOME}/.local/share/arise"
SCRIPT_NAME="arise.sh"
ARISE_BLOCK_START="# >>> arise initialize >>>"
ARISE_BLOCK_END="# <<< arise initialize <<<"

echo -e "${C_CYAN}${C_BOLD}"
echo "    ___    ____  _________ ______"
echo "   /   |  / __ \/  _/ ___// ____/"
echo "  / /| | / /_/ // / \__ \/ __/   "
echo " / ___ |/ _, _// / ___/ / /___   "
echo "/_/  |_/_/ |_/___//____/_____/   "
echo -e "${C_RESET}"
echo -e "${C_GRAY}Activate Python virtual environments with style${C_RESET}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if arise.sh exists
if [[ ! -f "${SCRIPT_DIR}/${SCRIPT_NAME}" ]]; then
    echo -e "${C_RED}✗${C_RESET} Error: ${SCRIPT_NAME} not found in ${SCRIPT_DIR}"
    exit 1
fi

# Create installation directory
echo -e "${C_CYAN}→${C_RESET} Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Copy the script
echo -e "${C_CYAN}→${C_RESET} Installing arise..."
cp "${SCRIPT_DIR}/${SCRIPT_NAME}" "${INSTALL_DIR}/${SCRIPT_NAME}"
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

# Detect shell and rc file
detect_shell_rc() {
    local shell_name=$(basename "$SHELL")
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
        echo -e "${C_YELLOW}!${C_RESET} Arise already configured in ${SHELL_RC}"
    elif grep -q "arise.sh" "$SHELL_RC"; then
        echo -e "${C_YELLOW}!${C_RESET} Existing arise config detected in ${SHELL_RC}"
        echo -e "  ${C_GRAY}Keeping current shell config unchanged${C_RESET}"
    else
        echo -e "${C_CYAN}→${C_RESET} Adding arise to ${SHELL_RC}..."
        {
            echo ""
            echo "$ARISE_BLOCK_START"
            echo "# Arise - Virtual environment activator with style"
            echo "$SOURCE_LINE"
            echo "$ARISE_BLOCK_END"
        } >> "$SHELL_RC"
        echo -e "${C_GREEN}✓${C_RESET} Added to ${SHELL_RC}"
    fi
else
    echo -e "${C_YELLOW}!${C_RESET} Could not detect shell configuration file"
    echo -e "  Add this line to your shell rc file manually:"
    echo -e "  ${C_CYAN}${SOURCE_LINE}${C_RESET}"
fi

# Create config directory
echo -e "${C_CYAN}→${C_RESET} Creating config directory..."
mkdir -p "${HOME}/.config/arise"

# Success message
echo ""
echo -e "${C_GREEN}${C_BOLD}✓ Installation complete!${C_RESET}\n"
echo -e "To start using arise, either:"
echo -e "  ${C_CYAN}1.${C_RESET} Restart your terminal"
echo -e "  ${C_CYAN}2.${C_RESET} Run: ${C_CYAN}source ${SHELL_RC}${C_RESET}\n"
echo -e "Then navigate to a Python project with a .venv and run:"
echo -e "  ${C_CYAN}arise${C_RESET}\n"
echo -e "To see all options:"
echo -e "  ${C_CYAN}arise --help${C_RESET}\n"
echo -e "${C_GRAY}Enjoy coding in style! ⚡${C_RESET}"
