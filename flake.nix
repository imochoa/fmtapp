{
  description = "flake app that manages formatters for you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pname = "fmtapp";
    in
    {

      devShells.${system}.default = pkgs.mkShell { packages = [ ]; };
      packages = {
        ${system} = {
          default = pkgs.writeShellApplication {
            name = "${pname}";
            runtimeInputs = [
              pkgs.nodePackages.prettier
              pkgs.ruff
              pkgs.nixfmt-rfc-style
              pkgs.nodePackages_latest.prettier-plugin-toml
            ];
            text = ''
              echo "prettier ''$(prettier --version)"
              ruff --version
              nixfmt --version
            '';
          };
        };
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/${pname}";
        # program = pkgs.lib.getBin "${self.packages.${system}.default}";
      };

    };
}
