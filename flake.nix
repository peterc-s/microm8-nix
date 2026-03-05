{
  description = "microM8 - Apple ][ Emulator";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};

      runtimeLibs = [
        pkgs.portaudio
        pkgs.libGL
        pkgs.libglvnd
        pkgs.libx11
        pkgs.libxcursor
        pkgs.libxrandr
        pkgs.libxinerama
        pkgs.libxi
        pkgs.libxxf86vm
        pkgs.stdenv.cc.cc.lib
      ];

      guiLibs = [
        pkgs.gtk2
        pkgs.glib
        pkgs.pango
        pkgs.gdk-pixbuf
        pkgs.cairo
        pkgs.atk
      ];

      microm8 = pkgs.stdenv.mkDerivation {
        pname = "microm8";
        version = "latest";

        src = pkgs.fetchzip {
          url = "https://paleotronic.com/download/microm8-linux.zip";
          hash = "sha256-XuNbPXQTOsgG85JnhdbYaYOc2JaUpgrvJbn5YCTxhPQ=";
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];

        buildInputs = runtimeLibs;

        dontBuild = true;
        dontConfigure = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 $src/microm8 $out/bin/microm8
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "microM8 - Apple II Emulator";
          homepage = "https://paleotronic.com/microm8";
          platforms = ["x86_64-linux"];
          mainProgram = "microm8";
          license = licenses.unfree;
        };
      };

      microm8-gui = pkgs.stdenv.mkDerivation {
        pname = "microm8-gui";
        version = "1.1";

        src = pkgs.fetchzip {
          url = "https://github.com/paleotronic/microm8-gui/releases/download/v1.1/microm8-gui-linux.zip";
          hash = "sha256-4v22kFzC9LQUuS+uktxk6oAC/timqe7VyPvkq5qGVn0=";
          stripRoot = false;
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];

        buildInputs = runtimeLibs ++ guiLibs;

        dontBuild = true;
        dontConfigure = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 $src/microm8 $out/bin/microm8
          install -Dm755 $src/microm8-gui $out/bin/microm8-gui
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "microM8 Apple II Emulator with GUI frontend";
          homepage = "https://github.com/paleotronic/microm8-gui";
          platforms = ["x86_64-linux"];
          mainProgram = "microm8-gui";
          license = licenses.unfree;
        };
      };
    in {
      packages = {
        inherit microm8 microm8-gui;
        default = microm8;
      };

      apps = {
        microm8 = {
          type = "app";
          program = "${microm8}/bin/microm8";
        };
        microm8-gui = {
          type = "app";
          program = "${microm8-gui}/bin/microm8-gui";
        };
        default = self.apps.${system}.microm8;
      };
    });
}
