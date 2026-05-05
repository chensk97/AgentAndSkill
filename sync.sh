#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENTS_DIR="${SCRIPT_DIR}/agents"
SOURCE_SKILLS_DIR="${SCRIPT_DIR}/skills"

# ── Target defaults ──
TARGET=""
AGENT_SUFFIX="md"
DRY_RUN=0
VERBOSE=0
SKIP_CHECK=0
VALIDATE=0
VALIDATE_ONLY=0
HAS_CHANGES=0

# ── Platform-specific paths ──
COPILOT_HOME="${COPILOT_HOME:-${HOME}/.copilot}"
CC_HOME="${AAS_HOME:-${HOME}/.claude/aas-marketplace/plugins/agent-and-skill}"
CC_CACHE_HOME="${HOME}/.claude/plugins/cache/aas-marketplace/agent-and-skill/1.0.0"
CC_PLUGIN_NAME="agent-and-skill"
CC_PLUGIN_VERSION="1.0.0"
CC_PLUGIN_DESC="Multi-agent project orchestration and learning workflow system for Claude Code"
CC_MARKETPLACE_NAME="aas-marketplace"
CC_MARKETPLACE_DESC="Agent and Skill marketplace for Claude Code - multi-agent orchestration and learning workflows"
CC_MARKETPLACE_OWNER_NAME="AAS"
CC_MARKETPLACE_OWNER_EMAIL="aas@local"

OPENCODE_HOME="${OPENCODE_HOME:-${HOME}/.opencode}"

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
  cat <<'EOF'
Usage: ./sync.sh --target <platform> [options]

Sync agents/ and skills/ from this repository to the target platform
directory, applying platform-specific post-processing as needed.

Required:
  -t, --target <platform>   Deployment target: copilot | claude-code | opencode

Options:
  --agent-suffix <suffix>   Agent file suffix for copilot target: md | agent.md
                            (default: md)
  --dry-run                 Show pending changes without writing files
  --verbose                 Print rsync itemized changes while syncing
  --skip-check              Skip superpowers plugin check
  --validate                Run repository validation before syncing
  --validate-only           Run repository validation and exit without syncing
  -h, --help                Show this help message

Environment:
  COPILOT_HOME              Override Copilot target directory (default: ~/.copilot)
  AAS_HOME                  Override Claude Code plugin directory inside a
                            marketplace layout
                            (default: ~/.claude/aas-marketplace/plugins/agent-and-skill)
  OPENCODE_HOME             Override OpenCode target directory (default: ~/.opencode)

Behavior:
  - Source of truth is this script's repository root
  - Only additive / overwrite sync is performed
  - Extra files already present in the target are NOT deleted
  - Source files use {{AAS_HOME}} as a platform-neutral path placeholder;
    sync.sh replaces it with the resolved target path for each platform
    (default examples):
      copilot     →  ~/.copilot
      claude-code →  ~/.claude/aas-marketplace/plugins/agent-and-skill
      opencode    →  ~/.opencode
  - Claude Code targets must point to a plugin directory inside a
    marketplace plugins/ directory (for example:
    ~/.claude/aas-marketplace/plugins/agent-and-skill)
  - Before syncing, checks if superpowers plugin is installed and
    offers to install it if missing (--skip-check to bypass)
  - Validation uses tools/validate_copilot_assets.py when requested
EOF
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
}

# ── Validation ──

run_validation() {
  local validator_path="${SCRIPT_DIR}/tools/validate_copilot_assets.py"

  if [[ ! -f "$validator_path" ]]; then
    printf 'Error: validator not found: %s\n' "$validator_path" >&2
    exit 1
  fi

  require_command python3
  python3 "$validator_path"
}

# ── Superpowers detection and installation ──

check_superpowers_copilot() {
  local home_dir="$1"
  if command -v copilot >/dev/null 2>&1; then
    if copilot plugin list 2>/dev/null | grep -iq "superpowers"; then
      return 0
    fi
  fi
  if find "$home_dir" -maxdepth 5 -type d -path "*/plugins/*" \( -name "superpowers" -o -name "*superpowers*" \) 2>/dev/null | grep -q .; then
    return 0
  fi
  return 1
}

check_superpowers_claude_code() {
  local claude_root="${HOME}/.claude"
  if find "$claude_root/plugins" "$claude_root/aas-marketplace" "$claude_root/.plugins" \
      -maxdepth 6 -type d \( -name "superpowers" -o -name "*superpowers*" \) 2>/dev/null | grep -q .; then
    return 0
  fi
  return 1
}

