{lib, fetchPypi, buildPythonPackage, ipykernel, pexpect}:

buildPythonPackage rec {
  pname = "metakernel";
  version = "0.20.14";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0b5dl86470s57qsznp7ldv9fz81nshadak19rvjrzwgx96x05zvv";
  };

  propagatedBuildInputs = [
    ipykernel
    pexpect
  ];

  doCheck = false;

  meta = with lib; {
    homepage = https://github.com/Calysto/metakernel;
    description = "Jupyter/IPython Kernel Tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [];
  };
}
