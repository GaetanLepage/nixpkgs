{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, absl-py
, dm-env
, etils
, flask
, flask-cors
, flax
, grpcio
, gym
, jaxopt
, ml-collections
, mujoco
, numpy
, optax
, pillow
, scipy
, tensorboardx
, trimesh
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "brax";
  version = "0.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "google";
    repo = "brax";
    rev = "v${version}";
    hash = "sha256-O95LeQ8A4Yv7nAGDl08/34FuUPHjeetuKzYUBtTpzaU=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    absl-py
    dm-env
    etils
    flask
    flask-cors
    flax
    grpcio
    gym
    jaxopt
    ml-collections
    mujoco
    numpy
    optax
    pillow
    scipy
    tensorboardx
    trimesh
  ];

  pythonImportsCheck = [ "brax" ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Massively parallel rigidbody physics simulation on accelerator hardware";
    homepage = "https://github.com/google/brax";
    license = licenses.asl20;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
