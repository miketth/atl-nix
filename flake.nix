{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        bionic-translation = pkgs.callPackage ./bionic_translation {};
        wolfssl = pkgs.callPackage ./wolfssl {};
        art = pkgs.callPackage ./art_standalone { inherit bionic-translation wolfssl; };
        skia = pkgs.callPackage ./skia {};
        libOpenSLES = pkgs.callPackage ./libOpenSLES {};
    in {
      packages.x86_64-linux.default = pkgs.callPackage ./android_translation_layer {inherit art bionic-translation skia libOpenSLES;};

      devShell.x86_64-linux =
        pkgs.mkShell { 
            buildInputs = [ 
                self.packages.x86_64-linux.default 
            ]; 
        };
   };
}
