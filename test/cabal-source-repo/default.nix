{ stdenv, cabalProject', recurseIntoAttrs, haskellLib, testSrc }:

with stdenv.lib;

let
  project = cabalProject' {
    index-state = "2020-05-25T00:00:00Z";
    src = testSrc "cabal-source-repo";
  };
  packages = project.hsPkgs;
in recurseIntoAttrs {
  ifdInputs = {
    inherit (project) plan-nix;
  };
  run = stdenv.mkDerivation {
    name = "call-cabal-project-to-nix-test";

    buildCommand = ''
      exe="${packages.use-cabal-simple.components.exes.use-cabal-simple}/bin/use-cabal-simple${stdenv.hostPlatform.extensions.executable}"

      printf "checking whether executable runs... " >& 2
      cat ${haskellLib.check packages.use-cabal-simple.components.exes.use-cabal-simple}

      touch $out
    '';

    meta.platforms = platforms.all;

    passthru = {
      # Attributes used for debugging with nix repl
      inherit packages;
    };
  };
}
