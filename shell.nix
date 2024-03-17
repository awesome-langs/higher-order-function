let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.11";
  nixpkgs_old = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-23.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
  pkgs_old = import nixpkgs_old { config = {}; overlays = []; };
in
pkgs.mkShell.override { stdenv = pkgs.libcxxStdenv; } {
  packages = [
    pkgs.cacert
    pkgs.git

    pkgs.dotnet-sdk_8
    pkgs.gcc13
    pkgs.clojure
    pkgs.coffeescript
    pkgs.sbcl
    pkgs.crystal
    pkgs.dmd
    pkgs.dart
    pkgs.elixir_1_16
    pkgs.elmPackages.elm
    pkgs.emacs29
    pkgs.erlang_26
    pkgs.go
    pkgs.groovy
    (builtins.getFlake "git+https://github.com/facebook/hhvm.git?submodules=1&shallow=1&ref=refs/tags/HHVM-4.164.0").packages.x86_64-linux.default
    pkgs.haskell.compiler.ghc981
    pkgs.haxe pkgs.neko
    pkgs.jdk21
    pkgs.nodejs_21 
    pkgs.corepack_21
    pkgs.julia
    pkgs.kotlin
    pkgs.lua54Packages.lua
    pkgs.nim2
    pkgs.gnustep.base
    pkgs.gnustep.libobjc
    pkgs.ocaml
    pkgs.perl
    pkgs.php83
    pkgs.purescript
    pkgs.python312
    pkgs.racket-minimal
    pkgs.rakudo
    pkgs.ocamlPackages.reason
    pkgs.ruby_3_2
    pkgs.rustc
    pkgs.scala_3
    pkgs.guile
    pkgs.mlton
    pkgs_old.swiftPackages.swift
    pkgs_old.swiftPackages.Foundation
    pkgs.typescript
  ];
}