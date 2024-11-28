{lib
,stdenv
,fetchFromGitLab
,wolfssl
,bionic-translation
,python3
,which
,jdk17
,zip
,xz
,icu
,zlib
,libcap
,expat
,openssl
,libbsd
,lz4
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "art-standalone";
  version = "0";

  patches = [ ./add-liblog-dep.patch ];

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "art_standalone";
    rev = "57f9bbd9417b67a6d7bf70a7d7d457fc894250f5";
    hash = "sha256-VfyU/YKLkIeg+EF3E1Y+rrLp/j7jPGTiBZGT1dC3pfE=";
  };

  enableParallelBuilding = true;

  strictDeps = true;

  nativeBuildInputs = [
    python3
    which
    jdk17
    zip
  ];

  buildInputs = [
    wolfssl
    xz
    icu
    zlib
    libcap
    expat
    openssl
    libbsd
    lz4
    bionic-translation
  ];

  preConfigure = ''
    patchShebangs --build .
  '';

  makeFlags = [
    "____LIBDIR=lib" "____PREFIX=${placeholder "out"}" "____INSTALL_ETC=${placeholder "out"}/etc"
  ];

  meta = {
    description = "";
    homepage = "";
  };
})
