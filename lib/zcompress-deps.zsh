# Dependency installation and platform/package-manager resolution.

typeset -g ZCOMPRESS_APT_UPDATED=0
: "${ZCOMPRESS_AUTO_INSTALL:=1}"

zcompress::detect_pkg_manager() {
  local manager
  local -a managers=(brew apt dnf yum pacman zypper apk pkg)

  for manager in "${managers[@]}"; do
    if zcompress::check_command "$manager"; then
      print -- "$manager"
      return 0
    fi
  done

  return 1
}

zcompress::resolve_package_name() {
  local manager="$1"
  local command_name="$2"

  case "$manager:$command_name" in
    brew:7z) print -- "p7zip" ;;
    apt:7z) print -- "p7zip-full" ;;
    dnf:7z|yum:7z|pacman:7z|zypper:7z|apk:7z|pkg:7z) print -- "p7zip" ;;
    brew:unrar|apt:unrar|dnf:unrar|yum:unrar|pacman:unrar|zypper:unrar|apk:unrar|pkg:unrar) print -- "unrar" ;;
    brew:rar|apt:rar|dnf:rar|yum:rar|pacman:rar|zypper:rar|apk:rar|pkg:rar) print -- "rar" ;;
    brew:zip|apt:zip|dnf:zip|yum:zip|pacman:zip|zypper:zip|apk:zip|pkg:zip) print -- "zip" ;;
    brew:unzip|apt:unzip|dnf:unzip|yum:unzip|pacman:unzip|zypper:unzip|apk:unzip|pkg:unzip) print -- "unzip" ;;
    brew:tar|apt:tar|dnf:tar|yum:tar|pacman:tar|zypper:tar|apk:tar|pkg:tar) print -- "tar" ;;
    brew:gzip|apt:gzip|dnf:gzip|yum:gzip|pacman:gzip|zypper:gzip|apk:gzip|pkg:gzip) print -- "gzip" ;;
    brew:bzip2|apt:bzip2|dnf:bzip2|yum:bzip2|pacman:bzip2|zypper:bzip2|apk:bzip2|pkg:bzip2) print -- "bzip2" ;;
    brew:xz|apt:xz|dnf:xz|yum:xz|pacman:xz|zypper:xz|apk:xz|pkg:xz) print -- "xz" ;;
    brew:zstd|apt:zstd|dnf:zstd|yum:zstd|pacman:zstd|zypper:zstd|apk:zstd|pkg:zstd) print -- "zstd" ;;
    *) print -- "$command_name" ;;
  esac
}

zcompress::install_with_manager() {
  local manager="$1"
  local package_name="$2"
  local is_termux=0
  local -a sudo_cmd=()

  if [[ -n "${PREFIX:-}" && "${PREFIX}" == *"/com.termux/"* ]]; then
    is_termux=1
  fi

  if [[ "$manager" != "brew" && "$manager" != "pkg" && "$EUID" -ne 0 ]]; then
    if zcompress::check_command sudo; then
      sudo_cmd=(sudo)
    else
      zcompress::print_error "sudo is required to install '$package_name' via $manager."
      return 1
    fi
  elif [[ "$manager" == "pkg" && "$EUID" -ne 0 && "$is_termux" -eq 0 ]]; then
    if zcompress::check_command sudo; then
      sudo_cmd=(sudo)
    fi
  fi

  case "$manager" in
    brew)
      brew install "$package_name"
      ;;
    apt)
      if [[ "$ZCOMPRESS_APT_UPDATED" -eq 0 ]]; then
        "${sudo_cmd[@]}" apt update || return 1
        ZCOMPRESS_APT_UPDATED=1
      fi
      "${sudo_cmd[@]}" apt install -y "$package_name"
      ;;
    dnf)
      "${sudo_cmd[@]}" dnf install -y "$package_name"
      ;;
    yum)
      "${sudo_cmd[@]}" yum install -y "$package_name"
      ;;
    pacman)
      "${sudo_cmd[@]}" pacman -Sy --noconfirm "$package_name"
      ;;
    zypper)
      "${sudo_cmd[@]}" zypper --non-interactive install "$package_name"
      ;;
    apk)
      "${sudo_cmd[@]}" apk add "$package_name"
      ;;
    pkg)
      "${sudo_cmd[@]}" pkg install -y "$package_name"
      ;;
    *)
      return 1
      ;;
  esac
}

zcompress::install_dependency() {
  local command_name="$1"
  local manager package_name

  if zcompress::check_command "$command_name"; then
    return 0
  fi

  if [[ "$ZCOMPRESS_AUTO_INSTALL" != "1" ]]; then
    zcompress::print_error "Missing dependency '$command_name'. Set ZCOMPRESS_AUTO_INSTALL=1 to allow auto-install."
    return 1
  fi

  manager="$(zcompress::detect_pkg_manager)" || {
    zcompress::print_error "No supported package manager found. Install '$command_name' manually."
    return 1
  }

  package_name="$(zcompress::resolve_package_name "$manager" "$command_name")"
  zcompress::print_info "Installing '$command_name' with $manager (package: $package_name)..."

  zcompress::install_with_manager "$manager" "$package_name" || {
    zcompress::print_error "Failed to install '$package_name' using $manager."
    return 1
  }

  if ! zcompress::check_command "$command_name"; then
    zcompress::print_error "Command '$command_name' is still unavailable after installation."
    return 1
  fi

  return 0
}
