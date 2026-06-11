{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # nativeBuildInputs
  rustPlatform,

  # dependencies
  anyio,

  # tests
  objsize,
  pydantic,
  pytestCheckHook,
  trio,

  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycrdt";
  version = "0.14.0";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "y-crdt";
    repo = "pycrdt";
    tag = finalAttrs.version;
    hash = "sha256-aCbE0TGmWy22Mc8gSF10Nhm6c2d0yJvpyCmoXSeoMT8=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  dependencies = [ anyio ];

  pythonImportsCheck = [ "pycrdt" ];

  nativeCheckInputs = [
    anyio
    objsize
    pydantic
    pytestCheckHook
    trio
  ];

  pytestFlags = [
    "-Wignore::pytest.PytestUnknownMarkWarning" # requires unpackaged pytest-mypy-testing
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = {
    description = "CRDTs based on Yrs";
    homepage = "https://github.com/jupyter-server/pycrdt";
    changelog = "https://github.com/jupyter-server/pycrdt/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.jupyter ];
  };
})
