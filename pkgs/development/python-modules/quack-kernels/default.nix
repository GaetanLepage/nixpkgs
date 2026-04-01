{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  apache-tvm-ffi,
  cuda-bindings,
  torch,
  torch-c-dlpack-ext,

  # tests
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "quack-kernels";
  version = "0.3.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Dao-AILab";
    repo = "quack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6nwQmeK84qRPu2inezF+Cj9/w6C9hW9/HJmE9nYmeCk=";
  };

  build-system = [
    setuptools
  ];

  pythonRemoveDeps = [
    "nvidia-cutlass-dsl"
  ];
  dependencies = [
    apache-tvm-ffi
    cuda-bindings
    torch
    torch-c-dlpack-ext
  ];

  pythonImportsCheck = [ "quack" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Quirky Assortment of CuTe Kernels";
    homepage = "https://github.com/Dao-AILab/quack";
    changelog = "https://github.com/Dao-AILab/quack/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
