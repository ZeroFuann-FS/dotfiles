#!/usr/bin/env bash
# instalar-kde.sh — el escritorio Carbon de ZeroFuann (KDE Plasma 6).
#   ./instalar-kde.sh            widgets propios, fondo-pausa (Meta+P) y tema de Spotify
#   ./instalar-kde.sh --paneles  además, pone mis paneles: barra de arriba y dock en cada pantalla
# Lo que ya tengas lo respalda como <archivo>.antes-dotfiles. No usa sudo.
set -euo pipefail
cd "$(dirname "$0")"
PANELES=0; [ "${1:-}" = "--paneles" ] && PANELES=1

respalda() { [ -e "$1" ] && cp -a "$1" "$1.antes-dotfiles" && echo "  respaldo: $1.antes-dotfiles" || true; }

echo "→ Widgets propios en ~/.local/share/plasma/plasmoids"
dest="$HOME/.local/share/plasma/plasmoids"; mkdir -p "$dest"
for w in widgets/org.zerofuann.*; do
  n="$(basename "$w")"
  [ -d "$dest/$n" ] && { rm -rf "$dest/$n.antes-dotfiles"; mv "$dest/$n" "$dest/$n.antes-dotfiles"; }
  cp -r "$w" "$dest/$n"; echo "  $n"
done

echo "→ fondo-pausa (Meta+P pausa el fondo animado cuando hay ventanas)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
cp scripts/fondo-pausa "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/fondo-pausa"
cp scripts/fondo-pausa.desktop "$HOME/.local/share/applications/"

echo "→ Tema de Spotify (Spicetify)"
mkdir -p "$HOME/.config/spicetify/Themes"
rm -rf "$HOME/.config/spicetify/Themes/ZeroFuann"; cp -r spicetify/ZeroFuann "$HOME/.config/spicetify/Themes/"

echo "→ Animación de los menús de la barra (deslizar 300/250 ms)"
kwriteconfig6 --file kwinrc --group Plugins --key slidingpopupsEnabled true
kwriteconfig6 --file kwinrc --group Effect-slidingpopups --key SlideInTime 300
kwriteconfig6 --file kwinrc --group Effect-slidingpopups --key SlideOutTime 250

if [ "$PANELES" = 1 ]; then
  echo "→ Paneles (tu configuración actual queda respaldada)"
  A="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"; S="$HOME/.config/plasmashellrc"
  respalda "$A"; respalda "$S"
  systemctl --user stop plasma-plasmashell
  # Solo se escriben los paneles; Plasma vuelve a crear el escritorio de cada pantalla al arrancar.
  sed "s#__HOME__#$HOME#g" paneles/plasma-paneles.appletsrc > "$A"
  python3 - "$S" paneles/plasmashellrc-paneles <<'EOF'
import re, sys
dest, nuevo = sys.argv[1], open(sys.argv[2]).read()
try: txt = open(dest).read()
except FileNotFoundError: txt = ""
bloques = [b for b in re.split(r'(?m)^(?=\[)', txt) if not b.startswith("[PlasmaViews]")]
open(dest, "w").write("".join(bloques).rstrip() + "\n\n" + nuevo)
EOF
  systemctl --user start plasma-plasmashell
  echo "  Listo. Para volver a como estaba: copia los .antes-dotfiles encima y reinicia plasmashell."
fi

cat <<'EOF'

Instala desde "Obtener widgets nuevos" (clic derecho en el panel → Agregar widgets):
  · Panel Colorizer (luisbocanegra) — el estilo Carbon de los paneles, preset "Carbon"
  · Audio Visualizer (luisbocanegra) y PlasMusic Toolbar — música en la barra
  · Andromeda Launcher — el menú de inicio
  · Plasma Flex Hub — el centro de control
  · Modern Clock (prayag2) — el reloj grande del escritorio
Otros:
  · Esquema de colores y estilo Plasma "Monochrome"; íconos Tela-circle-dark
    (para la versión gris: python3 -I scripts/tela-circle-a-gris.py <origen> <destino>)
  · Barras y Esfera necesitan el relay de audio de plaintop: https://github.com/highscrren-dotcom/plaintop
  · Clima y Reloj tarjeta usan Misantla: cambia ciudad, latitud y longitud en su main.qml
  · Spotify: instala Spicetify y corre  spicetify config current_theme ZeroFuann && spicetify apply
Reinicia Plasma para ver los widgets:  systemctl --user restart plasma-plasmashell
EOF
