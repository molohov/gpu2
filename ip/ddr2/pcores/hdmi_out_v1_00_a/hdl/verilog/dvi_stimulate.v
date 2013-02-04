module dvi_stimulate (
	input clock,
	input reset,
	input start,
	output hsync_out,
	output vsync_out,
	output reg ve
);

localparam RESET = 2'b00, HSYNC = 2'b01, ACTIVE = 2'b10, DONE = 2'b11; 

localparam H_1280_720p_S = 40;		//sync
localparam H_1280_720p_FP = 110; 	//front porch
localparam H_1280_720p_AV = 1280; 	//active video
localparam H_1280_720p_BP = 220;	//back porch
//vertical localparams
localparam V_1280_720p_S = 5;		//sync
localparam V_1280_720p_FP = 5; 	//front porch
localparam V_1280_720p_AV = 720; 	//active video
localparam V_1280_720p_BP = 20;	//back porch

localparam H_1280_720p_POL = 1; // positive polarity
localparam V_1280_720p_POL = 1; // positive polarity

localparam H_800_600p_S = 128;		//sync
localparam H_800_600p_FP = 40; 	//front porch
localparam H_800_600p_AV = 800; 	//active video
localparam H_800_600p_BP = 88;	//back porch

localparam V_800_600p_S = 4;		//sync
localparam V_800_600p_FP = 1; 	//front porch
localparam V_800_600p_AV = 600; 	//active video
localparam V_800_600p_BP = 23;	//back porch

localparam H_800_600p_POL = 1; // positive polarity
localparam V_800_600p_POL = 1; // positive polarity

/*
localparam H_AV = H_1280_720p_AV;
localparam H_AV_FP = H_1280_720p_AV + H_1280_720p_FP;
localparam H_AV_FP_S = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S;
localparam H_AV_FP_S_BP = H_1280_720p_AV + H_1280_720p_FP + H_1280_720p_S + H_1280_720p_BP;
localparam H_POL = H_1280_720p_POL; 

localparam V_AV = V_1280_720p_AV;
localparam V_AV_FP = V_1280_720p_AV + V_1280_720p_FP;
localparam V_AV_FP_S = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S;
localparam V_AV_FP_S_BP = V_1280_720p_AV + V_1280_720p_FP + V_1280_720p_S + V_1280_720p_BP;
localparam V_POL = V_1280_720p_POL; 
*/

localparam H_AV = H_800_600p_AV;
localparam H_AV_FP = H_800_600p_AV + H_800_600p_FP;
localparam H_AV_FP_S = H_800_600p_AV + H_800_600p_FP + H_800_600p_S;
localparam H_AV_FP_S_BP = H_800_600p_AV + H_800_600p_FP + H_800_600p_S + H_800_600p_BP;
localparam H_POL = H_800_600p_POL; 

localparam V_AV = V_800_600p_AV;
localparam V_AV_FP = V_800_600p_AV + V_800_600p_FP;
localparam V_AV_FP_S = V_800_600p_AV + V_800_600p_FP + V_800_600p_S;
localparam V_AV_FP_S_BP = V_800_600p_AV + V_800_600p_FP + V_800_600p_S + V_800_600p_BP;
localparam V_POL = V_800_600p_POL; 

reg [1:0] state, nextstate;
reg [10:0] hcounter, nexthcounter;
reg [9:0] vcounter, nextvcounter;
reg nexthsync, nextvsync;
reg nextve, hsync, vsync;

assign hsync_out = hsync ^ H_POL;
assign vsync_out = vsync ^ V_POL;

always @ (posedge clock)
begin
    if (reset)
    begin
        state <= RESET;
        hsync <= 1;
        vsync <= 1;
        hcounter <= H_AV_FP_S_BP - 1;
        vcounter <= V_AV_FP_S_BP - 1;
        ve <= 0;
    end
    else
    begin
        state <= nextstate;
        hsync <= nexthsync;
        vsync <= nextvsync;
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
