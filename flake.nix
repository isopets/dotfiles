{
  description = "Cockpit Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "aarch64-darwin";
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
          # ./nix/modules/window_manager.nix  <-- 削除しました
          
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
