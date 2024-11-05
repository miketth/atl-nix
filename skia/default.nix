{ lib
, stdenv
, fetchFromGitHub
, fetchgit
, expat
, fontconfig
, freetype
, harfbuzzFull
, icu
, gn
, libGL
, libjpeg_turbo
, libwebp
, libX11
, ninja
, python3
, testers
, vulkan-headers
, vulkan-memory-allocator
, xcbuild
, git
, cacert

, enableVulkan ? !stdenv.hostPlatform.isDarwin
}:
let 
  dng_sdk = fetchgit {
    url = "https://android.googlesource.com/platform/external/dng_sdk.git";
    rev = "c8d0c9b1d16bfda56f15165d39e0ffa360a11123";
    hash = "sha256-lTtvBUGaia0jhrxpw7k7NIq2SVyGmBJPCvjIqAQCmNo=";
  };
  piex = fetchgit {
    url = "https://android.googlesource.com/platform/external/piex.git";
    rev = "bb217acdca1cc0c16b704669dd6f91a1b509c406";
    hash = "sha256-IhAfxlu0UmllihBP9wbg7idT8azlbb9arLKUaZ6qNxY=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "skia";
  # Version from https://skia.googlesource.com/skia/+/refs/heads/main/RELEASE_NOTES.md
  # or https://chromiumdash.appspot.com/releases
  # plus date of the tip of the corresponding chrome/m$version branch
  version = "0";

  patches = [ ./remove-harfbuzz.patch ];

  src = fetchFromGitHub {
    owner = "Mis012";
    repo = "skia";
    rev = "ced64f6f90cb5349de58e349309d3514cb345c28";
    hash = "sha256-EeH2I4M9sr2HfJ1DaowkECzZqaEq57BV9WjfeohK19E=";
  };

  prePatch = with {inherit dng_sdk piex;}; ''
    mkdir -p third_party/externals
    ln -s ${dng_sdk} third_party/externals/dng_sdk
    ln -s ${piex} third_party/externals/piex
  '';

  postPatch = ''
    # System zlib detection bug workaround
    substituteInPlace BUILD.gn \
      --replace-fail 'deps = [ "//third_party/zlib" ]' 'deps = []' \

    substituteInPlace gn/skia/BUILD.gn \
      --replace-fail 'exec_script("//gn/xamarin_inject_compat.py", [ rebase_path("../..") ])' ' ' \
  '';


  strictDeps = true;
  nativeBuildInputs = [
    gn
    ninja
    python3
    git
    cacert
  ] ++ lib.optional stdenv.hostPlatform.isDarwin xcbuild;

  buildInputs = [
    expat
    fontconfig
    freetype
    harfbuzzFull
    icu
    libGL
    libwebp
    libX11
    libjpeg_turbo
  ] ++ lib.optionals enableVulkan [
    vulkan-headers
    vulkan-memory-allocator
  ];

  gnFlags = let
    cpu = {
      "x86_64" = "x64";
      "i686" = "x86";
      "arm" = "arm";
      "aarch64" = "arm64";
    }.${stdenv.hostPlatform.parsed.cpu.name};
  in [
    "cc=\"${stdenv.cc.targetPrefix}cc\""
    "cxx=\"${stdenv.cc.targetPrefix}c++\""
    "ar=\"${stdenv.cc.targetPrefix}ar\""
    "target_cpu=\"${cpu}\""
    "target_os=\"${stdenv.hostPlatform.parsed.kernel.name}\""
    "extra_cflags=[\"-I${harfbuzzFull.dev}/include/harfbuzz\", \"-DSKIA_C_DLL\"]"
    "skia_enable_gpu=true"
    "skia_enable_tools=false"
    "skia_use_icu=false"
    "skia_use_piex=true"
    "skia_use_sfntly=false"
    "skia_use_wuffs=false"
    "is_debug=false"
    "is_official_build=true"
    "linux_soname_version=\"99.9\""
  ] ++ map (lib: "skia_use_system_${lib}=true") [
    "zlib"
    "harfbuzz"
    "libpng"
    "libwebp"
    "expat"
    "freetype2"
    "libjpeg_turbo"
  ] ++ lib.optionals enableVulkan [
    "skia_use_vulkan=true"
  ];

  ninjaFlags = ["SkiaSharp" "skia" "modules"];

  # Somewhat arbitrary, but similar to what other distros are doing
  installPhase = ''
    runHook preInstall

    # Libraries
    mkdir -p $out/lib
    cp *.so *.a $out/lib
    cp libSkiaSharp.so.99.9 $out/lib
    ln -s $out/lib/libSkiaSharp.so.99.9 $out/lib/libSkiaSharp.so

    # Includes
    pushd ../../include
    find . -name '*.h' -exec install -Dm644 {} $out/include/skia/{} \;
    popd
    pushd ../../modules
    find . -name '*.h' -exec install -Dm644 {} $out/include/skia/modules/{} \;
    popd

    # Pkg-config
    mkdir -p $out/lib/pkgconfig
    cat > $out/lib/pkgconfig/skia.pc <<'EOF'
    prefix=${placeholder "out"}
    exec_prefix=''${prefix}
    libdir=''${prefix}/lib
    includedir=''${prefix}/include/skia
    Name: skia
    Description: 2D graphic library for drawing text, geometries and images.
    URL: https://skia.org/
    Version: ${lib.versions.major finalAttrs.version}
    Libs: -L''${libdir} -lskia -lSkiaSharp
    Cflags: -I''${includedir}
    EOF

    runHook postInstall
  '';

  preFixup = ''
    # Some skia includes are assumed to be under an include sub directory by
    # other includes
    for file in $(grep -rl '#include "include/' $out/include); do
      substituteInPlace "$file" \
        --replace-fail '#include "include/' '#include "'
    done
  '';

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "2D graphic library for drawing text, geometries and images";
    homepage = "https://skia.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = with lib.platforms; arm ++ aarch64 ++ x86 ++ x86_64;
    pkgConfigModules = [ "skia" ];
    # https://github.com/NixOS/nixpkgs/pull/325871#issuecomment-2220610016
    broken = stdenv.hostPlatform.isDarwin;
  };
})
