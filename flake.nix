{
  description = "flake app that manages formatters for you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      # systems = [ ${system} ];
      pkgs = import nixpkgs { inherit system; };
      pname = "fmtapp";
      # Small tool to iterate over each systems
      # eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      # Eval the treefmt modules from ./treefmt.nix
      # treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      # for `nix fmt`
      # formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      formatter.${system} = treefmtEval.config.build.wrapper;
      # for `nix flake check`
      # checks = eachSystem (pkgs: { formatting = treefmtEval.${pkgs.system}.config.build.check self; });
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
      };

      devShells.${system}.default = pkgs.mkShell { packages = [ pkgs.treefmt2 ]; };

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
