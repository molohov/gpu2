module fsm (
    // inputs
    input           clk,
    input           nreset,
    input           start,
    input [31:0]    fb_addr,
    input [31:0]    zbuff_addr,
    input [31:0]    y,
    input [31:0]    x1,
    input [31:0]    x2,
    input [31:0]    z1,
    input [31:0]    z2,

    // outputs
    output          rd_req,
    output          wr_req,
    output [31:0]   addr,
    output [1:0]    byteenable

);

    // ENGLISH LANGUAGE CODE:
    // 1. burst the maximum length (256 words) into a FIFO that is also 256 words long
    // 2. from x1 to x2
    //    2a. calculate the interpolated z value for the current x value 
    //    2b. check to see if the calculated z value is less than (therefore in front of) the existing z value
    //    2c. if it is, update the z-write FIFO as well as the byte-enable FIFO (which represents replaced or not replaced)
    // 3. burst write the z-line and use the byte-enable FIFO as byte-enables
    // 4. burst write the fb to the appropriate address (using the rgbx value) and reuse the byte-enable FIFO 
    // 5. subtract 256 from the length of the line = abs(x1 - x2)
    // 5. repeat until length of line = 0 

    // wires
    wire increment_offset

    // assignments
    assign increment_offset = (state == WR_FBUFF) ? 1 : 0;

    // guessing how many states there might be
    reg [2:0] state, nextstate; 
    reg [3:0] be, nextbe;
    reg [1:0] beindex, nextbeindex;
    reg [31:0] addr_offset, nextaddr_offset;

    // define states
    localparam  IDLE        = 3'd0, // reset state. 
                LOAD_ZBUFF  = 3'd1, // load zbuff MAX_LEN from pre calculated address 
                                    // and set AXI burst params accordingly
                TRAVERSE_X  = 3'd2,
                INTERP_Z    = 3'd3, // who knows how long this may take...
                                    // assume it can calculate and write values in the same 
                                    // state (1 z-value and 1 byte-enable per 4 cycles)
                WR_ZBUFF    = 3'd4, // burst the zbuffer and wait for completion
                WR_FBUFF    = 3'd5; // burst the framebuffer and wait for completion. 
                                    // calculate the next burst addr
    always @ (posedge clk)
    begin
        if (!nreset)
        begin
            state       <= IDLE;
            be          <= 4'd0;
            beindex     <= 2'd0;
            addr_offset <= 32'd0;
        end
        else
        begin
            state       <= nextstate;
            be          <= nextbe;
            beindex     <= nextbeindex;
            addr_offset <= nextaddr_offset;
        end
    end

    always @ (*)
    begin
        nextstate = state;
        nextbe = be;
        nextbeindex = beindex;

        case (state)
            IDLE:
            begin
                if (start)
                begin
                    nextstate = LOAD_ZBUFF;
                end
            end
            LOAD_ZBUFF:
            begin
            end
            TRAVERSE_X:
            begin
            end
            INTERP_Z:
            begin
            end
            WR_ZBUFF:
            begin
            end
            WR_FBUFF:
            begin
            end
        endcase
    end

endmodule
