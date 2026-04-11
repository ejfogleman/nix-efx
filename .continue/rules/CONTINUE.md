# nix-efx Project Guide

## Project Overview

**nix-efx** is an open-source integrated circuit (IC) design tool environment built on top of the Nix package manager. It provides a reproducible, declarative development environment for ASIC (Application-Specific Integrated Circuit) design workflows.

### Purpose
This project creates a comprehensive, batteries-included environment for digital IC design by bundling essential open-source EDA (Electronic Design Automation) tools. It eliminates the complexity of managing dependencies and tool installations, providing a consistent development environment across different machines.

### Key Technologies
- **Nix Flakes**: Modern Nix feature for reproducible package management
- **nix-eda**: Foundation from fossi-foundation providing core EDA tools
- **Ciel**: Integrated EDA tool from fossi-foundation
- **Platform**: Linux x86_64

### Architecture
The project is structured as a Nix flake that:
1. Pulls in dependencies from nixpkgs, nix-eda, and ciel
2. Bundles EDA tools into a single meta-package (`allTools`)
3. Provides both a shell environment (`nix shell`) and development shell (`nix develop`)
4. Ensures all tools work together harmoniously with proper dependencies

### Included Tools
**Synthesis & Verification:**
- Yosys (synthesis framework)
- Yosys-SBY (formal verification)
- Yosys-EQY (equivalence checking)
- Verilator (fast simulator)
- Bitwuzla (SMT solver)

**Simulation:**
- Icarus Verilog (iverilog)
- GTKWave (waveform viewer)
- ngspice (circuit simulator)

**Layout & Physical Design:**
- Magic (VLSI layout tool)
- KLayout (GDS viewer/editor)
- Netgen (LVS tool)
- GDSTK (GDS manipulation library)

**Schematic & Design:**
- Xschem (schematic editor)

**Supporting Tools:**
- Ciel (EDA framework)
- TCL tools (tk-x11, tclint)
- GTK3 libraries for GUI support

## Getting Started

### Prerequisites

**Required:**
- A Linux system (x86_64 architecture)
- Approximately 2-5 GB of disk space for tools
- Internet connection for initial download

**Nix Installation:**
If you don't have Nix installed, you'll need to install it first (see Installation step 1 below).

### Installation

#### 1. Install Nix (Single-User Mode)

If Nix is not already installed:

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

**Note:** Single-user mode is recommended as it doesn't require root access after installation.

#### 2. Configure Your Shell

Add Nix to your shell profile for automatic loading. Edit `~/.bashrc`:

```bash
# Load Nix profile for single-user installation
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
```

Activate the changes:
```bash
source ~/.bashrc
```

Or start a new terminal session.

#### 3. Enable Nix Flakes

Nix flakes are an experimental feature that must be explicitly enabled:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

#### 4. Clone nix-efx

```bash
cd ~
git clone https://github.com/ejfogleman/nix-efx.git
cd nix-efx
```

### Basic Usage

#### Option A: Temporary Shell (`nix shell`)
For quick access to tools without development environment setup:

```bash
cd ~/nix-efx
nix shell .
```

This gives you access to all EDA tools in your current shell session.

#### Option B: Development Shell (`nix develop`)
For a more permanent development environment with custom shell configuration:

```bash
cd ~/nix-efx
nix develop
```

This provides:
- All EDA tools available
- Custom shell prompt: `[nix-efx] user@host:path$`
- Proper locale settings for GTK applications

### Verifying Installation

Test that tools are available:

```bash
# Check Yosys
yosys -V

# Check Icarus Verilog
iverilog -v

# Check Magic
magic -noconsole --version

# Check GTKWave
gtkwave --version
```

### Running Tests

*Note: This project currently doesn't include a test suite as it's primarily a packaging/distribution project. Testing should be done on your actual IC design projects using these tools.*

## Project Structure

```
nix-efx/
├── flake.nix           # Main Nix flake configuration
├── flake.lock          # Locked dependency versions
├── README.md           # User-facing documentation
├── LICENSE             # Project license
├── .gitignore          # Git ignore patterns
└── .continue/
    └── rules/
        └── CONTINUE.md # This file
```

### Key Files

#### `flake.nix`
The heart of the project. Defines:
- **Inputs**: Dependencies from nixpkgs, nix-eda, and ciel
- **Outputs**: 
  - `packages.x86_64-linux.allTools`: Meta-package bundling all tools
  - `packages.x86_64-linux.default`: Alias to allTools
  - `devShells.x86_64-linux.default`: Development shell environment

