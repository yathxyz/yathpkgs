{
  description = "Personal packages and NixOS modules pinned to upstream releases";

  inputs = {
    edwin.url = "github:yathxyz/edwin/v0.1.3";
    workbench.url = "github:yathxyz/workbench/v0.1.17";
    workbench.inputs.edwin.follows = "edwin";
    workbench.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.follows = "edwin/nixpkgs";
  };

  outputs =
    {
      self,
      edwin,
      workbench,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} =
        removeAttrs edwin.packages.${system} [ "default" ]
        // removeAttrs workbench.packages.${system} [ "default" ];

      overlays.default = _final: prev: self.packages.${prev.stdenv.hostPlatform.system} or { };

      nixosModules = {
        inherit (edwin.nixosModules) edwin;
        inherit (workbench.nixosModules) workbench;
        # Edwin v0.1.2 exports its desktop module under both names.
        edwind = import (edwin.outPath + "/nix/edwind-module.nix") edwin;
      };

      checks.${system} = self.packages.${system};
      formatter.${system} = pkgs.nixfmt;
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.git
          pkgs.nix
          pkgs.python3
        ];
      };
    };
}
