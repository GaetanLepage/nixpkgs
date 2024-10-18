{
  lib,
  config,
  buildPythonPackage,
  fetchFromGitHub,

  # nativeBuildInputs
  cudaPackages,

  # dependencies
  torch,
  pybind11,

  # tests
  pytestCheckHook,
  scipy,
  which,

  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage rec {
  pname = "deepwave";
  version = "0.0.20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ar4";
    repo = "deepwave";
    tag = "v${version}";
    hash = "sha256-AZmh99BLa/A9Jvxk9O14BlKoIGc2qKDiA1A956RmsvA=";
  };

  postPatch = ''
    substituteInPlace src/deepwave/build_linux.sh \
      --replace-fail " -Ofast -mavx2" ""

    patchShebangs .
  '';

  nativeBuildInputs = lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = lib.optionals cudaSupport [
    cudaPackages.cuda_cudart.dev
  ];

  preBuild = ''
    pushd src/deepwave
    ./build_linux.sh ${lib.optionalString (!cudaSupport) "NOCUDA"}
    popd
  '';

  dependencies = [
    torch
    pybind11
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
    which
  ];

  pytestFlagsArray = [ "-vvvvv" ];

  pythonImportsCheck = [ "deepwave" ];

  meta = {
    description = "Wave propagation modules for PyTorch";
    homepage = "https://github.com/ar4/deepwave";
    license = lib.licenses.mit;
    platforms = lib.intersectLists lib.platforms.x86_64 lib.platforms.linux;
    maintainers = with lib.maintainers; [ atila ];
  };
}
