# changes 1/12/25 ejf
# removed /4.3.1 from nix-eda (don't worry about gdsfactory sky130)
# removed 'edaPkgs.tclFull' from nix-eda packages
# added xschem-gaw for analog waveform viewing with xschem
{
  description = "nix-efx: Open-source ASIC tool environment";

  # Define inputs with URLs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";  # or 'unstable'

    ciel.url = "github:fossi-foundation/ciel";

    nix-eda = {
      url = "github:fossi-foundation/nix-eda";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Define outputs using the inputs
  outputs = { self, nixpkgs, ciel, nix-eda, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      edaPkgs = nix-eda.packages.x86_64-linux;

      # Custom package: xschem-gaw (GTK Analog Wave viewer)
      xschem-gaw = pkgs.stdenv.mkDerivation rec {
        pname = "xschem-gaw";
        version = "20200922";

        src = pkgs.fetchFromGitHub {
          owner = "StefanSchippers";
          repo = "xschem-gaw";
          rev = "6b8fa4ab007e88b3129381e0479737ae014a8b51";  # latest commit (Mar 28, 2025)
          sha256 = "sha256-rZ0XsMfctZAbfLswVMzcginR6bHG5lY9qG/xyfF/ooM=";  # updated after first build
        };

        nativeBuildInputs = with pkgs; [
          autoreconfHook
          pkg-config
        ];

        buildInputs = with pkgs; [
          gtk3
          alsa-lib
          gettext
        ];

        configureFlags = [
          "--enable-gawsound=yes"
        ];

        meta = with pkgs.lib; {
          description = "GTK Analog Wave viewer - fork with xschem integration patches";
          homepage = "https://github.com/StefanSchippers/xschem-gaw";
          license = licenses.gpl2Plus;
          platforms = platforms.linux;
        };
      };

      # Custom package: ciccreator (Custom IC Creator - cic/cic-gui)
      ciccreator = pkgs.stdenv.mkDerivation {
        pname = "ciccreator";
        version = "0.1.5";

        src = pkgs.fetchFromGitHub {
          owner = "wulffern";
          repo = "ciccreator";
          rev = "85f470946531f1e794cc431a7cfaf09e528b3485";  # latest master (Aug 2026)
          hash = "sha256-1ZuTjNKPFf52nakKfHhqq05XWUfvmYDeI3E5yE89oZ0=";
        };

        nativeBuildInputs = [ pkgs.qt6.qmake pkgs.qt6.wrapQtAppsHook ];
        buildInputs = [ pkgs.qt6.qtbase ];

        # Upstream's Makefile stamps this via `git describe`, which isn't
        # available from a fetchFromGitHub source tree (no .git dir).
        postPatch = ''
          printf '#define CICVERSION "0.1.5+ nix"\n#define CICHASH ""\n' > cic/src/version.h
          printf '#define CICVERSION "0.1.5+ nix"\n#define CICHASH ""\n' > cic-gui/src/version.h
        '';

        qmakeFlags = [ "ciccreator.pro" ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          install -Dm755 bin/linux/cic $out/bin/cic
          install -Dm755 bin/linux/cic-gui $out/bin/cic-gui
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Custom IC Creator: compiles a JSON object definition + SPICE + design rules into layout (JSON or GDS)";
          homepage = "https://github.com/wulffern/ciccreator";
          license = licenses.gpl3Plus;
          platforms = platforms.linux;
          mainProgram = "cic";
        };
      };

      # Custom package: cicspi (dependency of cicpy, PyPI-only, no nixpkgs entry)
      cicspi = pkgs.python3.pkgs.buildPythonPackage rec {
        pname = "cicspi";
        version = "0.1.4";
        format = "wheel";

        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/a4/b3/6d33e3e78d52b8ba7e580c96946a0bfda029897846adf5e56c12b6d7288d/${pname}-${version}-py3-none-any.whl";
          sha256 = "405e81285eea5f14df469fa6448199467b0f725c94be90ddbdb98ae70643a073";
        };

        propagatedBuildInputs = [ pkgs.python3.pkgs.click ];
        doCheck = false;
      };

      # Custom package: cicpy (Custom IC Creator Python frontend, PyPI-only)
      cicpy = pkgs.python3.pkgs.buildPythonApplication rec {
        pname = "cicpy";
        version = "0.1.10";
        format = "wheel";

        src = pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/2d/d4/e4dfbe822624d2b55bfce3e421ca219a7968ca3dcf7f2874b4d972b9d8f3/${pname}-${version}-py3-none-any.whl";
          sha256 = "092502de202c8eaa45fb32fbb63c2e341136d311f7c5963e883f8472e72267fc";
        };

        propagatedBuildInputs = with pkgs.python3.pkgs; [
          numpy
          pandas
          svgwrite
          click
          pyyaml
          matplotlib
          cicspi
        ];

        doCheck = false;

        meta = with pkgs.lib; {
          description = "Custom IC Creator Python frontend (cicpy)";
          homepage = "https://github.com/wulffern/cicpy";
          license = licenses.mit;
          platforms = platforms.linux;
          mainProgram = "cicpy";
        };
      };

    in {

      # ---------------------------
      # Meta-package for `nix shell .`
      # ---------------------------
      packages.x86_64-linux = {
        allTools = pkgs.buildEnv {
          name = "efx_all_tools";
          paths = [
            # nix-eda packages
            edaPkgs.magic
            # edaPkgs.klayout-gdsfactory  # broken!
            edaPkgs.klayout
            edaPkgs.netgen
            edaPkgs.tk-x11
            (edaPkgs.verilator.overrideAttrs (_: {
              doCheck = false;
            }))
            edaPkgs.xschem
            edaPkgs.bitwuzla
            edaPkgs.yosys
            edaPkgs.yosys-sby
            edaPkgs.yosys-eqy
            edaPkgs.yosys-lighter
            edaPkgs.yosys-ghdl
            # edaPkgs.gdsfactory  # broken!
            edaPkgs.gdstk
            edaPkgs.tclint

            # Packages from nixpkgs
            pkgs.iverilog
            pkgs.gtkwave
            pkgs.gtk3
            pkgs.libcanberra
            pkgs.ngspice

            # Ciel tool
            ciel.packages.x86_64-linux.default

            # Custom packages
            xschem-gaw
            ciccreator
            cicpy
          ];
        };

        default = self.packages.x86_64-linux.allTools;

        inherit xschem-gaw ciccreator cicpy;
      };

      # ---------------------------
      # Smoke tests for locally-built custom packages
      # (upstream nix-eda/nixpkgs/ciel packages are already built and
      # tested by their own flakes, so they're not re-tested here)
      # Run with `nix flake check`.
      # ---------------------------
      checks.x86_64-linux = {
        # gaw is a pure GTK app with no non-interactive --help/--version
        # mode, so the meaningful check is "does it link cleanly" rather
        # than "does it run" (no display is available in the sandbox).
        xschem-gaw-smoke = pkgs.runCommand "xschem-gaw-smoke-test" { } ''
          set -euo pipefail
          test -x ${xschem-gaw}/bin/gaw
          missing=$(${pkgs.glibc.bin}/bin/ldd ${xschem-gaw}/bin/gaw | grep "not found" || true)
          if [ -n "$missing" ]; then
            echo "Unresolved shared libraries for gaw:" >&2
            echo "$missing" >&2
            exit 1
          fi
          touch $out
        '';

        ciccreator-smoke = pkgs.runCommand "ciccreator-smoke-test" { } ''
          set -euo pipefail
          ${ciccreator}/bin/cic ${ciccreator.src}/examples/routes.json ${ciccreator.src}/examples/tech.json routes
          test -s routes.cic
          touch $out
        '';

        cicpy-smoke = pkgs.runCommand "cicpy-smoke-test" { } ''
          set -euo pipefail
          ${cicpy}/bin/cicpy --help
          touch $out
        '';
      };

      # ---------------------------
      # Dev shell for `nix develop`
      # ---------------------------
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "efx_tools_dev_shell";

        buildInputs = [
          self.packages.x86_64-linux.allTools
        ];

        # Set proper locales for GTK
          # Use the installed locale
        shellHook = ''
            unset LC_ALL
            export LANG=en_US.utf8
            export LANGUAGE=en_US:en

        # Set prompt manually
        export PS1="[nix-efx] \u@\h:\w\$ "
        '';
      };
    };
}

