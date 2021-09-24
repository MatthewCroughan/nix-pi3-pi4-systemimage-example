This builds an Image for a Pi3 or Pi4 (aarch64) that:

# Usage

1. Clone this repo, enter it and
```
# Pi3
nix build .#packages.aarch64-linux.sd_image_pi3
# Pi4
nix build .#packages.aarch64-linux.sd_image_pi4
```

Or just do it remotely without cloning this repo: `nix build
github:matthewcroughan/nix-pi3-pi4-systemimage-example#packages.aarch64-linux.sd_image_pi3`

