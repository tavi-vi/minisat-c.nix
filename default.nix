{ lib, stdenv, emscriptenStdenv, fetchFromGitHub
, pkg-config
, minisat, zlib
, emscriptenPackages
, targetEmscripten ? false }:

(if targetEmscripten
  then emscriptenStdenv
  else stdenv).mkDerivation rec {

  pname = "minisat-c-bindings";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "niklasso";
    repo = pname;
    rev = "2f137cbedc7a1a0ecd4117baaf84a005c2045134";
    sha256 = "sha256-GGym3p4f+wMjfAHvEV1PYLau4TR5/D3baSYu7IXOHdw=";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = if targetEmscripten
    then [ emscriptenPackages.zlib emscriptenPackages.minisat ]
    else [ minisat zlib.dev ];

  CXXFLAGS = "-iquote ${minisat}/include";
  LDFLAGS = "-L${minisat}/lib";

  configurePhase = ''
    CXXFLAGS="$CXXFLAGS `pkg-config zlib --cflags`"
    LDFLAGS="$LDFLAGS `pkg-config zlib --libs`"
    make config prefix="$out" MBINDC_LDFLAGS="$LDFLAGS -lminisat"
  '';
  buildPhase = if targetEmscripten
    then ''
      emmake make static
    ''
    else ''
      make
    '';
  installPhase = if targetEmscripten
    then ''
      emmake make install-static
    ''
    else ''
      make install
    '';
  checkPhase = "";

  meta = with lib; {
    description = "Compact and readable SAT solver";
    maintainers = with maintainers; [ gebner raskin ];
    platforms = platforms.unix;
    license = licenses.mit;
    homepage = "http://minisat.se/";
  };
}
