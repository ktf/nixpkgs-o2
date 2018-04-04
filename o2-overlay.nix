self: super:

let
  myGCC = super.gcc6.overrideAttrs(old: rec {
    extraPackages = [super.zlib.dev];
  }
  );
  myZlib = super.zlib.overrideAttrs (old: rec {
    name = "zlib-1.2.8";
    version = "v1.2.8";
    src = super.fetchFromGitHub {
      owner = "star-externals";
      repo = "zlib";
      # This repository has numbered versions, but not Git tags.
      rev = "v1.2.8";
      sha256 = "1w08maq1p3dsv116p3nhd3mrn3pp6qh1vkzbiwycv65jwv87xp9d";
    };
  });

  myCmake = super.cmake.overrideAttrs (old: rec {
    name = "cmake-3.11.0";
    version = "v3.11.0";
    patches = [ patches/search-path-3.9.patch ];
    src = super.fetchFromGitHub {
      owner = "Kitware";
      repo = "cmake";
      rev = "${version}";
      sha256 = "1iiyysw16asqj1c077gk6s9pqy8qij6d83kwxc59swc7xgcy1g0d";
    };
  });

  myBoost = super.boost.overrideAttrs (old: rec {
    name = "boost-1.64";
    version = "1.64_0";
    src = super.fetchurl {
      url = "mirror://sourceforge/boost/boost_1_64_0.tar.bz2";
      # SHA256 from http://www.boost.org/users/history/version_1_64_0.html
      sha256 = "0cikd35xfkpg9nnl76yqqnqxnf3hyfjjww8xjd4akflprsm5rk3v";
    };
    enableParallelBuilding = true;
  });

  myRoot = super.root.overrideAttrs (old: rec {
    buildInputs = with self; with super.darwin.apple_sdk.frameworks; [ self.cmake pcre python2 zlib libxml2 lz4 lzma gsl super.xxHash super.pythia ]
      ++ super.stdenv.lib.optionals (!super.stdenv.isDarwin) [ libX11 libXpm libXft libXext libGLU_combined ]
      ++  super.stdenv.lib.optionals (super.stdenv.isDarwin) [ Cocoa OpenGL ]
      ;
    cmakeFlags = [
     "-Drpath=ON"
     "-DCMAKE_INSTALL_LIBDIR=lib"
     "-DCMAKE_INSTALL_INCLUDEDIR=include"
     "-Dalien=OFF"
     "-Dbonjour=OFF"
     "-Dcastor=OFF"
     "-Dchirp=OFF"
     "-Ddavix=OFF"
     "-Ddcache=OFF"
     "-Dfftw3=OFF"
     "-Dfitsio=OFF"
     "-Dfortran=OFF"
     "-Dimt=OFF"
     "-Dgfal=OFF"
     "-Dhttp=ON"
     "-Dgviz=OFF"
     "-Dhdfs=OFF"
     "-Dkrb5=OFF"
     "-Dldap=OFF"
     "-Dmonalisa=OFF"
     "-Dminuit2=ON"
     "-Dmysql=OFF"
     "-Dodbc=OFF"
     "-Dopengl=ON"
     "-Doracle=OFF"
     "-Dpgsql=OFF"
     "-Dpythia6_nolink=ON"
     "-Drfio=OFF"
     "-Droofit=ON"
     "-Dsqlite=OFF"
     "-Dssl=OFF"
     "-Dvdt=ON"
     "-Dbuiltin_vdt=ON"
     "-Dxml=ON"
     "-Dxrootd=OFF"
  ];
  });

  myMetakernel = super.callPackage ./pkgs/metakernel {
    inherit (super.stdenv) lib;
    inherit (super.python36.pkgs) fetchPypi;
    inherit (super.python36.pkgs) buildPythonPackage;
    inherit (super.python36.pkgs) ipykernel;
    inherit (super.python36.pkgs) pexpect;
  };

  myPython = super.python36.withPackages(ps: with ps; [
        pip
        matplotlib
        numpy
        certifi
        ipython
        ipywidgets
        ipykernel
        notebook
        pyyaml
        myMetakernel
    ]);
in
{
  ccacheWrapper = super.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR=~/.ccache
      export CCACHE_UMASK=007
    '';
  };

  alice = (super.alice or {}) // {
    cmake = myCmake;
    zeromq = super.zeromq;
    root = myRoot;
    boost = myBoost;
    fairroot = import ./pkgs/fairroot {
      inherit (super) stdenv zlib gtest;
      inherit (self.alice) cmake zeromq root boost;
    };
    o2 = import ./pkgs/o2 {
      inherit (super) stdenv zlib;
      inherit (self.alice) fairroot cmake;
    };

    o2BuildEnv = with super; buildEnv {
        name = "o2BuildEnv";
        paths = with super; [
          glibc
          glibc.out
          glibc.dev
          bison
          flex
          readline
          autoconf
          m4
          automake
          pkgconfig
          gettext
          libtool
          gcc
          gfortran
          zlib.dev
          zlib
          zlib.out
  #        curl.dev
  #        curl
          curlFull
          curlFull.dev
          curlFull.out
          myPython
          libpng
          libpng.dev
          gsl
          sqlite
          freetype
          freetype.dev
          glew
          libGLU.dev
          libGLU.out
          libGL.dev
          libGL.out
          myPython
          xorg.libX11
          xorg.libX11.dev
          xorg.libXpm
          xorg.libXpm.dev
          xorg.libXpm.out
          xorg.libXi
          xorg.libXi.dev
          xorg.libXScrnSaver
          xorg.libXcursor
          xorg.libXcursor.dev
          xorg.libXinerama
          xorg.libXinerama.dev
          xorg.libXext
          xorg.libXext.dev
          xorg.libXxf86vm
          xorg.libXxf86vm.dev
          xorg.libXrandr
          xorg.libXrandr.dev
          xorg.xproto
          xorg.libXft
          xorg.libXft.dev
          fontconfig
          fontconfig.dev
          xorg.libXrender
          xorg.libXrender.dev
          xorg.renderproto
          bzip2
          bzip2.dev
          zeromq
          nanomsg
          protobuf
          protobuf.out
          libyamlcpp
          libyamlcpp.dev
          boost
          boost.dev
          vc
          lzma
          lzma.dev
          flatbuffers
          myCmake
          libxml2
          libxml2.dev
          libxml2.out
          openssl
          openssl.dev
          openssl.out
          texinfo
        ];
      };
  };
}
