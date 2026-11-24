#!/usr/bin/env bash
# hstp.sh - Minimalistischer Bash-History-Picker (Prompt-Übernahme & Clipboard)

__hstp_copy() {
  local text="$1"
  if command -v xclip >/dev/null 2>&1; then
    printf '%s' "$text" | xclip -selection clipboard
    return 0
  elif command -v xsel >/dev/null 2>&1; then
    printf '%s' "$text" | xsel --clipboard --input
    return 0
  elif command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$text" | wl-copy
    return 0
  fi
  return 1
}

hstp() {
  local query="${READLINE_LINE:-$*}"
  local selected=0
  local key esc_seq
  local -a all_cmds=() filtered=()

  # 1. History laden: Falls als eigenes Sub-Skript gestartet, ~/.bash_history lesen
  if [[ -n "${BASH_VERSION:-}" ]] && history 1 >/dev/null 2>&1 && [[ -n "$(history 1)" ]]; then
    mapfile -t all_cmds < <(
      history |
        sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' |
        tac |
        awk '!seen[$0]++'
    )
  else
    local hist_file="${HISTFILE:-$HOME/.bash_history}"
    [[ -f "$hist_file" ]] && mapfile -t all_cmds < <(
      tac "$hist_file" | awk '!seen[$0]++'
    )
  fi

  printf '\e[?25l' >&2
  trap 'printf "\e[?25h" >&2' RETURN

  while true; do
    filtered=()
    local cmd ok word
    for cmd in "${all_cmds[@]}"; do
      [[ -z "$cmd" || "$cmd" == hstp* ]] && continue
      ok=1
      for word in $query; do
        if [[ "${cmd,,}" != *"${word,,}"* ]]; then
          ok=0
          break
        fi
      done
      (( ok )) && filtered+=("$cmd")
    done

    (( selected >= ${#filtered[@]} )) && selected=0
    (( ${#filtered[@]} == 0 )) && selected=0

    # UI zeichnen
    printf '\r\e[J' >&2
    printf '\e[1m[hstp]\e[0m %s_  (%d/%d)\n' "$query" "${#filtered[@]}" "${#all_cmds[@]}" >&2
    if (( ${#filtered[@]} == 0 )); then
      printf '  (keine Treffer)\n' >&2
    else
      local limit=8
      (( ${#filtered[@]} < limit )) && limit=${#filtered[@]}
      local i
      for (( i = 0; i < limit; i++ )); do
        if (( i == selected )); then
          printf '\e[7m> %s\e[0m\n' "${filtered[$i]}" >&2
        else
          printf '  %s\n' "${filtered[$i]}" >&2
        fi
      done
    fi

    IFS= read -rsn1 key || break

    # Enter -> Übernehmen
    if [[ -z "$key" ]]; then
      printf '\r\e[J' >&2
      if (( ${#filtered[@]} > 0 )); then
        local picked="${filtered[$selected]}"

        # Fall A: Per Ctrl+R (Readline) aufgerufen -> direkt in den Prompt legen
        if [[ -n "${READLINE_LINE+x}" ]]; then
          READLINE_LINE="$picked"
          READLINE_POINT=${#READLINE_LINE}
        else
          # Fall B: Direkt als Befehl aufgerufen -> in Zwischenablage kopieren + ausgeben
          if __hstp_copy "$picked"; then
            printf '\e[32m[Kopiert]\e[0m %s\n' "$picked" >&2
          else
            printf '\e[33m[Hinweis: xclip/xsel fehlt]\e[0m %s\n' "$picked"
          fi
        fi
      fi
      return 0
    fi

    # Escape / Pfeiltasten
    if [[ "$key" == $'\e' ]]; then
      IFS= read -rsn2 -t 0.05 esc_seq || {
        printf '\r\e[J' >&2
        return 1
      }
      case "$esc_seq" in
        '[A') (( selected > 0 )) && (( selected-- )) ;;
        '[B') (( selected + 1 < ${#filtered[@]} )) && (( selected++ )) ;;
      esac
      continue
    fi

    # Backspace
    if [[ "$key" == $'\x7f' || "$key" == $'\b' ]]; then
      query="${query%?}"
      continue
    fi

    # Ctrl+C -> Abbruch
    if [[ "$key" == $'\x03' ]]; then
      printf '\r\e[J' >&2
      return 1
    fi

    query+="$key"
  done
}

# Wenn das Skript gesourct wird (aus .bashrc): Ctrl+R binden
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  bind -r '\C-r' 2>/dev/null
  bind -x '"\C-r": hstp'
else
  # Wenn direkt als ./hstp.sh oder hstp.sh ausgeführt: starten
  hstp "$@"
fi