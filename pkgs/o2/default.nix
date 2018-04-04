with import <nixpkgs> {};
{ stdenv, zlib, cmake, fairroot, boost}:

stdenv.mkDerivation rec {
    name = "o2-${version}";
    version = "v0.1.0";

    src = fetchFromGitHub {
      owner = "AliceO2Group";
      repo = "AliceO2";
      # This repository has numbered versions, but not Git tags.
      rev = "dev";
      sha256 = "0nrxq959yrr4w8q6c9mz55dffvl22vmia357z0g934x9ialiwg3h";
    };

    makeFlags = ["CC=cc"];
    buildInputs = [ zlib cmake fairroot boost ];

    installPhase = ''
      cmake -DCMAKE_INSTALL_PREFIX=$out
    '';

    meta = with stdenv.lib; {
      description = "O2 Package";
      homepage = https://aliceo2group.github.io/;
      license = licenses.gpl3;
      platforms = with platform; linux ++ darwin;
    };
  }
