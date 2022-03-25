with import <nixpkgs> { };
mkShell rec {
  buildInputs = [
    # Build tools
    rustup
    pkg-config

    # Deps
    libclang
    libGL
    pkgs.qt5.full

    # Dev
    nodePackages.nodemon
    rust-analyzer
  ];
  nativeBuildInputs = [ clang ];

  LIBCLANG_PATH = "${libclang.lib}/lib";
  RUST_SRC_PATH = rust.packages.stable.rustPlatform.rustLibSrc;
  LD_LIBRARY_PATH = lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
  GIO_MODULE_DIR = "${glib-networking}/lib/gio/modules/";
}
