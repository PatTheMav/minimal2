#
# Minimal theme
#
# Original minimal theme for zsh written by subnixr:
# https://github.com/subnixr/minimal
#

function {
  zstyle -s ':color:ok' minimal2 'MNML_OK_COLOR' || MNML_OK_COLOR=${MNML_OK_COLOR:-'green'}
  zstyle -s ':color:clean' minimal2 'MNML_CLEAN_COLOR' || MNML_CLEAN_COLOR=${MNML_CLEAN_COLOR:-'green'}
  zstyle -s ':color:error' minimal2 'MNML_ERR_COLOR' || MNML_ERR_COLOR=${MNML_ERR_COLOR:-'red'}
  zstyle -s ':color:diverged' minimal2 'MNML_DIV_COLOR' || MNML_DIV_COLOR=${MNML_DIV_COLOR:-'magenta'}
  zstyle -s ':color:dirty' minimal2 'MNML_DIRTY_COLOR' || MNML_DIRTY_COLOR=${MNML_DIRTY_COLOR:-'red'}
  zstyle -s ':color:behind' minimal2 'MNML_BEHIND_COLOR' || MNML_BEHIND_COLOR=${MNML_BEHIND_COLOR:-'cyan'}
  zstyle -s ':color:ahead' minimal2 'MNML_AHEAD_COLOR' || MNML_AHEAD_COLOR=${MNML_AHEAD_COLOR:-'cyan'}

  zstyle -s ':char:user' minimal2 'MNML_USER_CHAR' || MNML_USER_CHAR=${MNML_USER_CHAR:-'λ'}
  zstyle -s ':char:insert' minimal2 'MNML_INSERT_CHAR' || MNML_INSERT_CHAR=${MNML_INSERT_CHAR:-'›'}
  zstyle -s ':char:normal' minimal2 'MNML_NORMAL_CHAR' || MNML_NORMAL_CHAR=${MNML_NORMAL_CHAR:-'·'}
  zstyle -s ':char:git:ahead' minimal2 'MNML_AHEAD_CHAR' || MNML_AHEAD_CHAR=${MNML_AHEAD_CHAR:-''}
  zstyle -s ':char:git:behind' minimal2 'MNML_BEHIND_CHAR' || MNML_BEHIND_CHAR=${MNML_BEHIND_CHAR:-''}
  zstyle -s ':char:git:dirty' minimal2 'MNML_DIRTY_CHAR' || MNML_DIRTY_CHAR=${MNML_DIRTY_CHAR:-''}
  zstyle -s ':char:git:clean' minimal2 'MNML_CLEAN_CHAR' || MNML_CLEAN_CHAR=${MNML_CLEAN_CHAR:-''}
  zstyle -s ':char:git:diverged' minimal2 'MNML_DIV_CHAR' || MNML_DIV_CHAR=${MNML_DIV_CHAR:-''}

  zstyle -a ':config:prompt' minimal2 'MNML_PROMPT' || MNML_PROMPT=${MNML_PROMPT}
  [ "${+MNML_PROMPT}" -eq 0 ] && MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)
  zstyle -a ':config:rprompt' minimal2 'MNML_RPROMPT' || MNML_RPROMPT=${MNML_RPROMPT}
  [ "${+MNML_RPROMPT}" -eq 0 ] && MNML_RPROMPT=('mnml_cwd 2 0' mnml_git)
  zstyle -a ':config:infoline' minimal2 'MNML_INFOLN' || MNML_INFOLN=${MNML_INFOLN}
  [ "${+MNML_INFOLN}" -eq 0 ] && MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)

  zstyle -a ':config:magicenter' minimal2 'MNML_MAGICENTER' || MNML_MAGICENTER=${MNML_MAGICENTER}
  [ "${+MNML_MAGICENTER}" -eq 0 ] && MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)
}

# Components
mnml_status() {
  local output="%F{%(?.${MNML_OK_COLOR}.${MNML_ERR_COLOR})}%(!.#.${MNML_USER_CHAR})%f"

  echo -n "%(1j.%U${output}%u.${output})"
}

mnml_keymap() {
  local kmstat="${MNML_INSERT_CHAR}"
  [ "$KEYMAP" = 'vicmd' ] && kmstat="${MNML_NORMAL_CHAR}"
  echo -n "${kmstat}"
}

