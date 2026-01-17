//
// Save RAM Handler for Mega Drive
// Handles loading and saving of battery-backed SRAM
//

module save_handler (
    input  logic        clk_74a,
    input  logic        clk_sys,
    input  logic        reset,

    input  logic        bridge_rd,
    input  logic        bridge_wr,
    input  logic        bridge_endian_little,
    input  logic [31:0] bridge_addr,
    input  logic [31:0] bridge_wr_data,
    output logic [31:0] bridge_rd_data,

    // Save RAM interface
    output logic        bk_wr,
    output logic [16:0] bk_addr,
    output logic [15:0] bk_data,
    input  logic [15:0] bk_q,

    input  logic        cart_download
);

    logic [17:0] loader_addr;
    logic [17:0] unloader_addr;
    logic [15:0] unloader_din;
    logic [15:0] bk_data_int;
    logic        write_en;

    // Data unloader - reads save RAM back to APF
    data_unloader #(
        .ADDRESS_MASK_UPPER_4 (4'h6),
        .ADDRESS_SIZE         (18),
        .READ_MEM_CLOCK_DELAY (15),
        .INPUT_WORD_SIZE      (2)
    ) save_data_unloader (
        .clk_74a              (clk_74a),
        .clk_memory           (clk_sys),

        .bridge_rd            (bridge_rd),
        .bridge_endian_little (bridge_endian_little),
        .bridge_addr          (bridge_addr),
        .bridge_rd_data       (bridge_rd_data),

        .read_en              (),
        .read_addr            (unloader_addr),
        .read_data            (unloader_din)
    );

    // Data loader - writes save data from APF to save RAM
    data_loader #(
        .ADDRESS_MASK_UPPER_4       (4'h6),
        .ADDRESS_SIZE               (18),
        .WRITE_MEM_CLOCK_DELAY      (15),
        .WRITE_MEM_EN_CYCLE_LENGTH  (3),
        .OUTPUT_WORD_SIZE           (2)
    ) save_data_loader (
        .clk_74a              (clk_74a),
        .clk_memory           (clk_sys),

        .bridge_wr            (bridge_wr),
        .bridge_endian_little (bridge_endian_little),
        .bridge_addr          (bridge_addr),
        .bridge_wr_data       (bridge_wr_data),

        .write_en             (write_en),
        .write_addr           (loader_addr),
        .write_data           (bk_data_int)
    );

    // Address multiplexing - loader during save load, unloader during save read
    always_comb begin
        if (write_en) begin
            bk_addr = loader_addr[17:1];
            bk_wr = 1'b1;
            bk_data = bk_data_int;
        end else begin
            bk_addr = unloader_addr[17:1];
            bk_wr = 1'b0;
            bk_data = 16'h0;
        end
    end

    // Data readback
    assign unloader_din = bk_q;

endmodule
