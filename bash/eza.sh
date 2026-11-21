# eza en gris (Carbon) con líneas de árbol
export EZA_ICON_SPACING=2
export EZA_COLORS="reset:di=1;38;5;255:ex=38;5;252:ln=38;5;250:ur=38;5;250:uw=38;5;250:ux=38;5;250:ue=38;5;250:gr=38;5;245:gw=38;5;245:gx=38;5;245:tr=38;5;240:tw=38;5;240:tx=38;5;240:sn=38;5;252:sb=38;5;243:df=38;5;252:ds=38;5;243:da=38;5;244:uu=38;5;244:un=38;5;244:gu=38;5;244:gn=38;5;244:lc=38;5;244:lm=38;5;244:xx=38;5;238:hd=4;38;5;243:ga=38;5;108:gm=38;5;179:gd=38;5;174:gv=38;5;179:gt=38;5;179:gi=38;5;240:gc=38;5;174:Gm=38;5;250:Go=38;5;244:Gc=38;5;108:Gd=38;5;179"
if command -v eza >/dev/null; then
  _eza='eza --icons --group-directories-first'
  alias ls="$_eza --tree --level=1"                                   # lista con líneas de árbol (solo esta carpeta)
  alias lg="$_eza"                                                    # cuadrícula compacta
  alias ll="$_eza -l --tree --level=1 --git --no-user --no-permissions --time-style=relative"   # con tamaño, fecha y git
  alias la="$_eza -la --tree --level=1 --git --no-user --no-permissions --time-style=relative"  # igual, con ocultos
  # lt [niveles] [carpeta]: árbol más profundo, sin lo que ignora git. Ej: lt, lt 3, lt 2 src
  lt() { local n=2; [[ $1 =~ ^[0-9]+$ ]] && { n=$1; shift; }; eval "$_eza --tree --level=$n --git-ignore" '"$@"'; }
fi
