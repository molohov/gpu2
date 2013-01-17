
module wrapper10k100 (
	address,
	data,
	clk,
	pclk,
	fc,
	as,
	reset,
	dtack,
	lds,
	uds,
	rw,

	srama,
	sramdl,
	sramdh,
	sram3dl,
	sram4dh,

	sram1en,
	sram2en,
	sram3en,
	sram4en,
	sram1oe,
	sram2oe,
	sram3oe,
	sram4oe,
	sram1we,
	sram2we,
	sram3we,
	sram4we,
	sram1ud,
	sram2ud,
	sram3ud,
	sram4ud,
	sram1ld,
	sram2ld,
	sram3ld,
	sram4ld,

	cod_sync,
	cod_sdin,
	cod_sdout,
	cod_lrsync,
	cod_sclk,

	br_sfpga,
	bg_sfpga,
	bgack_sfpga,
	irqsf,
	iacksf,

	videog,
	videor,
	videob,
	vidblank,
	vidclk,
	vsync,
	hsync,

	vidin_vpo,
	vidin_llc,
	vidin_rts0,
	vidin_vs,
	vidin_href,
	vidin_cref,
	vidin_sda,
	vidin_scl,

	hex0,
	hex1,
	hex2,
	hex3,
	sfpga_digital,
	sfpga_con40,
	sfpga_logic,
	sfpga_con60,
	led
);

input	[23:1]	address;
inout	[15:0]	data;
input			clk;
input			pclk;
input	[2:0]	fc;
input			as;
input			reset;
output			dtack;
input			lds;
input			uds;
input			rw;

input	[17:0]	srama;
input	[15:0]	sramdl;
input	[15:0]	sramdh;
input	[15:0]	sram3dl;
input	[15:0]	sram4dh;

input			sram1en;
input			sram2en;
input			sram3en;
input			sram4en;
input			sram1oe;
input			sram2oe;
input			sram3oe;
input			sram4oe;
input			sram1we;
input			sram2we;
input			sram3we;
input			sram4we;
input			sram1ud;
input			sram2ud;
input			sram3ud;
input			sram4ud;
input			sram1ld;
input			sram2ld;
input			sram3ld;
input			sram4ld;

input			cod_sync;
input			cod_sdin;
input			cod_sdout;
input			cod_lrsync;
input			cod_sclk;

input			br_sfpga;
input			bg_sfpga;
input			bgack_sfpga;
output			irqsf;
input			iacksf;

input	[7:0]	videog;
input	[7:0]	videor;
input	[7:0]	videob;
input			vidblank;
input			vidclk;
input			vsync;
input			hsync;

input	[15:0]	vidin_vpo;
input			vidin_llc;
input			vidin_rts0;
input			vidin_vs;
input			vidin_href;
input			vidin_cref;
input			vidin_sda;
input			vidin_scl;

input	[7:0]	hex0;
input	[7:0]	hex1;
input	[7:0]	hex2;
input	[7:0]	hex3;
input	[23:0]	sfpga_digital;
input	[31:0]	sfpga_con40;
input	[17:0]	sfpga_logic;
input	[51:0]	sfpga_con60;

output	[15:0]	led;

reg		[3:0]	dataled;
reg		[20:0]	count;

always @(posedge clk or negedge reset)
begin
	if (reset == 1'b0)
	begin
		count = 20'b000000000000000000000; 
	end
	else
	begin
		count = count + 1;
	end
end

always @(posedge clk or negedge reset)
begin
	if (reset == 1'b0)
	begin
			dataled <= 4'b0000;
	end
	else
	begin
		if (count == 20'b11111111111111111111)
		begin
			dataled = dataled + 1; 
		end
		else
		begin
			dataled = dataled;
		end
	end
end

assign led = ((dataled == 4'b0000) ? 16'b1111111111111110 : // led1
			((dataled == 4'b0001) ? 16'b1111111111111101 : // led2
			((dataled == 4'b0010) ? 16'b1111111111111011 : // led3
			((dataled == 4'b0011) ? 16'b1111111111110111 : // led4
			((dataled == 4'b0100) ? 16'b1111111111101111 : // led5
			((dataled == 4'b0101) ? 16'b1111111111011111 : // led6
			((dataled == 4'b0110) ? 16'b1111111110111111 : // led7
			((dataled == 4'b0111) ? 16'b1111111101111111 : // led8
			((dataled == 4'b1000) ? 16'b1111111011111111 : // led9
			((dataled == 4'b1001) ? 16'b1111110111111111 : // led10
			((dataled == 4'b1010) ? 16'b1111101111111111 : // led11
			((dataled == 4'b1011) ? 16'b1111011111111111 : // led12
			((dataled == 4'b1100) ? 16'b1110111111111111 : // led13
			((dataled == 4'b1101) ? 16'b1101111111111111 : // led14
			((dataled == 4'b1110) ? 16'b1011111111111111 : // led15
			((dataled == 4'b1111) ? 16'b0111111111111111 : // led16
          	16'b1111111111111111))))))))))))))));


my_top top_block
  (
   .i68k_address(address),
   .io68k_data(data),
   .i68k_clk(clk),
   .i68k_as_b(as),
   .i68k_lds_b(lds),
   .i68k_uds_b(uds),
   .i68k_reset_b(reset),
   .o68k_dtack_b(dtack),
   .i68k_rw(rw),
   .o68k_irq6_b(irqsf)
   );

   
endmodule


