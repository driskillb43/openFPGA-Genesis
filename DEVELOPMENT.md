# Development Guide - openFPGA-MegaDrive

## Project Status

✅ **Phase 1 Complete**: Repository structure and integration framework

The project now has all the necessary scaffolding to begin compilation and testing on Analogue Pocket hardware.

## What's Been Done

### 1. Repository Structure
```
openFPGA-MegaDrive/
├── dist/                           # Analogue Pocket distribution files
│   ├── Cores/brentdriskill.MegaDrive/
│   │   ├── core.json              ✅ Core metadata
│   │   ├── input.json             ✅ Controller mappings (3 & 6-button)
│   │   ├── video.json             ✅ Video modes (256/320 x 224/240)
│   │   ├── audio.json             ✅ Audio configuration
│   │   ├── data.json              ✅ ROM/save slot definitions
│   │   ├── interact.json          ✅ Settings menu
│   │   └── variants.json          ✅ Regional variants
│   └── Platforms/
│       └── megadrive.json         ✅ Platform definition
├── src/fpga/
│   ├── apf/                       ✅ Analogue Platform Framework files
│   ├── core/
│   │   ├── core_top.sv            ✅ Main APF interface wrapper
│   │   ├── rtl/                   ✅ Nuked-MD core files (23 files)
│   │   ├── data_loader.sv         ✅ ROM loading
│   │   ├── data_unloader.sv       ✅ Save data reading
│   │   ├── sdram.sv               ✅ SDRAM controller
│   │   ├── md_io.sv               ✅ Controller I/O
│   │   ├── lightgun.sv            ✅ Light gun support
│   │   ├── sound_i2s.sv           ✅ Audio output
│   │   └── mf_pllbase.*           ✅ Clock generation PLL
│   ├── ap_core.qpf                ✅ Quartus project
│   └── ap_core.qsf                ✅ Quartus settings & pin assignments
└── README.md                      ✅ Project documentation
```

### 2. Integration Layer (`core_top.sv`)

The main wrapper connects Nuked-MD to the Analogue Pocket:

**Implemented:**
- ✅ APF bridge command handler
- ✅ Clock generation (PLL for ~53.6 MHz system clock)
- ✅ ROM loading via data_loader
- ✅ SDRAM controller integration
- ✅ I2S audio output
- ✅ Controller input mapping (6-button support)
- ✅ Video output routing
- ✅ Settings interface (interact.json)
- ✅ md_board instantiation

**TODO (Next Phase):**
- ⚠️ Cart interface - Connect SDRAM to cart_data input
- ⚠️ Save RAM handling
- ⚠️ Video processing/scaling
- ⚠️ Audio mixing (YM3438 vs YM2612 selection)
- ⚠️ Region detection from ROM header
- ⚠️ TMSS ROM loading (optional)

### 3. Nuked-MD Core Files

All 23 original Nuked-MD Verilog files are included:
- 68k.v - Motorola 68000 CPU
- z80.v - Zilog Z80 sound CPU
- ym7101.v - VDP (Video Display Processor)
- ym3438.v + modules - FM sound chip
- ym6045.v - Bus arbiter
- ym6046.v - I/O controller
- fc1004.v - Integrated Yamaha chips
- md_board.v - Top-level board integration
- tmss.v - Security chip (later models)
- vram.v - Video RAM

## Next Steps

### Phase 2: Compilation & Debugging

1. **Set up development environment:**
   - Install Intel Quartus Prime Lite (with Cyclone V support)
   - Consider using a Linux VM or dual boot for better performance

2. **First compilation attempt:**
   ```bash
   # Open in Quartus
   quartus src/fpga/ap_core.qpf

   # Or command line:
   quartus_sh --flow compile src/fpga/ap_core.qpf
   ```

3. **Expected issues to resolve:**
   - Missing module definitions
   - Port connection mismatches
   - Clock domain crossings
   - Timing constraints violations

### Phase 3: Cart/ROM Interface

The most critical missing piece is connecting the SDRAM to the Nuked-MD core's cart interface:

```systemverilog
// In core_top.sv around line 750
// TODO: Replace placeholder with actual SDRAM cart interface
assign cart_data_en = 1'b0;  // Currently disabled

// Need to implement:
// - Map cart_addr to SDRAM addresses
// - Handle cart_cs, cart_oe timing
// - Implement cart_dtack handshaking
// - Connect cart_data from SDRAM read data
```

**Reference:** Look at the MiSTer port's cartridge.sv for guidance.

### Phase 4: Testing

1. **Minimal test:**
   - Compile and generate .rbf
   - Convert to .rbf_r (bit-reversed)
   - Copy to Pocket SD card with JSON files
   - Boot and verify it doesn't crash

2. **ROM loading test:**
   - Load a simple ROM (Sonic 1, etc.)
   - Check if it reaches the SEGA screen
   - Debug video output issues

3. **Full functionality:**
   - Controllers
   - Audio
   - Save RAM
   - Different video modes

