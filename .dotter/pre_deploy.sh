#!/usr/bin/env bash
set -euo pipefail

cosmic_source_dir="dotfiles/cosmic"
cosmic_target_dir="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic"
replaced_link_count=0

[[ -d "$cosmic_source_dir" ]] || exit 0

while IFS= read -r -d '' cosmic_source; do
  cosmic_relative_path="${cosmic_source#"$cosmic_source_dir"/}"
  cosmic_target="$cosmic_target_dir/$cosmic_relative_path"

  if [[ -e "$cosmic_target" && ! -L "$cosmic_target" ]]; then
    printf 'COSMIC managed file is no longer a symlink: %s\n' "$cosmic_target" >&2
    ((replaced_link_count += 1))
  fi
done < <(find "$cosmic_source_dir" -type f -print0)

if ((replaced_link_count > 0)); then
  printf 'Dotter will restore %d COSMIC symlink(s).\n' "$replaced_link_count" >&2
fi
