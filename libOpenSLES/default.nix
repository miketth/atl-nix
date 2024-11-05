{lib
,stdenv
,fetchFromGitLab
,meson
,ninja
,jdk17
,pkg-config
,SDL2
,libsndfile
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libOpenSLES";
  version = "0";

    #patches = [ ./remove-harfbuzz.patch ];

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "libopensles-standalone";
    rev = "605a83f47263a022427afb6e95801bd39b459b78";
    hash = "sha256-YKGAs4AdKmYKstF4ObDpy1WMXM5zJjhnN/CBOzaly6g=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    meson
    ninja
    jdk17
    pkg-config
  ];

  buildInputs = [
    SDL2
    libsndfile
  ];

  meta = {
    description = "";
    homepage = "";
  };
})
