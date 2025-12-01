{
  description = "Cockpit Environment";

  inputs = {
    # Stable (Base)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    # Unstable (For Sheldon, Neovim)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    homeConfigurations = {
      "isogaiyuto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        
        # 🚨 ここが重要: Unstableパッケージセットを作成して渡す
        extraSpecialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        };
        
        modules = [ ./home.nix ];
      };
    };
  };
}
