#!/bin/bash
# ┌─────────────────────────────────────────────────────────────────┐
# │  ARISE Uninstaller                                              │
# │  Removes arise from your system                                 │
# └─────────────────────────────────────────────────────────────────┘

# Colors
C_RESET="\e[0m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_CYAN="\e[36m"
C_GRAY="\e[38;5;242m"

INSTALL_DIR="${HOME}/.local/share/arise"
CONFIG_DIR="${HOME}/.config/arise"

echo -e "${C_CYAN}Uninstalling Arise...${C_RESET}\n"

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${C_CYAN}→${C_RESET} Removing ${INSTALL_DIR}..."
    rm -rf "$INSTALL_DIR"
    echo -e "${C_GREEN}✓${C_RESET} Removed installation directory"
else
    echo -e "${C_YELLOW}!${C_RESET} Installation directory not found"
fi

# Remove config directory
if [[ -d "$CONFIG_DIR" ]]; then
    echo -e "${C_CYAN}→${C_RESET} Removing ${CONFIG_DIR}..."
    rm -rf "$CONFIG_DIR"
    echo -e "${C_GREEN}✓${C_RESET} Removed config directory"
else
    echo -e "${C_YELLOW}!${C_RESET} Config directory not found"
fi

# Note about shell rc
echo ""
echo -e "${C_YELLOW}Note:${C_RESET} You may want to remove the arise source line from your shell rc file"
echo -e "      Look for a line containing 'arise.sh' in your .bashrc or .zshrc"
echo ""
echo -e "${C_GREEN}✓ Arise has been uninstalled${C_RESET}"

