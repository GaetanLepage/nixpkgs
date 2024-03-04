{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, setuptools
, wheel
, brax
, pytestCheckHook
, pytest-xdist
}:

buildPythonPackage rec {
  pname = "stoix";
  version = "unstable-2024-03-03";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "EdanToledo";
    repo = "Stoix";
    rev = "58fe7a954531bdf912ec4247bd9dea092a9e9455";
    hash = "sha256-mhlfXFcevQAN95xI8LDVk00amLkiitLQPhf0l50NxIk=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatesBuildInputs = [
    brax
    # colorama
    # craftax
    # distrax @ git+https://github.com/google-deepmind/distrax  # distrax release doesn't support jax > 0.4.13
    # flashbax @ git+https://github.com/instadeepai/flashbax
    # flax
    # gymnax>=0.0.6
    # huggingface_hub
    # hydra-core==1.3.2
    # id-marl-eval @ git+https://github.com/instadeepai/marl-eval
    # jax>=0.4.10
    # jaxlib
    # jaxmarl
    # jumanji @ git+https://github.com/instadeepai/jumanji.git@main
    # mctx
    # neptune
    # numpy
    # omegaconf
    # optax
    # protobuf
    # rlax
    # tdqm
    # tensorboard_logger
    # tensorflow==2.11.1
    # tensorflow_probability==0.19.0
    # xminigrid @ git+https://github.com/corl-team/xland-minigrid.git@main
  ];

  pythonImportsCheck = [ "stoix" ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  meta = with lib; {
    description = "A research-friendly codebase for fast experimentation of single-agent reinforcement learning in JAX";
    homepage = "https://github.com/EdanToledo/Stoix";
    license = licenses.asl20;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