#### `flake.lock`
Auto-generated file that locks all dependency versions for reproducibility. Ensures everyone gets the exact same tool versions.

#### `.gitignore`
Configured to ignore:
- Nix build artifacts (`/result`, `/.direnv`)
- Python cache files (for potential scripts)
- Editor-specific files (VSCode, Vim, IntelliJ)
- System files (macOS, Windows)

## Development Workflow

### Making Changes to the Flake

#### Adding a New Tool

1. Identify the tool source:
   - Is it in nixpkgs? Use `pkgs.toolname`
   - Is it in nix-eda? Use `edaPkgs.toolname`
   - Is it external? Add a new flake input

2. Add to the `paths` list in `allTools`:
   ```nix
   paths = [
     # ... existing tools ...
     pkgs.newtool  # or edaPkgs.newtool
   ];
   ```

3. Test the change:
   ```bash
   nix flake lock --update-input nixpkgs  # if needed
   nix develop
   # Verify the tool is available
   ```

#### Removing a Tool

Simply remove the line from the `paths` list in `flake.nix`.

#### Updating Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input nix-eda
nix flake lock --update-input ciel
```

### Version Control Guidelines

- Commit `flake.lock` to ensure reproducibility
- Document significant tool additions/removals in commit messages
- Update README.md when adding major new capabilities

### Coding Standards

While this isn't a code-heavy project, Nix style guidelines apply:
- Use 2-space indentation
- Keep expressions readable with appropriate line breaks
- Comment non-obvious overrides or workarounds
- Follow Nix naming conventions (camelCase for variables)

## Key Concepts

### Nix Flakes
A flake is a Nix package that:
- Has a `flake.nix` file describing inputs and outputs
- Uses `flake.lock` for reproducible builds
- Can be referenced by other flakes via URL

### Meta-packages
A meta-package (created with `buildEnv`) doesn't build software itself but bundles multiple packages together. `allTools` is a meta-package that combines all EDA tools.

### Package Overrides
Some packages require modifications:
- **Verilator**: `doCheck = false` override disables tests (they may fail in some environments)
- Tools are sourced from specific providers (nix-eda vs nixpkgs) to ensure compatibility

### Development Shells
`mkShell` creates an environment with:
- All specified tools in PATH
- Custom environment variables
- Shell hooks for setup (locale, prompt)

### Architecture Specificity
The flake explicitly targets `x86_64-linux`. To support other architectures (ARM, macOS), additional outputs would be needed.

### EDA Tool Categories

**Frontend (RTL to Netlist):**
- Yosys: RTL synthesis
- Verilator: Fast simulation
- Icarus Verilog: Event-driven simulation

**Backend (Netlist to Layout):**
- Magic: Layout editing and DRC
- KLayout: GDS viewing and manipulation
- Netgen: Layout vs Schematic verification

**Verification:**
- SBY, EQY: Formal verification
- Bitwuzla: SMT solving for formal proofs
- ngspice: Analog simulation

## Common Tasks

### Task: Starting a New IC Design Project

1. Enter the nix-efx environment:
   ```bash
   cd ~/nix-efx
   nix develop
   ```

2. Create your project directory (outside nix-efx):
   ```bash
   mkdir ~/my-chip-design
   cd ~/my-chip-design
   ```

3. Create your Verilog source file:
   ```bash
   vim design.v
   ```

4. Verify with iverilog:
   ```bash
   iverilog -o design.out design.v testbench.v
   vvp design.out
   gtkwave dump.vcd
   ```

### Task: Synthesizing RTL with Yosys

```bash
# Create a simple synthesis script
cat > synth.ys <<EOF
read_verilog design.v
hierarchy -check
proc
opt
techmap
opt
write_verilog synth_design.v
EOF

# Run synthesis
yosys synth.ys
```

### Task: Viewing GDS Layout

```bash
klayout design.gds
# or
magic design.gds
```

### Task: Running Formal Verification

```bash
# Create an SBY configuration file
cat > design.sby <<EOF
[options]
mode prove

[engines]
smtbmc bitwuzla

[script]
read -formal design.v
prep -top design

[files]
design.v
EOF

