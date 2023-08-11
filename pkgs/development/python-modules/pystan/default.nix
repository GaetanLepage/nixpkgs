{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, aiohttp
, clikit
, httpstan
, numpy
, pysimdjson
, setuptools
, pandas
, pytest-asyncio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pystan";
  version = "3.7.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "stan-dev";
    repo = "pystan";
    rev = version;
    hash = "sha256-lhBug5jKCcvdiPR1GMx08J+ZuYwaPKhV6lFTUS/2Av8=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    aiohttp
    clikit
    httpstan
    numpy
    pysimdjson
    setuptools
  ];

  nativeCheckInputs = [
    pandas
    pytest-asyncio
    pytestCheckHook
  ];

  pythonImportsCheck = [ "stan" ];

  meta = with lib; {
    description = "PyStan, a Python interface to Stan, a platform for statistical modeling";
    homepage = "https://github.com/stan-dev/pystan";
    license = licenses.isc;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
