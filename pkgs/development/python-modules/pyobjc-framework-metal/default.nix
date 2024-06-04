{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  pyobjc-core,
  pyobjc-framework-cocoa,
}:

buildPythonPackage rec {
  pname = "pyobjc-framework-metal";
  version = "10.3";
  pyproject = true;

  src = fetchPypi {
    pname = "pyobjc_framework_metal";
    inherit version;
    hash = "sha256-8Tf7ghdb9HflbeXHiOlsqirR+DtlpPw3T529Hx+ekcw=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    pyobjc-core
    pyobjc-framework-cocoa
  ];

  pythonImportsCheck = [ "pyobjc_framework_metal" ];

  meta = {
    description = "Wrappers for the framework Metal on macOS";
    homepage = "https://pypi.org/project/pyobjc-framework-Metal/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
