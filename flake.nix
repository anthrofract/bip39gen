{
  description = "bip39gen: Generate a BIP-39 mnemonic from multiple entropy sources";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkBip39gen =
        pkgs:
        pkgs.rustPlatform.buildRustPackage {
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
