{
  lib,
  stdenv,
  fetchFromGitHub,

  # Defaults to cmake: xtb's meson build races on cross-target Fortran modules and must be
  # serialized (slow), while the cmake build is parallel and robust.
  buildType ? "cmake",

  mctc-lib,
  cpcm-x,
  jonquil,
  mstore,
  newScope,
  numsa,
  tblite,
  simple-dftd3,
  toml-f,
  test-drive,
  dftd4,
  multicharge,

  # nativeBuildInputs
  cmake,
  gfortran,
  meson,
  ninja,
  pkg-config,

  # buildInputs
  blas,
  lapack,

  # passthru
  nix-update-script,
}:

assert (
  builtins.elem buildType [
    "meson"
    "cmake"
  ]
);

let
  deps = lib.makeScope newScope (self: {
    mctc-lib = mctc-lib.override {
      inherit buildType;
      inherit (self) jonquil;
    };
    jonquil = jonquil.override {
      inherit buildType;
      inherit (self)
        toml-f
        test-drive
        ;
    };
    numsa = numsa.override {
      inherit buildType;
      inherit (self)
        mctc-lib
        mstore
        test-drive
        ;
    };
    mstore = mstore.override {
      inherit buildType;
      inherit (self) mctc-lib;
    };
    test-drive = test-drive.override {
      inherit buildType;
    };
    cpcm-x = cpcm-x.override {
      inherit buildType;
      inherit (self)
        mctc-lib
        numsa
        toml-f
        test-drive
        ;
    };
    simple-dftd3 = simple-dftd3.override {
      inherit buildType;
      inherit (self)
        mctc-lib
        mstore
        toml-f
        ;
    };
    # xtb master requires the newer grimme generation (dftd4 4.x / tblite 0.6 /
    # multicharge 0.5 / toml-f 0.5), which the shared nixpkgs packages cannot
    # provide because cp2k is stuck on the older generation. Pin the newer
    # versions here, scoped to xtb only.
    dftd4 =
      (dftd4.override {
        inherit buildType;
        inherit (self)
          mctc-lib
          mstore
          multicharge
          ;
      }).overrideAttrs
        (_: {
          version = "4.2.0";
          src = fetchFromGitHub {
            owner = "dftd4";
            repo = "dftd4";
            tag = "v4.2.0";
            hash = "sha256-uKjNOIza3/I0oREp88oFESoNqEdumo1AztIjcrVb1O8=";
          };
        });
    multicharge =
      (multicharge.override {
        inherit buildType;
        inherit (self)
          mctc-lib
          mstore
          ;
      }).overrideAttrs
        (_: {
          version = "0.5.0";
          src = fetchFromGitHub {
            owner = "grimme-lab";
            repo = "multicharge";
            tag = "v0.5.0";
            hash = "sha256-hswqC+fvC6tuxDpuUgowyqm72ubVikzpR4EzXtTM5cs=";
          };
        });
    toml-f =
      (toml-f.override {
        inherit buildType;
        inherit (self)
          test-drive
          ;
      }).overrideAttrs
        (_: {
          version = "0.5.0";
          src = fetchFromGitHub {
            owner = "toml-f";
            repo = "toml-f";
            tag = "v0.5.0";
            hash = "sha256-KezWMZln7iyVRu1zfs+2JjZszh5NDByALf3RSVsDt3Y=";
          };
          # 0.5 finds test-drive via CMAKE_PREFIX_PATH; the 0.4-era flag is stale.
          cmakeFlags = [ ];
        });
    tblite =
      (tblite.override {
        inherit buildType;
        inherit (self)
          dftd4
          simple-dftd3
          mctc-lib
          mstore
          toml-f
          multicharge
          ;
      }).overrideAttrs
        (_: {
          version = "0.6.0";
          src = fetchFromGitHub {
            owner = "tblite";
            repo = "tblite";
            tag = "v0.6.0";
            hash = "sha256-z0g+bf6APqNLB9mDE49FelitQ9ptZXdFQuYeXIT0NIw=";
          };
        });
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xtb";
  # No tagged release supports the tblite 0.6 / dftd4 4.2 API; the latest tag (6.7.1) targets
  # tblite 0.3. Track master, which builds against the current grimme-lab stack packaged in nixpkgs
  version = "6.7.1-unstable-2026-05-16";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "grimme-lab";
    repo = "xtb";
    rev = "2b5cd4829290775e575807daee21560f851ff7e1";
    hash = "sha256-dnpmbjLG6xKSLXEUdwndsA0ADTEyaTY9fJiOSXI7jD4=";
  };

  # The Fortran unit-test executable races on xtb's own modules under meson (cross-target module
  # ordering with default_library=both) and fails to build.
  # Drop it; the program, library and C-API test still build.
  # The cmake build is unaffected and keeps the full test suite.
  postPatch = lib.optionalString (buildType == "meson") ''
    substituteInPlace test/meson.build --replace-fail "subdir('unit')" ""
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

  cmakeFlags = [
    (lib.cmakeFeature "MCTCLIB_FIND_METHOD" "cmake")
    (lib.cmakeFeature "TBLITE_FIND_METHOD" "cmake")

    # symmetry/symmetry_i.c defines a function named `true`, which is a reserved
    # keyword since C23 (GCC's default). The meson build already pins c_std=c11.
    (lib.cmakeFeature "CMAKE_C_STANDARD" "17")
  ];

  mesonFlags = [
    # Require the optional backends rather than letting the `auto` features
    # silently disable themselves if a dependency is not found.
    (lib.mesonEnable "tblite" true)
    (lib.mesonEnable "cpcmx" true)
  ];

  # Serialize the meson build: ninja otherwise compiles xtb's program/library objects before the
  # library's Fortran modules are generated.
  # `enableParallel` only controls the explicit -j flag and ninja parallelizes regardless, so the
  # race has to be killed with an explicit -j1.
  ninjaFlags = lib.optionals (buildType == "meson") [
    "-j1"
  ];

  buildInputs = [
    blas
    lapack
    deps.cpcm-x
    deps.dftd4
    deps.mctc-lib
    deps.multicharge
    deps.simple-dftd3
    deps.numsa
    deps.tblite
    deps.test-drive
    deps.toml-f
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Semiempirical Extended Tight-Binding Program Package";
    homepage = "https://github.com/grimme-lab/xtb";
    # changelog = "https://github.com/grimme-lab/xtb/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "xtb";
    platforms = lib.platforms.all;
  };
})