check_superpowers_opencode() {
  local home_dir="$1"
  if [[ -d "$home_dir/plugins/superpowers" ]]; then
    return 0
  fi
  if find "$home_dir" -maxdepth 5 -type d -path "*/plugins/*" \( -name "superpowers" -o -name "*superpowers*" \) 2>/dev/null | grep -q .; then
    return 0
  fi
  return 1
}

install_superpowers_copilot() {
  printf '\n'
  printf "${CYAN}[superpowers]${NC} Installing superpowers for GitHub Copilot CLI...\n"
  if command -v copilot >/dev/null 2>&1; then
    printf "${CYAN}[superpowers]${NC} Running: copilot plugin marketplace add obra/superpowers-marketplace\n"
    if copilot plugin marketplace add obra/superpowers-marketplace 2>&1; then
      printf "${CYAN}[superpowers]${NC} Running: copilot plugin install superpowers@superpowers-marketplace\n"
      if copilot plugin install superpowers@superpowers-marketplace 2>&1; then
        printf "${GREEN}[superpowers]${NC} Superpowers installed successfully for Copilot CLI.\n"
        return 0
      fi
    fi
    printf "${YELLOW}[superpowers]${NC} Automatic installation failed. Please install manually:\n"
  else
    printf "${YELLOW}[superpowers]${NC} 'copilot' CLI not found in PATH. Please install manually:\n"
  fi
  printf '\n'
  printf '  %s\n' "copilot plugin marketplace add obra/superpowers-marketplace"
  printf '  %s\n' "copilot plugin install superpowers@superpowers-marketplace"
  printf '\n'
  return 1
}

install_superpowers_claude_code() {
  printf '\n'
  printf "${CYAN}[superpowers]${NC} Superpowers for Claude Code must be installed from within a Claude Code session.\n"
  printf "${YELLOW}[superpowers]${NC} Please run one of these commands inside Claude Code:\n"
  printf '\n'
  printf '  Option 1 (official marketplace):\n'
  printf '    %s\n' "/plugin install superpowers@claude-plugins-official"
  printf '\n'
  printf '  Option 2 (superpowers marketplace):\n'
  printf '    %s\n' "/plugin marketplace add obra/superpowers-marketplace"
  printf '    %s\n' "/plugin install superpowers@superpowers-marketplace"
  printf '\n'
  return 1
}

install_superpowers_opencode() {
  printf '\n'
  printf "${CYAN}[superpowers]${NC} Superpowers for OpenCode can be installed by cloning the repository.\n"
  printf "${YELLOW}[superpowers]${NC} Please run:\n"
  printf '\n'
  printf '  %s\n' "git clone https://github.com/obra/superpowers ~/.opencode/plugins/superpowers"
  printf '\n'
  printf '  Or if you have a custom plugins directory, clone there and ensure OpenCode can discover it.\n'
  printf '\n'
  return 1
}

ensure_superpowers() {
  local target="$1"
  local home_dir="$2"

  if [[ "$SKIP_CHECK" -eq 1 ]]; then
    return 0
  fi

  printf "${CYAN}[superpowers]${NC} Checking superpowers plugin for %s...\n" "$TARGET_LABEL"

  local is_installed=0
  case "$target" in
    copilot)
      check_superpowers_copilot "$home_dir" && is_installed=1
      ;;
    claude-code)
      check_superpowers_claude_code "$home_dir" && is_installed=1
      ;;
    opencode)
      check_superpowers_opencode "$home_dir" && is_installed=1
      ;;
  esac

  if [[ "$is_installed" -eq 1 ]]; then
    printf "${GREEN}[superpowers]${NC} Superpowers plugin detected.\n"
    return 0
  fi

  printf "${YELLOW}[superpowers]${NC} Superpowers plugin NOT detected.\n"

  case "$target" in
    copilot)
      install_superpowers_copilot
      ;;
    claude-code)
      install_superpowers_claude_code
      ;;
    opencode)
      install_superpowers_opencode
      ;;
  esac

  printf "${YELLOW}[superpowers]${NC} Continuing with sync (superpowers is recommended but not required).\n"
}

# ── Plugin manifest (Claude Code) ──

