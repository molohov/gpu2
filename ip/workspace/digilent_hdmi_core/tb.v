module tb (
     output TMDS_TX_CLK_P,
     output TMDS_TX_CLK_N,
     output TMDS_TX_2_P,
     output TMDS_TX_2_N,
     output TMDS_TX_1_P,
     output TMDS_TX_1_N,
     output TMDS_TX_0_P,
     output TMDS_TX_0_N
);

reg clock;
reg reset;
reg start;

initial clock = 0;
initial start = 0;

always #100 clock = ~clock;

hdmi_wrapper hdmi_dut (
     .clock (clock),
     .reset (reset),
     .start (start),
     .color (24'h00112233),
     //.resn,
     .TMDS_TX_CLK_P (TMDS_TX_CLK_P),
     .TMDS_TX_CLK_N (TMDS_TX_CLK_N),
     .TMDS_TX_2_P (TMDS_TX_2_P),
     .TMDS_TX_2_N (TMDS_TX_2_N),
     .TMDS_TX_1_P (TMDS_TX_1_P),
     .TMDS_TX_1_N (TMDS_TX_1_N),
     .TMDS_TX_0_P (TMDS_TX_0_P),
     .TMDS_TX_0_N (TMDS_TX_0_N)
);

initial
begin
	@ (negedge clock)
	reset = 1;
	@ (negedge clock)
    reset = 0;
	start = 1;
end

endmodule
