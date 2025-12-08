# nix-efx: Open-source IC design tools

Utilizes [fossi-foundation/nix-eda](https://github.com/fossi-foundation/nix-eda) with some modifications
* Adds 'ciel'
* sky130-compatible klayout 
* Other tools at latest version

# Initial setup

1. Install nix in single-user mode

    `sh <(curl -L https://nixos.org/nix/install) --no-daemon`
        - `--no-daemon` = single-user mode
        - Installs everything under your home directory (~/.nix-profile and ~/.nix)

2. Update your shell environment

    After installation, either log out and log back in, or source the profile manually:

    `. ~/.nix-profile/etc/profile.d/nix.sh`

    This sets $PATH and other environment variables so Nix commands are available.

3. Enable experimental features for flakes

    Edit or create the config:
    ```
    mkdir -p ~/.config/nix
    vi ~/.config/nix/nix.conf
    ```

    Add: `experimental-features = nix-command flakes`

# Installation

1. Clone `nix-efx` to home directory.
2. `cd nix-efx`
3. `nix shell .`

