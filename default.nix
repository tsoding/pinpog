with import <nixpkgs> {}; rec {
  pinpogEnv = stdenv.mkDerivation {
    name = "pingpog-env";
    buildInputs = [ nasm qemu gdb ];
  };
}
