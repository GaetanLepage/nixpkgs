# NOTE: Since 0.6.x, upstream no longer pre-compiles kernels here (the AOT half now lives in the
# separate `flashinfer-jit-cache` distribution). Every kernel is therefore compiled at runtime via
# PyTorch's JIT, which requires the CUDA toolkit (via nvcc) to be available.
#
# This means that if you plan to use flashinfer, you will need to set the environment variable
# `CUDA_HOME` to `cudatoolkit`.
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  apache-tvm-ffi,
  packaging,
  setuptools,

  # nativeBuildInputs
  ninja,
  cudaPackages,
  writableTmpDirAsHomeHook,

  # dependencies
  click,
  cuda-bindings,
  cuda-core,
  cuda-tile,
  einops,
  nccl4py,
  numpy,
  nvidia-cudnn-frontend,
  nvidia-cutlass-dsl,
  nvidia-ml-py,
  requests,
  tabulate,
  torch,
  tqdm,

  # tests
  mpi4py,
  numba,
  nvidia-cutlass,
  pytestCheckHook,
  pytest-timeout,
  responses,

  cudaSupport ? torch.cudaSupport,
}:

buildPythonPackage.override { inherit (torch) stdenv; } (finalAttrs: {
  pname = "flashinfer-python";
  version = "0.7.1";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "flashinfer-ai";
    repo = "flashinfer";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-rUi9Tj7/PhDNU9W63ycYztFN8HuOcVNE0EgjsMJ5PrU=";
  };

  build-system = [
    apache-tvm-ffi
    packaging
    setuptools
  ];

  nativeBuildInputs = [
    ninja
    (lib.getBin cudaPackages.cuda_nvcc)
    # flashinfer creates its JIT workspace in $HOME at import time
    writableTmpDirAsHomeHook
  ];

  buildInputs = with cudaPackages; [
    cccl
    cuda_cudart
    libcublas
    libcurand
  ];

  env = {
    FLASHINFER_CUDA_ARCH_LIST = lib.concatStringsSep " " torch.cudaCapabilities;
    # Prevent the build backend from trying to pip-install cuda-tile/NIXL wheels
    FLASHINFER_BUILD_NO_PIP = "1";
    # Skip the (best-effort) NIXL-EP submodule build
    BUILD_NVEP = "0";
  };

  pythonRemoveDeps = [
    # `cuda-python` is a meta-package pulling in the sub-packages of github:NVIDIA/cuda-python.
    # Only the ones flashinfer actually imports are substituted below.
    "cuda-python"

    # Unpackaged. Only provides the optional `nccl.ep` backend of `flashinfer.moe_ep`, which is
    # probed at runtime.
    "nccl-extensions"
  ];
  dependencies = [
    apache-tvm-ffi
    click
    cuda-bindings
    cuda-core
    cuda-tile
    einops
    nccl4py
    ninja
    numpy
    nvidia-cudnn-frontend
    nvidia-cutlass-dsl
    nvidia-ml-py
    packaging
    requests
    tabulate
    torch
    tqdm
  ];

  pythonImportsCheck = [ "flashinfer" ];

  nativeCheckInputs = [
    # nvshmem4py
    mpi4py
    numba
    nvidia-cutlass # pycute
    pytestCheckHook
    pytest-timeout
    responses
  ];

  disabledTestPaths = [
    # Require unpackaged nvshmem4py
    "tests/comm/test_nvshmem.py"
    "tests/comm/test_nvshmem_allreduce.py"
  ];

  # Tests require access to a GPU
  doCheck = false;
  passthru.gpuCheck = finalAttrs.finalPackage.overrideAttrs {
    requiredSystemFeatures = [ "cuda" ];
    doInstallCheck = true;
  };

  meta = {
    broken = !cudaSupport;
    homepage = "https://flashinfer.ai/";
    downloadPage = "https://github.com/flashinfer-ai/flashinfer";
    changelog = "https://github.com/flashinfer-ai/flashinfer/releases/tag/${finalAttrs.src.tag}";
    description = "Library and kernel generator for Large Language Models";
    longDescription = ''
      FlashInfer is a library and kernel generator for Large Language Models
      that provides high-performance implementation of LLM GPU kernels such as
      FlashAttention, PageAttention and LoRA. FlashInfer focus on LLM serving
      and inference, and delivers state-of-the-art performance across diverse
      scenarios.
    '';
    license = lib.licenses.asl20;
    mainProgram = "flashinfer";
    maintainers = with lib.maintainers; [
      GaetanLepage
      breakds
      daniel-fahey
    ];
  };
})
