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
    # pythonEnv = pkgs.python3.withPackages (python-packages: [
    #   python-packages.vobject
    #   python-packages.webdavclient3
    # ]);
    {

      devShells.${system}.default = pkgs.mkShell { packages = [ ]; };
      packages = {
        ${system}.default = pkgs.writeShellApplication {
          name = "show-nixos-org";
          runtimeInputs = [
            pkgs.curl
            pkgs.w3m
          ];
          text = ''
            curl -s 'https://nixos.org' | w3m -dump -T text/html
          '';
        };
      };

      # apps.${system}.default = {
      #   type = "app";
      #   program = "${self.packages.x86_64-linux.blender_2_79}/bin/blender";
      # };

    };
}
