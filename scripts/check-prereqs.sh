#!/bin/sh
set -eu

WAIT=false

case "${1:-}" in
  --wait)
    WAIT=true
    ;;
  "")
    ;;
  *)
    printf 'Usage: %s [--wait]\n' "$0" >&2
    exit 2
    ;;
esac

print_install_commands() {
  dependency=$1

  case "$dependency" in
    chezmoi)
      case "$(uname -s)" in
        Darwin)
          printf '  brew install chezmoi\n'
          ;;
        Linux)
          printf '  sh -c "$(curl -fsLS get.chezmoi.io)"\n'
          ;;
      esac
      ;;
    zsh)
      case "$(uname -s)" in
        Darwin)
          printf '  brew install zsh\n'
          ;;
        Linux)
          printf '  sudo apt install zsh\n'
          printf '  sudo dnf install zsh\n'
          printf '  sudo pacman -S zsh\n'
          ;;
      esac
      ;;
    oh-my-zsh)
      printf '  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"\n'
      ;;
    powerlevel10k)
      printf '  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"\n'
      ;;
  esac
}

check_prereqs() {
  os=$(uname -s)

  case "$os" in
    Darwin|Linux)
      ;;
    *)
      printf 'Unsupported OS: %s\n' "$os" >&2
      printf 'This installer currently supports macOS and Linux only.\n' >&2
      return 1
      ;;
  esac

  missing=false

  if ! command -v chezmoi >/dev/null 2>&1; then
    printf 'Missing required dependency: chezmoi\n' >&2
    print_install_commands chezmoi >&2
    missing=true
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    printf 'Missing required dependency: zsh\n' >&2
    print_install_commands zsh >&2
    missing=true
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    printf 'Missing required dependency: oh-my-zsh\n' >&2
    print_install_commands oh-my-zsh >&2
    missing=true
  fi

  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    printf 'Missing required dependency: powerlevel10k Oh My Zsh theme\n' >&2
    print_install_commands powerlevel10k >&2
    missing=true
  fi

  if [ "$missing" = true ]; then
    return 1
  fi

  return 0
}

if [ "$WAIT" = true ]; then
  while ! check_prereqs; do
    printf '\nInstall the missing dependencies manually, then press Enter to re-check. '
    read -r _
    printf '\n'
  done
else
  check_prereqs
fi
