#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-scripts

set -eou pipefail

version=$1

linux_cuda_version="cuda12"
linux_cudnn_version="cudnn89"
linux_cuda_bucket="https://storage.googleapis.com/jax-releases/${linux_cuda_version}"
linux_cpu_bucket="https://storage.googleapis.com/jax-releases/nocuda"
darwin_bucket="https://storage.googleapis.com/jax-releases/mac"

url_and_key_list=(
  "x86_64-linux-310 $linux_cpu_bucket/jaxlib-${version}-cp310-cp310-manylinux2014_x86_64.whl jaxlib-${version}-cp310-cp310-manylinux2014_x86_64.whl"
  "x86_64-linux-311 $linux_cpu_bucket/jaxlib-${version}-cp311-cp311-manylinux2014_x86_64.whl jaxlib-${version}-cp311-cp311-manylinux2014_x86_64.whl"
  "x86_64-linux-310-cuda $linux_cuda_bucket/jaxlib-${version}%2B${linux_cuda_version}.${linux_cudnn_version}-cp310-cp310-manylinux2014_x86_64.whl jaxlib-${version}-cp310-cp310-manylinux2014_x86_64.whl"
  "x86_64-linux-311-cuda $linux_cuda_bucket/jaxlib-${version}%2B${linux_cuda_version}.${linux_cudnn_version}-cp311-cp311-manylinux2014_x86_64.whl jaxlib-${version}-cp311-cp311-manylinux2014_x86_64.whl"
  "x86_64-darwin-310 $darwin_bucket/jaxlib-${version}-cp310-cp310-macosx_10_14_x86_64.whl jaxlib-${version}-cp310-cp310-macosx_10_14_x86_64.whl"
  "x86_64-darwin-311 $darwin_bucket/jaxlib-${version}-cp311-cp311-macosx_10_14_x86_64.whl jaxlib-${version}-cp311-cp311-macosx_10_14_x86_64.whl"
  "aarch64-darwin-310 $darwin_bucket/jaxlib-${version}-cp310-cp310-macosx_11_0_arm64.whl jaxlib-${version}-cp310-cp310-macosx_11_0_arm64.whl"
  "aarch64-darwin-311 $darwin_bucket/jaxlib-${version}-cp311-cp311-macosx_11_0_arm64.whl jaxlib-${version}-cp311-cp311-macosx_11_0_arm64.whl"
)

hashfile=binary-hashes-"$version".nix
echo "  \"$version\" = {" >> $hashfile

for url_and_key in "${url_and_key_list[@]}"; do
  key=$(echo "$url_and_key" | cut -d' ' -f1)
  url=$(echo "$url_and_key" | cut -d' ' -f2)
  name=$(echo "$url_and_key" | cut -d' ' -f3)

  echo "prefetching ${url}..."
  hash=$(nix hash to-sri --type sha256 `nix-prefetch-url "$url" --name "$name"`)

  echo "    $key = {" >> $hashfile
  echo "      name = \"$name\";" >> $hashfile
  echo "      url = \"$url\";" >> $hashfile
  echo "      hash = \"$hash\";" >> $hashfile
  echo "    };" >> $hashfile

  echo
done

echo "  };" >> $hashfile
echo "done."
