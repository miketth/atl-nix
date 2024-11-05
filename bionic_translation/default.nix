{lib
,fetchFromGitLab
,stdenv
,meson
,ninja
,pkg-config
,libGL
,libbsd
,libunwind
,libelf
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bionic-translation";
  version = "0";

    #patches = [ ./remove-harfbuzz.patch ];

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "bionic_translation";
    rev = "e502e9273c5fb600751f53a1d843ad38c910b2d8";
    hash = "sha256-6V/CLD7JgkEwc0Y26XVBZGN5c7AUEGFHbC++PjJJhyc=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    libbsd
    libunwind
    libelf
  ];

  meta = {
    description = "";
    homepage = "";
  };
})
