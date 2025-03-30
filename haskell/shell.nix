{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  name = "dev-shell";
  packages = with pkgs; [
    ghc
    haskell-language-server
  ];
}
