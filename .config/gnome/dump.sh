#!/bin/bash
# Capture the GNOME settings we care about into ~/.config/gnome/dconf/*.dconf so yadm
# can track them. Re-run this after tweaking the desktop, then commit the result.
#
# dconf only stores keys that differ from the schema default, so these dumps stay small
# and are a delta against a stock GNOME rather than a full snapshot.
set -u

GNOME_DIR="$HOME/.config/gnome"
OUT="$GNOME_DIR/dconf"

# Each entry becomes <path with / -> .>.dconf, e.g. /org/gnome/shell/ -> org.gnome.shell.dconf
PATHS="
/org/gnome/shell/
/org/gnome/desktop/interface/
/org/gnome/desktop/wm/preferences/
/org/gnome/desktop/wm/keybindings/
/org/gnome/desktop/peripherals/
/org/gnome/desktop/input-sources/
/org/gnome/mutter/
/org/gnome/settings-daemon/plugins/media-keys/
"

# Keys that are regenerated from the current wallpaper or are pure usage telemetry.
# Pinning them would carry one machine's wallpaper palette onto another for no benefit.
NOISE='^((light-|dark-)?(count|palette|prominent)[0-9]*|(light-|dark-)?bguri|welcome-dialog-last-shown-version|reloadstyle)='

command -v dconf >/dev/null 2>&1 || { echo "dconf not found." >&2; exit 1; }
mkdir -p "$OUT"

for p in $PATHS; do
  file="$OUT/$(echo "${p#/}" | sed 's:/*$::; s:/:.:g').dconf"
  dump="$(dconf dump "$p" 2>/dev/null | grep -vE "$NOISE")"
  # A path with nothing but defaults dumps to just "[/]" (or nothing) — don't track those.
  if [ -z "$(echo "$dump" | grep -vE '^\[|^$')" ]; then
    rm -f "$file"
    echo "skip  $p (all defaults)"
    continue
  fi
  { echo "# dconf dump of $p — regenerate with ~/.config/gnome/dump.sh"; echo "$dump"; } > "$file"
  echo "write $file ($(echo "$dump" | grep -cE '^[a-z]') keys)"
done
