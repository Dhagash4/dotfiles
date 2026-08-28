#!/bin/bash
# Quick-capture: append a timestamped entry to today's inbox note in the
# Obsidian vault, then open it in a small floating wezterm (floats via the
# Pop Shell float rule for class "floating-note", not window tricks).
VAULT="$HOME/projects/work/eternal_amr"
NOTE="$VAULT/Inbox/$(date +%Y.%m.%d).md"
mkdir -p "$VAULT/Inbox"
[ -f "$NOTE" ] || printf '# Inbox — %s\n' "$(date +%Y-%m-%d)" > "$NOTE"
printf '\n## %s\n\n' "$(date +%H:%M)" >> "$NOTE"

COLS=70; ROWS=18
# Center the window (X11). If xdpyinfo is missing, fall back to 1920x1080.
read -r SW SH <<< "$(xdpyinfo 2>/dev/null | awk '/dimensions:/{print $2}' | tr 'x' ' ')"
SW=${SW:-1920}; SH=${SH:-1080}
WW=$((COLS * 10)); WH=$((ROWS * 20))
X=$(( (SW - WW) / 2 )); Y=$(( (SH - WH) / 2 ))

exec wezterm --config font_size=12 \
  --config "initial_cols=$COLS" --config "initial_rows=$ROWS" \
  --config 'window_decorations="RESIZE"' \
  --config 'window_padding={left=10,right=10,top=10,bottom=10}' \
  --config 'enable_tab_bar=false' \
  start --always-new-process --class floating-note --position "$X,$Y" \
  -- "${SHELL:-/bin/zsh}" -ic "nvim + +startinsert '$NOTE'"
