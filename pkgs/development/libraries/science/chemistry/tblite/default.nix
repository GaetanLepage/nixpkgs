{
  stdenv,
  lib,
  fetchFromGitHub,
  gfortran,
  buildType ? "meson",
  meson,
  ninja,
  cmake,
  pkg-config,
  blas,
  lapack,
  mctc-lib,
  mstore,
  toml-f,
  multicharge,
  dftd4,
  simple-dftd3,
  python3,
}:

assert !blas.isILP64 && !lapack.isILP64;
assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

stdenv.mkDerivation (finalAttrs: {
  pname = "tblite";
  version = "0.5.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tblite";
    repo = "tblite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hePy/slEeM2o1gtrAbq/nkEUILa6oQjkD2ddDstQ2Zc=";
  };

  patches = [
    ./0001-fix-multicharge-dep-needed-for-static-compilation.patch

    # Fix wrong paths in pkg-config file
    ./pkgconfig.patch
  ];

  # Python scripts in test subdirectories to run the tests
  postPatch = ''
    patchShebangs ./
  '';

  nativeBuildInputs = [
    gfortran
    pkg-config
  ]
  ++ lib.optionals (buildType == "meson") [
    meson
    ninja
  ]
  ++ lib.optionals (buildType == "cmake") [
    cmake
  ];

  buildInputs = [
    blas
    lapack
    mctc-lib
    mstore
    toml-f
    multicharge
    dftd4
    simple-dftd3
  ];

  outputs = [
    "out"
    "dev"
  ];

  nativeCheckInputs = [
    # Runs python test drivers (test/*/tester.py) during checkPhase, so it must be available on the
    # build host (strictDeps)
    python3
  ];

  checkFlags = [
    "-j1" # Tests hang when multiple are run in parallel
  ];

  doCheck = buildType == "meson";

  preCheck = ''
    export OMP_NUM_THREADS=2
  '';

  meta = {
    description = "Light-weight tight-binding framework";
    mainProgram = "tblite";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    homepage = "https://github.com/tblite/tblite";
    changelog = "https://github.com/tblite/tblite/releases/tag/${finalAttrs.src.tag}";
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sheepforce ];
  };
})
