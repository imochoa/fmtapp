{
  description = "flake app that manages formatters for you";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    sbomnix = {
      url = "github:tiiuae/sbomnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    {

      devShells.${system}.default = pkgs.mkShell { packages = [ ]; };
      packages = {
        ${system} = {
          default = pkgs.writeShellApplication {
            name = "fmtapp";
            runtimeInputs = [
              pkgs.nodePackages.prettier
              pkgs.ruff
              pkgs.nixfmt-rfc-style
              pkgs.nodePackages_latest.prettier-plugin-toml
            ];
            text = ''
              # prettier "''$@"
              echo "prettier ''$(prettier --version)"
              ruff --version
              nixfmt --version
            '';
          };
        };
      };
      scans =
        pkgs.runCommand "Calling a flake"
          {
            buildInputs = with pkgs; [ yj ];
            # json = builtins.toJSON atuinConfig;
            # passAsFile = [ "json" ]; # will be available as `$jsonPath`
          }
          ''
            mkdir -p $out
            printf '%s\n' "hello" >> $out/README.md
            #
            printf '%s\n' "${inputs.sbomnix.apps.x86_64-linux.nixgraph.program}" >> $out/README.md
            printf '%s\n' "${self.packages.${system}.default.outPath}" >> $out/README.md
            cd $out
            ${inputs.sbomnix.apps.x86_64-linux.nixgraph.program} ${self.packages.${system}.default.drvPath}
          '';
      # nix run github:tiiuae/sbomnix#nixgraph

      # nix shell github:tiiuae/sbomnix --command sbomnix ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command nixgraph ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command nixmeta ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command vulnxscan ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command repology_cli ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command repology_cve ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command nix_outdated ${oci-image-content.drvPath}
      #  nix shell github:tiiuae/sbomnix --command provenance ${oci-image-content.drvPath}

      # {inputs.sbomnix.packages.x86_64-linux.sbomnix} "${oci-image-content.drvPath}"'

      #   echo 'sbomnix "${oci-image-content.drvPath}"' > $out/manual-cmd.sh
      #   # sbomnix "${oci-image-content.drvPath}"
      #   nix-shell --run 'sbomnix "${oci-image-content.drvPath}"'

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/fmtapp";
        # program = pkgs.lib.getBin "${self.packages.${system}.default}";
      };

    };
}
