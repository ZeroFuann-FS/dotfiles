#!/usr/bin/env bash
# instalar.sh — copia la terminal Carbon de ZeroFuann a tu equipo.
# Lo que ya tengas lo respalda como <archivo>.antes-dotfiles antes de reemplazarlo.
# No usa sudo: al final te dice qué programas te faltan y cómo instalarlos.
set -euo pipefail
cd "$(dirname "$0")"

pon() {   # pon <origen> <destino>
  local o="$1" d="$2"
  mkdir -p "$(dirname "$d")"
  if [ -e "$d" ] && ! cmp -s "$o" "$d"; then cp -p "$d" "$d.antes-dotfiles"; fi
  cp -p "$o" "$d"
}

echo "→ Scripts en ~/.local/bin"
for f in bin/*; do pon "$f" "$HOME/.local/bin/$(basename "$f")"; chmod +x "$HOME/.local/bin/$(basename "$f")"; done

echo "→ Bash (~/.bashrc.d)"
for f in bash/*; do pon "$f" "$HOME/.bashrc.d/$(basename "$f")"; done
if ! grep -q 'bashrc.d' "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# Carga ~/.bashrc.d/*\nfor rc in ~/.bashrc.d/*; do [ -f "$rc" ] && . "$rc"; done\n' >> "$HOME/.bashrc"
fi
[ -f "$HOME/.bashrc.d/00-privado.sh" ] || cat > "$HOME/.bashrc.d/00-privado.sh" <<'EOF'
# Tus datos personales (este archivo no va al repo)
# export CLIMA_CIUDAD="Tu ciudad"      # clima: si lo dejas vacío, se detecta por tu IP
# export MASCOTA="nombre"              # imagen de ~/Imágenes/terminal que sale al abrir kitty
EOF

echo "→ kitty, starship, fastfetch, btop, lazygit, yazi, cava, spotify_player"
for f in kitty/*; do pon "$f" "$HOME/.config/kitty/$(basename "$f")"; done
pon config/starship.toml "$HOME/.config/starship.toml"
for f in config/fastfetch/*; do pon "$f" "$HOME/.config/fastfetch/$(basename "$f")"; done
pon config/btop/btop.conf "$HOME/.config/btop/btop.conf"
pon config/btop/themes/carbon.theme "$HOME/.config/btop/themes/carbon.theme"
pon config/lazygit/config.yml "$HOME/.config/lazygit/config.yml"
for f in config/yazi/*; do pon "$f" "$HOME/.config/yazi/$(basename "$f")"; done
pon config/cava/config "$HOME/.config/cava/config"
for f in config/spotify-player/*; do pon "$f" "$HOME/.config/spotify-player/$(basename "$f")"; done

echo "→ Frases, sonido del látigo y terminal desplegable"
pon share/frases/frases.txt "$HOME/.local/share/frases/frases.txt"
pon share/sonidos/latigo.wav "$HOME/.local/share/sonidos/latigo.wav"
pon share/applications/terminal-desplegable.desktop "$HOME/.local/share/applications/terminal-desplegable.desktop"
mkdir -p "$HOME/Imágenes/terminal"/{anime,marvel,barca,otros}

echo
echo "Listo. Abre una kitty nueva."
echo
falta=()
for p in kitty starship fastfetch eza zoxide fzf fd bat btop lazygit yazi cava; do
  command -v "$p" >/dev/null || falta+=("$p")
done
if [ ${#falta[@]} -gt 0 ]; then
  echo "Te faltan estos programas (en Fedora):"
  echo "  sudo dnf install ${falta[*]}"
  echo "  (starship y lazygit pueden venir de COPR o de su página si dnf no los encuentra)"
fi
command -v spotify_player >/dev/null || echo "Opcional: spotify_player → https://github.com/aome510/spotify-player/releases"
command -v pokeget >/dev/null       || echo "Opcional: pokeget        → https://github.com/talwat/pokeget-rs/releases"
command -v asciiquarium >/dev/null  || echo "Opcional: sudo dnf install asciiquarium"
python3 -c "import PIL" 2>/dev/null || echo "Para «personaje»: sudo dnf install python3-pillow"
echo
echo "Atajo de la terminal desplegable: Configuración del sistema → Atajos → agrega"
echo "«Terminal desplegable» con Meta+Enter."
