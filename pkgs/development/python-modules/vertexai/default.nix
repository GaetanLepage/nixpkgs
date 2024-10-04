{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  docstring-parser,
  google-api-core,
  google-auth,
  google-cloud-bigquery,
  google-cloud-resource-manager,
  google-cloud-storage,
  protobuf,
  proto-plus,
  pydantic,
  shapely,

  # tests
  pytest-asyncio,
  pytestCheckHook,
  ray,
}:

buildPythonPackage rec {
  pname = "vertexai";
  version = "1.69.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-aiplatform";
    rev = "refs/tags/v${version}";
    hash = "sha256-SNFxpitIfRAwaHpEBLtc/XuGuLBEX+Ppfs+jlo3joF0=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    docstring-parser
    google-api-core
    google-auth
    google-cloud-bigquery
    google-cloud-resource-manager
    google-cloud-storage
    protobuf
    proto-plus
    pydantic
    shapely
  ];

  pythonImportsCheck = [
    "vertexai"
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    ray
  ];

  meta = {
    description = "A Python SDK for Vertex AI, a fully managed, end-to-end platform for data science and machine learning";
    homepage = "https://github.com/googleapis/python-aiplatform";
    changelog = "https://github.com/googleapis/python-aiplatform/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
