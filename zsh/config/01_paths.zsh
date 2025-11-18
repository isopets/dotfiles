# --- 基本設定 ---

# 日本語ファイル名の文字化け防止
export LANG=ja_JP.UTF-8

# M1/M2/M3 Mac用 Homebrewパス
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
