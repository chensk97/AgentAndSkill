#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENTS_DIR="${SCRIPT_DIR}/agents"
SOURCE_SKILLS_DIR="${SCRIPT_DIR}/skills"

COPILOT_HOME="${COPILOT_HOME:-${HOME}/.copilot}"
TARGET_AGENTS_DIR="${COPILOT_HOME}/agents"
TARGET_SKILLS_DIR="${COPILOT_HOME}/skills"

DRY_RUN=0
VERBOSE=0
HAS_CHANGES=0

usage() {
  cat <<'EOF'
Usage: ./sync_to_copilot.sh [options]

Compare the repository's agents/ and skills/ with the target Copilot home,
then apply incremental overwrite sync when differences are found.

Options:
  --dry-run       Show pending changes without writing files
  --verbose       Print rsync itemized changes while syncing
  -h, --help      Show this help message

Environment:
  COPILOT_HOME    Override the default target directory (default: $HOME/.copilot)

Behavior:
  - Source of truth is this script's repository root
  - Sync targets are <COPILOT_HOME>/agents and <COPILOT_HOME>/skills
  - Only additive / overwrite sync is performed
  - Extra files already present in the target are NOT deleted
EOF
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
}

trim_rsync_output() {
  sed \
    -e '/^sending incremental file list$/d' \
    -e '/^sent [0-9].* bytes  received [0-9].* bytes  [0-9].*$/d' \
    -e '/^total size is [0-9].*$/d' \
    -e '/^$/d'
}

sync_dir() {
  local label="$1"
  local src_dir="$2"
  local dst_dir="$3"
  local preview_output
  local preview_status
  local preview_dst_dir="$dst_dir"
  local preview_root_dir=""

  if [[ "$DRY_RUN" -eq 1 && ! -d "$COPILOT_HOME" ]]; then
    preview_root_dir="$(mktemp -d)"
    preview_dst_dir="${preview_root_dir}/$(basename -- "$dst_dir")"
    printf '[%s] target root does not exist yet, dry-run compares against an empty tree: %s\n' "$label" "$COPILOT_HOME"
  fi

  set +e
  preview_output="$({
    rsync \
      --archive \
      --checksum \
      --omit-dir-times \
      --itemize-changes \
      --dry-run \
      --exclude='.DS_Store' \
      --exclude='.git/' \
      "$src_dir/" "$preview_dst_dir/"
  } 2>&1 | trim_rsync_output)"
  preview_status=$?
  set -e

  if [[ -n "$preview_root_dir" ]]; then
    rm -rf "$preview_root_dir"
  fi

  if [[ "$preview_status" -ne 0 ]]; then
    printf '[%s] rsync preview failed.\n' "$label" >&2
    if [[ -n "$preview_output" ]]; then
      printf '%s\n' "$preview_output" >&2
    fi
    exit "$preview_status"
  fi

  if [[ -z "$preview_output" ]]; then
    printf '[%s] no differences detected.\n' "$label"
    return 0
  fi

  HAS_CHANGES=1
  printf '[%s] differences detected:\n' "$label"
  printf '%s\n' "$preview_output"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[%s] dry-run only, no files were changed.\n' "$label"
    return 0
  fi

  if [[ "$VERBOSE" -eq 1 ]]; then
    rsync \
      --archive \
      --checksum \
      --omit-dir-times \
      --itemize-changes \
      --exclude='.DS_Store' \
      --exclude='.git/' \
      "$src_dir/" "$dst_dir/"
  else
    rsync \
      --archive \
      --checksum \
      --omit-dir-times \
      --exclude='.DS_Store' \
      --exclude='.git/' \
      "$src_dir/" "$dst_dir/"
  fi

  printf '[%s] incremental overwrite sync completed.\n' "$label"
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    --verbose)
      VERBOSE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown option: %s\n\n' "$arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_command rsync

if [[ ! -d "$SOURCE_AGENTS_DIR" ]]; then
  printf 'Error: source directory not found: %s\n' "$SOURCE_AGENTS_DIR" >&2
  exit 1
fi

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Error: source directory not found: %s\n' "$SOURCE_SKILLS_DIR" >&2
  exit 1
fi

printf 'Source root   : %s\n' "$SCRIPT_DIR"
printf 'Copilot home  : %s\n' "$COPILOT_HOME"
printf 'Sync mode     : %s\n' "$([[ "$DRY_RUN" -eq 1 ]] && printf 'dry-run' || printf 'apply')"

if [[ "$DRY_RUN" -ne 1 ]]; then
  mkdir -p "$COPILOT_HOME"
fi

sync_dir "agents" "$SOURCE_AGENTS_DIR" "$TARGET_AGENTS_DIR"
sync_dir "skills" "$SOURCE_SKILLS_DIR" "$TARGET_SKILLS_DIR"

if [[ "$HAS_CHANGES" -eq 0 ]]; then
  printf 'Done: target directories are already in sync.\n'
elif [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Done: dry-run finished, rerun without --dry-run to apply changes.\n'
else
  printf 'Done: repository agents/ and skills/ have been synced to %s.\n' "$COPILOT_HOME"
fi