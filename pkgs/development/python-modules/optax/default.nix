{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  flit-core,

  # dependencies
  absl-py,
  jax,
  jaxlib,
  numpy,

  # tests
  callPackage,
}:

buildPythonPackage (finalAttrs: {
  pname = "optax";
  version = "0.2.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "optax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E5tRNzUblPD3gy1sVvVbKvWmj86Q6HW6VW7QKCOAFnU=";
  };

  outputs = [
    "out"
    "testsout"
  ];

  build-system = [ flit-core ];

  dependencies = [
    absl-py
    jax
    jaxlib
    numpy
  ];

  postInstall = ''
    mkdir $testsout
    cp -R examples $testsout/examples
  '';

  pythonImportsCheck = [ "optax" ];

  # check in passthru.tests.pytest to escape infinite recursion with flax
  doCheck = false;

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Gradient processing and optimization library for JAX";
    homepage = "https://github.com/deepmind/optax";
    changelog = "https://github.com/deepmind/optax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
})
