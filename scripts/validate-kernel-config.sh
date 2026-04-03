#!/usr/bin/env bash
set -euo pipefail

cfg_file="${1:-src/build-generic/.config}"

if [[ ! -f "$cfg_file" ]]; then
  printf 'Could not find generated config: %s\n' "$cfg_file" >&2
  exit 1
fi

check_cfg() {
  local pattern="$1"
  local message="$2"

  if ! grep -Eq "$pattern" "$cfg_file"; then
    printf 'Validation failed: %s\n' "$message" >&2
    printf 'Pattern: %s\n' "$pattern" >&2
    printf 'Config: %s\n' "$cfg_file" >&2
    exit 1
  fi
}

check_cfg '^CONFIG_DRM_SIMPLEDRM=y$' 'CONFIG_DRM_SIMPLEDRM must be enabled in generic flavor'
check_cfg '^CONFIG_FRAMEBUFFER_CONSOLE=y$' 'CONFIG_FRAMEBUFFER_CONSOLE must be enabled in generic flavor'

printf 'Kernel config validation passed: %s\n' "$cfg_file"
