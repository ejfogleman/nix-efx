{
  description = "nix-efx: Open-source ASIC tool environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    ciel.url = "github:fossi-foundation/ciel";
    nix-eda.url = "github:fossi-foundation/nix-eda";
    # Pin klayout-gdsfactory at v4.3.1
    klayout-gdsfactory.url = "github:fossi-foundation/klayout-gdsfactory?ref=v4.3.1";
  };

  outputs = { self, nixpkgs, ciel, nix-eda, klayout-gdsfactory, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      edaPkgs = nix-eda.packages.x86_64-linux;
      klayoutGdsfactory = klayout-gdsfactory.packages.x86_64-linux.default;
    in {
      packages.x86_64-linux = {
        ciel = ciel.packages.x86_64-linux.ciel;
        # Expose all tools from nix-eda and klayout-gdsfactory pinned version
        klayout-gdsfactory = klayoutGdsfactory;
        # Forward all packages from nix-eda
        inherit (edaPkgs) magic magic-vlsi netgen klayout tclFull tk-x11 iverilog verilator xschem ngspice bitwuzla yosys yosys-sby yosys-eqy yosys-lighter yosys-slang yosys-ghdl gdsfactory gdstk tclint;
        default = self.packages.x86_64-linux.ciel;
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "efx_tools_dev_shell";
        buildInputs = [
          self.packages.x86_64-linux.ciel
          # Main EDA tools (excluding klayout-gdsfactory)
          edaPkgs.magic
          edaPkgs.magic-vlsi
          edaPkgs.netgen
          edaPkgs.klayout
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
          klayoutGdsfactory
        ];
      };
    };
}

