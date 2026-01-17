# Development Guide - openFPGA-Genesis

## Project Status

✅ **Phase 1 Complete**: Repository structure and integration framework

The project now has all the necessary scaffolding to begin compilation and testing on Analogue Pocket hardware.

## What's Been Done

### 1. Repository Structure
```
openFPGA-Genesis/
├── dist/                           # Analogue Pocket distribution files
│   ├── Cores/brentdriskill.Genesis/
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
- ✅ Cart interface - SDRAM connected to cart_data (lines 500-547, 766-782)
- ✅ Save RAM handling - Implemented with dual-port RAM + save_handler.sv
- ✅ Video processing/scaling - Color LUT, COFI filter, mode detection
- ✅ Audio mixing (YM3438 vs YM2612 selection) - FM chip selection implemented
- ⚠️ PLL reconfiguration for proper video clocks
- ⚠️ Region detection from ROM header (optional)
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

### Phase 3: Cart/ROM Interface ✅ COMPLETE

The SDRAM to cart interface has been implemented using the multiplexing pattern from both GBC and SNES reference cores:

```systemverilog
// In core_top.sv lines 500-547
// SDRAM multiplexing - during download, ioctl controls SDRAM
// During normal operation, cart interface controls SDRAM
wire [24:1] sdram_addr = cart_download ? ioctl_addr[24:1] : {1'b0, cart_addr};
wire [15:0] sdram_din  = cart_download ? {ioctl_data[7:0], ioctl_data[15:8]} : cart_data_wr;
wire [15:0] sdram_dout;
wire        sdram_we   = cart_download ? ioctl_wr : (cart_cs & (cart_lwr | cart_uwr));
wire        sdram_req  = cart_download ? ioctl_wr : (cart_cs & cart_oe);
```

**Implementation notes:**
- Address multiplexing: Download uses ioctl_addr, runtime uses cart_addr
- Data byte swapping for big-endian Genesis ROMs
- Write enable properly muxed between loader and cart writes
- Cart data enable only active during cart reads (not download)

### Phase 4: Save RAM Implementation ✅ COMPLETE

Battery-backed SRAM support has been implemented following the GBC/SNES pattern:

**New Files:**
- `src/fpga/core/save_handler.sv` - Handles APF bridge communication for save data

**Implementation Details:**

1. **Dual-Port RAM (64KB)** - core_top.sv lines 479-497
   - Port A: Genesis cart access at 0x200000-0x3FFFFF
   - Port B: APF save/load operations via save_handler

2. **Address Space Detection** - core_top.sv lines 770-778
   ```systemverilog
   // Genesis SRAM typically appears at 0x200000-0x3FFFFF
   wire sram_active = (cart_addr[22:20] == 3'b001);
   ```

3. **Data Multiplexing** - core_top.sv line 781
   ```systemverilog
   // Multiplex between ROM (SDRAM) and SRAM
   wire [15:0] cart_data_muxed = sram_active ? sram_dout_a : sdram_dout;
   ```

4. **APF Integration:**
   - data_loader at address 0x6xxxxxxx for writing saves
   - data_unloader at address 0x6xxxxxxx for reading saves
   - datatable reports 64KB size to APF (matching data.json)
   - Bridge read mux handles 0x6xxxxxxx address space

**Notes:**
- 64KB is the standard maximum SRAM size for Genesis games
- Most games use 8KB-32KB, but 64KB accommodates all titles
- SRAM is only active when cart addresses 0x200000-0x3FFFFF
- Per-game SRAM size detection could be added via ROM header parsing

### Phase 5: Video Processing ✅ PARTIAL

Video output has been implemented following the openFPGA-Genesis pattern:

**Implemented:**
- ✅ Color lookup table (4-bit → 8-bit RGB expansion)
- ✅ Composite video filter (cofi.sv)
- ✅ Video mode detection and encoding
- ✅ Proper sync signal handling
- ✅ Blanking signal processing with vblank latching

**TODO:**
- ⚠️ **PLL Reconfiguration Required** - The PLL needs to be regenerated in Quartus to output video clocks:
  - `clk_vid_256` @ ~6.71 MHz for 256-width modes
  - `clk_vid_320` @ ~8.39 MHz for 320-width modes
  - 90-degree phase-shifted versions of each
  - Currently using system clock as temporary workaround

**Video Signal Flow:**
```
md_board VDP outputs (4-bit RGB + sync)
  → Color LUT expansion
  → COFI composite filter (optional)
  → Video mode encoding
  → Video output registers (clocked by pixel clock)
  → APF scaler
```

**Resolution Support:**
- 256 x 224 (most common)
- 320 x 224 (high-res mode)
- 256 x 240 (PAL)
- 320 x 240 (PAL high-res)

### Phase 5a: Audio Processing ✅ COMPLETE

Audio output has been implemented with FM chip selection support:

**Implemented:**
- ✅ YM3438 audio output (authentic chip)
- ✅ YM2612 audio output (emulation mode)
- ✅ FM chip selection via interact.json setting
- ✅ Automatic PSG mixing (handled by md_board)
- ✅ I2S audio output

**Implementation Details:**

1. **Audio Sources** - core_top.sv lines 558-568
   ```systemverilog
   // md_board provides both YM3438 and YM2612 outputs pre-mixed with PSG
   wire [15:0] A_L;        // YM3438 + PSG (16-bit signed)
   wire [15:0] A_R;
   wire [17:0] A_L_2612;   // YM2612 + PSG (18-bit signed)
   wire [17:0] A_R_2612;

   // Select audio based on FM chip setting (cs_fm_chip: 0=YM2612, 1=YM3438)
   wire [15:0] AUDIO_L = cs_fm_chip ? A_L : A_L_2612[17:2];
   wire [15:0] AUDIO_R = cs_fm_chip ? A_R : A_R_2612[17:2];
   ```

2. **Audio Chip Selection**
   - Controlled by `cs_fm_chip` setting at address 0x00A00000
   - 0 = YM2612 (emulation mode with slightly different tone)
   - 1 = YM3438 (authentic Genesis 2 chip)

3. **Audio Mixing**
   - Nuked-MD core handles all mixing internally
   - Both FM chip outputs already include PSG mix
   - 18-bit YM2612 output scaled to 16-bit by dropping 2 LSBs

**Audio Signal Flow:**
```
md_board audio synthesis
  → YM3438 (A_L/A_R) or YM2612 (A_L_2612/A_R_2612)
  → Both pre-mixed with PSG
  → Chip selection mux (based on cs_fm_chip)
  → I2S output module
  → Analogue Pocket DAC
```

**Notes:**
- YM3438 is more accurate to later Genesis/Mega Drive models
- YM2612 emulation may have subtle tone differences
- PSG (Programmable Sound Generator) audio is included in both modes
- No additional audio filtering implemented (could add LPF/HPF in future)

### Phase 6: Testing

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
