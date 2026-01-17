# openFPGA-Genesis

> ⚠️ **WORK IN PROGRESS** - This core is currently under development and **not yet functional**. It has not been compiled or tested on hardware.

Cycle-accurate Sega Genesis / Mega Drive core for Analogue Pocket, based on [Nuked-MD-FPGA](https://github.com/nukeykt/Nuked-MD-FPGA).

## About

This is a port of the Nuked-MD FPGA core to the Analogue Pocket platform. The goal is to provide the most accurate Genesis / Mega Drive emulation possible using cycle-accurate implementations of the original hardware chips.

### Nuked-MD Core

The Nuked-MD core emulates the following chips:
* Motorola 68000 (Main CPU) - NMOS variant
* Zilog Z80 (Sound CPU) - NMOS variant
* Yamaha YM7101 (VDP)
* Yamaha YM2612/YM3438 (FM Sound)
* Yamaha YM6045 (Arbiter)
* Yamaha YM6046 (I/O)
* FC1004 (integrated Yamaha chips)
* TMSS (later revision feature)

All chip implementations are based on die photographs and hardware reverse engineering for maximum accuracy.

## Status

| Component | Status |
|-----------|--------|
| Core Integration | ✅ Complete |
| Video Processing | ✅ Complete |
| Audio Mixing | ✅ Complete |
| Save RAM | ✅ Complete |
| Controller I/O | ✅ Complete |
| **Compilation** | ❌ Not Started |
| **Hardware Testing** | ❌ Not Started |

**Next Steps:**
1. Compile with Intel Quartus Prime (requires x86-64 system)
2. Test on Analogue Pocket hardware
3. Debug and optimize

## Cloning

This project uses git submodules for the Nuked-MD core files. Clone with:

```bash
git clone --recursive https://github.com/driskillb43/openFPGA-Genesis.git
```

Or if you've already cloned the repository:

```bash
git submodule update --init --recursive
```

## Directory Structure

```
openFPGA-Genesis/
├── dist/                           # Distribution files for Analogue Pocket
│   ├── Cores/
│   │   └── driskillb43.Genesis/
│   │       ├── core.json          # Core metadata
│   │       ├── input.json         # Controller configuration
│   │       ├── video.json         # Video settings
│   │       ├── audio.json         # Audio settings
│   │       ├── data.json          # ROM/save slots
│   │       ├── interact.json      # Interactive settings
│   │       ├── variants.json      # Platform variants
│   │       └── bitstream.rbf_r    # Compiled bitstream
│   └── Platforms/
│       └── genesis.json           # Platform definition
├── src/
│   └── fpga/
│       ├── apf/                   # Analogue Platform Framework files
│       ├── core/                  # Core integration layer
│       │   ├── rtl/              # Nuked-MD core files (git submodule)
│       │   └── core_top.sv       # Main APF interface
│       └── ap_core.qpf           # Quartus project
└── README.md
```

## Building

### Requirements

- Intel Quartus Prime Lite (with Cyclone V device support)
- Analogue Pocket (for testing)

### Build Steps

1. Open `src/fpga/ap_core.qpf` in Quartus Prime
2. Compile the project (Processing → Start Compilation)
3. Convert the output `.sof` file to bit-reversed RBF format
4. Copy to SD card along with JSON files from `dist/`

## Credits

- **nukeykt** - Nuked-MD FPGA core, reverse engineering
- **ogamespec** - FC1004 decap, reverse engineering
- **andkorzh** - Reverse engineering
- **HardWareMan** - YM2612 decap, reverse engineering
- **agg23** - Prior Analogue Pocket porting
- **ericlewis** - Prior Genesis port

## References

- [Nuked-MD-FPGA](https://github.com/nukeykt/Nuked-MD-FPGA) - Original FPGA core
- [Nuked-MD](https://github.com/nukeykt/Nuked-MD) - C++ emulator version
- [MegaDrive MiSTer](https://github.com/MiSTer-devel/MegaDrive_MiSTer) - MiSTer FPGA port
- [openFPGA-Genesis](https://github.com/opengateware/openFPGA-Genesis) - Alternative Pocket Genesis core

## License

See individual source files for licensing information. The Nuked-MD core is licensed under GPL v2+.
