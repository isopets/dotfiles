{ config, pkgs, ... }:

{
  # 既存のプロファイルパスにある settings.json の内容をNixで定義する
  home.file = {
    # 1. [Base] Common プロファイルの設定
    # 全てのプロファイルのベースとなる設定を定義します。
    "dotfiles/vscode/profiles/[Base] Common/settings.json" = {
      enable = true;
      text = builtins.toJSON {
        "editor.fontSize" = 13;
        "editor.wordWrap" = "on";
      };
    };

    # 2. [Lang] Python プロファイルの設定
    # Python開発時に必要な追加設定を定義します。
    "dotfiles/vscode/profiles/[Lang] Python/settings.json" = {
      enable = true;
      text = builtins.toJSON {
        "editor.fontSize" = 16; # Python作業時だけフォントを大きくする例
        "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
      };
    };
    
    # 3. [Lang] Web プロファイルの設定（省略）
    # ... 他のプロファイルも同様に追記 ...
  };
}