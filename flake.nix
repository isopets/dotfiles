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
    system = "aarch64-darwin"; # Apple Silicon
    
    # Unstable Packages
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    darwinConfigurations = {
      # Hostname
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
