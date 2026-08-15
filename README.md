# nix-efx: Open-source IC design tools

Utilizes [fossi-foundation/nix-eda](https://github.com/fossi-foundation/nix-eda) with some modifications
* Adds 'ciel', 'iverilog', 'gtkwave', 'xschem-gaw', 'ciccreator', 'cicpy'
* Uses `github:fossi-foundation/nix-eda/4.3.1` for sky130-compatible klayout 

# Initial setup (assuming nix is not installed)

1. Install nix in single-user mode:
    ```bash
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    ```
    single-user mode; does not require root after installation

2. Update your shell environment

    Add Nix to your shell automatically by editing ~/.bashrc:
    ```bash
    # Load Nix profile for single-user installation
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    ```

    This ensures `$PATH` and other environment variables are set for all new Bash sessions.

    After adding this, either start a new terminal or run:
    ```bash
    source ~/.bashrc
    ```

to activate Nix in your current session.

3. Enable "experimental features" so nix will recognize flakes.

    Edit or create the config:
    ```bash
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    ```

# Installation of nix-efx

1. Clone `nix-efx` to home directory:
    ```bash
    cd ~
    git clone https://github.com/ejfogleman/nix-efx.git
    ```
2. `cd nix-efx`
3. Either `nix shell .` or `nix develop` will give you a shell with the tools

