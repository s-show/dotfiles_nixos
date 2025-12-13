{ pkgs, lib }:

let
  # wasm32-wasip1 ターゲット付きの Rust ツールチェーン
  rustWithWasm = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-wasip1" ];
  };
  
  # カスタム rustPlatform を作成
  rustPlatformWasm = pkgs.makeRustPlatform {
    cargo = rustWithWasm;
    rustc = rustWithWasm;
  };
in
rustPlatformWasm.buildRustPackage rec {
  pname = "zellij-harpoon";
  version = "unstable-2024-09-05";

  src = pkgs.fetchFromGitHub {
    owner = "Nacho114";
    repo = "harpoon";
    rev = "main";
    # 初回は lib.fakeHash を使用
    # ビルドエラーから正しいハッシュをコピーして置き換える
    hash = "sha256-NwZWFIocBAXoPbqdKoyatG9XYIvJ2fLhfuHTRQNVqNk=";
  };

  # Cargo.lock から依存関係のハッシュを計算
  # 初回は lib.fakeHash を使用
  # ビルドエラーから正しいハッシュをコピーして置き換える
  cargoHash = "sha256-uL8g7bxb30/PVlTYg248H1d1tbn8m7KvluXhhyj8bp8=";

  # WASM ターゲットにビルド
  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    cargo build --release --target wasm32-wasip1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/zellij/plugins
    cp target/wasm32-wasip1/release/harpoon.wasm $out/share/zellij/plugins/
    runHook postInstall
  '';

  # テストはスキップ
  doCheck = false;

  meta = with lib; {
    description = "Zellij plugin to quickly navigate your panes (clone of nvim's harpoon)";
    homepage = "https://github.com/Nacho114/harpoon";
    license = licenses.mit;
    platforms = platforms.all;
  };
}

