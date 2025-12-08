{
  description = "nix-efx: Open-source ASIC tool environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    ciel.url = "github:fossi-foundation/ciel";
    nix-eda.url = "github:fossi-foundation/nix-eda/4.3.1";
  };

  outputs = { self, nixpkgs, ciel, nix-eda, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      edaPkgs = nix-eda.packages.x86_64-linux;
    in {
      packages.x86_64-linux = {
        ciel = ciel.packages.x86_64-linux.ciel;
        # Inherit all available tools from nix-eda 4.3.1
        inherit (edaPkgs) magic klayout klayout-gdsfactory netgen tclFull tk-x11 iverilog verilator xschem ngspice bitwuzla yosys yosys-sby yosys-eqy yosys-lighter yosys-slang yosys-ghdl gdsfactory gdstk tclint;
        default = self.packages.x86_64-linux.ciel;
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "efx_tools_dev_shell";
        buildInputs = [
          self.packages.x86_64-linux.ciel
          edaPkgs.magic
          edaPkgs.klayout
          edaPkgs.klayout-gdsfactory
          edaPkgs.netgen
          edaPkgs.tclFull
          edaPkgs.tk-x11
          edaPkgs.iverilog
          edaPkgs.verilator
          edaPkgs.xschem
          edaPkgs.ngspice
          edaPkgs.bitwuzla
          edaPkgs.yosys
          edaPkgs.yosys-sby
          edaPkgs.yosys-eqy
          edaPkgs.yosys-lighter
          edaPkgs.yosys-slang
          edaPkgs.yosys-ghdl
          edaPkgs.gdsfactory
          edaPkgs.gdstk
          edaPkgs.tclint
        ];
      };
    };
}

