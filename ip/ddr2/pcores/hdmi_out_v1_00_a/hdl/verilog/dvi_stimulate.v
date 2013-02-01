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

localparam H_AV = H_1280_720p_AV;
localparam H_AV_FP = H_1280_720p_AV + H_1280_720p_FP;
localparam H_AV_FP_S = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S;
localparam H_AV_FP_S_BP = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S + H_1280_720p_BP;

localparam V_AV = V_1280_720p_AV;
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
    nextve = ve;

    // pixel/line counters and video data enable
    if (hcounter == H_AV_FP_S_BP - 1) 
        begin
        nexthcounter = 0;
        if (vcounter == V_AV_FP_S_BP - 1)
            nextvcounter = 0;
        else
            nextvcounter = vcounter + 1;
        end
    else
        nexthcounter = hcounter + 1;

    // sync pulse in sync phase
    if (hcounter >= H_AV_FP-1 && hcounter < H_AV_FP_S-1)
        begin
        nexthsync = 0;
        if (vcounter >= V_AV_FP && vcounter < V_AV_FP_S)
            nextvsync = 0;
        else
            nextvsync = 1;
        end
    else
        nexthsync = 1;

    //video data enable
    if ((hcounter == H_AV_FP_S_BP - 1 && (vcounter == V_AV_FP_S_BP - 1 || vcounter < V_AV - 1)) || (hcounter < H_AV - 1 && vcounter < V_AV))
        nextve = 1;
    else
        nextve = 0;
end

endmodule
