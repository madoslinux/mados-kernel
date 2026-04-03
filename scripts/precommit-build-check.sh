#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! command -v makepkg >/dev/null 2>&1; then
  printf 'makepkg is required for pre-push kernel build check\n' >&2
  exit 1
fi

flags_env="${MADOS_PRECOMMIT_MAKEPKG_FLAGS:---noconfirm --nopackage}"
read -r -a makepkg_flags <<<"$flags_env"

printf 'Running local kernel build check with makepkg -s %s\n' "$flags_env"
makepkg -s "${makepkg_flags[@]}"

"$repo_root/scripts/validate-kernel-config.sh" "$repo_root/src/build-generic/.config"
