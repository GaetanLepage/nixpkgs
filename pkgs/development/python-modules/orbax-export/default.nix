{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  flit-core,

  # dependencies
  absl-py,
  dataclasses-json,
  etils,
  jax,
  jaxlib,
  jaxtyping,
  numpy,
  orbax-checkpoint,
  protobuf,
  tensorflow,

  # tests
  chex,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "orbax-export";
  version = "0.0.8";
  pyproject = true;

  src = fetchPypi {
    pname = "orbax_export";
    inherit (finalAttrs) version;
    hash = "sha256-VE7vVk4qbxfNEbEWf+vjSLe3z1bZV13plKM9VhPdVoo=";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
    absl-py
    dataclasses-json
    etils
    jax
    jaxlib
    jaxtyping
    numpy
    orbax-checkpoint
    protobuf
    tensorflow
  ];

  pythonImportsCheck = [
    "orbax"
    "orbax.export"
  ];

  nativeCheckInputs = [
    chex
    pytestCheckHook
  ];

  meta = {
    description = "Serialization library for JAX users, enabling the exporting of JAX models to the TensorFlow SavedModel format";
    homepage = "https://github.com/google/orbax/tree/main/export";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
