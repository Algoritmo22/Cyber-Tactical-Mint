# Managed by Cyber-Tactical-Mint (paleta: @@THEME_NAME@@)
# Este archivo se carga desde ~/.bashrc. Solo actúa en shells interactivas.
[[ $- == *i* ]] || return 0

export CTM_HOME="@@CTM_HOME@@"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac

# ── Alias ──
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -lah --icons --group-directories-first --git"
  alias tree="eza --tree --icons"
else
  alias ls="ls --color=auto --group-directories-first"
  alias ll="ls -lah"
fi
alias la="ls -A"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
alias update="sudo apt update && sudo apt full-upgrade"
alias ports="ss -tulpn"
alias myip="curl -s https://ifconfig.me; echo"
alias sysmon="btop"
alias dfh="df -hT -x tmpfs -x devtmpfs"
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat="batcat"

# ── HUD y tema ──
hud() {  # hud [on|off|toggle]
  local conf="$HOME/.config/conky/cyber-tactical/conky.conf"
  case "${1:-toggle}" in
    off) pkill -x conky ;;
    on)  pkill -x conky 2>/dev/null; setsid conky -c "$conf" >/dev/null 2>&1 & ;;
    *)   if pgrep -x conky >/dev/null; then pkill -x conky; else setsid conky -c "$conf" >/dev/null 2>&1 & fi ;;
  esac
}
ctm-theme() {
  if [[ -x $CTM_HOME/scripts/set-theme.sh ]]; then "$CTM_HOME/scripts/set-theme.sh" "$@"
  else echo "No encuentro $CTM_HOME; ¿moviste el repositorio?" >&2; return 1; fi
}

# ── Herramientas opcionales ──
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
for f in /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/key-bindings.bash; do
  [[ -r $f ]] && { . "$f"; break; }
done

# ── Prompt ──
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\[\e[38;2;@@MUTED_RGB@@m\]┌─\[\e[38;2;@@PRIMARY_RGB@@m\][\u@\h]\[\e[38;2;@@MUTED_RGB@@m\]─\[\e[38;2;@@SECONDARY_RGB@@m\][\w]\n\[\e[38;2;@@MUTED_RGB@@m\]└─\[\e[38;2;@@ACCENT_RGB@@m\]▸ \[\e[0m\]'
fi

# ── Banner opcional: descomenta para ver fastfetch en cada terminal Kitty nueva ──
# [[ -n $KITTY_WINDOW_ID ]] && command -v fastfetch >/dev/null 2>&1 && fastfetch
