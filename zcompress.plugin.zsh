# ~/.oh-my-zsh/custom/plugins/zcompress/zcompress.plugin.zsh

# Help function with colored output
zcompress::help() {
  print -P "%B%F{cyan}Usage:%f%b"
  print -P "  %Bzc%f <targetFile> <outFile>  - Compress a file or directory"
  print -P "  %Bzx%f <archiveFile> [destDir] - Extract an archive (default: current directory)"
  print -P "%B%F{cyan}Supported formats:%f%b .zip, .rar, .7z, .tar, .tar.gz, .tgz, .tar.xz, .bz2"
}

# Get file extension (lowercase, robust)
zcompress::get_ext() {
  local filePath="$1"
  # Use Zsh parameter expansion to extract extension
  local ext="${${filePath##*.}:l}"
  print -- "$ext"
}

# Check if a command exists
zcompress::check_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 && return 0 || return 1
}

# Install missing dependencies based on OS
zcompress::install_dependency() {
  local cmd="$1"
  local pkg="$2"
  local os_type="$(uname -s)"

  if ! zcompress::check_command "$cmd"; then
    print -P "%B%F{yellow}Installing $cmd...%f%b"
    case "$os_type" in
      Darwin)
        if ! zcompress::check_command brew; then
          print -P "%B%F{red}Error:%f%b Homebrew not found. Please install Homebrew or $cmd manually."
          return 1
        fi
        brew install "$pkg"
        ;;
      Linux)
        if [[ -f /etc/debian_version ]]; then
          sudo apt update && sudo apt install -y "$pkg"
        elif [[ -f /etc/arch-release ]]; then
          sudo pacman -S --noconfirm "$pkg"
        else
          print -P "%B%F{red}Error:%f%b Unsupported Linux distribution. Install $cmd manually."
          return 1
        fi
        ;;
      *)
        print -P "%B%F{red}Error:%f%b Unsupported OS: $os_type. Install $cmd manually."
        return 1
        ;;
    esac
    # Verify installation
    zcompress::check_command "$cmd" || {
      print -P "%B%F{red}Error:%f%b Failed to install $cmd."
      return 1
    }
  fi
  return 0
}

# Compression function
zcompress() {
  # Validate input
  if [[ $# -lt 2 ]]; then
    print -P "%B%F{red}Error:%f%b Too few arguments for compression."
    zcompress::help
    return 1
  fi

  local targetFolder="$1"
  local outFilePath="$2"
  local ext=$(zcompress::get_ext "$outFilePath")

  # Check if target exists
  if [[ ! -e "$targetFolder" ]]; then
    print -P "%B%F{red}Error:%f%b Target '$targetFolder' does not exist."
    return 1
  fi

  # Handle compression based on extension
  case "$ext" in
    rar)
      zcompress::install_dependency rar rar || return 1
      rar a "$outFilePath" "$targetFolder"
      ;;
    zip)
      zcompress::install_dependency zip zip || return 1
      zip -r "$outFilePath" "$targetFolder"
      ;;
    7z)
      zcompress::install_dependency 7z p7zip-full || return 1
      7z a "$outFilePath" "$targetFolder"
      ;;
    bz2)
      zcompress::install_dependency tar tar || return 1
      zcompress::install_dependency bzip2 bzip2 || return 1
      tar -cf "${outFilePath}.tar" "$targetFolder" && bzip2 "${outFilePath}.tar" && mv "${outFilePath}.tar.bz2" "$outFilePath"
      ;;
    tar)
      zcompress::install_dependency tar tar || return 1
      tar -cvf "$outFilePath" "$targetFolder"
      ;;
    tar.xz)
      zcompress::install_dependency tar tar || return 1
      tar -Jcvf "$outFilePath" "$targetFolder"
      ;;
    tar.gz|tgz)
      zcompress::install_dependency tar tar || return 1
      tar -zcvf "$outFilePath" "$targetFolder"
      ;;
    *)
      print -P "%B%F{red}Error:%f%b Extension '$ext' is not supported."
      zcompress::help
      return 1
      ;;
  esac

  if [[ $? -eq 0 ]]; then
    print -P "%B%F{green}Success:%f%b Compressed '$targetFolder' to '$outFilePath'."
  else
    print -P "%B%F{red}Error:%f%b Failed to compress to '$outFilePath'."
    return 1
  fi
}

# Extraction function
zextract() {
  # Validate input
  if [[ $# -lt 1 ]]; then
    print -P "%B%F{red}Error:%f%b Too few arguments for extraction."
    zcompress::help
    return 1
  fi

  local archiveFile="$1"
  local destDir="${2:-.}" # Default to current directory
  local ext=$(zcompress::get_ext "$archiveFile")

  # Check if archive exists
  if [[ ! -f "$archiveFile" ]]; then
    print -P "%B%F{red}Error:%f%b Archive '$archiveFile' does not exist."
    return 1
  fi

  # Create destination directory if it doesn't exist
  if [[ ! -d "$destDir" ]]; then
    mkdir -p "$destDir" || {
      print -P "%B%F{red}Error:%f%b Failed to create destination directory '$destDir'."
      return 1
    }
  fi

  # Handle extraction based on extension
  case "$ext" in
    rar)
      zcompress::install_dependency unrar unrar || return 1
      unrar x -y "$archiveFile" "$destDir"
      ;;
    zip)
      zcompress::install_dependency unzip unzip || return 1
      unzip -o "$archiveFile" -d "$destDir"
      ;;
    7z)
      zcompress::install_dependency 7z p7zip-full || return 1
      7z x "$archiveFile" -o"$destDir" -y
      ;;
    bz2)
      zcompress::install_dependency tar tar || return 1
      zcompress::install_dependency bzip2 bzip2 || return 1
      cp "$archiveFile" "${archiveFile}.bz2" && bunzip2 "${archiveFile}.bz2" && tar -xvf "${archiveFile}" -C "$destDir" && rm "${archiveFile}"
      ;;
    tar)
      zcompress::install_dependency tar tar || return 1
      tar -xvf "$archiveFile" -C "$destDir"
      ;;
    tar.xz)
      zcompress::install_dependency tar tar || return 1
      tar -Jxvf "$archiveFile" -C "$destDir"
      ;;
    tar.gz|tgz)
      zcompress::install_dependency tar tar || return 1
      tar -zxvf "$archiveFile" -C "$destDir"
      ;;
    *)
      print -P "%B%F{red}Error:%f%b Extension '$ext' is not supported."
      zcompress::help
      return 1
      ;;
  esac

  if [[ $? -eq 0 ]]; then
    print -P "%B%F{green}Success:%f%b Extracted '$archiveFile' to '$destDir'."
  else
    print -P "%B%F{red}Error:%f%b Failed to extract '$archiveFile'."
    return 1
  fi
}

# Aliases
alias zc=zcompress
alias zx=zextract