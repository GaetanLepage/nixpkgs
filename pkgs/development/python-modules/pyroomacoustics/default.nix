{ lib
, buildPythonPackage
, fetchFromGitHub
, cython
, numpy
, pybind11
, setuptools
, wheel
, matplotlib
, mir-eval
, samplerate
, scipy
, sounddevice
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pyroomacoustics";
  version = "0.7.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LCAV";
    repo = "pyroomacoustics";
    rev = "refs/tags/v${version}";
    hash = "sha256-hrQC+8/fsPYWbKkSWBdZSxayt6RJR7CdlFvOgxgwFic=";
    fetchSubmodules = true;
  };

  build-system = [
    cython
    numpy
    pybind11
    setuptools
    wheel
  ];

  dependencies = [
    cython
    matplotlib
    mir-eval
    numpy
    pybind11
    samplerate
    scipy
    sounddevice
  ];

  pythonImportsCheck = [ "pyroomacoustics" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # doCheck = false;

  meta = {
    description = "Pyroomacoustics is a package for audio signal processing for indoor applications. It was developed as a fast prototyping platform for beamforming algorithms in indoor scenarios";
    homepage = "https://github.com/LCAV/pyroomacoustics";
    changelog = "https://github.com/LCAV/pyroomacoustics/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
