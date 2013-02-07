module hdmi_wrapper (
    input clock,
    input reset,
    input start,
    input [23:0] color,
    //input [31:0] resn,
    output TMDS_TX_CLK_P,
    output TMDS_TX_CLK_N,
    output TMDS_TX_2_P,
    output TMDS_TX_2_N,
    output TMDS_TX_1_P,
    output TMDS_TX_1_N,
    output TMDS_TX_0_P,
    output TMDS_TX_0_N,

);

wire hsync, vsync, vde;
wire Pclk, Pclk_x2, PClk_x10;
wire SerdesStrb;
wire [7:0] red = color[23:16];
wire [7:0] green = color[15:8];
wire [7:0] blue = color[7:0];

/* 800x600 for now */
localparam RES_SEL = R800_600P;
localparam DISP_RES = 0x00075300;

clk_gen clkgen_inst (
    .CLK_I (clock),
    .RST_I (reset),
    .RES_I (DISP_RES),
    .CLK_O (PClk),
    .CLK_X2_O (PClk_x2),
    .CLK_X10_O (PClk_x10),
    .SERSTRB_O (SerdesStrb),
    .READY_O ()
);

DVITransmitter dvitransmitter_inst (
    .RED_I (red),
    .GREEN_I (green),
    .BLUE_I (blue),
    .HS_I (hsync),
    .VS_I (vsync),
    .VDE_I (vde),
    .PCLK_I (PClk),
    .PCLK_X2_I (PClk_x2),
    .SERCLK_I (PClk_x10),
    .SERSTB_I (SerdesStrb),
    .TMDS_TX_CLK_P (TMDS_TX_CLK_P),
    .TMDS_TX_CLK_N (TMDS_TX_CLK_N),
    .TMDS_TX_2_P (TMDS_TX_2_P),
    .TMDS_TX_2_N (TMDS_TX_2_N),
    .TMDS_TX_1_P (TMDS_TX_1_P),
    .TMDS_TX_1_N (TMDS_TX_1_N),
    .TMDS_TX_0_P (TMDS_TX_0_P),
    .TMDS_TX_0_N (TMDS_TX_0_N)
);

VideoTimingCtl videotimingctl_inst (
    .PCLK_I (PClk),
    .RST_I (reset),
    .RSEL_I (RES_SEL),
    .VDE_O (vde),
    .HS_O (hsync),
    .VS_O (vsync),
    .HCNT_O (),
    .VCNT_O ()
);

endmodule
