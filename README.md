# ⚔️ Arise

<p align="center">
  <img src="https://img.shields.io/badge/bash-4.0%2B-green?style=flat-square&logo=gnu-bash" alt="Bash 4.0+">
  <img src="https://img.shields.io/badge/zsh-supported-blueviolet?style=flat-square" alt="Zsh">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey?style=flat-square" alt="Platform">
</p>

<p align="center">
  <strong>Enter the dungeon. Awaken your environment. 🌑</strong>
</p>

<p align="center">
  A Solo Leveling-inspired way to activate Python virtual environments.<br>
  Replace <code>source .venv/bin/activate</code> with a System window, a Gate, or a shadow extraction.
</p>

---

## ✨ Features

- 🌑 **10 Solo Leveling Effects** - Shadow extraction, System windows, Gates, level-ups and more
- 🪟 **The System Window** - A blue "[ SYSTEM ]" panel confirms every successful entry
- 🚪 **Open a Gate** - `arise --create` generates a venv and steps right in
- 🏃 **Retreat Anytime** - `arise --retreat` leaves the dungeon (deactivates the venv)
- 🎯 **Smart Detection** - Finds `.venv`, `venv`, `env`, or `.env` automatically
- 🧠 **Smart Fallback** - Skips animations in non-interactive terminals
- 🖥️ **Terminal Title** - Shows `⚔ ARISE (project)` while you're inside
- 🪶 **Zero Dependencies** - Pure shell, no `bc` required

## 🎥 Effects Gallery

| Effect | Inspired by | Description |
|--------|-------------|-------------|
| `shadow` | Shadow Extraction | Purple shadow smoke rises, then **A R I S E** *(default)* |
| `system` | The System | A blue System window opens, a Daily Quest completes |
| `gate` | Dungeon Gates | A spiral dimensional Gate tears open |
| `monarch` | Shadow Monarch | The Monarch's aura radiates outward in waves |
| `instant` | Instant Dungeon | The System glitches and an Instant Dungeon spawns |
| `stealth` | Stealth | Quiet and minimal, the shadows fade you in |
| `levelup` | Level Up | Stat allocation boot sequence |
| `exchange` | Shadow Exchange | Teleport streaks burst from the centre |
| `rank` | Hunter Ranks | Scan from E-Rank all the way up to S-Rank |
| `none` | - | No animation (instant activation) |

When it's over, you land in a System window:

```
┌─ SYSTEM ────────────────────────┐
│ Shadow extraction successful.   │
│ Dungeon : my-project            │
│ Class   : Python 3.12.3         │
└─────────────────────────────────┘
```

## 📦 Installation

### Quick Install

```bash
git clone https://github.com/yourusername/arise.git
cd arise
chmod +x install.sh
./install.sh
```

### Manual Install

1. Copy `arise.sh` to a location of your choice:
   ```bash
   mkdir -p ~/.local/share/arise
   cp arise.sh ~/.local/share/arise/
   ```

2. Add to your shell rc file (`.bashrc` or `.zshrc`):
   ```bash
   source ~/.local/share/arise/arise.sh
   ```

3. Restart your terminal or source your rc file:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

## 🚀 Usage

Walk into any Python project with a virtual environment directory and say the word:

```bash
arise
```

### Commands

```bash
arise                      # Enter the dungeon (activate the venv)
arise --create [name]      # Open a new Gate (create + activate a venv)
arise --retreat            # Leave the dungeon (deactivate)
arise --set <effect>       # Set your awakening style
arise --list               # List all available effects
arise --preview [effect]   # Preview an effect without activating
arise --current            # Show current effect setting
arise --help               # Show help message
arise --version            # Show version
```

### Examples

```bash
# Switch to the Gate effect
arise --set gate

# Preview the Level Up sequence
arise --preview levelup

# Open a new Gate at the default .venv and step inside
arise --create

# Open a Gate with a custom folder name
arise --create .venv-dev

# Done for the day? Leave the dungeon
arise --retreat
```

## ⚙️ Configuration

Your awakening style is saved in `~/.config/arise/config` and persists across sessions.

```bash
arise --set shadow
```

> **Upgrading from v1?** Old effect names are migrated automatically
> (`zone`→`shadow`, `matrix`→`gate`, `pulse`→`monarch`, `glitch`→`instant`,
> `minimal`→`stealth`, `cyber`→`levelup`, `warp`→`exchange`, `neon`→`system`,
> `scanline`→`rank`).

## 🗑️ Uninstallation

```bash
./uninstall.sh
```

Or manually:
```bash
rm -rf ~/.local/share/arise
rm -rf ~/.config/arise
# Remove the "arise initialize" block from your .bashrc or .zshrc
```

## 📋 Requirements

- Bash 4.0+ or Zsh
- A terminal emulator with ANSI escape code support (256-color recommended for the full purple glow)
- `tput` (usually pre-installed on Linux/macOS)
- Python 3 with the `venv` module (only for `arise --create`)

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest new effects (Igris? Beru? Monarch's Domain?)
- 🔧 Submit pull requests

### Adding a New Effect

1. Add your effect function in `arise.sh`:
   ```bash
   effect_youreffect() {
       local cols rows
       _arise_begin                 # alt screen, hide cursor, clear
       cols=$(tput cols); rows=$(tput lines)

       # Your animation code here
       _arise_center $((rows / 2)) "YOUR TEXT" "$C_VIOLET"
       sleep 0.5

       _arise_end                   # restore screen and cursor
   }
   ```
   Helpers available: `_arise_center`, `_arise_type`, `_arise_box`, `_arise_rep`.

2. Add the name to `ARISE_EFFECTS` and to `list_effects`
3. Add a line for it in `_arise_landing_line`
4. Submit a PR!

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## ⚠️ Disclaimer

Arise is an unofficial fan project inspired by *Solo Leveling*. It is not affiliated with or endorsed by the creators or publishers of the series. All series names and concepts belong to their respective owners.

---

<p align="center">
  Made with 🌑 by developers who believe terminal UX matters
</p>

<p align="center">
  <i>Because activating a virtual environment should feel like awakening as the Shadow Monarch</i>
</p>