write_generated_file() {
  local target_path="$1"
  local label="$2"
  local temp_file
  local action="created"

  temp_file="$(mktemp "${TMPDIR:-/tmp}/agent-and-skill.XXXXXX")"
  cat > "$temp_file"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ ! -f "$target_path" ]]; then
      printf '[%s] dry-run: would create %s\n' "$label" "$target_path"
    elif ! cmp -s "$temp_file" "$target_path"; then
      printf '[%s] dry-run: would update %s\n' "$label" "$target_path"
    fi
    rm -f -- "$temp_file"
    return 0
  fi

  mkdir -p "$(dirname -- "$target_path")"
  if [[ -f "$target_path" ]]; then
    if cmp -s "$temp_file" "$target_path"; then
      rm -f -- "$temp_file"
      return 0
    fi
    action="updated"
  fi

  mv -- "$temp_file" "$target_path"
  printf '[%s] %s %s\n' "$label" "$action" "$target_path"
}


resolve_claude_code_layout() {
  local plugin_dir="$1"
  local plugins_dir
  local marketplace_candidate

  plugins_dir="$(dirname -- "$plugin_dir")"
  if [[ "$(basename -- "$plugins_dir")" != "plugins" ]]; then
    printf 'Error: Claude Code target must be a plugin directory inside a marketplace plugins/ directory: %s\n' "$plugin_dir" >&2
    exit 1
  fi

  marketplace_candidate="$(dirname -- "$plugins_dir")"
  if [[ -d "$marketplace_candidate" ]]; then
    MARKETPLACE_ROOT="$(cd -- "$marketplace_candidate" && pwd)"
  else
    MARKETPLACE_ROOT="$marketplace_candidate"
  fi

  PLUGIN_RELATIVE_PATH="./plugins/$(basename -- "$plugin_dir")"
}

ensure_plugin_manifest() {
  local plugin_dir="$1"
  local manifest_dir="${plugin_dir}/.claude-plugin"

  write_generated_file "${manifest_dir}/plugin.json" "manifest" <<MANIFEST_EOF
{
  "name": "${CC_PLUGIN_NAME}",
  "description": "${CC_PLUGIN_DESC}",
  "version": "${CC_PLUGIN_VERSION}"
}
MANIFEST_EOF
}

ensure_marketplace_manifest() {
  local marketplace_root="$1"
  local plugin_relative_path="$2"
  local manifest_dir="${marketplace_root}/.claude-plugin"

  write_generated_file "${manifest_dir}/marketplace.json" "marketplace" <<MKTPL_EOF
{
  "name": "${CC_MARKETPLACE_NAME}",
  "description": "${CC_MARKETPLACE_DESC}",
  "owner": {
    "name": "${CC_MARKETPLACE_OWNER_NAME}",
    "email": "${CC_MARKETPLACE_OWNER_EMAIL}"
  },
  "plugins": [
    {
      "name": "${CC_PLUGIN_NAME}",
      "source": "${plugin_relative_path}",
      "description": "${CC_PLUGIN_DESC}",
      "version": "${CC_PLUGIN_VERSION}"
    }
  ]
}
MKTPL_EOF
}

ensure_cache_manifests() {
  local cache_dir="$1"

  ensure_plugin_manifest "$cache_dir"

  local manifest_dir="${cache_dir}/.claude-plugin"

  write_generated_file "${manifest_dir}/marketplace.json" "manifest" <<MKTPL_CACHE_EOF
{
  "name": "${CC_MARKETPLACE_NAME}",
  "description": "${CC_MARKETPLACE_DESC}",
  "owner": {
    "name": "${CC_MARKETPLACE_OWNER_NAME}",
    "email": "${CC_MARKETPLACE_OWNER_EMAIL}"
  },
  "plugins": [
    {
      "name": "${CC_PLUGIN_NAME}",
      "description": "${CC_PLUGIN_DESC}",
      "version": "${CC_PLUGIN_VERSION}",
      "source": "./"
    }
  ]
}
MKTPL_CACHE_EOF
}

sync_to_cache() {
  local src_home="$1"
  local cache_home="$2"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[cache] dry-run: would sync to plugin cache: %s\n' "$cache_home"
    return 0
  fi

  mkdir -p "$cache_home"

  rsync \
    --archive \
    --checksum \
    --omit-dir-times \
    --exclude='.DS_Store' \
    --exclude='.git/' \
    "$src_home/" "$cache_home/"

  ensure_cache_manifests "$cache_home"

  printf '[cache] synced to plugin cache: %s\n' "$cache_home"
}

