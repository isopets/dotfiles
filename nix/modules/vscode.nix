{ config, pkgs, ... }:

{
  programs.vscode.enable = true;

  programs.vscode.userSettings = {
    "terminal.integrated.shellIntegration.enabled" = false;

    # ここに、全プロファイルに共通で適用したい設定（例: フォントサイズ、テーマ）を追記できます
    # "editor.fontSize" = 14; 
  };
  
  # NOTE: VS Code Extensionsの管理もここに追記可能ですが、
  # 現時点ではファイル分離のみに留めています。
}