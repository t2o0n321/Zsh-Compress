# Zsh-Compress
Simple Oh My Zsh plugin for cross-platform compression/extraction workflows.

## Installation
1. Clone the repository:
```bash
git clone https://github.com/t2o0n321/Zsh-Compress.git "${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zcompress"
```
2. Add `zcompress` to `~/.zshrc`:
```zsh
plugins=(
  ...
  zcompress
)
```
3. Reload shell:
```bash
source ~/.zshrc
```

## Usage
- Compress: `zc <targetPath> <outFile>`
- Extract: `zx <archiveFile> [destDir]` (default: current directory)
- Help: `zc --help` or `zx --help`

Example:
```bash
zc myfolder output.tar.zst
zc notes.txt notes.txt.gz
zx output.tar.zst extracted_folder
zx notes.txt.gz
```

## Supported Formats
- Archive/package formats:
  - `.zip`, `.rar`, `.7z`, `.tar`
  - `.tar.gz`, `.tgz`
  - `.tar.xz`
  - `.tar.bz2`, `.tbz2`
  - `.tar.zst`, `.tzst`
- Single-file compression formats:
  - `.gz`, `.bz2`, `.xz`, `.zst`

Note: single-file formats (`.gz/.bz2/.xz/.zst`) do not package directories. Use `tar.*` for folders.

## Supported Platforms (auto dependency install)
- macOS: `brew`
- Linux: `apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`
- FreeBSD/Termux-style environments: `pkg`

Set `ZCOMPRESS_AUTO_INSTALL=0` to disable automatic dependency installation.

## Project Structure
```text
zcompress.plugin.zsh       # lightweight loader + aliases
lib/zcompress-utils.zsh    # shared helpers and help text
lib/zcompress-deps.zsh     # package manager + dependency install logic
lib/zcompress-formats.zsh  # format registry and handlers
lib/zcompress-commands.zsh # zcompress/zextract entrypoints
_zcompress                 # completion
```
