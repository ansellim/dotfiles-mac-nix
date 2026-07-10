{
  description = "dotfiles";

  inputs = {
    # Shared channel for Mac (nix-darwin) and Linux (home-manager).
    # For Mac-only binary-cache priority you can switch to nixpkgs-26.05-darwin.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your username differs.
      user = "ansel";

      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit user; };
          modules = [ ./home.nix ];
        };
    in
    {
      # Mac: full system via nix-darwin + home-manager + Homebrew
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };

      # Linux: standalone home-manager (no NixOS required).
      # Switch with: home-manager switch --flake ~/.dotfiles#ansel
      # Or for aarch64: home-manager switch --flake ~/.dotfiles#ansel-aarch64
      homeConfigurations = {
        ${user} = mkHome "x86_64-linux";
        "${user}-aarch64" = mkHome "aarch64-linux";
      };
    };
}