# ── Sync functions ──

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
  local home_dir="$4"
  local preview_output
  local preview_status
  local preview_dst_dir="$dst_dir"
  local preview_root_dir=""

  if [[ "$DRY_RUN" -eq 1 && ! -d "$home_dir" ]]; then
    preview_root_dir="$(mktemp -d)"
    preview_dst_dir="${preview_root_dir}/$(basename -- "$dst_dir")"
    printf '[%s] target root does not exist yet, dry-run compares against an empty tree: %s\n' "$label" "$home_dir"
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

  local rsync_args=(
    --archive
    --checksum
    --omit-dir-times
    --exclude='.DS_Store'
    --exclude='.git/'
  )
  if [[ "$VERBOSE" -eq 1 ]]; then
    rsync_args+=(--itemize-changes)
  fi

  rsync "${rsync_args[@]}" "$src_dir/" "$dst_dir/"

  printf '[%s] incremental overwrite sync completed.\n' "$label"
}

# Rename agent .md files to .agent.md for Copilot (which requires that suffix).
rename_agent_files_for_copilot() {
  local agents_dir="$1"
  local count=0

  if [[ ! -d "$agents_dir" ]]; then
    return 0
  fi

  while IFS= read -r -d '' file; do
    local base="${file%.md}"
    local new_name="${base}.agent.md"

    if [[ "$file" == *.agent.md ]]; then
      continue
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '  [dry-run] would rename: %s -> %s\n' "$(basename -- "$file")" "$(basename -- "$new_name")"
    else
      mv -- "$file" "$new_name"
    fi
    count=$((count + 1))
  done < <(find "$agents_dir" -maxdepth 1 -name "*.md" ! -name "*.agent.md" -type f -print0)

  if [[ "$count" -gt 0 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '[post-sync] %d agent file(s) would be renamed (.md -> .agent.md).\n' "$count"
    else
      printf '[post-sync] %d agent file(s) renamed (.md -> .agent.md).\n' "$count"
    fi
  fi
}

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

replace_placeholder_in_file() {
  local file_path="$1"
  local replacement="$2"
  local temp_file

  temp_file="$(mktemp "${TMPDIR:-/tmp}/agent-and-skill.XXXXXX")"
  sed "s|{{AAS_HOME}}|${replacement}|g" "$file_path" > "$temp_file"
  mv -- "$temp_file" "$file_path"
}

postprocess() {
  local replacement="$1"
  shift
  local target_dirs=("$@")
  local replacement_escaped
  local found_files=0

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[post-sync] dry-run: would replace {{AAS_HOME}} -> %s\n' "$replacement"
    return 0
  fi

  replacement_escaped="$(escape_sed_replacement "$replacement")"

  for target_dir in "${target_dirs[@]}"; do
    if [[ ! -d "$target_dir" ]]; then
      continue
    fi

    while IFS= read -r -d '' file_path; do
      replace_placeholder_in_file "$file_path" "$replacement_escaped"
      found_files=1
    done < <(find "$target_dir" -type f -name "*.md" -print0)
  done

  if [[ "$found_files" -eq 0 ]]; then
    printf '[post-sync] no markdown files found for placeholder replacement.\n'
    return 0
  fi

  if grep -rq "{{AAS_HOME}}" "${target_dirs[@]}" 2>/dev/null; then
    printf '[post-sync] WARNING: unresolved {{AAS_HOME}} placeholders found!\n' >&2
  fi

  printf '[post-sync] {{AAS_HOME}} -> %s replacement completed.\n' "$replacement"
}

# ── Parse arguments ──

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      if [[ $# -lt 2 ]]; then
        printf 'Error: --target requires a value (copilot | claude-code | opencode)\n' >&2
        exit 1
      fi
      TARGET="$2"
      shift 2
      ;;
    --agent-suffix)
      if [[ $# -lt 2 ]]; then
        printf 'Error: --agent-suffix requires a value (md | agent.md)\n' >&2
        exit 1
      fi
      AGENT_SUFFIX="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --skip-check)
      SKIP_CHECK=1
      shift
      ;;
    --validate)
      VALIDATE=1
      shift
      ;;
    --validate-only)
      VALIDATE=1
      VALIDATE_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# ── Validate target ──

case "$TARGET" in
  copilot)
    TARGET_AGENTS_DIR="${COPILOT_HOME}/agents"
    TARGET_SKILLS_DIR="${COPILOT_HOME}/skills"
    TARGET_HOME="$COPILOT_HOME"
    TARGET_LABEL="Copilot"
    TARGET_KEY="copilot"
    ;;
  claude-code)
    TARGET_AGENTS_DIR="${CC_HOME}/agents"
    TARGET_SKILLS_DIR="${CC_HOME}/skills"
    TARGET_HOME="$CC_HOME"
    TARGET_LABEL="Claude Code"
    TARGET_KEY="claude-code"
    ;;
  opencode)
    TARGET_AGENTS_DIR="${OPENCODE_HOME}/agents"
    TARGET_SKILLS_DIR="${OPENCODE_HOME}/skills"
    TARGET_HOME="$OPENCODE_HOME"
    TARGET_LABEL="OpenCode"
    TARGET_KEY="opencode"
    ;;
  "")
    printf 'Error: --target is required. Use copilot, claude-code, or opencode.\n\n' >&2
    usage >&2
    exit 1
    ;;
  *)
    printf 'Error: unknown target "%s". Use copilot, claude-code, or opencode.\n' "$TARGET" >&2
    exit 1
    ;;
