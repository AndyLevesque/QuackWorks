{
  description = "Quack works";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    bosl2 = {
      url = "github:BelfrySCAD/BOSL2";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, bosl2, ... }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        bosl2-lib = pkgs.runCommand "bosl2-lib" { } ''
          mkdir -p $out/
          ln -s ${bosl2} $out/BOSL2
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.openscad
          ];
          OPENSCADPATH = "${bosl2-lib}";
        };
      }));
}
