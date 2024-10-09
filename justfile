set shell := ["bash", "-euco", "pipefail"]

# Open fzf picker
[no-cd]
choose:
    @just --choose

build:
    nix build .

run: build
    nix run .

# Use treefmt in nix
fmt: build
    nix fmt

check: build
    nix flake check

# Run all tools in `nix flake show github:tiiuae/sbomnix` (https://github.com/tiiuae/sbomnix/blob/main/README.md)
sbomnix:
    nix run github:tiiuae/sbomnix -- .
    nix run github:tiiuae/sbomnix#nixgraph -- .
    nix run github:tiiuae/sbomnix#nixmeta -- -f .
    nix run github:tiiuae/sbomnix#provenance -- . --out provenance
    nix run github:tiiuae/sbomnix#vulnxscan .

# nix run github:tiiuae/sbomnix#repology_cli -- --pkg_search 'firef' --repository 'nix_unstable'
# nix run github:tiiuae/sbomnix#repology_cve -- [-h] [--verbose VERBOSE] [--out [OUT]] PKG_NAME PKG_VERSION
