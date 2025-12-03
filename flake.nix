{
  description = "Cockpit Darwin System";

  inputs = {
    # 🚀 Base OS: Unstable (常に最新)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # 📦 Tools: Baseと同じものを指す
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # 🍏 Nix-Darwin: Master (最新のmacOSに対応)
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # 🏠 Home Manager: Master (最新のNixpkgsに対応)
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "aarch64-darwin"; # Apple Silicon
    
    # Unstableパッケージセット
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    darwinConfigurations = {
      # Hostname: isogaiyuujinnoMacBook-Air
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
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
  };
}