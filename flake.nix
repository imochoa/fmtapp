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
      systems = [
        "x86_64-linux"
        # "x86_64-darwin"
      ];
      pname = "fmtapp";
      # Small tool to iterate over each systems
      eachSystem = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
      # out: {linux: fn(nixpkgs), ...}
      #
      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (ps: inputs.treefmt-nix.lib.evalModule ps ./treefmt.nix);
    in
    # out: {linux: evalModule(nixpkgs, config), ...}
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell { packages = [ ]; };
      });

      packages = eachSystem (pkgs: {
        default = pkgs.writeShellApplication {
          name = "${pname}";
          runtimeInputs = with pkgs; [
            nodePackages.prettier
            ruff
            nixfmt-rfc-style
          ];
          text = ''
            echo "prettier ''$(prettier --version)"
            ruff --version
            nixfmt --version
          '';
        };
      });

      apps = eachSystem (pkgs: {
        pname = {
          type = "app";
          program = "${self.packages.${pkgs.system}.default}/bin/${pname}";
        };
      });
    };
}
