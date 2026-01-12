# changes 1/12/25 ejf
# removed /4.3.1 from nix-eda (don't worry about gdsfactory sky130)
# removed 'edaPkgs.tclFull' from nix-eda packages
{
  description = "nix-efx: Open-source ASIC tool environment";

  # Define inputs with URLs
  inputs = {
    ciel.url = "github:fossi-foundation/ciel";
    nix-eda.url = "github:fossi-foundation/nix-eda";
  };

  # Define outputs using the inputs
  outputs = { self, nixpkgs, ciel, nix-eda, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      edaPkgs = nix-eda.packages.x86_64-linux;
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
            edaPkgs.klayout-gdsfactory
            edaPkgs.netgen
            edaPkgs.tk-x11
            edaPkgs.verilator
            edaPkgs.xschem
            edaPkgs.ngspice
            edaPkgs.bitwuzla
            edaPkgs.yosys
            edaPkgs.yosys-sby
            edaPkgs.yosys-eqy
            edaPkgs.yosys-lighter
            edaPkgs.yosys-ghdl
            edaPkgs.gdsfactory
            edaPkgs.gdstk
            edaPkgs.tclint

            # Packages from nixpkgs
            pkgs.iverilog
            pkgs.gtkwave
            pkgs.gtk3
            pkgs.libcanberra

            # Ciel tool
            ciel.packages.x86_64-linux.default
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
        shellHook = ''
          export LANG=en_US.UTF-8
          export LANGUAGE=en_US:en
          export LC_ALL=en_US.UTF-8
        '';
      };
    };
}

