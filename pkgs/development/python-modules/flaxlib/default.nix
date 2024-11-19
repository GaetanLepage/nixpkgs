{
  lib,
  buildPythonPackage,
  flax,
  tomlq,
  rustPlatform,
  python,

  # build-system
  meson-python,
  nanobind,
  ninja,

  # nativeBuildInputs
  cmake,
  pkg-config,
}:

buildPythonPackage rec {
  pname = "flaxlib";
  version = "0.0.1-a1";
  pyproject = true;

  inherit (flax) src;

  sourceRoot = "${src.name}/flaxlib_src";

  postPatch = ''
    expected_version="$version"
    actual_version=$(${lib.getExe tomlq} --file Cargo.toml "package.version")

    if [ "$actual_version" != "$expected_version" ]; then
      echo -e "\n\tERROR:"
      echo -e "\tThe version of the flaxlib python package ($expected_version) does not match the one in its Cargo.toml file ($actual_version)"
      echo -e "\tPlease update the version attribute of the nix python3Packages.flaxlib package."
      exit 1
    fi
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      ;
    hash = "sha256-CN/ZbDxdCQPEuLfxPh/m+JtlFDkerO8aWgAaUwhixjQ=";
  };

  dontUseCmakeConfigure = true;
  preConfigure = ''
    export CMAKE_PREFIX_PATH=$(${python.interpreter} -m nanobind --cmake_dir)
  '';

  build-system = [
    meson-python
    nanobind
    ninja
  ];
  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [ nanobind ];

  pythonImportsCheck = [ "flaxlib" ];

  # This package does not have tests (yet ?)
  doCheck = false;

  passthru = {
    inherit (flax) updateScript;
  };

  meta = {
    description = "Rust library used internally by flax";
    homepage = "https://github.com/google/flax/tree/main/flaxlib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    # Since flax 0.10.2, flaxlib uses meson-python and it fails to detect nanobind:
    #    Run-time dependency nanobind found: NO (tried pkgconfig and cmake)
    #    ../meson.build:8:15: ERROR: Dependency "nanobind" not found, tried pkgconfig and cmake
    broken = true;
  };
}
