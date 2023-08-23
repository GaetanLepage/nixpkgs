{ lib
, buildNpmPackage
, fetchFromGitHub
, pnpm-lock-export
}:

buildNpmPackage rec {
  pname = "vtsls";
  version = "0.1.20";

  src = fetchFromGitHub {
    owner = "yioneko";
    repo = "vtsls";
    rev = "server-v${version}";
    hash = "sha256-9PiAabYw8UnA+TzqIUKiDfeXc34kk5sxhoRgADk+raI=";
  };

  postPatch = ''
    ls -al
    ${pnpm-lock-export}/bin/pnpm-lock-export --schema package-lock.json@v1
    ls -al
  '';

  meta = with lib; {
    description = "LSP wrapper for typescript extension of vscode";
    homepage = "https://github.com/yioneko/vtsls";
    license = licenses.mit;
    maintainers = with maintainers; [ GaetanLepage ];
  };
}
