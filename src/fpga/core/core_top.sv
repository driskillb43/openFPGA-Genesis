//
// User core top-level for Nuked-MD Mega Drive
//
// Instantiated by apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz
input   wire            clk_74a,
input   wire            clk_74b,

///////////////////////////////////////////////////
// cartridge interface
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
output  wire            cart_pin30_pwroff_reset,
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable,

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,

///////////////////////////////////////////////////
// cellular psram 0 and 1
output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit
output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit
output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync
input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart
output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector
output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus
inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,

//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,

output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
input   wire    [15:0]  cont1_key,
input   wire    [15:0]  cont2_key,
input   wire    [15:0]  cont3_key,
input   wire    [15:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig

);

// not using the IR port
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;
assign cart_tran_pin31 = 1'bz;
assign cart_tran_pin31_dir = 1'b0;

// link port is input only
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;

// tie off unused RAM
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;

///////////////////////////////////////////////////
// PLL - Generate clocks for Mega Drive
///////////////////////////////////////////////////

wire clk_sys;      // ~53.6 MHz system clock
wire clk_ram;      // ~107 MHz RAM clock
wire pll_core_locked;

mf_pllbase mp1 (
    .refclk   ( clk_74a ),
    .rst      ( 0 ),

    .outclk_0 ( clk_sys ),
    .outclk_1 ( clk_ram ),

    .locked   ( pll_core_locked )
);

///////////////////////////////////////////////////
// Bridge Command Handler
///////////////////////////////////////////////////

wire            reset_n;
wire    [31:0]  cmd_bridge_rd_data;

// bridge host commands
wire            status_boot_done = pll_core_locked;
wire            status_setup_done = pll_core_locked;
wire            status_running = reset_n;

wire            dataslot_requestread;
wire    [15:0]  dataslot_requestread_id;
wire            dataslot_requestread_ack = 1;
wire            dataslot_requestread_ok = 1;

wire            dataslot_requestwrite;
wire    [15:0]  dataslot_requestwrite_id;
wire            dataslot_requestwrite_ack = 1;
wire            dataslot_requestwrite_ok = 1;

wire            dataslot_allcomplete;

wire            savestate_supported = 0;
wire    [31:0]  savestate_addr;
wire    [31:0]  savestate_size;
wire    [31:0]  savestate_maxloadsize;

wire            savestate_start;
wire            savestate_start_ack;
wire            savestart_start_busy;
wire            savestate_start_ok;
wire            savestate_start_err;

wire            savestate_load;
wire            savestate_load_ack;
wire            savestate_load_busy;
wire            savestate_load_ok;
wire            savestate_load_err;

wire            osnotify_inmenu;

wire    [9:0]   datatable_addr;
wire            datatable_wren;
wire    [31:0]  datatable_data;
wire    [31:0]  datatable_q;

core_bridge_cmd icb (
    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),

    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),

    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )
);

///////////////////////////////////////////////////
// Core Settings (from interact.json)
///////////////////////////////////////////////////

// Audio
reg cs_fm_chip            = 0;  // 0=YM2612, 1=YM3438
reg [1:0] cs_audio_filter = 0;

// Video
reg cs_composite_enable   = 0;
reg cs_sprite_limit       = 1;

// System
reg cs_multitap           = 0;
reg [1:0] cs_cpu_turbo    = 0;

always @(posedge clk_74a) begin
    if (bridge_wr) begin
        casex (bridge_addr)
            32'h00A00000: cs_fm_chip         <= bridge_wr_data[0];
            32'h00F00000: cs_audio_filter    <= bridge_wr_data[1:0];
            32'h00000020: cs_composite_enable <= bridge_wr_data[0];
            32'h00000030: cs_sprite_limit    <= bridge_wr_data[0];
            32'h00000000: cs_multitap        <= bridge_wr_data[0];
            32'h00C00000: cs_cpu_turbo       <= bridge_wr_data[1:0];
        endcase
    end
end

///////////////////////////////////////////////////
// ROM Loading
///////////////////////////////////////////////////

reg         ioctl_download = 0;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;

wire        cart_download;

always @(posedge clk_74a) begin
    if (dataslot_requestwrite) ioctl_download <= 1;
    else if (dataslot_allcomplete) ioctl_download <= 0;
end

data_loader #(
    .ADDRESS_MASK_UPPER_4(4'h1),
    .ADDRESS_SIZE(25),
    .WRITE_MEM_CLOCK_DELAY(12),
    .WRITE_MEM_EN_CYCLE_LENGTH(2),
    .OUTPUT_WORD_SIZE(2)
) rom_loader (
    .clk_74a(clk_74a),
    .clk_memory(clk_sys),

    .bridge_wr(bridge_wr),
    .bridge_endian_little(bridge_endian_little),
    .bridge_addr(bridge_addr),
    .bridge_wr_data(bridge_wr_data),

    .write_en(ioctl_wr),
    .write_addr(ioctl_addr),
    .write_data(ioctl_data)
);

