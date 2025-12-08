# nix-efx: Open-source IC design tools

Utilizes [fossi-foundation/nix-eda](https://github.com/fossi-foundation/nix-eda) with some modifications
* Adds 'ciel', 'iverilog', 'gtkwave'
* Uses `github:fossi-foundation/nix-eda/4.3.1` for sky130-compatible klayout 

# Initial setup (assuming nix is not installed)

1. Install nix in single-user mode:
    ```
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    ```
    single-user mode; does not require root after installation

2. Update your shell environment

    After installation, either log out and log back in, or source the profile manually:
    ```
    . ~/.nix-profile/etc/profile.d/nix.sh
    ```
    This sets $PATH and other environment variables so Nix commands are available.

3. Enable "experimental features" so nix will recognize flakes.

    Edit or create the config:
    ```
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    ```

# Installation of nix-efx

1. Clone `nix-efx` to home directory:
    ```
    cd ~
    git clone https://github.com/ejfogleman/nix-efx.git
    ```
2. `cd nix-efx`
3. Either `nix shell .` or `nix develop` will give you a shell with the tools

