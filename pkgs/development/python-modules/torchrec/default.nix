{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, setuptools
, wheel
, black
, cmake
, fbgemm-gpu
, hypothesis
, iopath
, numpy
, pandas
, pyre-extensions
, scikit-build
, torchmetrics
# , torchx
, tqdm
, usort
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "torchrec";
  version = "0.7.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "torchrec";
    rev = "refs/tags/v${version}";
    hash = "sha256-KCSIAUC90hKjOdbm+asAC1bSQGz1YV55LqUdbErUk80=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    fbgemm-gpu
    hypothesis
    iopath
    numpy
    pandas
    pyre-extensions
    scikit-build
    torchmetrics
    # torchx
    tqdm
    usort
  ];

  pythonImportsCheck = [ "torchrec" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Pytorch domain library for recommendation systems";
    changelog = "https://github.com/pytorch/torchrec/releases/tag/v${version}";
    homepage = "https://github.com/pytorch/torchrec";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
