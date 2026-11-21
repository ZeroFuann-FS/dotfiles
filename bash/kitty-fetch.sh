# Al abrir kitty muestra fastfetch con la Z animada (solo en terminales interactivas de kitty)
if [[ $- == *i* && "$TERM" == "xterm-kitty" && -z "$CLAUDECODE" && -z "$ZFETCH_SHOWN" ]]; then
  export ZFETCH_SHOWN=1
  zfetch
  if command -v frase >/dev/null; then                # idea #18: frase del día (con tu mascota al lado)
    echo
    # MASCOTA = nombre de una imagen en ~/Imágenes/terminal (se define en ~/.bashrc.d/privado.sh)
    if [ -n "$MASCOTA" ] && command -v personaje >/dev/null; then COLUMNS=$(( $(tput cols) - 28 )) frase | personaje mini "$MASCOTA" junto; else frase; fi
  fi
fi
alias fetch='zfetch'
