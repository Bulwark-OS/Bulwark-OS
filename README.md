<img alt="BulwarkOS-logo" src="https://github.com/user-attachments/assets/2a97939e-b5da-4acb-9adc-29f656ef2981" />

# [![bluebuild build badge](https://github.com/connorethanjay/BulwarkOS/actions/workflows/build.yml/badge.svg)](https://github.com/connorethanjay/BulwarkOS/actions/workflows/build.yml) <img src="https://img.shields.io/badge/built%20with-BlueBuild-informational" alt="Built with BlueBuild"/> <img src="https://img.shields.io/badge/base-Fedora%20Silverblue-blue?logo=fedora" alt="Base: Fedora Silverblue"/> <img src="https://img.shields.io/badge/status-early%20alpha-orange" alt="Status: Early Alpha"/>

> [!WARNING]
> BulwarkOS is in very early development and is built primarily for personal use. It is becoming functional but is incomplete. Do not use this as your primary system unless you are comfortable debugging a work-in-progress immutable Linux distribution.
  
# About BulwarkOS

BulwarkOS is an immutable desktop Linux distribution that brings the compartmentalization threat model of [**Qubes OS**](https://www.qubes-os.org/) to a conventional hypervisor stack without the significant usability constraints that Qubes OS imposes.

Rather than running Xen like in Qubes OS, BulwarkOS uses libvirt/KVM as it's hypervisor, with VFIO hardware passthrough to isolate meaningful hardware like your physical network interfaces & graphics card. Environments like "Work" and "Personal" can be separated into different virtual machines, all configured automatically by a first-run setup wizard and then accessed with a custom panel application.

The end-goal is a system that is meaningfully harder to compromise than a standard desktop Linux install, without sacrificing a system's usability or gaming capability.

## How it works

BulwarkOS establishes a layered isolation architecture on top of a standard Fedora Silverblue base:

**sys-net** receives your physical network interfaces via VFIO passthrough. The host never touches the network directly after setup.

**sys-firewall** sits between sys-net and your AppVMs, enforcing traffic policy via nftables. All AppVM traffic routes through it.

**AppVMs** are isolated Fedora, Windows, Alpine, etc virtual machines, each representing a trust domain. They communicate with the outside world only through sys-firewall, never directly.

The host itself runs a minimal footprint: 

- the BulwarkOS Panel provides access & management to your virtual machines
- virt-manager acts as a backup to the BulwarkOS Panel for more granular control.
- Loupe for viewing simple media on the host.
- Nautilus for simple file management on the host.

## OOBE setup wizard

After installation, a GTK4/Libadwaita setup wizard runs automatically on first login. It handles everything required to bring the isolation stack online:

- Detects CPU vendor and confirms IOMMU is active
- Enumerates IOMMU groups and surfaces any group contamination warnings
- Lets you select which physical NICs to pass through to sys-net
- Optionally configures GPU passthrough to a dedicated gaming VM (with Looking Glass support)
- Lets you choose which AppVM trust domains to provision
- Shows a full review of every command that will run before applying anything
- Writes kernel arguments, modprobe config, and rebuilds the initramfs via `rpm-ostree`
- Defines libvirt networks and VM domains
- Installs selected Flatpaks
- Reboots to activate the configuration

No manual kernel argument editing or XML writing required.

## Installation

> [!NOTE]
> IOMMU must be supported and enabled in your UEFI firmware before installing. Look for **AMD-Vi**, **Intel VT-d**, or **IOMMU** in your UEFI settings and enable it before proceeding.

### Requirements

- x86\_64 system with IOMMU support (AMD-Vi or Intel VT-d)
- Separate IOMMU groups for your NIC(s) — check with `find /sys/kernel/iommu_groups/ -type l`
- At least 16GB RAM (32GB+ recommended for multiple AppVMs)
- At least 100GB of free disk space

### ISO installation

An installable ISO can be generated locally using the BlueBuild ISO tool. See [BlueBuild's ISO guide](https://blue-build.org/how-to/generate-iso/) for instructions. Pre-built ISOs are not currently distributed but will be in the near future.

### From an existing Fedora Atomic installation

Rebase to the unsigned image first to pull signing keys:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/connorethanjay/bulwark-os:latest
systemctl reboot
```

Then rebase to the signed image:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/connorethanjay/bulwark-os:latest
systemctl reboot
```

On next login, the OOBE setup wizard will launch automatically.

## Default Flatpaks

The host is intentionally minimal. Most applications belong in an AppVM, not on the host.

| Flatpak | Purpose |
|---|---|
| `org.gnome.Loupe` | Image viewer |
| `org.gnome.Nautilus` | File manager for VM shared folder access |

The following will be available as an opt-in during OOBE for users who want gaming support.

| Flatpak | Purpose |
|---|---|
| `com.github.gnome_looking_glass.LookingGlass` | Low-latency GPU passthrough display capture |

## VM trust domains

The following are pre-defined trust levels within BulwarkOS.
| VM | Base OS | Trust level | Default |
|---|---|---|---|
| sys-net | Alpine | System — routed directly to internet | ✓ |
| sys-firewall | Alpine | System — firewall between AppVMs and sys-net | ✓ |
| personal | Fedora w/ GUI | Trusted — browsing, email, social | Optional |
| work | Fedora w/ GUI | Trusted — office, meetings, internal tools | Optional |
| banking | Fedora w/ GUI | Vault — financial sites, no clipboard sharing | Optional |
| development | Fedora w/ GUI | Development — compilers, containers, local servers | Optional |
| media | Fedora w/ GUI  | Untrusted — streaming, local media playback | Optional |
| disposable | Tails OS | Untrusted — wiped completely on shutdown | Optional |
| gaming-vm | User-installed | Untrusted passthrough, Looking Glass display | Optional |

sys-net and sys-firewall are always provisioned automatically.

## Roadmap

This is a personal project and there are no fixed timelines, but planned work includes:

- [ ] virt-manager replacement / custom VM control panel (BulwarkOS Panel)
- [ ] AppVM image auto-update mechanism
- [ ] Integration of hardening defaults from [secureblue](https://github.com/secureblue/secureblue)
- [ ] Per-AppVM nftables egress policy configuration in the OOBE wizard
- [ ] Wayland clipboard broker between AppVMs (controlled sharing)
- [ ] Looking Glass integration improvements for the gaming VM
- [ ] ISO distribution

## Acknowledgements

BulwarkOS stands on the shoulders of several projects:

- **[Qubes OS](https://www.qubes-os.org/)** — the threat model and compartmentalization philosophy that inspired this project
- **[BlueBuild](https://blue-build.org/)** — the toolchain used to build and publish the OCI image
- **[Universal Blue](https://universal-blue.org/)** — the Fedora Atomic ecosystem and base images
- **[secureblue](https://secureblue.dev)** — planned future source of hardening defaults
- **[Fedora Project](https://fedoraproject.org/)** — the upstream Silverblue base

## Verification

BulwarkOS images are signed with [Sigstore](https://www.sigstore.dev/) cosign. Verify with:

```bash
cosign verify --key cosign.pub ghcr.io/connorethanjay/bulwark-os
```

## License

Apache-2.0 — see [LICENSE](./LICENSE) for details.
