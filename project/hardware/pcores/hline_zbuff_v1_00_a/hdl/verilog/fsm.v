module fsm (
    // inputs
    input           clk,
    input           nreset,
    input           start,
    input [31:0]    fb_addr,
    input [31:0]    zbuff_addr,
    input [31:0]    y,
    input [15:0]    x1,
    input [15:0]    x2,
    input [31:0]    slope,
    input [31:0]    z1,
    input [31:0]    z2,
    input           zread_empty,
    input [31:0]    zfifo_in,
    input [31:0]    rem,
    input [31:0]    err,
    input           axi_done,

    // outputs
    output          rd_req,
    output          wr_req,
    output [31:0]   addr,
    output          byteenable,
    output          read_zfifo,
    output          write_zfifo,
    output          write_befifo,
    output [31:0]   z_out,
    output          read_zbuffout_fifo,
    output          read_be_fifo
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

    // guessing how many states there might be
    reg [2:0] state, nextstate; 
    reg be, nextbe;
    reg writebe, nextwritebe;
    reg [31:0] addr_offset, nextaddr_offset;
    reg [15:0] xsum, nextxsum, xcnt, next_xcnt;
    reg [31:0] zsum, nextzsum;
    reg [31:0] error, nexterror;
    reg [31:0] dx, nextdx;

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

    // Mealy state machine assignments
    assign addr = (state == WR_ZBUFF) ? zbuff_addr + addr_offset : fb_addr + addr_offset; 
    assign rd_req = (state == LOAD_ZBUFF) && (xsum > 0);
    assign wr_req = (state == WR_ZBUFF || state == WR_FBUFF);
    assign read_zfifo = (state == INTERP_Z);
    assign write_zfifo = read_zfifo;
    assign z_out = zsum;
    assign read_zbuffout_fifo = (state == WR_ZBUFF);
    assign read_be_fifo = (state == WR_ZBUFF || state == WR_FBUFF);

    always @ (posedge clk)
    begin
        if (!nreset)
        begin
            state       <= IDLE;
            be          <= 4'd0;
            addr_offset <= 32'd0;
            xsum        <= 16'd0;
            zsum        <= 32'd0;
            xcnt        <= 16'd0;
            error       <= 32'd0;
            dx          <= 32'd0;
	    writebe     <= 1'd0;
        end
        else
        begin
            state       <= nextstate;
            be          <= nextbe;
            addr_offset <= nextaddr_offset;
            xsum        <= nextxsum;
            zsum        <= nextzsum;
            xcnt        <= next_xcnt;
            error       <= nexterror;
            dx          <= nextdx;
	    writebe     <= nextwritebe;
        end
    end

    always @ (*)
    begin
        nextstate = state;
        nextbe = be;
        nextaddr_offset = addr_offset;
        nextxsum = xsum;
        nextzsum = zsum;
        next_xcnt = xcnt;
        nexterror = error;
        nextdx = dx;
	nextwritebe = writebe;

        case (state)
            IDLE:
            begin
                if (start)
                begin
                    nextstate = LOAD_ZBUFF;
                    nextxsum = (x1 > x2) ? x1 - x2 : x2 - x1;
                    nextdx = nextxsum;
                    nextzsum = z1;
                end
            end
            LOAD_ZBUFF:
            begin
                if (xsum > 0)
                begin
                    nextxsum = xsum - 256;
                    next_xcnt = 256; 
                    nexterror = err + rem;
                    nextstate = TRAVERSE_X; 
                end
                else
                    nextstate = IDLE;
            end
            TRAVERSE_X:
            begin
                // wait for the fifo to have something
                if (!zread_empty)
                    nextstate = INTERP_Z;
            end
            INTERP_Z:
            // write a new z value every cycle (for 256 cycles)
            begin
                if (xcnt == 0)
		begin
                    nextstate = WR_ZBUFF;
		    nextwritebe = 1'd0;
		end    
                else
                begin
                    next_xcnt = xcnt - 1;
		    nextwritebe = 1'd1;
                    nextbe = (zsum < zfifo_in) ? 1'b1 : 1'b0;
                    nexterror = error + rem;
                    if (error > dx)
                    begin
                         nextzsum = zsum + slope + ((slope > 0) ? 1 : -1);
                         nexterror = error + rem - dx;
                    end
                    else
                         nextzsum = zsum + slope;
                end
            end
            WR_ZBUFF:
            begin
                // TODO: start the transfer with the correct go signal
                // wr_req is already high (mealy state machine)
                // control the read signals to the zbuff fifo 
                // poll the done signal from the AXI bus
                if (axi_done)
                    nextstate = WR_FBUFF;
                // TODO: clear the done bit
            end
            WR_FBUFF:
            begin
                // TODO: start the transfer, and clear the done bit when done
                if (axi_done)
                    nextstate = LOAD_ZBUFF;
            end
        endcase
    end

endmodule
