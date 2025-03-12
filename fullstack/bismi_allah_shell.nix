# بسم الله الرحمن الرحيم
# la ilaha illa Allah Mohammed Rassoul Allah
with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "sveltekit-jetzig";
  buildInputs = with pkgs; [
    nodejs_22
    zig_0_14
  ];

  shellHook = ''
    npm config set prefix ~/.cache/npm/modules/
  '';
}
