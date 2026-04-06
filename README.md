<img width="4061" height="884" alt="BulwarkOS-logo" src="https://github.com/user-attachments/assets/fdea4b2a-3d4c-4f13-b25c-6a2dd4475cc0" />


# bulwarkOS &nbsp; [![bluebuild build badge](https://github.com/connorethanjay/bulwarkOS/actions/workflows/build.yml/badge.svg)](https://github.com/connorethanjay/bulwarkOS/actions/workflows/build.yml)
     
bulwarkOS is a desktop Linux operating system intending to replicate the compartmentalization threat model established by distributions like [Qubes OS](https://www.qubes-os.org/). It is built using BlueBuild and shipped as a set of OCI bootable containers, using Fedora Atomic Desktop's base images as a starting point. Currently a work-in-progress with a website coming soon.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/connorethanjay/bulwark-os:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/connorethanjay/bulwark-os:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

If building on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/connorethanjay/bulwarkOS
```