synch_3 cart_download_s (
    ioctl_download & bridge_addr[31:28] == 4'h1,
    cart_download,
    clk_sys
);

///////////////////////////////////////////////////
// SDRAM Controller
///////////////////////////////////////////////////

wire [24:1] rom_addr;
wire [15:0] rom_data;
wire [15:0] rom_wdata;
wire  [1:0] rom_be;
wire rom_req, rom_ack, rom_we;

sdram sdram (
    .init(~pll_core_locked),
    .clk(clk_ram),

    // ROM loader port
    .addr0(ioctl_addr[24:1]),
    .din0({ioctl_data[7:0], ioctl_data[15:8]}),
    .dout0(),
    .wrl0(1),
    .wrh0(1),
    .req0(ioctl_wr),
    .ack0(),

    // Core ROM access port
    .addr1(rom_addr),
    .din1(rom_wdata),
    .dout1(rom_data),
    .wrl1(rom_we & rom_be[0]),
    .wrh1(rom_we & rom_be[1]),
    .req1(rom_req),
    .ack1(rom_ack),

    // SDRAM physical interface
    .SDRAM_DQ(dram_dq),
    .SDRAM_A(dram_a),
    .SDRAM_DQML(dram_dqm[0]),
    .SDRAM_DQMH(dram_dqm[1]),
    .SDRAM_BA(dram_ba),
    .SDRAM_nCS(1'b0),
    .SDRAM_nWE(dram_we_n),
    .SDRAM_nRAS(dram_ras_n),
    .SDRAM_nCAS(dram_cas_n),
    .SDRAM_CLK(dram_clk),
    .SDRAM_CKE(dram_cke)
);

///////////////////////////////////////////////////
// Audio Output (I2S)
///////////////////////////////////////////////////

wire [15:0] AUDIO_L, AUDIO_R;

sound_i2s #(
    .CHANNEL_WIDTH(16),
    .SIGNED_INPUT (1)
) sound_i2s (
    .clk_74a(clk_74a),
    .clk_audio(clk_sys),

    .audio_l(AUDIO_L),
    .audio_r(AUDIO_R),

    .audio_mclk(audio_mclk),
    .audio_lrck(audio_lrck),
    .audio_dac(audio_dac)
);

///////////////////////////////////////////////////
// Video Output
///////////////////////////////////////////////////

wire [7:0] r, g, b;
wire hs, vs;
wire hblank, vblank;
wire ce_pix;

// TODO: Video processing and output
assign video_rgb_clock = clk_sys;
assign video_rgb_clock_90 = clk_sys;
assign video_rgb = {r, g, b};
assign video_de = ~(hblank | vblank);
assign video_hs = hs;
assign video_vs = vs;
assign video_skip = 0;

///////////////////////////////////////////////////
// Controller Mapping
///////////////////////////////////////////////////

wire [15:0] joystick_0, joystick_1, joystick_2, joystick_3;

// Map Pocket controller to Genesis format
assign joystick_0 = {
    cont1_key[9],  // Z
    cont1_key[6],  // Y
    cont1_key[8],  // X
    cont1_key[14], // mode
    cont1_key[15], // start
    cont1_key[4],  // B
    cont1_key[5],  // C
    cont1_key[7],  // A
    cont1_key[0],  // up
    cont1_key[1],  // down
    cont1_key[2],  // left
    cont1_key[3]   // right
};

assign joystick_1 = {
    cont2_key[9],  cont2_key[6],  cont2_key[8],  cont2_key[14],
    cont2_key[15], cont2_key[4],  cont2_key[5],  cont2_key[7],
    cont2_key[0],  cont2_key[1],  cont2_key[2],  cont2_key[3]
};

assign joystick_2 = {
    cont3_key[9],  cont3_key[6],  cont3_key[8],  cont3_key[14],
    cont3_key[15], cont3_key[4],  cont3_key[5],  cont3_key[7],
    cont3_key[0],  cont3_key[1],  cont3_key[2],  cont3_key[3]
};

assign joystick_3 = {
    cont4_key[9],  cont4_key[6],  cont4_key[8],  cont4_key[14],
    cont4_key[15], cont4_key[4],  cont4_key[5],  cont4_key[7],
    cont4_key[0],  cont4_key[1],  cont4_key[2],  cont4_key[3]
};

///////////////////////////////////////////////////
// Nuked-MD Core Instance
///////////////////////////////////////////////////

