# Zsh-Compress
簡單的壓縮懶人包插件。

# Installation
1. Clone the repository
    ```
    git clone http://gitlab.lan/t2o0n321/Zsh-Compress.git ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/zcompress
    ```
2. Add it to ``~/.zshrc``
    ```
    plugins=( 
        ...
        zcompress
    )
    ```
3. Reload Zsh: `source ~/.zshrc`

# Usage
- Compress: `zc <targetFile> <outFile>`
- Extract: `zx <archiveFile> [destDir]` (defaults to current directory)
- Examples:
    ```bash
    zc myfolder output.zip         # Compress myfolder to output.zip
    zx output.zip extracted_folder # Extract output.zip to extracted_folder
    zx output.zip                  # Extract to current directory
    ```

# Supported Formats
- .zip, .rar, .7z, .tar, .tar.gz, .tgz, .tar.xz, .bz2