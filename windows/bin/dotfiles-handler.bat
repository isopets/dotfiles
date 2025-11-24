@echo off
setlocal

REM --- Configuration ---
REM WSLのディストリビューション名 (Ubuntuなど)
set WSL_DISTRO=Ubuntu

REM URL引数を取得 (dotfiles://...)
set "URL_PAYLOAD=%1"

REM WSLを起動し、Zshのハンドラー関数を呼び出す
REM (Windows側のパス変換などの面倒な処理はWSL側に任せる)
wsl.exe -d %WSL_DISTRO% zsh -i -c "dotfiles_url_handler \"%URL_PAYLOAD%\""

endlocal
