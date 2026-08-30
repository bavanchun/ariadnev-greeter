# ADVS Greeter

> **Attribution** — AriadnevGreeter is derived from
> [dank-greeter](https://github.com/AvengeMedia/dank-greeter) by Avenge Media LLC,
> used under the MIT License. The original copyright notice is retained in `LICENSE`.
> This is an independent fork, not affiliated with or endorsed by Avenge Media.
> Distro packaging under `distro/` still points at upstream build-service accounts
> (COPR/PPA/OBS) and needs new accounts before it can run.

<div align="center">
  <a href="https://ariadnev.vchun.dev">
    <img src="assets/advlogo.svg" alt="ADVS Greeter" width="200">
  </a>

### A greetd login screen with the Adv Material aesthetic

Built with [Quickshell](https://quickshell.org/) and [Go](https://go.dev/)

[![Documentation](https://img.shields.io/badge/docs-ariadnev.vchun.dev-9ccbfb?style=for-the-badge&labelColor=101418)](https://ariadnev.vchun.dev/docs/advgreeter)
[![GitHub stars](https://img.shields.io/github/stars/bavanchun/ariadnev-greeter?style=for-the-badge&labelColor=101418&color=ffd700)](https://github.com/bavanchun/ariadnev-greeter/stargazers)
[![GitHub License](https://img.shields.io/github/license/bavanchun/ariadnev-greeter?style=for-the-badge&labelColor=101418&color=b9c8da)](https://github.com/bavanchun/ariadnev-greeter/blob/master/LICENSE)
[![AUR version (git)](<https://img.shields.io/aur/version/greetd-advs-greeter-git?style=for-the-badge&labelColor=101418&color=9ccbfb&label=AUR%20(git)>)](https://aur.archlinux.org/packages/greetd-advs-greeter-git)
[![Discord](https://img.shields.io/badge/discord-join?style=for-the-badge&logo=discord&logoColor=ffffff&label=discord&labelColor=101418&color=5865f2)](https://discord.gg/ppWTpKmPgT)
[![Ko-Fi donate](https://img.shields.io/badge/donate-kofi?style=for-the-badge&logo=ko-fi&logoColor=ffffff&label=ko-fi&labelColor=101418&color=f16061&link=https%3A%2F%2Fko-fi.com%2Fariadnev)](https://ko-fi.com/ariadnev)

</div>

ADVS Greeter is a login screen for [greetd](https://github.com/kennylevinsen/greetd) that looks and behaves like the [AriadnevShell](https://github.com/bavanchun/AriadnevShell) lock screen. It ships as a single `advs-greeter` binary with the Quickshell UI embedded, runs under niri, Hyprland, Sway, Scroll, Miracle WM, labwc, or MangoWC, and syncs your ADVS theme, wallpaper, and settings so the login screen matches your desktop.

## Repository Structure

This is a monorepo containing both the greeter interface and the core backend:

```
ariadnev-greeter/
├── quickshell/         # QML-based greeter interface
│   ├── Modules/Greetd/ # Login screen, user picker, session selection
│   ├── Services/       # Read-only status (network, battery, audio, weather)
│   ├── Widgets/        # Adv UI controls
│   ├── Common/         # Shared resources, themes, and i18n
│   ├── AdvCommon/     # → symlink into the ariadnev-qml-common submodule
│   └── translations/   # POEditor-managed string catalogs
├── ariadnev-qml-common/    # Shared ADVS widget library (git submodule)
├── core/               # Go backend and CLI
│   ├── cmd/advs-greeter/# CLI entrypoint and greeter launcher
│   └── internal/       # Compositor launcher, greetd config, sync, PAM
├── distro/             # Distribution packaging + NixOS module
├── assets/             # sysusers/tmpfiles, AppArmor profile, sample configs
└── Makefile            # Build, install, and dev targets
```

## Installation

### Arch Linux (AUR)

```bash
yay -S greetd-advs-greeter-git
```

### Debian / openSUSE

Official packages are available from the [AdvLinux OBS repository](https://software.opensuse.org/download/package?package=advs-greeter&project=home%3Abavanchun%3Aariadnev). Add the repo for your distribution, then install **`advs-greeter`** (stable) or **`advs-greeter-git`** (master; Conflicts with stable):

```bash
# Debian 13
sudo apt install advs-greeter
# sudo apt install advs-greeter-git

# openSUSE Tumbleweed
zypper install advs-greeter
# zypper install advs-greeter-git
```

Ubuntu uses the same package names from [`ppa:avengemedia/ariadnev`](https://launchpad.net/~avengemedia/+archive/ubuntu/ariadnev). See the [Installation guide](https://ariadnev.vchun.dev/docs/advgreeter/installation) for full repository setup.

### Fedora / RHEL / Rocky / Alma

```bash
sudo dnf copr enable avengemedia/ariadnev
sudo dnf install advs-greeter
```

For the latest development build from `master` (Conflicts with the stable package):

```bash
sudo dnf copr enable avengemedia/ariadnev
sudo dnf install advs-greeter-git
```

### Void Linux

```bash
echo 'repository=https://void.ariadnev.vchun.dev/advs/current' | sudo tee /etc/xbps.d/advs.conf
sudo xbps-install -S advs-greeter
# sudo xbps-install -S advs-greeter-git   # master snapshots; Conflicts with stable
```

The packages create the greeter user (via `systemd-sysusers` for atomic/immutable compatibility, with package script fallback), set up directories and permissions, and apply SELinux contexts where relevant.

After installing from any package:

```bash
advs-greeter enable   # point greetd at advs-greeter
advs-greeter sync     # sync your ADVS theme to the login screen
```

Or run `advs-greeter install` for interactive setup - it installs greetd where needed and writes `/etc/greetd/config.toml` for you.

### From Source

```bash
git clone --recurse-submodules https://github.com/bavanchun/ariadnev-greeter.git
cd ariadnev-greeter
make build
sudo make install
```

Already cloned without submodules? Run `git submodule update --init` first -
the shared widget library ([ariadnev-qml-common](https://github.com/bavanchun/ariadnev-qml-common))
is vendored as a submodule and the build fails without it.

Then create the greeter user and cache directory if your setup doesn't have them:

```bash
sudo groupadd -r greeter
sudo useradd -r -g greeter -d /var/lib/greeter -s /bin/bash -c "System Greeter" greeter
sudo mkdir -p /var/lib/greeter /var/cache/advs-greeter
sudo chown greeter:greeter /var/lib/greeter /var/cache/advs-greeter
sudo chmod 2770 /var/cache/advs-greeter
```

And finish with `advs-greeter enable && advs-greeter sync`, or write `/etc/greetd/config.toml` yourself (see Usage).

At launch the embedded UI is unpacked read-only under the greeter cache
directory and verified against the binary on every start, so editing the
unpacked files has no effect. To run a modified copy of the UI, point
advs-greeter at any directory containing a `shell.qml` with `-c <dir>` or the
`ADVS_GREETER_SHELL_DIR` environment variable - there is no implicit filesystem
lookup otherwise.

### NixOS

Add the repo to your flake inputs, then:

```nix
imports = [
  inputs.ariadnev-greeter.nixosModules.default
];

programs.advs-greeter = {
  enable = true;
  compositor.name = "niri"; # or hyprland, sway, labwc, mango, scroll, miracle
  configHome = "/home/user"; # copies that user's ADVS settings (and wallpaper) into the greeter data directory before greetd starts
};
```

### Requirements

- [greetd](https://github.com/kennylevinsen/greetd)
- [Quickshell](https://quickshell.org) (`qs`)
- One of the supported compositors
- Go 1.26+ (build only - the binary is pure Go, no CGO)

## Features

**ADVS Sync**
`advs-greeter sync` copies your AriadnevShell theme, wallpaper, and settings
into the greeter cache, so the login screen matches your desktop. Greeter
options live in ADVS under **Settings → Greeter** - the greeter itself only
reads the synced files.

**Multi User**
Log in as any system user, with per-user themes and profile images in the user
picker.

**Multiple Compositors**
One binary launches the greeter under niri, Hyprland, Sway, Scroll,
Miracle WM, labwc, or MangoWC, generating the compositor config on the fly.

**Session Memory**
Remembers the last selected session and user. Disable via the
`greeterRememberLastSession` and `greeterRememberLastUser` settings, or the
`--no-save-session` / `--no-save-username` flags.

**Fingerprint & Security Keys**
Optional fingerprint (`pam_fprintd`) and U2F (`pam_u2f`) login, managed
through `/etc/pam.d/greetd`. Existing custom PAM configuration is respected.

**Localized**
User-facing strings are translatable and managed through POEditor.

## Usage

greetd runs the greeter through `/etc/greetd/config.toml`:

```toml
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "/usr/bin/advs-greeter --command niri"
```

The launcher takes care of the compositor side:

```bash
advs-greeter --command niri
advs-greeter --command hyprland
advs-greeter --command sway
advs-greeter --command mangowc
advs-greeter --command niri -C /path/to/custom-niri.kdl
advs-greeter --command niri --remember-last-user false --remember-last-session false
```

## Configuration

### Compositor

Only niri has a generated greeter config path managed by `advs-greeter sync`:

- niri: `advs-greeter sync` writes the generated greeter config to `/etc/greetd/niri/config.kdl`. Add local manual tweaks in `/etc/greetd/niri_overrides.kdl`.
- Other compositors use a launcher-generated config by default. For a custom compositor config, add `-C /path/to/config` to the `advs-greeter` command in `/etc/greetd/config.toml`.

### Personalization

The greeter is personalized with wallpapers, themes, weather, and clock formats the same way as ADVS itself.

**Single user:** run `advs-greeter sync` and you're done.

**Multi-user systems:** one **main admin** runs full sync once to set up greetd and the shared cache (`advs-greeter sync`, or `advs-greeter sync --local` when developing from a checkout). **Every other account** - including other admins - should only run:

```bash
advs-greeter sync --profile
```

Before that, an administrator must add each user to the `greeter` group in ADVS **Settings → Users** (greeter toggle) or with `sudo usermod -aG greeter <username>`. Each added user must log out and back in before `--profile` will work.

Per-user settings are stored under `/var/cache/advs-greeter/users/<username>/` for the login picker; the root cache remains the default fallback and is owned by whoever ran full sync.

### Local development

Run `advs-greeter sync --local` from a `ariadnev-greeter` checkout to build its Go launcher with the checkout's QML embedded. The development binary is installed separately at `/usr/local/bin/advs-greeter-local`; the package-owned `/usr/bin/advs-greeter` is not replaced. Re-run the command after Go, QML, or `ariadnev-qml-common` changes. Run `advs-greeter sync` without `--local` to point greetd back at the packaged binary.

The `ariadnev-qml-common` submodule must be initialized (`git submodule update --init ariadnev-qml-common`). `dankgo` is consumed at the version pinned in `core/go.mod`; use a Go workspace or `replace` directive explicitly when testing a local `dankgo` checkout.

**Manual method:** if you want greeter settings to always mirror your shell:

```bash
# Add yourself to the greeter group
sudo usermod -aG greeter $USER

# Set ACLs to allow greeter user to traverse your home directory
setfacl -m u:greeter:x ~ ~/.config ~/.local ~/.cache ~/.local/state

# Set group permissions on ADVS directories
sudo chgrp -R greeter ~/.config/AriadnevShell ~/.local/state/AriadnevShell ~/.cache/quickshell
sudo chmod -R g+rX ~/.config/AriadnevShell ~/.local/state/AriadnevShell ~/.cache/quickshell

# Create symlinks for theme files
sudo ln -sf ~/.config/AriadnevShell/settings.json /var/cache/advs-greeter/settings.json
sudo ln -sf ~/.local/state/AriadnevShell/session.json /var/cache/advs-greeter/session.json
sudo ln -sf ~/.cache/AriadnevShell/advs-colors.json /var/cache/advs-greeter/colors.json

# Logout and login for group membership to take effect
```

The cache directory location can be overridden with `--cache-dir` (default `/var/cache/advs-greeter`). It should be owned by `<greeter-user>:<greeter-group>` with `2770` permissions; if the greeter user doesn't exist yet, sync falls back to `root:<greeter-group>`.

### Fingerprint authentication

Install your distribution's fingerprint service and PAM integration before enabling it. On Fedora the native stack is:

```bash
sudo dnf install fprintd fprintd-pam
fprintd-enroll
```

After enrollment, enable fingerprint login in ADVS **Settings → Greeter**. The toggle applies the PAM configuration on the next `advs-greeter sync`; use `advs-greeter sync --auth` to apply authentication configuration alone.

greetd tries fingerprint and password sequentially. Managed PAM allows two scans for up to ten seconds before password fallback. Existing distro PAM policy takes precedence, so fallback timing can differ.

Verify enrollment with `fprintd-list "$USER"`; pass a token such as `fprintd-enroll -f right-thumb` to enroll a specific finger. Security keys similarly require `pam_u2f` setup and key registration before enabling the login toggle.

If `fprintd-enroll` reports **No devices available**, check the [libfprint supported devices list](https://fprint.freedesktop.org/supported-devices.html). Some Validity/Synaptics readers are not supported by the native stack regardless of distribution; the [open-fprintd](https://github.com/uunicorn/open-fprintd) service with the [python-validity](https://github.com/uunicorn/python-validity) driver may work instead. Don't run the stock `fprintd` daemon alongside its replacement.

## Development

```bash
make dev     # fast build without the embedded UI
make run     # preview the greeter UI in your current session
make build   # release build with the UI embedded
make test    # run the Go test suite
```
