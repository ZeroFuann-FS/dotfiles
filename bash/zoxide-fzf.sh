# zoxide + fzf en gris (Carbon). Ideas #3 y #4 de "Mi terminal".
#   z <algo>   salta a la carpeta más usada que coincida   (z brio, z proy)
#   zi         elige la carpeta con fzf
#   Ctrl+R     busca en el historial
#   Ctrl+T     busca un archivo y lo pega en la línea (con vista previa)
#   Alt+C      busca una carpeta y entra
#   ff         abre un archivo elegido con fzf en tu editor

# Historial más largo y sin repetidos, para que Ctrl+R sirva de verdad
HISTSIZE=20000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

if command -v fzf >/dev/null; then
  # Colores Carbon: fondo de kitty, texto gris, coincidencias en blanco
  export FZF_DEFAULT_OPTS="
    --height=45% --layout=reverse --border=rounded --margin=0,1
    --prompt='❯ ' --pointer='▌' --marker='•' --info=inline-right
    --separator='─' --scrollbar='│'
    --color=fg:#b8b8bc,bg:-1,hl:#f0f0f2:bold
    --color=fg+:#f0f0f2,bg+:#1e1e20,hl+:#ffffff:bold
    --color=border:#3a3a3e,separator:#2a2a2e,scrollbar:#5a5a60
    --color=prompt:#d0d0d4,pointer:#e6e6e8,marker:#d0d0d4
    --color=info:#5a5a60,spinner:#d0d0d4,header:#8a8a90,label:#8a8a90
    --bind='ctrl-/:toggle-preview'"

  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Vista previa: archivos con bat, carpetas con el árbol de eza
  export FZF_CTRL_T_OPTS="--border-label=' archivos ' --preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--border-label=' carpetas ' --preview 'eza --tree --level=2 --icons --color=always --group-directories-first {} 2>/dev/null'"
  export FZF_CTRL_R_OPTS="--border-label=' historial ' --preview 'echo {2..}' --preview-window=down,3,wrap,hidden"

  eval "$(fzf --bash)"

  # ff: elegir un archivo y abrirlo en el editor
  ff() {
    local f
    f=$(fzf --border-label=' abrir ' --preview 'bat --color=always --style=numbers --line-range=:200 {}') && "${EDITOR:-nano}" "$f"
  }
fi

if command -v zoxide >/dev/null; then
  export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --border-label=' saltar a ' --preview 'eza --tree --level=1 --icons --color=always --group-directories-first {2..} 2>/dev/null'"
  eval "$(zoxide init bash)"
fi

# btop (idea #5): "top" abre btop con el tema Carbon
command -v btop >/dev/null && alias top='btop'

# lazygit (idea #6): "gg" abre git con menús.
# En un repo lo abre directo; fuera de uno, eliges proyecto de ~/Proyectos con fzf.
if command -v lazygit >/dev/null; then
  gg() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      lazygit "$@"; return
    fi
    local r
    r=$(for d in ~/Proyectos/*/.git; do basename "$(dirname "$d")"; done |
        fzf --border-label=' ¿qué repo? ' \
            --preview 'git -C ~/Proyectos/{} log --oneline --color=always -15' ) || return
    cd ~/Proyectos/"$r" && lazygit
  }
fi

# yazi (idea #7): "y" abre el explorador; al salir con q te quedas en la carpeta donde ibas
if command -v yazi >/dev/null; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# cava (idea #12): "ondas" = barras de tu música en gris (q para salir)
command -v cava >/dev/null && alias ondas='cava'

