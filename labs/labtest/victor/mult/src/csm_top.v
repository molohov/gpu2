/* This is a carry save multiplier. */

module csm_top(mer, mand, product, reset, clk, go, done);
	input [15:0] mer;
	input [15:0] mand;
	output reg [31:0] product;

	input clk;
	input reset;

	input go;
	output done;

	wire [13:0] carry;
	wire [31:16] product_wire;

	reg [15:0] ina;
	reg [15:0] inb;
	reg [15:0] cin;
	reg [15:0] sin;
	reg        csb;
	wire [15:0] sout;
	wire [15:0] cout;

	reg [4:0] cur_state = 5'd0;

	assign done = (cur_state == 5'd18);

	// assign cur_state to the next state
	always@(posedge clk)
	begin
		$display("product: %b", product);

		if (!reset || cur_state == 5'd18)
			cur_state <= 5'd0;
		else
			if (go || cur_state != 5'd0)
				cur_state <= cur_state + 5'd1;
			else
				cur_state <= cur_state;
	end

	// register inputs and assign product accordingly
	always@(posedge clk)
	begin
		if (cur_state == 5'd0 && go)
		begin
			ina <= mer;
			inb <= mand;
			product <= 0;
		end
		else if (cur_state == 5'd17)
			product[31:16] <= product_wire;
	end

	// case-dependant logic
	always@(posedge clk)
	begin
		case (cur_state)
			5'd1:
			begin
				cin <= 16'h0000;
				sin <= 16'h0000;
				csb <= inb[0];
			end
			5'd2:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[1];
				product[0] <= sout[0];
			end
			5'd3:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[2];
				product[1] <= sout[0];
			end
			5'd4:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[3];
				product[2] <= sout[0];
			end
			5'd5:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[4];
				product[3] <= sout[0];
			end
			5'd6:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[5];
				product[4] <= sout[0];
			end
			5'd7:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[6];
				product[5] <= sout[0];
			end
			5'd8:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[7];
				product[6] <= sout[0];
			end
			5'd9:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[8];
				product[7] <= sout[0];
			end
			5'd10:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[9];
				product[8] <= sout[0];
			end
			5'd11:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[10];
				product[9] <= sout[0];
			end
			5'd12:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[11];
				product[10] <= sout[0];
			end
			5'd13:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[12];
				product[11] <= sout[0];
			end
			5'd14:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[13];
				product[12] <= sout[0];
			end
			5'd15:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[14];
				product[13] <= sout[0];
			end
			5'd16:
			begin
				cin <= cout;
				sin <= {1'b0, sout[15:1]};
				csb <= inb[15];
				product[14] <= sout[0];
			end
			5'd17:
			begin
				cin <= 0;
				sin <= 0;
				csb <= 0;
				product[15] <= sout[0];
			end
			default:
			begin
				cin <= 0;
				sin <= 0;
				csb <= 0;
			end
		endcase
	end

	carrySave cs(cin, sin, ina, csb, cout, sout);

        ha a0(cout[0], sout[1], carry[0], product_wire[16]);
        fa a1(cout[1], sout[2], carry[0], carry[1], product_wire[17]);
        fa a2(cout[2], sout[3], carry[1], carry[2], product_wire[18]);
        fa a3(cout[3], sout[4], carry[2], carry[3], product_wire[19]);
        fa a4(cout[4], sout[5], carry[3], carry[4], product_wire[20]);
        fa a5(cout[5], sout[6], carry[4], carry[5], product_wire[21]);
        fa a6(cout[6], sout[7], carry[5], carry[6], product_wire[22]);
        fa a7(cout[7], sout[8], carry[6], carry[7], product_wire[23]);
        fa a8(cout[8], sout[9], carry[7], carry[8], product_wire[24]);
        fa a9(cout[9], sout[10], carry[8], carry[9], product_wire[25]);
        fa aa(cout[10], sout[11], carry[9], carry[10], product_wire[26]);
        fa ab(cout[11], sout[12], carry[10], carry[11], product_wire[27]);
        fa ac(cout[12], sout[13], carry[11], carry[12], product_wire[28]);
        fa ad(cout[13], sout[14], carry[12], carry[13], product_wire[29]);
        fa ae(cout[14], sout[15], carry[13], product_wire[31], product_wire[30]);
	
endmodule

