{ wxGTK, lib, stdenv, fetchFromGitHub, cmake, mesa, zlib
, libX11, gettext, glew, glm, cairo, curl, openssl, boost, pkgconfig
, doxygen, pcre, libpthreadstubs, libXdmcp

, oceSupport ? true, opencascade_oce
, ngspiceSupport ? true, ngspice
, scriptingSupport ? true, swig, python, wxPython
}:

with lib;
stdenv.mkDerivation rec {
  name = "kicad-unstable-${version}";
  version = "2018-02-27";

  src = fetchFromGitHub {
    owner = "KICad";
    repo = "kicad-source-mirror";
    rev = "0d794b20bb5c308183cbd339be7a3dcf8a896d03";
    sha256 = "0c1rigr928xfpmxb9iv55rd4brjg0d95l8qbppa9ydix61l35pp6";
  };

  postPatch = ''
    substituteInPlace CMakeModules/KiCadVersion.cmake \
      --replace no-vcs-found ${version}
  '';

  cmakeFlags =
    optionals (oceSupport) [ "-DKICAD_USE_OCE=ON" "-DOCE_DIR=${opencascade_oce}" ]
    ++ optional (ngspiceSupport) "-DKICAD_SPICE=OFF"
    ++ optionals (scriptingSupport) [
      "-DKICAD_SCRIPTING=ON"
      "-DKICAD_SCRIPTING_MODULES=ON"
      "-DKICAD_SCRIPTING_WXPYTHON=ON"
      # nix installs wxPython headers in wxPython package, not in wxwidget
      # as assumed. We explicitely set the header location.
      "-DCMAKE_CXX_FLAGS=-I${wxPython}/include/wx-3.0"
    ];

  nativeBuildInputs = [ cmake doxygen  pkgconfig ];
  buildInputs = [
    mesa zlib libX11 wxGTK pcre libXdmcp gettext glew glm libpthreadstubs
    cairo curl openssl boost
  ] ++ optional (oceSupport) opencascade_oce
    ++ optional (ngspiceSupport) ngspice
    ++ optionals (scriptingSupport) [ swig python wxPython ];

  meta = {
    description = "Free Software EDA Suite, Nightly Development Build";
    homepage = http://www.kicad-pcb.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ berce ];
    platforms = with platforms; linux;
  };
}
