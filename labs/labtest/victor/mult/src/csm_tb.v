module csm_tb (
  output [31:0] product,
  output reg [31:0] ref,
  output done
);

reg clk;
reg reset;
reg [15:0] mer;
reg [15:0] mand;
reg go;

initial
  clk <= 0;
always @ (clk)
  clk <= #10 ~clk;

initial begin
reset <= 1;
go <= 0;
@(negedge clk);
mer <= 16'b1111111111111111;
mand <= 16'b0000000001010101;
@(negedge clk);
go <= 1;
@(posedge done);
go <= 0;
ref <= 32'h0054ffab;
@(negedge clk);
$display("%x", product);
$display("%x", ref);
mer <= 16'b0000000000000001;
mand <= 16'b0000000001110110;
@(negedge clk);
go <= 1;
@(posedge done);
go <= 0;
ref <= 32'h00000076;
@(negedge clk);
$display("%x", product);
$display("%x", ref);
mer <= 16'b0000000000001111;
mand <= 16'b0000000000010001;
@(negedge clk);
go <= 1;
@(posedge done);
go <= 0;
ref <= 32'h000000ff;
@(negedge clk);
$display("%x", product);
$display("%x", ref);
mer <= 16'b 0000000001001110;
mand <= 16'b0000000000010001;
@(negedge clk);
go <= 1;
@(posedge done);
go <= 0;
ref <= 32'h0000052e;
@(negedge clk);
$display("%x", product);
$display("%x", ref);
$finish;
end

csm_top csm_inst(
  .mer(mer),
  .mand(mand),
  .product(product),

  .clk(clk),
  .reset(reset),

  .go(go),
  .done(done)
);

endmodule
