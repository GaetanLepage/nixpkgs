{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  callPackage,
  makeBinaryWrapper,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  python3,
  ripgrep,
  fd,
  libxcb,
  tesseract,
}:

buildNpmPackage (finalAttrs: {
  pname = "feynman";
  version = "0.5.74";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Companion-Inc";
    repo = "feynman";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1tZo+FCyt0pyDYDIJAFegNjNvWvaDvU0+du5GMH1jFk=";
  };

  npmDepsHash = "sha256-BOPUNe1Yd4PjvpivFk8U58tYUMNaC2VqN+gwKWB8gFA=";
  npmDepsFetcherVersion = 2;

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    libxcb
  ];

  postInstall =
    let
      nodeModules = "$out/lib/node_modules/@companion-ai/feynman/node_modules";
    in
    # Drop the prebuilt liteparse addon (and its bundled pdfium) in favor of one built from source.
    # liteparse's loader falls back to `liteparse.node` next to its package.json.
    ''
      rm -rf ${nodeModules}/@llamaindex/liteparse-*
      rm -f ${nodeModules}/@llamaindex/liteparse/{*.node,libpdfium.*}
      ln -s ${finalAttrs.passthru.liteparse-napi}/lib/liteparse.node \
        ${nodeModules}/@llamaindex/liteparse/liteparse.node
    ''
    # Rebuild pi-tui's X11 clipboard helper from the C source shipped in the npm tarball
    + ''
      piTuiNative=${nodeModules}/@earendil-works/pi-tui/native
      rm -rf "$piTuiNative"/*/prebuilds
      patchShebangs "$piTuiNative/linux/build.sh"
      "$piTuiNative/linux/build.sh"
    '';

  postFixup = ''
    wrapProgram $out/bin/feynman \
      --prefix PATH : ${
        lib.makeBinPath [
          python3
          ripgrep
          fd
        ]
      } \
      --set-default PI_SKIP_VERSION_CHECK 1 \
      --set-default FEYNMAN_TELEMETRY off \
      --set-default TESSDATA_PREFIX ${tesseract}/share/tessdata
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = {
    liteparse-napi = callPackage ./liteparse-napi.nix { };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source AI research agent";
    homepage = "https://feynman.is/";
    downloadPage = "https://www.npmjs.com/package/@companion-ai/feynman";
    changelog = "https://github.com/Companion-Inc/feynman/blob/v${finalAttrs.version}/RELEASES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ZappD0S ];
    mainProgram = "feynman";
    # The native addons are only built from source for Linux for now
    platforms = lib.platforms.linux;
  };
})