wire [14:0] ram_68k_address;
wire  [1:0] ram_68k_byteena;
wire [15:0] ram_68k_data;
wire        ram_68k_wren;
wire [15:0] ram_68k_o;
wire [12:0] ram_z80_address;
wire  [7:0] ram_z80_data;
wire        ram_z80_wren;
wire  [7:0] ram_z80_o;

wire [22:0] cart_addr;
wire        cart_cs, cart_oe, cart_lwr, cart_uwr;
wire [15:0] cart_data_wr;
wire        cart_data_en;

wire  [6:0] PA_i, PA_o, PA_d;
wire  [6:0] PB_i, PB_o, PB_d;
wire  [6:0] PC_i, PC_o, PC_d;

wire        vdp_hclk1, vdp_de_h, vdp_de_v, vdp_intfield;
wire        vdp_m2, vdp_m5, vdp_rs1;

wire  [8:0] MOL, MOR;
wire [15:0] PSG;

wire        reset = ~reset_n | cart_download;

// 68k RAM
dpram #(15,16) ram_68k (
    .clock(clk_sys),
    .address_a(ram_68k_address),
    .data_a(ram_68k_data),
    .wren_a(ram_68k_wren),
    .byteena_a(ram_68k_byteena),
    .q_a(ram_68k_o),
    .address_b(15'h0),
    .wren_b(1'b0)
);

// Z80 RAM
dpram #(13,8) ram_z80 (
    .clock(clk_sys),
    .address_a(ram_z80_address),
    .data_a(ram_z80_data),
    .wren_a(ram_z80_wren),
    .q_a(ram_z80_o),
    .address_b(13'h0),
    .wren_b(1'b0),
    .data_b(8'hC7)  // reset instruction
);

// Controller I/O
md_io md_io (
    .clk(clk_sys),
    .reset(reset),

    .MODE(1'b1),  // 6-button mode
    .SMS(1'b0),
    .MULTITAP(cs_multitap ? 2'b01 : 2'b00),

    .P1_UP(joystick_0[3]),
    .P1_DOWN(joystick_0[2]),
    .P1_LEFT(joystick_0[1]),
    .P1_RIGHT(joystick_0[0]),
    .P1_A(joystick_0[4]),
    .P1_B(joystick_0[5]),
    .P1_C(joystick_0[6]),
    .P1_START(joystick_0[7]),
    .P1_MODE(joystick_0[8]),
    .P1_X(joystick_0[9]),
    .P1_Y(joystick_0[10]),
    .P1_Z(joystick_0[11]),

    .P2_UP(joystick_1[3]),
    .P2_DOWN(joystick_1[2]),
    .P2_LEFT(joystick_1[1]),
    .P2_RIGHT(joystick_1[0]),
    .P2_A(joystick_1[4]),
    .P2_B(joystick_1[5]),
    .P2_C(joystick_1[6]),
    .P2_START(joystick_1[7]),
    .P2_MODE(joystick_1[8]),
    .P2_X(joystick_1[9]),
    .P2_Y(joystick_1[10]),
    .P2_Z(joystick_1[11]),

    .P3_UP(joystick_2[3]),
    .P3_DOWN(joystick_2[2]),
    .P3_LEFT(joystick_2[1]),
    .P3_RIGHT(joystick_2[0]),
    .P3_A(joystick_2[4]),
    .P3_B(joystick_2[5]),
    .P3_C(joystick_2[6]),
    .P3_START(joystick_2[7]),
    .P3_MODE(joystick_2[8]),
    .P3_X(joystick_2[9]),
    .P3_Y(joystick_2[10]),
    .P3_Z(joystick_2[11]),

    .P4_UP(joystick_3[3]),
    .P4_DOWN(joystick_3[2]),
    .P4_LEFT(joystick_3[1]),
    .P4_RIGHT(joystick_3[0]),
    .P4_A(joystick_3[4]),
    .P4_B(joystick_3[5]),
    .P4_C(joystick_3[6]),
    .P4_START(joystick_3[7]),
    .P4_MODE(joystick_3[8]),
    .P4_X(joystick_3[9]),
    .P4_Y(joystick_3[10]),
    .P4_Z(joystick_3[11]),

    .GUN_OPT(1'b0),
    .GUN_TYPE(1'b0),
    .GUN_SENSOR(1'b0),
    .GUN_A(1'b0),
    .GUN_B(1'b0),
    .GUN_C(1'b0),
    .GUN_START(1'b0),

    .MOUSE(25'h0),
    .MOUSE_OPT(3'h0),

    .jcart_data(16'hFFFF),
    .jcart_th(2'b00),

    .port1_out(PA_i),
    .port1_in(PA_o),
    .port1_dir(PA_d),

    .port2_out(PB_i),
    .port2_in(PB_o),
    .port2_dir(PB_d)
);

// TODO: Cartridge interface - connect to SDRAM
assign cart_data_en = 1'b0;  // Placeholder

// Nuked-MD board
md_board md_board (
    .MCLK2(clk_sys),
    .ext_reset(reset),
    .reset_button(1'b1),
    .ext_vres(1'b1),
    .ext_zres(1'b1),

    // 68k/z80 RAM
    .ram_68k_address(ram_68k_address),
    .ram_68k_byteena(ram_68k_byteena),
    .ram_68k_data(ram_68k_data),
    .ram_68k_wren(ram_68k_wren),
    .ram_68k_o(ram_68k_o),
    .ram_z80_address(ram_z80_address),
    .ram_z80_data(ram_z80_data),
    .ram_z80_wren(ram_z80_wren),
    .ram_z80_o(ram_z80_o),

    // Cart
    .M3(1'b1),  // Genesis mode
    .cart_data(16'h0),  // TODO: Connect to SDRAM
    .cart_data_en(cart_data_en),
    .cart_address(cart_addr),
    .cart_cs(cart_cs),
    .cart_oe(cart_oe),
    .cart_lwr(cart_lwr),
    .cart_uwr(cart_uwr),
    .cart_time(),
    .cart_cas2(),
    .cart_data_wr(cart_data_wr),
    .cart_dma(),
    .cart_m3_pause(1'b0),
    .ext_dtack(1'b1),
    .pal(1'b0),  // NTSC
    .jap(1'b0),  // US

    // TMSS
    .tmss_enable(1'b0),
    .tmss_data(16'h0),
    .tmss_address(),

    // Video
    .V_R(r),
    .V_G(g),
    .V_B(b),
    .V_HS(hs),
    .V_VS(vs),
    .V_CS(),

    // Audio
    .A_L(AUDIO_L),
    .A_R(AUDIO_R),
    .A_L_2612(),
    .A_R_2612(),
    .MOL(MOL),
    .MOR(MOR),
    .MOL_2612(),
    .MOR_2612(),
    .PSG(PSG),
    .DAC_ch_index(),
    .fm_sel23(),

    // Input
    .PA_i(PA_i),
    .PA_o(PA_o),
    .PA_d(PA_d),
    .PB_i(PB_i),
    .PB_o(PB_o),
    .PB_d(PB_d),
    .PC_i(7'h7f),
    .PC_o(PC_o),
    .PC_d(PC_d),

    // Helpers
    .vdp_hclk1(vdp_hclk1),
    .vdp_intfield(vdp_intfield),
    .vdp_de_h(vdp_de_h),
    .vdp_de_v(vdp_de_v),
    .vdp_m2(vdp_m2),
    .vdp_m5(vdp_m5),
    .vdp_rs1(vdp_rs1),
    .vdp_lcb(),
    .vdp_psg_clk1(),
    .vdp_cramdot_dis(1'b0),
    .fm_clk1(),
    .vdp_hsync2(),
    .ym2612_status_enable(1'b0),
    .dma_68k_req(1'b0),
    .dma_z80_req(1'b0),
    .dma_z80_ack(),
    .res_z80(),
    .vdp_dma_oe_early(),
    .vdp_dma()
);

// Video blanking signals
assign hblank = ~vdp_de_h;
assign vblank = ~vdp_de_v;
assign ce_pix = vdp_hclk1;

///////////////////////////////////////////////////
// Bridge read data mux
///////////////////////////////////////////////////

always @(*) begin
    casex(bridge_addr)
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    default: begin
        bridge_rd_data <= 0;
    end
    endcase
end

endmodule

// Simple dual-port RAM module
module dpram #(
    parameter ADDRWIDTH = 8,
    parameter DATAWIDTH = 8
) (
    input clock,
    input [ADDRWIDTH-1:0] address_a,
    input [DATAWIDTH-1:0] data_a,
    input wren_a,
    input [(DATAWIDTH/8)-1:0] byteena_a,
    output reg [DATAWIDTH-1:0] q_a,

    input [ADDRWIDTH-1:0] address_b,
    input [DATAWIDTH-1:0] data_b,
    input wren_b
);

reg [DATAWIDTH-1:0] ram[0:(1<<ADDRWIDTH)-1];

always @(posedge clock) begin
    if (wren_a) begin
        if (byteena_a[0]) ram[address_a][7:0] <= data_a[7:0];
        if (DATAWIDTH > 8 && byteena_a[1]) ram[address_a][15:8] <= data_a[15:8];
    end
    q_a <= ram[address_a];

    if (wren_b) ram[address_b] <= data_b;
end

endmodule

// Simple 3-stage synchronizer
module synch_3 #(parameter WIDTH=1) (
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out,
    input clk
);
reg [WIDTH-1:0] stage1, stage2, stage3;
always @(posedge clk) begin
    stage1 <= in;
    stage2 <= stage1;
    stage3 <= stage2;
end
assign out = stage3;
endmodule
