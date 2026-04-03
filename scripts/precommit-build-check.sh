#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! command -v makepkg >/dev/null 2>&1; then
  printf 'makepkg is required for pre-push kernel build check\n' >&2
  exit 1
fi

if command -v pacman >/dev/null 2>&1; then
  required_deps=(
    bc cpio gettext libelf pahole perl python tar xz zstd git ccache ncurses clang lld llvm binutils
  )
  missing_deps=($(pacman -T "${required_deps[@]}"))
  if (( ${#missing_deps[@]} > 0 )); then
    printf 'Missing build dependencies for local kernel validation:\n' >&2
    printf '  - %s\n' "${missing_deps[@]}" >&2
    printf 'Install them with:\n' >&2
    printf '  sudo pacman -S --needed %s\n' "${missing_deps[*]}" >&2
    exit 1
  fi
fi

printf 'Running strict local kernel build check with makepkg -s --noconfirm -f -C\n'
makepkg -s --noconfirm -f -C </dev/null

"$repo_root/scripts/validate-kernel-config.sh" "$repo_root/src/build-generic/.config"
