{
  lib,
  stdenv,
  pkgs,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  rustPlatform,
  gitMinimal,
  importlib-resources,
  pytest-mypy,
  pytestCheckHook,
}:

let
  inherit (pkgs.wasmtime) version;
  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wasmtime-py";
    tag = version;
    hash = "sha256-a1GuIRJTjZngolbffreDDFWsIcP64H/O+LXbLQhCVBA=";
  };

  bindgen = rustPlatform.buildRustPackage {
    pname = "wasmtime-bindgen";
    inherit src version;

    sourceRoot = "${src.name}/rust";

    useFetchCargoVendor = true;
    cargoHash = "sha256-/Zft19U079GCTvedBc/T94zokYNMsTfoaIlsECYZwG0=";

    buildPhase = ''
      runHook preBuild

      cargo build \
        -j $NIX_BUILD_CORES \
        --target wasm32-wasip1 \
        --offline \
        --profile release \
        --package=bindgen

      runHook postBuild
    '';

    env.RUSTFLAGS = "-C target-feature=+atomics,+bulk-memory,+mutable-globals";

    cargoBuildFlags = [
      "--package=bindgen"
      "--target=wasm32-wasip1"
    ];
  };
in
buildPythonPackage {
  pname = "wasmtime";
  inherit src version;
  pyproject = true;

  postPatch = ''
    substituteInPlace wasmtime/_ffi.py \
      --replace-fail \
        "filename = Path(__file__).parent / (sys.platform + '-' + machine) / libname" \
        "filename = Path('${(lib.getDev pkgs.wasmtime)}/lib/libwasmtime${stdenv.hostPlatform.extensions.library}')"
  '';

  build-system = [
    setuptools
  ];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    gitMinimal
  ];

  dependencies = [
    importlib-resources
  ];

  postBuild = ''
    ls -al ${bindgen}
  '';

  pythonImportsCheck = [
    "wasmtime"
    "wasmtime.bindgen"
  ];

  nativeCheckInputs = [
    pytest-mypy
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf wasmtime
  '';

  meta = {
    description = "Python WebAssembly runtime powered by Wasmtime";
    homepage = "https://github.com/bytecodealliance/wasmtime-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
