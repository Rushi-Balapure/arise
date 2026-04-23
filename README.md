# 🚀 Arise

<p align="center">
  <img src="https://img.shields.io/badge/bash-4.0%2B-green?style=flat-square&logo=gnu-bash" alt="Bash 4.0+">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey?style=flat-square" alt="Platform">
</p>

<p align="center">
  <strong>Activate Python virtual environments with style ⚡</strong>
</p>

<p align="center">
  Transform your mundane <code>source .venv/bin/activate</code> into an immersive, cinematic experience.
</p>

---

## ✨ Features

- 🎬 **10 Visual Effects** - From minimal to matrix-style animations
- ⚙️ **Configurable** - Set your preferred effect once, use forever
- 🔌 **Easy Install** - One command setup for bash/zsh
- 🎯 **Smart Detection** - Finds `.venv`, `venv`, `env`, or `.env` automatically
- 🛠️ **One-Step Bootstrap** - Create and activate a virtualenv with `arise --create`
- 🖥️ **Terminal Title** - Updates your terminal title with project name

## 🎥 Effects Gallery

| Effect | Description |
|--------|-------------|
| `zone` | Horizontal ignition with neural flash *(default)* |
| `matrix` | Digital rain cascade with Japanese characters |
| `pulse` | Concentric circle expansion from center |
| `glitch` | Corrupted screen with random artifacts |
| `minimal` | Clean, professional fade-in |
| `cyber` | Cyberpunk-style boot sequence |
| `warp` | Star warp speed effect |
| `neon` | Flickering neon sign |
| `scanline` | Retro CRT television scanline |
| `none` | No animation (instant activation) |

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

### Basic Usage

Navigate to any Python project with a virtual environment directory (`.venv`, `venv`, `env`, or `.env`) and run:

```bash
arise
```

### Commands

```bash
arise                      # Activate .venv with current effect
arise --help              # Show help message
arise --list              # List all available effects
arise --set <effect>      # Set your preferred effect
arise --create [name]     # Create and activate a virtual environment
arise --preview [effect]  # Preview an effect without activating
arise --current           # Show current effect setting
arise --version           # Show version
```

### Examples

```bash
# Switch to the matrix effect
arise --set matrix

# Preview the cyber effect
arise --preview cyber

# Create and activate a default .venv
arise --create

# Create and activate a custom environment folder
arise --create .venv-dev

# See all available effects
arise --list

# Activate your environment (uses your saved effect)
arise
```

## ⚙️ Configuration

Your effect preference is saved in `~/.config/arise/config` and persists across sessions.

To change effects:
```bash
arise --set neon
```

## 🗑️ Uninstallation

Run the uninstall script:
```bash
./uninstall.sh
```

Or manually:
```bash
rm -rf ~/.local/share/arise
rm -rf ~/.config/arise
# Remove the source line from your .bashrc or .zshrc
```

## 📋 Requirements

- Bash 4.0+ or Zsh
- A terminal emulator with ANSI escape code support
- `tput` (usually pre-installed on Linux/macOS)
- `bc` (for some effects - usually pre-installed)

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest new effects
- 🔧 Submit pull requests

### Adding a New Effect

1. Add your effect function in `arise.sh`:
   ```bash
   effect_youreffect() {
       tput smcup    # Switch to alternate screen
       tput civis    # Hide cursor
       clear
       
       # Your animation code here
       
       tput rmcup    # Restore main screen
       tput cnorm    # Show cursor
   }
   ```

2. Add it to the `list_effects` function
3. Add it to the valid effects in `set_effect`
4. Submit a PR!

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ⚡ by developers who believe terminal UX matters
</p>

<p align="center">
  <i>Because activating a virtual environment should feel like entering The Zone</i>
</p>
