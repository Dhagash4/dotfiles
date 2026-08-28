#!/bin/bash
# Reproduce the tracked GNOME desktop setup: install the extensions listed in
# extensions.txt, enable whichever ones this distro actually has, then load the dconf
# dumps in dconf/. Idempotent — safe to re-run.
#
# Ubuntu and Pop!_OS both ship GNOME and share the dash-to-dock schema (Pop's dock is a
# dash-to-dock fork), so the dock settings carry across. Pop!_OS 24.04+ ships COSMIC,
# which is not GNOME at all — this script detects that and bows out.
set -u

GNOME_DIR="$HOME/.config/gnome"

if ! command -v gnome-extensions >/dev/null 2>&1 || ! command -v dconf >/dev/null 2>&1; then
  echo "no GNOME Shell here (gnome-extensions/dconf missing) — skipping desktop settings."
  return 0 2>/dev/null || exit 0
fi

SHELL_MAJOR="$(gnome-shell --version 2>/dev/null | grep -o '[0-9]\+' | head -1)"
if [ -z "$SHELL_MAJOR" ]; then
  echo "could not determine GNOME Shell version — skipping desktop settings." >&2
  return 0 2>/dev/null || exit 0
fi
echo "GNOME Shell $SHELL_MAJOR"

# ---------------------------------------------------------------- extensions
# extensions.gnome.org serves a per-shell-version zip; asking for the wrong major
# version gets you an extension that silently refuses to load.
install_extension() {
  uuid="$1"
  if gnome-extensions info "$uuid" >/dev/null 2>&1; then
    echo "  $uuid already installed"
    return 0
  fi

  rel="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$SHELL_MAJOR" \
    | grep -o '"download_url": *"[^"]*"' | sed 's/.*"download_url": *"//; s/"$//')"
  if [ -z "$rel" ]; then
    echo "  !! no build of $uuid for GNOME $SHELL_MAJOR" >&2
    return 1
  fi

  tmp="$(mktemp -d)"
  if ! curl -fsSL -o "$tmp/ext.zip" "https://extensions.gnome.org$rel"; then
    rm -rf "$tmp"; echo "  !! could not download $uuid" >&2; return 1
  fi
  if ! gnome-extensions install --force "$tmp/ext.zip"; then
    rm -rf "$tmp"; echo "  !! could not install $uuid" >&2; return 1
  fi
  rm -rf "$tmp"
  echo "  $uuid installed"
}

echo "==> extensions from extensions.gnome.org"
ext_failed=""
while read -r line; do
  uuid="${line%%#*}"; uuid="$(echo "$uuid" | tr -d '[:space:]')"
  [ -n "$uuid" ] || continue
  install_extension "$uuid" || ext_failed="$ext_failed $uuid"
done < "$GNOME_DIR/extensions.txt"

# ---------------------------------------------------------------- dconf
# Load before enabling, so an extension reads the intended settings the first time it
# runs instead of writing its own defaults over them.
echo "==> dconf"
for f in "$GNOME_DIR"/dconf/*.dconf; do
  [ -e "$f" ] || continue
  path="/$(basename "$f" .dconf | sed 's:\.:/:g')/"
  if dconf load "$path" < "$f"; then
    echo "  loaded $path"
  else
    echo "  !! failed to load $path" >&2
  fi
done

# ---------------------------------------------------------------- enable
# enabled-extensions in the dump lists Ubuntu's UUIDs. Enabling one that isn't installed
# leaves a permanently broken entry, so filter to what's actually here, and add the
# distro's own dock/desktop equivalents when they exist (Pop!_OS names them differently).
echo "==> enabling"
DISTRO_EXTRAS="cosmic-dock@system76.com cosmic-workspaces@system76.com pop-shell@system76.com dash-to-dock@micxgx.gmail.com"
WANTED="$(dconf read /org/gnome/shell/enabled-extensions 2>/dev/null | tr -d "[]'" | tr ',' ' ')"

enabled=""
for uuid in $WANTED $DISTRO_EXTRAS; do
  case " $enabled " in *" $uuid "*) continue ;; esac
  if gnome-extensions info "$uuid" >/dev/null 2>&1; then
    enabled="$enabled $uuid"
  fi
done

list="$(for u in $enabled; do printf "'%s', " "$u"; done | sed 's/, $//')"
dconf write /org/gnome/shell/enabled-extensions "[$list]"
echo "  enabled:$enabled"

if [ -n "$ext_failed" ]; then
  echo
  echo "These extensions could not be installed:$ext_failed" >&2
fi

echo
echo "Done. Log out and back in for extension changes to take effect (Wayland cannot"
echo "restart the shell in place)."
