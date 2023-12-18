{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, scikit-build
, setuptools-git-versioning
, cudaPackages
, tabulate
, torchWithCuda
, numpy
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "fbgemm";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "fbgemm";
    fetchSubmodules = true;
    rev = "refs/tags/v${version}";
    hash = "sha256-l/Q9shXw27D5PsvEShUfviLHCqnrSLZ2vFAZojffUZo=";
  };

  sourceRoot = "${src.name}/fbgemm_gpu";

  dontUseCmakeConfigure = true;

  build-system = [
    cmake
    scikit-build
    setuptools-git-versioning
  ];

  buildInputs = [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart # cuda_runtime.h
  ];

  dependencies = [
    tabulate
    torchWithCuda
    numpy
  ];

  pythonImportsCheckHook = [
    "fbgemm-gpu"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "FB (Facebook) + GEMM (General Matrix-Matrix Multiplication) - https://code.fb.com/ml-applications/fbgemm";
    changelog = "https://github.com/pytorch/FBGEMM/releases/tag/v${version}";
    homepage = "https://github.com/pytorch/fbgemm";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "fbgemm";
    platforms = lib.platforms.all;
  };
}
