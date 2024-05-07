{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, pythonRelaxDepsHook
, setuptools
, wheel
, gymnasium
, imageio
, jinja2
, mujoco
, numpy
, pettingzoo
, cython
, pytest
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "gymnasium-robotics";
  version = "1.2.4";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Farama-Foundation";
    repo = "Gymnasium-Robotics";
    rev = "refs/tags/v${version}";
    hash = "sha256-YsYARqQhy6EKuEexMi9fgrdL3LvURQtesG+DMFHHkk0=";
  };

  build-system = [
    pythonRelaxDepsHook
    setuptools
    wheel
  ];

  pythonRelaxDeps = [
    "mujoco"
  ];

  dependencies = [
    gymnasium
    imageio
    jinja2
    mujoco
    numpy
    pettingzoo
  ];

  passthru.optional-dependencies = {
    mujoco_py = [
      cython
      mujoco
    ];
    testing = [
      cython
      jinja2
      mujoco
      pettingzoo
      pytest
    ];
  };

  pythonImportsCheck = [
    "gymnasium_robotics"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    # Those tests are probably trying to access to a display output
    # RuntimeError: std::exception
    "test_render_modes"
  ];

  meta = with lib; {
    description = "A collection of robotics simulation environments for reinforcement learning";
    homepage = "https://github.com/Farama-Foundation/Gymnasium-Robotics";
    changelog = "https://github.com/Farama-Foundation/Gymnasium-Robotics/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