esac

case "$AGENT_SUFFIX" in
  md|agent.md) ;;
  *)
    printf 'Error: unknown agent-suffix "%s". Use md or agent.md.\n' "$AGENT_SUFFIX" >&2
    exit 1
    ;;
esac

# ── Pre-flight checks ──

require_command rsync

if [[ ! -d "$SOURCE_AGENTS_DIR" ]]; then
  printf 'Error: source directory not found: %s\n' "$SOURCE_AGENTS_DIR" >&2
  exit 1
fi

if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
  printf 'Error: source directory not found: %s\n' "$SOURCE_SKILLS_DIR" >&2
  exit 1
fi

# ── Validation ──

if [[ "$VALIDATE" -eq 1 ]]; then
  run_validation
  if [[ "$VALIDATE_ONLY" -eq 1 ]]; then
    printf 'Done: validation finished successfully.\n'
    exit 0
  fi
fi

# ── Execute ──

printf 'Source root   : %s\n' "$SCRIPT_DIR"
printf 'Target (%s) : %s\n' "$TARGET_LABEL" "$TARGET_HOME"
printf 'Sync mode     : %s\n' "$([[ "$DRY_RUN" -eq 1 ]] && printf 'dry-run' || printf 'apply')"
if [[ "$TARGET_KEY" == "copilot" ]]; then
  printf 'Agent suffix  : .%s\n' "$AGENT_SUFFIX"
fi

# Check superpowers before sync
ensure_superpowers "$TARGET_KEY" "$TARGET_HOME"

if [[ "$DRY_RUN" -ne 1 ]]; then
  mkdir -p "$TARGET_HOME"
  TARGET_HOME="$(cd -- "$TARGET_HOME" && pwd)"
  TARGET_AGENTS_DIR="${TARGET_HOME}/agents"
  TARGET_SKILLS_DIR="${TARGET_HOME}/skills"
fi

if [[ "$TARGET_KEY" == "claude-code" ]]; then
  resolve_claude_code_layout "$TARGET_HOME"
fi

sync_dir "agents" "$SOURCE_AGENTS_DIR" "$TARGET_AGENTS_DIR" "$TARGET_HOME"
sync_dir "skills" "$SOURCE_SKILLS_DIR" "$TARGET_SKILLS_DIR" "$TARGET_HOME"

# Ensure marketplace plugin manifest exists (Claude Code only)
if [[ "$TARGET_KEY" == "claude-code" && "$DRY_RUN" -ne 1 ]]; then
  ensure_plugin_manifest "$TARGET_HOME"
  ensure_marketplace_manifest "$MARKETPLACE_ROOT" "$PLUGIN_RELATIVE_PATH"
fi

# Copilot: optionally rename agent files to .agent.md suffix
if [[ "$TARGET_KEY" == "copilot" && "$AGENT_SUFFIX" == "agent.md" ]]; then
  rename_agent_files_for_copilot "$TARGET_AGENTS_DIR"
fi

if [[ "$DRY_RUN" -ne 1 ]]; then
  postprocess "$TARGET_HOME" "$TARGET_AGENTS_DIR" "$TARGET_SKILLS_DIR"
fi

# Sync to Claude Code plugin cache so agents/skills are discoverable at runtime.
if [[ "$TARGET_KEY" == "claude-code" ]]; then
  if [[ ! -d "$CC_CACHE_HOME" || "$HAS_CHANGES" -eq 1 ]]; then
    sync_to_cache "$TARGET_HOME" "$CC_CACHE_HOME"
  else
    printf '[cache] plugin cache is up to date: %s\n' "$CC_CACHE_HOME"
  fi
fi

if [[ "$HAS_CHANGES" -eq 0 ]]; then
  printf 'Done: target directories are already in sync.\n'
elif [[ "$DRY_RUN" -eq 1 ]]; then
  printf 'Done: dry-run finished, rerun without --dry-run to apply changes.\n'
else
  printf 'Done: repository agents/ and skills/ have been synced to %s (%s).\n' "$TARGET_HOME" "$TARGET_LABEL"
fi
