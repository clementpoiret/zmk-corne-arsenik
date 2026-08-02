{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zmk = zmk-nix.legacyPackages.${system};
          firmwareSrc = pkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".h"
            ".inc"
            ".json"
            ".keymap"
            ".overlay"
            ".shield"
            ".yaml"
            ".yml"
            "_defconfig"
          ];
          zephyrDepsHash = "sha256-gsqiTDJLAihVyBXVFlgXwqRmlREcFJctKpl4tEWmVlY=";
        in
        rec {
          default = firmware;

          firmware = zmk.buildSplitKeyboard {
            name = "firmware";

            src = firmwareSrc;

            board = "nice_nano_v2";
            shield = "corne_%PART% nice_view_adapter nice_view";

            inherit zephyrDepsHash;

            meta = {
              description = "ZMK firmware";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.all;
            };
          };

          settings-reset = zmk.buildSplitKeyboard {
            name = "settings-reset";
            src = firmwareSrc;
            board = "nice_nano_v2";
            shield = "settings_reset";
            inherit zephyrDepsHash;
            westDeps = firmware.westDeps;
          };

          flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
          flash-settings-reset = zmk-nix.packages.${system}.flash.override {
            firmware = settings-reset;
          };
          update = zmk-nix.packages.${system}.update;
        }
      );

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default;
      });
    };
}
