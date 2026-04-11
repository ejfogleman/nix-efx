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
          ];
        };

        default = self.packages.x86_64-linux.allTools;
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

