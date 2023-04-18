{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, pybind11
}:

buildPythonPackage rec {
  pname = "ml-dtypes";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jax-ml";
    repo = "ml_dtypes";
    rev = "refs/tags/v${version}";
    hash = "sha256-eqajWUwylIYsS8gzEaCZLLr+1+34LXWhfKBjuwsEhhI=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    numpy
    pybind11
  ];

  pythonImportsCheck = [ "ml_dtypes" ];

  meta = with lib; {
    description = "A stand-alone implementation of several NumPy dtype extensions used in machine learning libraries";
    homepage = "https://github.com/jax-ml/ml_dtypes";
    license = licenses.asl20;
    maintainers = with maintainers; [ GaetanLepage samuela ];
  };
}
