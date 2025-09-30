 <h1 id="header" align="center">
  <img src="https://github.com/NixOS/nixos-artwork/blob/c68a508b95baa0fcd99117f2da2a0f66eb208bbf/logo/nix-snowflake-colours.svg" width="96px" height="96px" />
  <br>
  sysBOFH
</h1>

<h2 align="center">My NixOS Configuration</h2>

<div align="center">

[![NixOS](https://img.shields.io/badge/NixOS-Configuration-blue)](https://nixos.org)
[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
[![Zen Linux](https://img.shields.io/badge/kernel-zen-blue)](https://github.com/zen-kernel/zen-kernel)
[![hyprland](https://img.shields.io/badge/hyprland-unstable-informational.svg?style=flat&logo=wayland)](https://hyprland.org/)
[![hydra build](https://img.shields.io/badge/Hydra_build-status-blue)](https://hydra.billy.sh/jobset/sysBOFH/sysbofh#tabs-jobs)

</div>

## Index

- [About](#About)
- [Structure](#Structure)
- [Screenshots](#Screenshots)
- [NixVim](#NixVim)
- [Contact](#Contact)
- [License](#License)

## About

### sysBOFH Project

- After using Nixos for a while on my main laptop, **I achieved a functional system tailored to me**, so much so that I wanted to replicate it on all the machines I use, so finally [flakes](https://nixos.wiki/wiki/Flakes) made sense.
- I'm using [NixOS](https://nixos.org/) [unstable](https://channels.nixos.org/?prefix=nixos-unstable/) with [home-manager](https://nixos.wiki/wiki/Home_Manager) (_standalone installation_) mostly for manage my dotfiles and keep my packages and services system-wide with the main _configuration.nix_
- I still keep all my dotfiles in original format, I have not rewritten them in nix syntax for two reasons: compatibility and laziness
- Lately I migrated to [Flakes](https://nixos.wiki/wiki/Flakes) from [Nix Channels](https://nixos.wiki/wiki/Nix_channels) so I try to keep my scheme and modules as simple as possible following the [KISS](https://en.wikipedia.org/wiki/KISS_principle) principle

### High level overview

- [SDDM](https://github.com/sddm/sddm) Login Manager with my custom ([BOFH Theme](https://github.com/wverac/bofh-theme-sddm)) version of [tokyo-night-sddm](https://github.com/rototrash/tokyo-night-sddm)
- [Wayland](https://wayland.freedesktop.org/) with [Hyprland](https://hyprland.org/) and [waybar](https://github.com/alexays/waybar)
- [SOPS-Nix](https://github.com/Mic92/sops-nix) as secrets management scheme
- [zen-kernel](https://github.com/zen-kernel/zen-kernel) in my main-personal machine

## Structure

```
sysbofh/
├── hosts
│   ├── nixlab
│   └── sysbofh
├── modules
│   ├── home
│   │   └── config
│   │       ├── alacritty
│   │       ├── dunst
│   │       ├── fastfetch
│   │       ├── feh
│   │       ├── hypr
│   │       │   └── scripts
│   │       ├── rofi
│   │       ├── waybar
│   │       │   └── scripts
│   │       └── wlogout
│   │           └── icons
│   └── nixos
└── screenshots
```

- [hosts](hosts) Custom settings for each machine I use
  - [nixlab](hosts/nixlab) Beelink S12 Pro Mini PC
  - ~~[overcloud](hosts/overcloud) ThinkPad X1 Carbon 6th~~
  - [sysbofh](hosts/sysbofh) System76 Lemur Pro
  - ~~[work](hosts/work) ThinkPad X1 Yoga Gen 6~~
  - [m4nix](hosts/minix) Apple M4 Pro
- [modules](modules) Modularized NixOS configurations
  - [home](modules/home) home-manager configurations
    - [config](modules/home/config) Programs dotfiles, themes and configurations
- [nixos](modules/nixos) OS-wide configurations and settings

## Screenshots

![lunarvim](https://github.com/wverac/nixvim/blob/main/assets/BOFH_01.png)
![lunarvim](https://github.com/wverac/nixvim/blob/main/assets/BOFH_02.png)
![overcloud02](screenshots/overcloud_02.png)
![overcloud01](screenshots/overcloud_01.png)

## NixVim

Yes, I made my NixVim distro, it's simple, it's functional, there are no thousand configuration files, it's fast and it's beautiful.  
https://github.com/wverac/nixvim

```nix
nix run github:wverac/nixvim
```

## Contact

`wv@linux.com`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