mnml_cwd() {
  local segments="${1:-2}"
  local seg_len="${2:-0}"

  if [ "${segments}" -le 0 ]; then
    segments=1
  fi
  if [ "${seg_len}" -gt 0 ] && [ "${seg_len}" -lt 4 ]; then
    seg_len=4
  fi
  local seg_hlen=$((seg_len / 2 - 1))

  local cwd="%${segments}~"
  cwd="${(%)cwd}"
  cwd=("${(@s:/:)cwd}")

  local pi=""
  for i in {1..${#cwd}}; do
    pi="$cwd[$i]"
    if [ "${seg_len}" -gt 0 ] && [ "${#pi}" -gt "${seg_len}" ]; then
      cwd[$i]="%F{244}${pi:0:$seg_hlen}%F{white}..%F{244}${pi: -$seg_hlen}%f"
    fi
  done

  echo -n "%F{244}${(j:/:)cwd//\//%F{white\}/%F{244\}}%f"
}

mnml_git() {
  [[ -n ${git_info} ]] && echo -n " ${(e)git_info[color]}${(e)git_info[rprompt]}"
}

mnml_uhp() {
  local cwd="%~"
  cwd="${(%)cwd}"

  echo -n "%F{244}%n%F{white}@%F{244}%m%F{white}:%F{244}${cwd//\//%F{white\}/%f%F{244\}}%f"
}

mnml_ssh() {
  if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
    echo -n "$(hostname -s)"
  fi
}

mnml_pyenv() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    _venv="$(basename ${VIRTUAL_ENV})"
    echo -n "${_venv%%.*}"
  fi
}

mnml_err() {
  echo -n "%(0?..%F{${MNML_ERR_COLOR}}${MNML_LAST_ERR}%f)"
}

mnml_jobs() {
  echo -n "%(1j.%F{244}%j&%f.)"
}

mnml_files() {
  local a_files="$(ls -1A | sed -n '$=')"
  local v_files="$(ls -1 | sed -n '$=')"
  local h_files="$((a_files - v_files))"

  local output="[%F{244}${v_files:-0}%f"

  if [ "${h_files:-0}" -gt 0 ]; then
    output="$output (%F{244}$h_files%f)"
  fi
  output="${output}]"

  echo -n "${output}"
}

# Magic enter functions
mnml_me_dirs() {
  if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
    local stack="$(dirs)"
    echo -n "%F{244}${stack//\//%F{white\}/%F{244\}}%f"
  fi
}

mnml_me_ls() {
  if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
    COLUMNS=${COLUMNS} CLICOLOR_FORCE=1 ls -C -G -F
  else
    ls -C -F --color="always" -w ${COLUMNS}
  fi
}

mnml_me_git() {
  git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
mnml_wrap() {
  local -a arr
  arr=()
  local cmd_out=""
  local cmd
  for cmd in ${(P)1}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      arr+="${cmd_out}"
    fi
  done

  echo -n "${(j: :)arr}"
}

# expand string as prompt would do
mnml_iline() {
  echo "${(%)1}"
}

# display magic enter
mnml_me() {
  local -a output
  output=()
  local cmd_output=""
  local cmd
  for cmd in ${MNML_MAGICENTER}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      output+="${(%)cmd_out}"
    fi
  done
  echo -n "${(j:\n:)output}" | less -XFR
}

# capture exit status and reset prompt
mnml_zle-line-init() {
  MNML_LAST_ERR="$?" # I need to capture this ASAP

  zle reset-prompt
}

# redraw prompt on keymap select
mnml_zle-keymap-select() {
  zle reset-prompt
}

# draw infoline if no command is given
mnml_buffer-empty() {
  if [ -z "${BUFFER}" ] && [ ! "${+MNML_MAGICENTER}" -eq 0 ]; then
    mnml_iline "$(mnml_wrap MNML_INFOLN)"
    mnml_me
    # zle redisplay
    zle zle-line-init
  else
    zle accept-line
  fi
}

# Safely bind widgets
# see: https://github.com/zsh-users/zsh-syntax-highlighting/blob/1f1e629290773bd6f9673f364303219d6da11129/zsh-syntax-highlighting.zsh#L292-L356
prompt_minimal2_bind() {
  zmodload zsh/zleparameter

  local -a bindings
  bindings=(zle-line-init zle-keymap-select buffer-empty)

  typeset -F SECONDS
  local zle_prefix="s${SECONDS}-r${RANDOM}"
  local cur_widget
  for cur_widget in ${bindings}; do
    case "${widgets[$cur_widget]:-""}" in
      user:mnml_*);;
      user:*)
        zle -N ${zle_prefix}-${cur_widget} ${widgets[$cur_widget]#*:}
        eval "mnml_ww_${(q)zle_prefix}-${(q)cur_widget}() { mnml_${(q)cur_widget}; zle ${(q)zle_prefix}-${(q)cur_widget} }"
        zle -N ${cur_widget} mnml_ww_${zle_prefix}-${cur_widget}
        ;;
      *)
        zle -N ${cur_widget} mnml_${cur_widget}
        ;;
    esac
  done
}

