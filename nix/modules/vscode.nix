{ config, pkgs, ... }:

{
  # Home Manager で VS Code の設定を管理することを有効化
  programs.vscode.enable = true;

  # VS Code のグローバル設定 (User Settings) を定義
  programs.vscode.userSettings = {
    # 【最重要】Shell Integration を無効化し、ターミナルの挙動を標準Zshに統一する
    "terminal.integrated.shellIntegration.enabled" = false;

    // ここに、全プロファイルに共通で適用したい設定（例: フォントサイズ、テーマ）を追記できます
    // "editor.fontSize" = 14;
  };
  
  // NOTE: VS Code Extensionsの管理もここに追加可能ですが、
  // 現時点ではファイル分離のみに留めています。
}