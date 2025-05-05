{
  fetchurl,
  writers,
  torch,
  torchvision,
  replaceVars,
  runCommand,
}:
let
  # fashionMnistDataset = symlinkJoin {
  #   name = "fashion-mnist";
  #   paths = [
  #     (fetchurl {
  #       url = "http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/train-images-idx3-ubyte.gz";
  #       hash = "sha256-Ou3jjWGGOQiteGE/ajLtJxYm3RKAC6JjZWlRI2kmioQ=";
  #     })
  #   ];
  #   # postBuild = ''
  #   #   ls -al
  #   # '';
  # };
  fashionMnistDataset = fetchurl {
    urls = [
      "http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/train-images-idx3-ubyte.gz"
    ];
    hash = "sha256-Ou3jjWGGOQiteGE/ajLtJxYm3RKAC6JjZWlRI2kmioQ=";
  };
  mnist-script =
    writers.writePython3 "test_mnist"
      {
        libraries = [
          torch
          torchvision
        ];
      }
      (
        replaceVars ./script.py {
          fashion-mnist-dataset = fashionMnistDataset;
        }
      );
in
runCommand "mnist" { } ''
  ls ${fashionMnistDataset}
  ${mnist-script}
''
