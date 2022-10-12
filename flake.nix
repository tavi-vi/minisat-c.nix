{
  inputs = {
    nixpkgs.url = "github:tavi-vi/nixpkgs/minisat-emscripten";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in {
          packages = {
            default = pkgs.callPackage ./default.nix { };
            emscripten = pkgs.callPackage ./default.nix { targetEmscripten = true; };
          };
        }
      );
}
