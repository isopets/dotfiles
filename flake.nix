{
  description = "Cockpit Darwin System";

  inputs = {
    # Stable (Base OS)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    # Unstable (Bleeding Edge Tools)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Nix-Darwin (The OS Manager)
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # Home Manager (The User Manager)
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    # 共通のアーキテクチャ設定
    system = "aarch64-darwin"; # Apple Silicon
    
    # Unstable パッケージセットの作成
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    darwinConfigurations = {
      # 🚨 ここをあなたのホスト名 (scutil --get LocalHostName) に書き換えてください
      "isogaiyuujinnoMacBook-Air" = nix-darwin.lib.darwinSystem {
        inherit system;
        
        # モジュール引数として Unstable を渡す
        specialArgs = { inherit inputs pkgs-unstable; };
        
        modules = [
          # 1. OS設定 (Finder, Dock, Yabai)
          ./nix/modules/darwin.nix
          
          # 2. ユーザー設定 (Home Manager を統合)
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.isogaiyuto = import ./home.nix;
            
            # Home Manager 側にも Unstable を渡す
            home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          }
        ];
      };
    };
  };
}