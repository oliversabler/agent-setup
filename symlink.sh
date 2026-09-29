#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
default_config_dir="$HOME/.config/opencode"
read -r -p "Symlink destination [$default_config_dir]: " config_dir
config_dir="${config_dir:-$default_config_dir}"
skills_dir="$config_dir/skills"
repo_skills_dir="$repo_dir/.opencode/skills"

mkdir -p "$skills_dir"

ln -sfn "$repo_dir/opencode.jsonc" "$config_dir/opencode.jsonc"
printf 'linked %s -> %s\n' "$config_dir/opencode.jsonc" "$repo_dir/opencode.jsonc"

ln -sfn "$repo_dir/AGENTS.md" "$config_dir/AGENTS.md"
printf 'linked %s -> %s\n' "$config_dir/AGENTS.md" "$repo_dir/AGENTS.md"

find "$repo_skills_dir" -name SKILL.md -not -path '*/node_modules/*' -print0 |
while IFS= read -r -d '' skill_md; do
  skill_path="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_path")"
  target="$skills_dir/$skill_name"

  [[ -e "$target" && ! -L "$target" ]] && rm -rf "$target"
  ln -sfn "$skill_path" "$target"
  printf 'linked %s -> %s\n' "$target" "$skill_path"
done
