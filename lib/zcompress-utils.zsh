# Shared utilities for the zcompress plugin.

zcompress::print_info() {
  print -P "%B%F{cyan}Info:%f%b $*"
}

zcompress::print_success() {
  print -P "%B%F{green}Success:%f%b $*"
}

zcompress::print_error() {
  print -P "%B%F{red}Error:%f%b $*"
}

zcompress::check_command() {
  command -v "$1" >/dev/null 2>&1
}

zcompress::detect_format() {
  local file_name="${1:t:l}"
  local format

  for format in "${ZCOMPRESS_SUPPORTED_FORMATS[@]}"; do
    if [[ "$file_name" == *".$format" ]]; then
      print -- "$format"
      return 0
    fi
  done

  return 1
}

zcompress::ensure_directory() {
  local dir="$1"
  [[ -d "$dir" ]] || mkdir -p "$dir"
}

zcompress::help() {
  local formats="${(j:, :)ZCOMPRESS_SUPPORTED_FORMATS}"
  print -P "%B%F{cyan}Usage:%f%b"
  print -P "  %Bzc%f <targetPath> <outFile>  - Compress a file or directory"
  print -P "  %Bzx%f <archiveFile> [destDir] - Extract an archive (default: current directory)"
  print -P "%B%F{cyan}Supported formats:%f%b $formats"
  print -P "%B%F{yellow}Note:%f%b .gz/.bz2/.xz/.zst are file-only formats. Use tar.* for directories."
}
