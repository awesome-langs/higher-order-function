let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShell.override { stdenv = pkgs.libcxxStdenv; } {
  packages = [
    pkgs.swiftPackages.swift
    pkgs.swiftPackages.Foundation
  ];
}