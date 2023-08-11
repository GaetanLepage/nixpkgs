{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest-benchmark
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pysimdjson";
  version = "5.0.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "TkTech";
    repo = "pysimdjson";
    rev = "v${version}";
    hash = "sha256-m2wTKsPF/05v8TuqrzrjvJXyxl7WBartWrZyTS0WGL4=";
  };

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Python bindings for the simdjson project";
    homepage = "https://github.com/TkTech/pysimdjson";
    changelog = "https://github.com/TkTech/pysimdjson/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
