{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  AVFoundation,
  CoreFoundation,
  Foundation,
  GameplayKit,
  MacOSX-SDK,
  MetalPerformanceShaders,
  libffi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyobjc-core";
  version = "10.3";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "ronaldoussoren";
    repo = "pyobjc";
    rev = "refs/tags/v${version}";
    hash = "sha256-pvExH5+dFzzcPgPkstk4EIRXKD37qRLcCk1rSfWFXIE=";
  };

  sourceRoot = "${src.name}/pyobjc-core";

  postPatch = ''
    mkdir -p ffi-header/ffi
    cp ${lib.getLib libffi.dev}/include/* ffi-header/ffi/
    substituteInPlace setup.py \
      --replace-fail '"-I/usr/include/ffi",' '"-I./ffi-header",'
  '';
    #
    # cat setup.py
      # --replace-fail '"-I/usr/include/ffi",' '"-I${lib.getLib libffi.dev}/include",'
    # ln -s ${libffi-src} ./libffi-src

  buildInputs = [
    AVFoundation
    CoreFoundation
    Foundation
    GameplayKit
    MacOSX-SDK
    MetalPerformanceShaders
    libffi.dev
  ];

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [ "pyobjc_core" ];

  meta = {
    description = "The Python <-> Objective-C Bridge with bindings for macOS frameworks";
    homepage = "https://github.com/ronaldoussoren/pyobjc";
    changelog = "https://github.com/ronaldoussoren/pyobjc/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platform = lib.platforms.darwin;
  };
}
