if [[ -n "${__ZCOMPRESS_LOADED:-}" ]]; then
  return 0
fi
typeset -g __ZCOMPRESS_LOADED=1

typeset -g ZCOMPRESS_PLUGIN_DIR="${${(%):-%N}:A:h}"
typeset module

for module in utils deps formats commands; do
  source "$ZCOMPRESS_PLUGIN_DIR/lib/zcompress-${module}.zsh"
done

alias zc=zcompress
alias zx=zextract
