{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
  aws-lc,
  cmake,
  openssl,
  pdfium,
  pkg-config,
  writableTmpDirAsHomeHook,
  leptonica,
  tesseract,
  zstd,
}:

# Node.js bindings for liteparse (the `@llamaindex/liteparse` npm package).
# Version must match the one pinned by `pi-docparser` in feynman's package-lock.json.
let
  # liteparse relies on extra FPDF* APIs (font/glyph/struct-tree accessors) that are
  # not in upstream pdfium, but carried in run-llama/pdfium-binaries.
  pdfium' = pdfium.overrideAttrs (old: {
    pname = "pdfium-llamaparse";
    patches = old.patches or [ ] ++ [
      (fetchpatch {
        name = "pdfium-llamaparse.patch";
        url = "https://raw.githubusercontent.com/run-llama/pdfium-binaries/2b14b662f4e187f3da1dbb87c377ece1143f7e11/patches/llamaparse/pdfium.patch";
        hash = "sha256-tWvChZ9L7qPCV1eo9Id8upRybDojdd1Fn4VppXj8pRk=";
      })
    ];
    # The patch's bidi fast path (all-LTR strings yield a single segment) breaks these
    checkPhase =
      lib.replaceStrings
        [ "./pdfium_unittests --gtest_filter='-" ]
        [ "./pdfium_unittests --gtest_filter='-fxcrt.BidiStringAll*:" ]
        old.checkPhase;
  });
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "liteparse-napi";
  version = "2.10.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "run-llama";
    repo = "liteparse";
    tag = "node-v${finalAttrs.version}";
    hash = "sha256-uutbeHPiXYJSsj/MD/Ifmve1MUcz7qeCElizw84zHjE=";
  };

  cargoHash = "sha256-+y+nhyTmYAFdmVNe12cEvWfJOrHt0b8+bZxccROAjGA=";

  # Same tesseract-rs handling as pkgs/by-name/li/liteparse
  postPatch = ''
    tesseractRsBuildRs=$(echo "$cargoDepsCopy"/source-registry-*/tesseract-rs-*/build.rs)
    substituteInPlace "$tesseractRsBuildRs" \
      --replace-fail \
        '.define("CMAKE_INSTALL_PREFIX", &leptonica_install_dir)' \
        '.define("CMAKE_INSTALL_PREFIX", &leptonica_install_dir)
                    .define("CMAKE_INSTALL_LIBDIR", "lib")' \
      --replace-fail \
        '.define("CMAKE_INSTALL_PREFIX", &tesseract_install_dir)' \
        '.define("CMAKE_INSTALL_PREFIX", &tesseract_install_dir)
                    .define("CMAKE_INSTALL_LIBDIR", "lib")'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    aws-lc
    openssl
    tesseract
    zstd
  ];

  dontUseCmakeConfigure = true;

  preBuild = ''
    mkdir -p "$HOME/.tesseract-rs/third_party" "$HOME/.tesseract-rs/tessdata"
    cp -rL ${leptonica.src} "$HOME/.tesseract-rs/third_party/leptonica"
    cp -rL ${tesseract.tesseractBase.src} "$HOME/.tesseract-rs/third_party/tesseract"
    chmod -R u+w "$HOME/.tesseract-rs"
    cp ${tesseract.languages.eng} "$HOME/.tesseract-rs/tessdata/eng.traineddata"
    cp ${tesseract.languages.tur} "$HOME/.tesseract-rs/tessdata/tur.traineddata"
  '';

  env = {
    OPENSSL_NO_VENDOR = true;
    # Use a source-built pdfium instead of downloading run-llama/pdfium-binaries.
    # pdfium is dlopen'ed at runtime from this (baked-in) directory.
    PDFIUM_INCLUDE_PATH = "${lib.getDev pdfium'}/include/public";
    PDFIUM_LIB_PATH = "${lib.getLib pdfium'}/lib";
  };

  cargoBuildFlags = [
    "--package"
    "liteparse-napi"
  ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      target/${stdenv.hostPlatform.rust.cargoShortTarget}/$cargoBuildType/libliteparse_napi${stdenv.hostPlatform.extensions.sharedLibrary} \
      $out/lib/liteparse.node

    runHook postInstall
  '';

  passthru.pdfium = pdfium';

  meta = {
    description = "Node.js bindings for liteparse";
    homepage = "https://github.com/run-llama/liteparse";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ZappD0S ];
    platforms = lib.platforms.linux;
  };
})
