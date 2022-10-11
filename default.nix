{ lib, stdenv, emscriptenStdenv
, fetchFromGitHub
, minisat, zlib
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

  buildInputs = [ minisat zlib ];

  configurePhase = ''
    make config prefix="$out" MINISAT_INCLUDE="-I${minisat}/include ${if targetEmscripten then "$NIX_CFLAGS_COMPILE" else ""}" MINISAT_LIB="${builtins.concatStringsSep " " (map (s: lib.escapeShellArg "-L${s}") buildInputs)} -lminisat"
  '';
  buildPhase = if targetEmscripten
    then ''
      emmake make static
    ''
    else ''
      emmake make
    '';
  installPhase = if targetEmscripten
    then ''
      emmake make install-static
    ''
    else ''
      emmake make install
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
