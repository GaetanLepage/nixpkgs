{
  lib,
  stdenv,
  fetchFromGitHub,

  # nativeBuildInputs
  cmake,

  # buildInputs
  glfw3,
  libGL,
  libX11,
  libXinerama,
  libXrandr,
  libXcursor,
  libXi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "box2d-lite";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "erincatto";
    repo = "box2d-lite";
    tag = finalAttrs.version;
    hash = "sha256-XilbE1HsDgpTvmz2EmcF9OZBHkabNxuBAo08al0Zixo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    glfw3
    libGL
    libXcursor
    libXi
    libX11
    libXrandr
    libXinerama
  ];

  installPhase = ''
    runHook preInstall

    pwd
    ls -al

    runHook postInstall
  '';

  meta = {
    description = "A small 2D physics engine";
    homepage = "https://github.com/erincatto/box2d-lite";
    changelog = "https://github.com/erincatto/box2d-lite/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "box2d-lite";
    platforms = lib.platforms.all;
  };
})
