# Find new releases at https://storage.googleapis.com/jax-releases/jax_releases.html.
# When upgrading, you can get these hashes from prefetch.sh. See
# https://github.com/google/jax/issues/12879 as to why this specific URL is the correct index.

# To add a new version, run "prefetch.sh 'new-version'" to paste the generated file as follows.

version : builtins.getAttr version {
  "0.4.12" = {
    x86_64-linux-310 = {
      name = "jaxlib-0.4.12-cp310-cp310-manylinux2014_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/nocuda/jaxlib-0.4.12-cp310-cp310-manylinux2014_x86_64.whl";
      hash = "sha256-8ef5aMP7M3/FetSqfdz2OCaVCt6CLHRSMMsVtV2bCLc=";
    };
    x86_64-linux-311 = {
      name = "jaxlib-0.4.12-cp311-cp311-manylinux2014_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/nocuda/jaxlib-0.4.12-cp311-cp311-manylinux2014_x86_64.whl";
      hash = "sha256-bd+lBtL5sCpjOa0a0BvJLLQjAPA4NhQFihDiWjXxWHg=";
    };
    x86_64-linux-310-cuda = {
      name = "jaxlib-0.4.12-cp310-cp310-manylinux2014_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/cuda12/jaxlib-0.4.12%2Bcuda12.cudnn89-cp310-cp310-manylinux2014_x86_64.whl";
      hash = "sha256-+ZYqr6Qun9E0fuhzHrYZuKdcDKv+oCctI/QklFLYheY=";
    };
    x86_64-linux-311-cuda = {
      name = "jaxlib-0.4.12-cp311-cp311-manylinux2014_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/cuda12/jaxlib-0.4.12%2Bcuda12.cudnn89-cp311-cp311-manylinux2014_x86_64.whl";
      hash = "sha256-22vAkAaisWRSYYIl4IV4TAW/Tjo4m8Yi+DpB0A1nbyQ=";
    };
    x86_64-darwin-310 = {
      name = "jaxlib-0.4.12-cp310-cp310-macosx_10_14_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/mac/jaxlib-0.4.12-cp310-cp310-macosx_10_14_x86_64.whl";
      hash = "sha256-I4zX1vv4L5Ik9eWrJ8fKd0EIt5C9XTN4JlfB8hH+l5c=";
    };
    x86_64-darwin-311 = {
      name = "jaxlib-0.4.12-cp311-cp311-macosx_10_14_x86_64.whl";
      url = "https://storage.googleapis.com/jax-releases/mac/jaxlib-0.4.12-cp311-cp311-macosx_10_14_x86_64.whl";
      hash = "sha256-G27Mlfe6/isiIrXs799H8PG6MjwuswNvMS7HyE+f59I=";
    };
    aarch64-darwin-310 = {
      name = "jaxlib-0.4.12-cp310-cp310-macosx_11_0_arm64.whl";
      url = "https://storage.googleapis.com/jax-releases/mac/jaxlib-0.4.12-cp310-cp310-macosx_11_0_arm64.whl";
      hash = "sha256-Opg/DB4wAVSm5L3+G470HiBPDoR/BO4qP0OX9HSbeSo=";
    };
    aarch64-darwin-311 = {
      name = "jaxlib-0.4.12-cp311-cp311-macosx_11_0_arm64.whl";
      url = "https://storage.googleapis.com/jax-releases/mac/jaxlib-0.4.12-cp311-cp311-macosx_11_0_arm64.whl";
      hash = "sha256-Fl3G03cDNFgnMUQHeXP6DHibYO+ipKg8adVzewqGsL0=";
    };
  };
}
