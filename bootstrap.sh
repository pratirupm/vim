#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/vim"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/vim"

if ! command -v vim >/dev/null 2>&1; then
  echo "error: vim not found" >&2
  exit 1
fi

config_phys="$(cd -- "$config_dir" 2>/dev/null && pwd -P || true)"

if [[ "$repo_dir" == "$config_phys" ]]; then
  : # this checkout already is ~/.config/vim
elif [[ -e "$config_dir" && ! -L "$config_dir" ]]; then
  echo "error: $config_dir already exists and is not a symlink." >&2
  echo "       Move it aside, then rerun this script." >&2
  exit 1
elif [[ -L "$config_dir" ]]; then
  current_target="$(readlink -f "$config_dir")"
  if [[ "$current_target" != "$repo_dir" ]]; then
    echo "error: $config_dir points to $current_target, not $repo_dir." >&2
    exit 1
  fi
else
  mkdir -p "$(dirname -- "$config_dir")"
  ln -s "$repo_dir" "$config_dir"
  echo "linked $config_dir -> $repo_dir"
fi

for legacy in "$HOME/.vimrc" "$HOME/.vim/vimrc"; do
  if [[ -e "$legacy" ]]; then
    echo "warning: $legacy exists and takes precedence over $config_dir/vimrc" >&2
  fi
done

mkdir -p "$config_dir/autoload" \
         "$state_dir/undo" \
         "$state_dir/swap" \
         "$state_dir/backup" \
         "$state_dir/fzf-history"

if [[ ! -f "$config_dir/autoload/plug.vim" ]]; then
  echo "downloading vim-plug..."
  curl -fLo "$config_dir/autoload/plug.vim" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "installing plugins..."
vim -es -Nu "$config_dir/vimrc" -c 'PlugInstall --sync' -c 'qa!'

echo
echo "done. start vim normally (do not pass -u) so it reads ~/.config/vim/vimrc."
echo "run :PlugStatus inside vim to verify the plugin list."
