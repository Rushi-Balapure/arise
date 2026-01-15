#!/bin/bash

arise() {
    # Dynamically find the venv in the CURRENT folder
    local VENV_PATH="./.venv/bin/activate"

    # Check if it exists here
    if [ ! -f "$VENV_PATH" ]; then
        echo -e "\e[31m[!] No .venv found in $(pwd)\e[0m"
        echo -e "\e[38;5;242m(Run this command inside your project folder)\e[0m"
        return
    fi

    # --- THE ZONE TRANSFORMATION ---
    tput smcup        # Alt-buffer (Full screen takeover)
    tput civis        # Hide cursor
    clear

    cols=$(tput cols)
    lines=$(tput lines)
    mid=$((lines / 2))

    # 1. The "Ignition" - Rapid horizontal line expansion (Matching your 3000us)
    for ((i=1; i<=cols/2; i+=5)); do
        tput cup $mid $((cols/2 - i))
        printf "\e[48;5;51m%$(($i*2))s\e[0m" " " # Cyan Flare
        sleep 0.003
    done

    # 2. The "Neural Flash" (Matching your 40000us)
    printf "\e[?5h"; sleep 0.04; printf "\e[?5l"

    # 3. Centered "Zone" Text with flicker (Matching your 100000us + 0.5s)
    tput cup $mid $(( (cols - 22) / 2 ))
    echo -e "\e[1;37;40m  ENTERING THE ZONE  \e[0m"
    sleep 0.1
    tput cup $mid $(( (cols - 22) / 2 ))
    echo -e "\e[1;30;107m  ENTERING THE ZONE  \e[0m"
    sleep 0.5

    tput rmcup        # Restore main screen
    tput cnorm        # Show cursor

    # --- THE ACTIVATION ---
    source "$VENV_PATH"

    # Update Ghostty Window Title (Pro Touch)
    printf "\033]2;⚡ IN THE ZONE (%s)\007" "$(basename $(pwd))"

    # Wipe history for a "Fresh Start"
    clear

    # Pro-level landing message
    echo -e "\e[1;36m// ZONE_ACCESS_GRANTED\e[0m"
    echo -e "\e[38;5;242mEnvironment: $(basename $(pwd)) | $(python --version)\e[0m"
}
