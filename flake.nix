{
  description = "The ultimate cockpit dotfiles environment managed by Nix";

  inputs = {
    # 安定したNixpkgsのバージョンを固定 (実績のあるLTS版を選択)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; 
    
    # Home Managerの安定版バージョンを固定
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # HMがNixpkgsのバージョンをこのflakeの設定に合わせる
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    # Home Managerの最終出力設定
    homeConfigurations = {
      "isogaiyuto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-darwin; # macOS (Darwin) 環境であることを明記
        # 既存のhome.nixファイルをモジュールとして読み込む
        modules = [ ./home.nix ];
      };
    };
  };
}
