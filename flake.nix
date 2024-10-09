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
      # pythonEnv = pkgs.python3.withPackages (python-packages: [
      #   python-packages.vobject
      #   python-packages.webdavclient3
      # ]);
    in
    rec {

      devShells.${system}.default = pkgs.mkShell { packages = [  ] ; };

      };
}
