with import <nixpkgs> {};
{ stdenv, zlib, gtest, cmake, zeromq, root, boost}:

stdenv.mkDerivation rec {
    name = "fairroot-${version}";
    version = "v0.1.0";

    src = fetchFromGitHub {
      owner = "FairRootGroup";
      repo = "FairRoot";
      # This repository has numbered versions, but not Git tags.
      rev = "dev";
      sha256 = "08a71l9g4kkrd8w27y9c34jrisfnfwgc056yk9i72g1b2zr6qxvd";
    };

    patchPhase = ''
      substituteInPlace cmake/modules/CheckCompiler.cmake --replace "sw_vers -productVersion" "echo 10.13"
    '';

    cmakeFlags = with stdenv; [
      "-DCMAKE_CXX_FLAGS=-std=c++11"
    ];

    CMAKE_CXX_FLAGS = "-fPIC -g -O2";

    makeFlags = ["CC=cc"];
    buildInputs = [ gtest zlib cmake gfortran root boost zeromq ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.libs.xpc darwin.apple_sdk.frameworks.CoreServices ];
#    installPhase = ''
#      cmake -DCMAKE_INSTALL_PREFIX=$out
#    '';

    meta = {
      description = "FairRoot";
      homepage = https://fairrootgroup.github.io/;
      license = stdenv.lib.licenses.gpl3;
      platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
    };
  }
