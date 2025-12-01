{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # --- 🛡️ Immutable Infrastructure Aliases ---
    # ここには「ツールの置き換え」や「安全装置」のみを定義する
    shellAliases = {
      # Modern Core Utils (Nixで入れたツールへの紐付け)
      ls = "eza --icons --git";
      cat = "bat";
      grep = "rg";
      find = "fd";
      
      # Editor Force
      vi = "nvim";
      vim = "nvim";
      
      # Safety Nets (事故防止)
      cp = "cp -i";
      mv = "mv -i";
      # rm は cockpit_logic.zsh で関数として制御しているため、ここでは定義しない
      # (あるいは rm = "trash-put" とここで強制しても良い)
    };

    # 🚨 最終形態: 全てを Sheldon に任せる
    initExtra = ''
      # Sheldon Init
      eval "$(sheldon source)"
    '';
  };
}