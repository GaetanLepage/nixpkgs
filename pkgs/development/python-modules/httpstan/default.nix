{ lib
, buildPythonPackage
, fetchFromGitHub
# , make
, curl
, poetry-core
, setuptools
, aiohttp
, appdirs
, marshmallow
, numpy
, webargs
, apispec
, pytest-asyncio
, pytestCheckHook
, pyyaml
}:

buildPythonPackage rec {
  pname = "httpstan";
  version = "4.10.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "stan-dev";
    repo = "httpstan";
    rev = version;
    hash = "sha256-OrEwyEZzwDmUcZrCowYIONf3tPGQaB2Cp5BKGCZIlNQ=";
  };

  nativeBuildInputs = [
    # make
    curl
    poetry-core
    setuptools
  ];

  preBuild = ''
    make
  '';

  propagatedBuildInputs = [
    aiohttp
    appdirs
    marshmallow
    numpy
    setuptools
    webargs
  ];

  # Many tests require network access
  # doCheck = false;

  nativeCheckInputs = [
    apispec
    pytest-asyncio
    pytestCheckHook
    pyyaml
  ];

  disabledTests = [
    # "test_compile"
    # "test_transformed_data_rng"
    # "test_user_inits"
  ];

  pythonImportsCheck = [ "httpstan" ];

  meta = with lib; {
    description = "HTTP interface to Stan, a package for Bayesian inference";
    homepage = "https://github.com/stan-dev/httpstan";
    license = licenses.isc;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
