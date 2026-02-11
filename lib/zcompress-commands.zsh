# Public command entrypoints.

zcompress() {
  local target_path="$1"
  local out_file="$2"
  local format

  if [[ "$target_path" == "-h" || "$target_path" == "--help" ]]; then
    zcompress::help
    return 0
  fi

  if [[ $# -lt 2 ]]; then
    zcompress::print_error "Too few arguments for compression."
    zcompress::help
    return 1
  fi

  if [[ ! -e "$target_path" ]]; then
    zcompress::print_error "Target '$target_path' does not exist."
    return 1
  fi

  format="$(zcompress::detect_format "$out_file")" || {
    zcompress::print_error "Could not detect a supported format from '$out_file'."
    zcompress::help
    return 1
  }

  zcompress::compress_with_format "$target_path" "$out_file" "$format" || {
    zcompress::print_error "Failed to compress '$target_path' to '$out_file'."
    return 1
  }

  zcompress::print_success "Compressed '$target_path' to '$out_file'."
}

zextract() {
  local archive_file="$1"
  local dest_dir="${2:-.}"
  local format

  if [[ "$archive_file" == "-h" || "$archive_file" == "--help" ]]; then
    zcompress::help
    return 0
  fi

  if [[ $# -lt 1 ]]; then
    zcompress::print_error "Too few arguments for extraction."
    zcompress::help
    return 1
  fi

  if [[ ! -f "$archive_file" ]]; then
    zcompress::print_error "Archive '$archive_file' does not exist."
    return 1
  fi

  zcompress::ensure_directory "$dest_dir" || {
    zcompress::print_error "Failed to create destination directory '$dest_dir'."
    return 1
  }

  format="$(zcompress::detect_format "$archive_file")" || {
    zcompress::print_error "Could not detect a supported format from '$archive_file'."
    zcompress::help
    return 1
  }

  zcompress::extract_with_format "$archive_file" "$dest_dir" "$format" || {
    zcompress::print_error "Failed to extract '$archive_file'."
    return 1
  }

  zcompress::print_success "Extracted '$archive_file' to '$dest_dir'."
}
