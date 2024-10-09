{
  description = "flake app that manages formatters for you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # sbomnix = {
    #   url = "github:tiiuae/sbomnix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # bombon = {
    #   url = "github:nikstur/bombon";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    # nodeEnv = {};#nodePackages_latest.prettier
    {

      devShells.${system}.default = pkgs.mkShell { packages = [ ]; };
      packages = {
        ${system}.default = pkgs.writeShellApplication {
          name = "fmtapp";
          runtimeInputs = [
            pkgs.nodePackages.prettier
            pkgs.ruff
            # nodePackages_latest.prettier-plugin-toml
          ];
          text = ''
            prettier "''$@"
          '';
        };
      };

      # apps.${system}.default = {
      #   type = "app";
      #   program = pkgs.lib.getBin "${self.packages.${system}.default}";
      # };

    };
}
