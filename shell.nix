{ pkgs ? import <nixpkgs> {} }:

# "Rename" the original pkgs
let pkgs' = pkgs; in
let
  # Apply our desired overlay on top
  pkgs = pkgs'.extend(import <mobile-nixos/overlay/overlay.nix>);
in

pkgs.mkShell {
  SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

  buildInputs = with pkgs; [
    ruby

    binutils
    curl
    file
    gzip
    lz4
    mkbootimg
    python3Packages.binwalk
    zlib
  ];
}
