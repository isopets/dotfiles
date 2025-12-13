{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    # --- 🧠 Knowledge & History ---
    atuin       # 魔法の履歴管理 (Ctrl+Rの強化版)
    navi        # インタラクティブ・チートシート (Ctrl+G)
    tealdeer    # 'tldr' (manコマンドの分かりやすい版)
    
    # --- ⚡ Core Tools ---
    starship    # 宇宙船プロンプト
    zoxide      # 爆速ディレクトリ移動 (z)
    fzf         # あいまい検索
    bat         # リッチなcat
    eza         # リッチなls
    ripgrep     # 高速grep
    fd          # 高速find
    jq          # JSON整形
    watch       # 監視ツール
    tree        # ツリー表示

    # --- 🛡️ Dev & Security ---
    git
    lazygit     # Git TUI
    direnv      # ディレクトリごとの環境変数
    mise        # バージョン管理 (Node, Python等)
    gh          # GitHub CLI
    gum         # ゴージャスなシェルUI
    snyk        # 脆弱性診断
    
    # --- 🐍 Python Utils ---
    uv          # 高速Pythonマネージャー
  ];
}
