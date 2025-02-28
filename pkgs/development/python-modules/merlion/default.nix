{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  cython,
  dill,
  GitPython,
  py4j,
  matplotlib,
  plotly,
  numpy,
  packaging,
  pandas,
  prophet,
  scikit-learn,
  scipy,
  statsmodels,
  lightgbm,
  tqdm,

  # tests
  pyspark,
  pytestCheckHook,
  tensorflow-datasets,
  torch,
}:

buildPythonPackage rec {
  pname = "merlion";
  version = "2.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "salesforce";
    repo = "Merlion";
    tag = "v${version}";
    hash = "sha256-oKkPKxeHfdJcKoVh3mvdz+Ji76tSjz+AfJX4lTD4H6Q=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    cython
    dill
    GitPython
    py4j
    matplotlib
    plotly
    numpy
    packaging
    pandas
    prophet
    scikit-learn
    scipy
    statsmodels
    lightgbm
    tqdm
  ];

  pythonImportsCheck = [ "merlion" ];

  nativeCheckInputs = [
    pyspark
    pytestCheckHook
    tensorflow-datasets
    torch
  ];

  meta = {
    description = "Machine Learning Framework for Time Series Intelligence";
    homepage = "https://github.com/salesforce/Merlion";
    changelog = "https://github.com/salesforce/Merlion/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
