{lib
,stdenv
,fetchFromGitLab
,makeWrapper
,art
,bionic-translation
,skia
,meson
,ninja
,jdk17
,pkg-config
,wayland-scanner
,glib
,wayland-protocols
,wayland
,gtk4
,openxr-loader
,libGL
,libportal
,sqlite
,ffmpeg
,libdrm
,libgudev
,webkitgtk_6_0
,alsa-lib
,alsa-plugins
,libepoxy
,pipewire
,intel-media-driver
,librsvg
,wrapGAppsHook4
,libOpenSLES
,webp-pixbuf-loader
,gnome

}:
stdenv.mkDerivation (finalAttrs: {
  pname = "android-translation-layer";
  version = "0";

    #patches = [ ./gtk_picture_redraw_workaround.patch ];

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "android_translation_layer";
    rev = "fc0091a989bdb9f02854c5c0789d613f1b9096fb";
    hash = "sha256-vHtTk8V0DWYpT662ByVLuSTvX4bdljGBtC2K8qsvxlA=";
  };

  postPatch = ''
    substituteInPlace meson.build \
        --replace-fail "cc.find_library('art', dirs : [ '/usr' / get_option('libdir') / 'art', '/usr/local' / get_option('libdir') / 'art', get_option('prefix') / get_option('libdir') / 'art' ])" "cc.find_library('art', dirs: [ '${lib.getDev art}' / 'lib/art'], required: true)"\
     	--replace-fail "cc.find_library('nativebridge', dirs : [ '/usr' / get_option('libdir') / 'art', '/usr/local' / get_option('libdir') / 'art', get_option('prefix') / get_option('libdir') / 'art' ])" "cc.find_library('nativebridge', dirs: [ '${lib.getDev art}' / 'lib/art'], required: true)"\
        --replace-fail "cc.find_library('androidfw', dirs : [ '/usr' / get_option('libdir') / 'art', '/usr/local' / get_option('libdir') / 'art', get_option('prefix') / get_option('libdir') / 'art' ])" "cc.find_library('androidfw', dirs: [ '${lib.getDev art}' / 'lib/art'], required: true)"\
        --replace-fail "if fs.is_file('/usr' / get_option('libdir') / 'java/core-all_classes.jar')" "if fs.is_file('${lib.getDev art}' / 'lib/java/core-all_classes.jar')"\
        --replace-fail "bootclasspath = '/usr' / get_option('libdir') / 'java/core-all_classes.jar'" "bootclasspath = '${lib.getDev art}'/ 'lib/java/core-all_classes.jar'"\
        --replace-fail "dependency('gudev-1.0'), dependency('libswscale'), dependency('webkitgtk-6.0')" "dependency('gudev-1.0'), dependency('libswscale'), dependency('webkitgtk-6.0'), dependency('gio-unix-2.0')"\
        --replace-fail "install_rpath: '\$ORIGIN/:' + get_option('prefix') / get_option('libdir') / 'art'" "install_rpath: '\$ORIGIN/:' + get_option('prefix') / get_option('libdir') / 'art:' + '${lib.getDev art}' / 'lib/art'"\
        --replace-fail "install_rpath: get_option('prefix') / get_option('libdir') / 'art:' + get_option('prefix') / get_option('libdir') / 'java/dex/android_translation_layer/natives'" "install_rpath: get_option('prefix') / get_option('libdir') / 'art:' + get_option('prefix') / get_option('libdir') / 'java/dex/android_translation_layer/natives:' + '${lib.getDev art}' / 'lib/art'"\
        --replace-fail "dependency('gtk4'), dependency('jni'), declare_dependency(link_with: libtranslationlayer_so), libart_dep, dependency('dl'), libdl_bio_dep, dependency('libportal')" "dependency('gtk4'), dependency('jni'), declare_dependency(link_with: libtranslationlayer_so), libart_dep, libandroidfw_dep, libskia_dep, dependency('dl'), libdl_bio_dep, dependency('libportal')"\

    substituteInPlace src/main-executable/main.c \
        --replace-fail "if (libart_so_dl_info.dli_fname) {" "if (0) {" \
		--replace-fail "dex_install_dir = \"DIDN'T_GET_SO_PATH_WITH_dladdr_SUS\";"  "dex_install_dir = \"$out/lib/java/dex\";" \
  '';

  postInstall = ''
    mkdir -p $out/lib/java/dex/microg/
    cp $NIX_BUILD_TOP/$sourceRoot/com.google.android.gms.apk $out/lib/java/dex/microg/
    export GDK_PIXBUF_MODULE_FILE="${gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
      extraLoaders = [
        librsvg
        webp-pixbuf-loader
      ];
    }}"
  '';

  postFixup = ''
    wrapProgram $out/bin/android-translation-layer \
    --set PATH ${lib.makeBinPath [art]} \
    --set ALSA_PLUGIN_DIR ${lib.makeLibraryPath [pipewire]}/alsa-lib \
    --set GTK_THEME Adwaita:dark \
    --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ intel-media-driver libOpenSLES ]} \
  '';

  strictDeps = true;
  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    jdk17
    pkg-config
    wayland-scanner
    art
    wrapGAppsHook4
  ];

  buildInputs = [
    art
    bionic-translation
    skia
    glib
    wayland-protocols
    wayland
    gtk4
    openxr-loader
    libGL
    libportal
    sqlite
    ffmpeg
    libdrm
    libgudev
    webkitgtk_6_0
    alsa-lib
    alsa-plugins
    libepoxy
    pipewire
    intel-media-driver
  ];

  meta = {
    description = "";
    homepage = "";
  };
})
