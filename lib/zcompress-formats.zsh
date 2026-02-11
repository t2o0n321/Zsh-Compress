# Format registry and format-specific compression/extraction handlers.

# Keep multi-part suffixes first so format detection prefers them.
typeset -ga ZCOMPRESS_SUPPORTED_FORMATS=(
  tar.zst tar.bz2 tar.gz tar.xz
  tbz2 tgz tzst
  zip rar 7z tar
  gz bz2 xz zst
)

zcompress::require_commands() {
  local cmd
  for cmd in "$@"; do
    zcompress::install_dependency "$cmd" || return 1
  done
}

zcompress::compress_file_stream() {
  local command_name="$1"
  local input_file="$2"
  local output_file="$3"

  case "$command_name" in
    gzip) gzip -c -- "$input_file" >| "$output_file" ;;
    bzip2) bzip2 -c -- "$input_file" >| "$output_file" ;;
    xz) xz -c -- "$input_file" >| "$output_file" ;;
    zstd) zstd -q -c -- "$input_file" >| "$output_file" ;;
    *) return 1 ;;
  esac
}

zcompress::extract_file_stream() {
  local command_name="$1"
  local archive_file="$2"
  local output_file="$3"

  case "$command_name" in
    gzip) gzip -dc -- "$archive_file" >| "$output_file" ;;
    bzip2) bzip2 -dc -- "$archive_file" >| "$output_file" ;;
    xz) xz -dc -- "$archive_file" >| "$output_file" ;;
    zstd) zstd -q -dc -- "$archive_file" >| "$output_file" ;;
    *) return 1 ;;
  esac
}

zcompress::output_name_from_archive() {
  local archive_file="$1"
  local format="$2"
  local output_name="${archive_file:t}"

  output_name="${output_name%.$format}"
  if [[ -z "$output_name" || "$output_name" == "${archive_file:t}" ]]; then
    output_name="${archive_file:t}.out"
  fi

  print -- "$output_name"
}

zcompress::compress_with_format() {
  setopt local_options pipefail
  local target_path="$1"
  local out_file="$2"
  local format="$3"

  case "$format" in
    rar)
      zcompress::require_commands rar || return 1
      rar a "$out_file" "$target_path"
      ;;
    zip)
      zcompress::require_commands zip || return 1
      zip -r "$out_file" "$target_path"
      ;;
    7z)
      zcompress::require_commands 7z || return 1
      7z a "$out_file" "$target_path"
      ;;
    tar)
      zcompress::require_commands tar || return 1
      tar -cvf "$out_file" "$target_path"
      ;;
    tar.gz|tgz)
      zcompress::require_commands tar gzip || return 1
      tar -czvf "$out_file" "$target_path"
      ;;
    tar.xz)
      zcompress::require_commands tar xz || return 1
      tar -cJvf "$out_file" "$target_path"
      ;;
    tar.bz2|tbz2)
      zcompress::require_commands tar bzip2 || return 1
      tar -cjvf "$out_file" "$target_path"
      ;;
    tar.zst|tzst)
      zcompress::require_commands tar zstd || return 1
      tar -cvf - "$target_path" | zstd -q -o "$out_file"
      ;;
    gz)
      zcompress::require_commands gzip || return 1
      if [[ -d "$target_path" ]]; then
        zcompress::print_error "'.gz' is file-only. Use '.tar.gz' for directories."
        return 1
      fi
      zcompress::compress_file_stream gzip "$target_path" "$out_file"
      ;;
    bz2)
      zcompress::require_commands bzip2 || return 1
      if [[ -d "$target_path" ]]; then
        zcompress::print_error "'.bz2' is file-only. Use '.tar.bz2' for directories."
        return 1
      fi
      zcompress::compress_file_stream bzip2 "$target_path" "$out_file"
      ;;
    xz)
      zcompress::require_commands xz || return 1
      if [[ -d "$target_path" ]]; then
        zcompress::print_error "'.xz' is file-only. Use '.tar.xz' for directories."
        return 1
      fi
      zcompress::compress_file_stream xz "$target_path" "$out_file"
      ;;
    zst)
      zcompress::require_commands zstd || return 1
      if [[ -d "$target_path" ]]; then
        zcompress::print_error "'.zst' is file-only. Use '.tar.zst' for directories."
        return 1
      fi
      zcompress::compress_file_stream zstd "$target_path" "$out_file"
      ;;
    *)
      return 1
      ;;
  esac
}

zcompress::extract_with_format() {
  setopt local_options pipefail
  local archive_file="$1"
  local dest_dir="$2"
  local format="$3"
  local output_name output_path

  case "$format" in
    rar)
      zcompress::require_commands unrar || return 1
      unrar x -y "$archive_file" "$dest_dir"
      ;;
    zip)
      zcompress::require_commands unzip || return 1
      unzip -o "$archive_file" -d "$dest_dir"
      ;;
    7z)
      zcompress::require_commands 7z || return 1
      7z x "$archive_file" -o"$dest_dir" -y
      ;;
    tar)
      zcompress::require_commands tar || return 1
      tar -xvf "$archive_file" -C "$dest_dir"
      ;;
    tar.gz|tgz)
      zcompress::require_commands tar gzip || return 1
      tar -xzvf "$archive_file" -C "$dest_dir"
      ;;
    tar.xz)
      zcompress::require_commands tar xz || return 1
      tar -xJvf "$archive_file" -C "$dest_dir"
      ;;
    tar.bz2|tbz2)
      zcompress::require_commands tar bzip2 || return 1
      tar -xjvf "$archive_file" -C "$dest_dir"
      ;;
    tar.zst|tzst)
      zcompress::require_commands tar zstd || return 1
      zstd -q -dc -- "$archive_file" | tar -xvf - -C "$dest_dir"
      ;;
    gz)
      zcompress::require_commands gzip || return 1
      output_name="$(zcompress::output_name_from_archive "$archive_file" "gz")"
      output_path="$dest_dir/$output_name"
      zcompress::extract_file_stream gzip "$archive_file" "$output_path"
      ;;
    bz2)
      zcompress::require_commands bzip2 || return 1
      output_name="$(zcompress::output_name_from_archive "$archive_file" "bz2")"
      output_path="$dest_dir/$output_name"
      zcompress::extract_file_stream bzip2 "$archive_file" "$output_path"
      ;;
    xz)
      zcompress::require_commands xz || return 1
      output_name="$(zcompress::output_name_from_archive "$archive_file" "xz")"
      output_path="$dest_dir/$output_name"
      zcompress::extract_file_stream xz "$archive_file" "$output_path"
      ;;
    zst)
      zcompress::require_commands zstd || return 1
      output_name="$(zcompress::output_name_from_archive "$archive_file" "zst")"
      output_path="$dest_dir/$output_name"
      zcompress::extract_file_stream zstd "$archive_file" "$output_path"
      ;;
    *)
      return 1
      ;;
  esac
}
