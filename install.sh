#!/bin/sh
set -eu

REPO_URL="git@github.com:huguesmcneilduval-il/chezmoi.git"

case "$(uname -s)" in
  Darwin|Linux)
    ;;
  *)
    printf 'Unsupported OS: %s\n' "$(uname -s)" >&2
    printf 'This installer currently supports macOS and Linux only.\n' >&2
    exit 1
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
  missing=false

  if ! command -v chezmoi >/dev/null 2>&1; then
    printf 'Missing required dependency: chezmoi\n'
    print_install_commands chezmoi
    missing=true
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    printf 'Missing required dependency: zsh\n'
    print_install_commands zsh
    missing=true
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    printf 'Missing required dependency: oh-my-zsh\n'
    print_install_commands oh-my-zsh
    missing=true
  fi

  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    printf 'Missing required dependency: powerlevel10k Oh My Zsh theme\n'
    print_install_commands powerlevel10k
    missing=true
  fi

  if [ "$missing" = true ]; then
    return 1
  fi

  return 0
}

while ! check_prereqs; do
  printf '\nInstall the missing dependencies manually, then press Enter to re-check. '
  read -r _
  printf '\n'
done

if chezmoi source-path >/dev/null 2>&1; then
  printf 'chezmoi is already initialized at:\n'
  chezmoi source-path
else
  chezmoi init "$REPO_URL"
fi

printf '\nShowing pending chezmoi changes:\n\n'
chezmoi diff

printf '\nApply these changes? [y/N] '
read -r answer

case "$answer" in
  y|Y|yes|YES)
    chezmoi apply
    ;;
  *)
    printf 'Skipped chezmoi apply.\n'
    ;;
esac
