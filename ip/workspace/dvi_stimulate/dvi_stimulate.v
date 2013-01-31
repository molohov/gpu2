module dvi_stimulate (
	input clock,
	input reset,
	input start,
	output reg [7:0] red,
	output reg [7:0] blue,
	output reg [7:0] green,
	output reg hsync,
	output reg vsync,
	output reg ve
);

localparam RESET = 2'b00, HSYNC = 2'b01, ACTIVE = 2'b10, DONE = 2'b11; 
localparam WIDTH = 10, HEIGHT = 10;

localparam H_1280_720p_S = 40;		//sync
localparam H_1280_720p_FP = 110; 	//front porch
localparam H_1280_720p_AV = 1280; 	//active video
localparam H_1280_720p_BP = 220;	//back porch
//vertical localparams
localparam V_1280_720p_S = 5;		//sync
localparam V_1280_720p_FP = 5; 	//front porch
localparam V_1280_720p_AV = 720; 	//active video
localparam V_1280_720p_BP = 20;	//back porch

/*
localparam H_1280_720p_AV_FP = H_1280_720p_AV + H_1280_720p_FP;
localparam H_1280_720p_AV_FP_S = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S;
localparam H_1280_720p_AV_FP_S_BP = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S + H_1280_720p_BP;

localparam V_1280_720p_AV_FP = V_1280_720p_AV + V_1280_720p_FP;
localparam V_1280_720p_AV_FP_S = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S;
localparam V_1280_720p_AV_FP_S_BP = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S + V_1280_720p_BP;
*/

localparam H_AV_FP = H_1280_720p_AV + H_1280_720p_FP;
localparam H_AV_FP_S = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S;
localparam H_AV_FP_S_BP = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S + H_1280_720p_BP;

localparam V_AV_FP = V_1280_720p_AV + V_1280_720p_FP;
localparam V_AV_FP_S = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S;
localparam V_AV_FP_S_BP = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S + V_1280_720p_BP;

//localparam H_1280_720p_POL : BOOLEAN := true; // positive polarity
//localparam V_1280_720p_POL : BOOLEAN := true; // positive polarity


reg [1:0] state, nextstate;
reg [10:0] hcounter, nexthcounter;
reg [9:0] vcounter, nextvcounter;
reg nexthsync, nextvsync;
reg [7:0] nextred, nextgreen, nextblue;
reg nextve;

always @ (posedge clock)
begin
	if (reset)
	begin
		nexthcounter <= H_AV_FP_S_BP - 1;
		nextvcounter <= V_AV_FP_S_BP - 1;
		nextv


process (PCLK_I)
begin
	if Rising_Edge(PCLK_I) then
		if (SRst = '1') then
			HCnt <= H_AV_FP_S_BP - 1; -- 0 is an active pixel
			VCnt <= V_AV_FP_S_BP - 1;
			vde <= '0';
			hs <= '1';
			vs <= '1';
		else
			--pixel/line counters and video data enable
			if (HCnt = H_AV_FP_S_BP - 1) then
				HCnt <= 0;
				if (VCnt = V_AV_FP_S_BP - 1) then
					VCnt <= 0;
				else
					VCnt <= VCnt + 1;
				end if;
			else
				HCnt <= HCnt + 1;
			end if;
			
			--sync pulse in sync phase
			if (HCnt >= H_AV_FP-1) and (HCnt < H_AV_FP_S-1) then -- one cycle earlier (registered)
				hs <= '0';
				if (VCnt >= V_AV_FP) and (VCnt < V_AV_FP_S) then
					vs <= '0';
				else
					vs <= '1';
				end if;				
			else
				hs <= '1';
			end if;
			
			--video data enable
			if ((HCnt = H_AV_FP_S_BP - 1 and (VCnt = V_AV_FP_S_BP - 1 or VCnt < V_AV - 1)) or -- first pixel in frame
				 (HCnt < H_AV - 1 and VCnt < V_AV)) then
				vde <= '1';
			else
				vde <= '0';
			end if;
		end if;
	end if;
end process;


always @ (posedge clock)
begin
	if (reset)
	begin
		state <= RESET;
		hsync <= 1;
		vsync <= 1;
		red <= 0;
		green <= 0;
		blue <= 0;
		hcounter <= H_AV_FP_S_BP - 1;
		vcounter <= V_AV_FP_S_BP - 1;
		ve <= 0;
	end
        else
	begin
		state <= nextstate;
		hsync <= nexthsync;
		vsync <= nextvsync;
		red <= nextred;
		green <= nextgreen;
		blue <= nextblue;
		hcounter <= nexthcounter;
		vcounter <= nextvcounter;
		ve <= nextve;
	end
end

always @ (*)
begin
	nextstate = state;
	nexthsync = hsync;
	nextvsync = vsync;
	nextred = red;
	nextblue = blue;
	nextgreen = green;
	nexthcounter = hcounter;
	nextvcounter = vcounter;
		case (state)
			RESET:
			begin
				if (start)
				begin
					nextstate = HSYNC;
					nexthsync = 1'b1;
				end
			end
			HSYNC:
			begin
				nexthsync = 1'b0;
				if (vcounter == HEIGHT)
				begin
					nextstate = DONE;
					nextvsync = 1;
				end
				else
				begin
					nextred = 8'b00000000;
					nextblue = 8'b11111111;
					nexthcounter = hcounter + 1;
					nextstate = ACTIVE;
				end
			end
			ACTIVE:
			begin
				nextred = 8'b11111111;
                                nexthcounter = hcounter + 1;
				if (hcounter == WIDTH)
				begin
					nexthcounter = 0;
					nexthsync = 1;
					nextvcounter = vcounter + 1;
					nextstate = HSYNC;
				end
			end
			DONE:
			begin
				//do nothing until reset
			end
		endcase
end

endmodule
