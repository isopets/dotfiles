{
  description = "The ultimate cockpit dotfiles environment managed by Nix";

  inputs = {
    # mise が含まれる新しいバージョン (24.05) を指定
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    # それに合わせた Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      "isogaiyuto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Apple Silicon (M1/M2/M3) 用
        modules = [ ./home.nix ];
      };
    };
  };
}
