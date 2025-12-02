{
  description = "Cockpit Darwin System";

  inputs = {
    # 🚀 Base OS: Unstable (常に最新・最強の構成にする)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # 📦 Tools: Baseと同じものを指す (重複ダウンロード回避)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # 🍏 Nix-Darwin: Master (最新のmacOSに対応)
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # 🏠 Home Manager: Master (最新のNixpkgsに対応)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "aarch64-darwin"; # Apple Silicon
    
    # Unstableパッケージセット (中身はBaseと同じだが、互換性維持のため定義)
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    darwinConfigurations = {
      # 🚨 ここをあなたのホスト名に書き換えてください (scutil --get LocalHostName)
      "isogaiyuujinnoMacBook-Air" = nix-darwin.lib.darwinSystem {
        inherit system;
        
        specialArgs = { inherit inputs pkgs-unstable; };
        
        modules = [
          ./nix/modules/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.isogaiyuto = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          }
          
          # 🚨 追記: システム全体で Unfree パッケージ (VS Code等) を許可
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
  };
}