{ lib
, buildPythonPackage
, setuptools
, mujoco-lib
, jax
, jaxlib
, mujoco
, scipy
, trimesh
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "mujoco-mjx";
  inherit (mujoco-lib) version src;
  pyproject = true;

  sourceRoot = "${src.name}/mjx";

  build-system = [
    setuptools
  ];

  dependencies = [
    jax
    jaxlib
    mujoco
    scipy
    trimesh
  ];

  # preCheck = ''
  #   ls -al
  #   rm -rf mujoco
  # '';

  pythonImportsCheck = [
    "mujoco.mjx"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Re-implementation of the MuJoCo physics engine in JAX";
    homepage = "https://github.com/google-deepmind/mujoco/tree/main/mjx";
    changelog = "https://github.com/google-deepmind/mujoco/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