## Development Tools

### Recommended IDE Setup

**For Verilog/SystemVerilog editing (on Mac):**
- VS Code with Verilog-HDL extension
- Configure file associations
- Syntax highlighting

**For Quartus (Windows/Linux VM):**
- Intel Quartus Prime Lite 21.1 or later
- Allocate 8GB+ RAM to VM
- Share project folder between Mac and VM

### Useful Commands

```bash
# Check project file count
find . -name "*.sv" -o -name "*.v" | grep -v ".git" | wc -l

# Verify all source files exist
cat src/fpga/ap_core.qsf | grep "set_global_assignment" | grep "FILE"

# Generate file list
ls src/fpga/core/rtl/*.v
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Analogue Pocket                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ apf_top.v (APF Framework - provided by Analogue)      │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│  ┌──────────────────▼──────────────────────────────────────┐│
│  │ core_top.sv (YOUR integration layer)                   ││
│  │                                                         ││
│  │ ┌─────────────┐  ┌──────────┐  ┌────────────────────┐ ││
│  │ │ Bridge CMD  │  │   PLL    │  │  Data Loaders      │ ││
│  │ └─────────────┘  └──────────┘  └────────────────────┘ ││
│  │                                                         ││
│  │ ┌──────────────────────────────────────────────────┐  ││
│  │ │  Nuked-MD Core (md_board.v)                      │  ││
│  │ │                                                   │  ││
│  │ │  ┌────────┐  ┌──────┐  ┌─────────┐  ┌─────────┐ │  ││
│  │ │  │ 68000  │  │ Z80  │  │ YM7101  │  │ YM3438  │ │  ││
│  │ │  │  CPU   │  │ CPU  │  │  (VDP)  │  │  (FM)   │ │  ││
│  │ │  └────────┘  └──────┘  └─────────┘  └─────────┘ │  ││
│  │ │                                                   │  ││
│  │ │  ┌────────┐  ┌────────┐  ┌──────────────────┐   │  ││
│  │ │  │YM6045  │  │YM6046  │  │    FC1004        │   │  ││
│  │ │  │(Arb.)  │  │ (I/O)  │  │  (Integrated)    │   │  ││
│  │ │  └────────┘  └────────┘  └──────────────────┘   │  ││
│  │ └──────────────────────────────────────────────────┘  ││
│  │                                                         ││
│  │ ┌──────────┐  ┌────────┐  ┌──────────┐  ┌──────────┐ ││
│  │ │  SDRAM   │  │  I2S   │  │ MD I/O   │  │ Video    │ ││
│  │ │Controller│  │ Audio  │  │(Control) │  │ Output   │ ││
│  │ └──────────┘  └────────┘  └──────────┘  └──────────┘ ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Key Challenges

1. **Clock Domain Crossing**
   - APF clock: 74.25 MHz
   - Genesis clock: ~53.6 MHz (NTSC) / ~53.2 MHz (PAL)
   - Need proper synchronization

2. **SDRAM Timing**
   - Genesis expects immediate cart access
   - SDRAM has latency - needs careful timing
   - May need caching or prefetch

3. **Video Output**
   - Genesis: Multiple resolutions (256/320 x 224/240)
   - APF expects specific formats
   - Need proper sync signal handling

4. **Audio Path**
   - Mix YM3438 FM + PSG
   - Convert to I2S format
   - Sample rate conversion

5. **Save RAM**
   - Variable sizes per game
   - Battery-backed simulation
   - Proper save/load timing

## Resources

- **Nuked-MD Original**: https://github.com/nukeykt/Nuked-MD-FPGA
- **MiSTer Port**: https://github.com/MiSTer-devel/MegaDrive_MiSTer
- **Reference Pocket Core**: https://github.com/opengateware/openFPGA-Genesis
- **APF Documentation**: https://www.analogue.co/developer/docs
- **GBC Core Example**: https://github.com/budude2/openfpga-GBC

## Git Workflow

```bash
# Check status
git status

# Create feature branch for cart interface work
git checkout -b feature/cart-interface

# Make changes, then commit
git add src/fpga/core/core_top.sv
git commit -m "Implement SDRAM cart interface"

# Merge back to main when working
git checkout main
git merge feature/cart-interface
```

## Questions & Debugging

Common issues and solutions:

**Q: Quartus can't find source files**
- Check working directory in .qsf matches structure
- Verify all paths are relative to project file
- Look for missing .qip includes

**Q: Synthesis errors about undefined modules**
- Check if all dependencies are listed in .qsf
- Verify module names match file names
- Look for SystemVerilog vs Verilog issues

**Q: Timing violations**
- May need to adjust PLL settings
- Add pipeline stages for long paths
- Check clock domain crossing constraints

**Q: Core loads but black screen**
- Video clock generation issue
- Check hsync/vsync polarity
- Verify resolution settings in video.json

---

*Generated by Claude Code - Initial project setup complete*
