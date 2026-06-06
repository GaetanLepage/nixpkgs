# Packages which have been deprecated or removed from cudaPackages
{ lib }:
let
  mkRenamed =
    oldName:
    { path, package }:
    lib.warn "cudaPackages.${oldName} is deprecated, use ${path} instead" package;
in
final: prev:
(builtins.mapAttrs mkRenamed {
  # A comment to prevent empty { } from collapsing into a single line
})
// {
  cuda_cccl =
    if (prev.cudaAtLeast "13.3") then
      lib.warn "cudaPackages.cuda_cccl is deprecated since CUDA 13.3, use cudaPackages.cccl instead" final.cccl
    else
      # Do not warn when running a CUDA version where cccl is still named cuda_cccl
      # -> Just alias silently
      final.cccl;
}
