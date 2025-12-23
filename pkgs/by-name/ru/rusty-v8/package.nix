{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rusty-v8";
  version = "142.2.0";

  src = fetchFromGitHub {
    owner = "denoland";
    repo = "rusty_v8";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OiVUhnHwMx2QFzmlXjSUokkjS5oMt77CZVs34JmMfFM=";
  };

  cargoHash = "sha256-KtpBpVJHv/lSv8weSXWStxbz4lGZ/xGeQ2bqJUoBnjs=";

  meta = {
    description = "Rust bindings for the V8 JavaScript engine";
    homepage = "https://github.com/denoland/rusty_v8";
  };
})
