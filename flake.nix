{
  description = "Cockpit Environment";

  inputs = {
    # Stable Channel (Base)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    # Unstable Channel (For latest tools like sheldon, neovim)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    homeConfigurations = {
      "isogaiyuto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        
        # 🚨 ここが修正ポイント: pkgs-unstable をモジュールに渡す魔法
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