prompt_minimal2_help() {
  cat <<EOH
  This prompt can be customized by setting environment variables in your
  .zshrc:

  --> (Note: For zstyle configuration, please check README.md) <--

  - MNML_OK_COLOR     : Color for successful things (default: 'green')
  - MNML_ERR_COLOR    : Color for failures (default: 'red')
  - MNML_CLEAN_COLOR    : Color for clean git status (default: 'green')
  - MNML_DIV_COLOR    : Color for diverged git status (default: 'magenta')
  - MNML_AHEAD_COLOR  : Color for repositories ahead of master (default: 'cyan')
  - MNML_BEHIND_COLOR : Color for repositories behind of master (default: 'cyan')
  - MNML_USER_CHAR    : Character used for unprivileged users (default: 'λ')
  - MNML_INSERT_CHAR  : Character used for vi insert mode (default: '›')
  - MNML_NORMAL_CHAR  : Character used for vi normal mode (default: '·')
  - MNML_AHEAD_CHAR   : Character used for ahead status (default: none)
  - MNML_BEHIND_CHAR  : Character used for behind status (default: none)
  - MNML_DIRTY_CHAR   : Character used for dirty git status (default: none)
  - MNML_CLEAN_CHAR   : Character used for clean git status (default: none)
  - MNML_DIV_CHAR     : Character used for diverged git status (default: none)

  --------------------------------------------------------------------------

  Three global arrays handle the definition and rendering position of the components:

  - Components on the left prompt
    MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)

  - Components on the right prompt
    MNML_RPROMPT=('mnml_cwd 2 0' mnml_git)

  - Components shown on info line
    MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)

  --------------------------------------------------------------------------

  An additional array is used to configure magic enter's behavior:

    MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)

  --------------------------------------------------------------------------

  Also some characters and colors can be set with direct prompt parameters
  (those will override the environment vars):

  prompt minimal2 [mnml_ok_color] [mnml_err_color] [mnml_div_color]
                  [mnml_user_char] [mnml_insert_char] [mnml_normal_char]

  --------------------------------------------------------------------------
EOH
}

prompt_minimal2_preview() {
  if (( ${#} )); then
    prompt_preview_theme minimal2 "${@}"
  else
    prompt_preview_theme minimal2
    print
    prompt_preview_theme minimal2 'green' 'red' 'magenta' '#' '>' 'o'
  fi
}

prompt_minimal2_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_minimal2_setup() {
  autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_minimal2_precmd
  prompt_opts=( cr percent sp subst )
  setopt nopromptbang promptcr promptpercent promptsp promptsubst
  prompt_minimal2_bind

  MNML_OK_COLOR="${${1}:-${MNML_OK_COLOR}}"
  MNML_ERR_COLOR="${${2}:-${MNML_ERR_COLOR}}"
  MNML_DIV_COLOR="${${3}:-${MNML_DIV_COLOR}}"
  MNML_USER_CHAR="${${4}:-${MNML_USER_CHAR}}"
  MNML_INSERT_CHAR="${${5}:-${MNML_INSERT_CHAR}}"
  MNML_NORMAL_CHAR="${${6}:-${MNML_NORMAL_CHAR}}"

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:dirty' format '%F{${MNML_DIRTY_COLOR}}${MNML_DIRTY_CHAR}'
  zstyle ':zim:git-info:diverged' format '%F{${MNML_DIV_COLOR}}${MNML_DIV_CHAR}'
  zstyle ':zim:git-info:behind' format '%F{${MNML_DIRTY_COLOR}}${MNML_BEHIND_CHAR}'
  zstyle ':zim:git-info:ahead' format '%F{${MNML_AHEAD_COLOR}}${MNML_AHEAD_CHAR}'
  zstyle ':zim:git-info:clean' format '%F{${MNML_CLEAN_COLOR}}${MNML_CLEAN_CHAR}'
  zstyle ':zim:git-info:keys' format \
    'prompt' '' \
    'rprompt' '%b%c' \
    'color' '$(coalesce "%D" "%V" "%B" "%A" "%C")'

  PS1='$(mnml_wrap MNML_PROMPT) '
  RPS1='$(mnml_wrap MNML_RPROMPT)'

  bindkey -M main "^M" buffer-empty
  bindkey -M vicmd "^M" buffer-empty
}

prompt_minimal2_setup "${@}"