# Run verification
sby design.sby
```

### Task: Creating a Schematic

```bash
xschem
# Use the GUI to create and edit schematics
```

### Task: Updating Tools to Latest Versions

```bash
cd ~/nix-efx
nix flake update
nix develop  # Rebuild with new versions
```

### Task: Checking Available Tool Versions

```bash
nix flake show  # Show flake outputs
nix search nixpkgs iverilog  # Search for packages
```

## Troubleshooting

### Issue: "error: experimental Nix feature 'flakes' is disabled"

**Solution:**
Enable flakes in your Nix configuration:
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Issue: GTK applications crash or show warnings

**Symptoms:**
```
Gtk-WARNING **: Locale not supported by C library
```

**Solution:**
The `devShell` already includes locale configuration. If issues persist:
```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

### Issue: "error: attribute 'packages.x86_64-linux' missing"

**Cause:** You're likely on a different architecture (ARM, macOS, etc.)

**Solution:**
This flake currently only supports x86_64-linux. To add support for other systems, the flake.nix would need to be modified to include additional architecture outputs.

### Issue: Tools are slow to load on first run

**Explanation:**
Nix downloads and builds tools on first use. Subsequent runs use cached builds.

**Solution:**
Be patient on first run. Consider:
```bash
nix build .#allTools  # Pre-build everything
```

### Issue: "error: getting status of '/nix/store/...': No such file or directory"

**Cause:** Corrupted Nix store or interrupted build

**Solution:**
```bash
nix-store --verify --check-contents
nix-collect-garbage
nix develop  # Retry
```

### Issue: Magic or KLayout won't start in GUI mode

**Symptoms:**
```
Error: Cannot open display
```

**Solution:**
Ensure you're running in a graphical environment (not SSH without X forwarding):
```bash
# For SSH, enable X forwarding
ssh -X user@host

# Or set DISPLAY
export DISPLAY=:0
```

### Issue: Version conflicts after updating

**Symptoms:**
Tools behave differently or fail after `nix flake update`

**Solution:**
Roll back to previous working version:
```bash
git checkout flake.lock  # Revert to committed version
```

Or pin to specific version by editing inputs in `flake.nix`:
```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";  # Specific release
```

## Debugging Tips

### Verbose Build Output
```bash
nix develop --print-build-logs
```

### Check What's in Your Environment
```bash
nix develop --command which yosys
nix develop --command env | grep PATH
```

### Test Individual Packages
```bash
nix build .#packages.x86_64-linux.allTools
ls -la result/bin/
```

### Inspect Flake Metadata
```bash
nix flake metadata
nix flake show
```

## References

### Official Documentation
- **Nix Manual**: https://nixos.org/manual/nix/stable/
- **Nix Flakes**: https://nixos.wiki/wiki/Flakes
- **nix-eda**: https://github.com/fossi-foundation/nix-eda
- **Ciel**: https://github.com/fossi-foundation/ciel

### EDA Tool Documentation
- **Yosys**: https://yosyshq.net/yosys/
- **Icarus Verilog**: http://iverilog.icarus.com/
- **Magic**: http://opencircuitdesign.com/magic/
- **KLayout**: https://www.klayout.de/
- **Xschem**: https://xschem.sourceforge.io/stefan/index.html
- **GTKWave**: http://gtkwave.sourceforge.net/
- **Verilator**: https://verilator.org/
- **ngspice**: http://ngspice.sourceforge.net/

### Community Resources
- **FOSSi Foundation**: https://www.fossi-foundation.org/
- **Nix Community**: https://discourse.nixos.org/
- **EDA Open Source**: https://github.com/hdl

### Related Projects
- **OpenLane**: Complete RTL to GDSII flow
- **OpenROAD**: Open-source RTL-to-GDSII platform
- **SkyWater PDK**: Open-source 130nm process design kit

## Project-Specific Notes

### Recent Changes (as of 1/12/25)
- Removed version pin (`/4.3.1`) from nix-eda
- Removed `edaPkgs.tclFull` from package list
- Using nixos-24.11 stable release

### Known Issues
- `gdsfactory` and `klayout-gdsfactory` are currently broken/disabled
- Verilator tests disabled due to potential environment incompatibilities
- Currently only supports x86_64-linux architecture

### Future Considerations
- Multi-architecture support (ARM, macOS via darwin)
- Integration with SkyWater PDK
- Additional simulation tools
- Python-based EDA tools integration
- Container/Docker image generation

---

**Last Updated:** Generated from codebase analysis
**Maintainer:** ejfogleman (https://github.com/ejfogleman)
**License:** See LICENSE file in repository root
