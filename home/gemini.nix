{ pkgs ? import <nixpkgs> {} }:

pkgs.buildNpmPackage rec {
  pname = "gemini-cli";
  version = "0.17.1";

  src = pkgs.fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "sha256-zfORrAMVozHiUawWiy3TMT+pjEaRJ/DrHeDFPJiCp38=";
  };

  npmDepsHash = "sha256-dKaKRuHzvNJgi8LP4kKsb68O5k2MTqblQ+7cjYqLqs0=";

  nodejs = pkgs.nodejs_22;

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.libsecret ];

  dontNpmBuild = true;
  dontCheckForBrokenSymlinks = true;

  # インストール後に実行ファイルのリンク先をバンドル版に書き換える
  postInstall = ''
    # デフォルトで作られたリンク（dist/src/gemini.js を向いている）を削除
    rm $out/bin/gemini

    # バンドル版（bundle/gemini.js）へのシンボリックリンクを作成
    ln -s $out/lib/node_modules/@google/gemini-cli/bundle/gemini.js $out/bin/gemini
  '';

  meta = with pkgs.lib; {
    description = "An open-source AI agent that brings the power of Gemini directly into your terminal.";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    mainProgram = "gemini";
  };
}
