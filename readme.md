# Zsh-Compress
簡單的壓縮懶人包插件。
# Installation
1. Clone the repository
    ```
    git clone https://github.com/t2o0n321/Zsh-Compress.git ${ZSH_CUSTOM:-~/.oh-my-zsh}/plugins/compress
    ```
2. Add it to ``~/.zshrc``
    ```
    plugins=( 
        ...
        compress
    )
    ```
# Usage
```
compress [目標資料夾] [輸出檔案]
```
# Supported Compression Format
- ``.rar``
- ``.zip``
- ``.7z``
- ``.bz2``
- ``.tar``
- ``.tar.xz``
- ``.tar.gz``
- ``.tgz``