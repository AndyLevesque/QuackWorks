# QuackWorks

QuackWorks is an OpenSCAD project centered around parametric functional prints. This repo houses multiple collections and some simpler one-off projects.

## Repository Structure

```
QuackWorks/
├── assets/           # Images and media files
├── docs/             # Documentation
├── libraries/        # Shared, reusable modules
├── projects/         # Main systems and one-off projects
│   ├── underware/    # Cable management system
│   ├── deskware/     # Modular desk system
│   ├── neogrid/      # Drawer management system
│   ├── opengrid/     # Tile generator
│   ├── multiconnect/ # Multiconnect-based mounts/holders
│   └── misc/         # One-off projects
└── tools/            # Development tools (flake.nix)
```

## Projects

The following are publicly available systems. New features continue to be developed for these systems as feedback is received:

1. **Underware** - Infinite Cable Management ([MakerWorld](https://makerworld.com/en/models/783010))
2. **Deskware** - A Modular Desk System ([MakerWorld](https://makerworld.com/en/models/1331760-deskware-a-modular-desk-system))
3. **NeoGrid 2.0** - Drawer Management System ([MakerWorld](https://makerworld.com/en/models/1501061-neogrid-2-0-drawer-management-system))
4. **Multiconnect** - Part Generators ([MakerWorld](https://makerworld.com/en/models/582260))
5. **openGrid** - Tile Generator ([MakerWorld](https://makerworld.com/en/models/1304337-opengrid-tile-generator))

### One-off Projects

Additional functional projects that are print-tested but may not receive as much attention:

1. **Customizable US Electrical Box Extension** ([MakerWorld](https://makerworld.com/en/models/1252965))
2. **Underware Drawer v1** ([MakerWorld](https://makerworld.com/en/models/1253194))

## Installation Instructions

**NOTE**: Most models within this repository are available on MakerWorld's Web-based generator and do not require install. Some features or projects may still be in beta and therefore not yet available on MakerWorld.

### Install Local OpenSCAD Developer Release

Install the latest developer release of OpenSCAD found at https://openscad.org/downloads.html

**NOTE**: The regular release of OpenSCAD will not work for most files found in this library. The Developer Release is required for performance and compatibility.

### Install BOSL2 Library

Download the latest BOSL2 Library (https://github.com/BelfrySCAD/BOSL2), unzip, rename the folder to BOSL2, and place in the OpenSCAD library folder found at File > Show Library Folder.

## Development

See [docs/multiconnect-standards.md](docs/multiconnect-standards.md) for Multiconnect development standards.

### Using Nix

If you have [nix](https://nixos.org/) installed with flakes activated, everything will be setup for you with `nix develop`.

## License

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
