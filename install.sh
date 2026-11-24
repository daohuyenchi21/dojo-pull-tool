#!/usr/bin/env bash
# Install dojo-pull into ~/.local/bin (or $PREFIX/bin).
#
#   curl -fsSL https://raw.githubusercontent.com/chihuyenichi/dojo-pull-tool/main/install.sh | bash
#   DOJO_PULL_REF=v0.1.0 bash install.sh      # pin a tag/commit
#   bash install.sh --uninstall
set -euo pipefail

REPO="chihuyenichi/dojo-pull-tool"
REF="${DOJO_PULL_REF:-main}"
BIN="${PREFIX:-$HOME/.local}/bin"
SRC="${BASH_SOURCE[0]:-}"
DIR=""
[[ -n "$SRC" && -f "$SRC" ]] && DIR="$(cd "$(dirname "$SRC")" && pwd)"

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -f "$BIN/dojo-pull"
  echo "[✓] removed $BIN/dojo-pull (config in ~/.config/dojo-pull kept)"
  exit 0
fi

mkdir -p "$BIN"
if [[ -n "$DIR" && -f "$DIR/dojo-pull" ]]; then
  install -m 755 "$DIR/dojo-pull" "$BIN/dojo-pull"
  echo "[✓] installed from local copy -> $BIN/dojo-pull"
else
  command -v curl >/dev/null || { echo "[✗] curl is required" >&2; exit 1; }
  tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
  curl -fsSL "https://raw.githubusercontent.com/$REPO/$REF/dojo-pull" -o "$tmp"
  head -1 "$tmp" | grep -q '^#!.*bash' || { echo "[✗] downloaded file is not a bash script" >&2; exit 1; }
  install -m 755 "$tmp" "$BIN/dojo-pull"
  echo "[✓] downloaded $REPO@$REF -> $BIN/dojo-pull"
fi

case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "[!] $BIN is not in PATH. Run:"
     echo "    echo 'export PATH=\"$BIN:\$PATH\"' >> ~/.bashrc && source ~/.bashrc" ;;
esac
echo "Next: dojo-pull init"
