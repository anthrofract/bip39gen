{
  description = "bip39gen: Generate a BIP-39 mnemonic from multiple entropy sources";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      rustToolchain =
        system:
        fenix.packages.${system}.toolchainOf {
          channel = "1.96.0";
          sha256 = "sha256-mvUGEOHYJpn3ikC5hckneuGixaC+yGrkMM/liDIDgoU=";
        };

      mkBip39gen =
        pkgs:
        let
          toolchain = rustToolchain pkgs.stdenv.hostPlatform.system;
          rustPlatform = pkgs.makeRustPlatform {
            cargo = toolchain.cargo;
            rustc = toolchain.rustc;
          };
        in
        rustPlatform.buildRustPackage {
          pname = "bip39gen";
          version = "0.1.0";
          src = self;
          cargoLock.lockFile = ./Cargo.lock;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = mkBip39gen pkgs;
          bip39gen = mkBip39gen pkgs;
        }
      );

      overlays.default = final: prev: {
        bip39gen = mkBip39gen final;
      };
    };
}
