module fsm (
    // INPUTS
    input           clk,
    input           nreset,
    input           start,
    input [31:0]    fb_addr,
    input [31:0]    zbuff_addr,
    input [31:0]    dx,
    input [31:0]    slope,
    input [31:0]    z1,
    input [31:0]    rem,
    input [31:0]    err,
    input [31:0]    rgbx, 
    input [31:0]    z_fifo_in,
    input [31:0]    f_fifo_in,
    input           axi_done,

    // OUTPUTS
    // DEBUG
    output [3:0]    curr_state,
    output          start_out,
    // signals to AXI bus
    output          rd_req,
    output          wr_req,
    output [31:0]   addr,
    output          done,
    // signals to pcore FIFOs
    output          axi_bus_to_z_fifo,
    output          axi_bus_to_f_fifo,
    output          read_in_fifos,
    output          write_out_fifos,
    output          read_z_out_fifo,
    output          read_f_out_fifo,
    output [31:0]   z_out,
    output [31:0]   f_out,
    output [31:0]   z_sum_out
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
    reg [3:0] state, nextstate; 
    reg [31:0] addr_offset, nextaddr_offset, offset_tmp, nextoffset_tmp;
    // readcnt is reused in INTERP_Z as the counter for end of non-256 word aligned math
    reg [15:0] xsum, nextxsum, xcnt, nextxcnt, readcnt, nextreadcnt;
    reg [31:0] zsum, nextzsum;
    reg [31:0] error, nexterror;

    // define states
    localparam  RELAX_AND_CHILL = 4'd0,
                INIT        = 4'd1, // idle state. 
                LOOP_START  = 4'd2, // calculate the address to burst read from for fbuff and zbuff, and check 
                                    // to see if the loop will terminate or not
                LOAD_ZBUFF  = 4'd3, // issue rd_req from zbuff into zbuff_fifo
                LOAD_FBUFF  = 4'd4, // issue rd_req from fbuff into fbuff_fifo
                INTERP_Z    = 4'd5, // who knows how long this may take...
                                    // assume it can calculate and write values in the same 
                                    // state (1 z-value and 1 byte-enable per 4 cycles)
                WR_ZBUFF    = 4'd6, // burst the zbuffer and wait for completion
                WR_FBUFF    = 4'd7, // burst the framebuffer and wait for completion. 
                                    // calculate the next burst addr
                DONE        = 4'd8; // self explanatory

    // Mealy state machine assignments
    assign addr = (state == WR_FBUFF || state == LOAD_FBUFF) ? fb_addr + addr_offset : zbuff_addr + addr_offset; 
    assign rd_req = (state == LOAD_ZBUFF || state == LOAD_FBUFF) & !axi_done;
    assign wr_req = (state == WR_ZBUFF || state == WR_FBUFF) & !axi_done;
    assign read_in_fifos = (state == INTERP_Z) && (xcnt != 0);
    assign write_out_fifos = read_in_fifos;
    assign z_out = (zsum < z_fifo_in) & (readcnt > 0) ? zsum : z_fifo_in;
    assign f_out = (zsum < z_fifo_in) & (readcnt > 0) ? rgbx : f_fifo_in;
    assign read_z_out_fifo = (state == WR_ZBUFF);
    assign read_f_out_fifo = (state == WR_FBUFF);
    assign axi_bus_to_z_fifo = (state == LOAD_ZBUFF);
    assign axi_bus_to_f_fifo = (state == LOAD_FBUFF);
    assign done = (state == DONE);
    //only valid when in DONE
    assign z_sum_out = zsum;

    assign curr_state = state;
    assign start_out = start;
 
    always @ (posedge clk)
    begin
        if (!nreset)
        begin
            state       <= RELAX_AND_CHILL;
            addr_offset <= 32'd0;
            xsum        <= 16'd0;
            zsum        <= 32'd0;
            xcnt        <= 16'd0;
            error       <= 32'd0;
            readcnt     <= 16'd0;
            offset_tmp  <= 32'd0;
        end
        else
        begin
            state       <= nextstate;
            addr_offset <= nextaddr_offset;
            xsum        <= nextxsum;
            zsum        <= nextzsum;
            xcnt        <= nextxcnt;
            error       <= nexterror;
            readcnt     <= nextreadcnt;
            offset_tmp  <= nextoffset_tmp;
        end
    end

    always @ (*)
    begin
        nextstate = state;
        nextaddr_offset = addr_offset;
        nextxsum = xsum;
        nextzsum = zsum;
        nextxcnt = xcnt;
        nexterror = error;
        nextreadcnt = readcnt;
        nextoffset_tmp = offset_tmp;

        case (state)
            RELAX_AND_CHILL:
            begin
                if (start)
                    nextstate = INIT;
            end
            INIT:
            begin
                nextstate = LOOP_START;
                nextxsum = dx; // dx is precalculated by sw
                nextzsum = z1;
                nextaddr_offset = 32'd0;
            end
            LOOP_START:
            begin
                if (xsum > 0)
                begin
                    nextxsum = xsum - 256;
                    nextxcnt = 256; 
                    nexterror = err + rem;
                    nextstate = LOAD_ZBUFF; 
                    nextreadcnt = 16'd0;
                    nextoffset_tmp = addr_offset;
                end
                else
                    nextstate = DONE;
            end
            LOAD_ZBUFF:
            begin
                // wait for AXI completion
                if (axi_done)
                begin
                    nextreadcnt = readcnt + 1;
                    nextaddr_offset = addr_offset + 16;
                    if (nextreadcnt == 64)
                    begin
                        nextreadcnt = 16'd0;
                        nextaddr_offset = offset_tmp;
                        nextstate = LOAD_FBUFF;
                    end
                end
            end
            LOAD_FBUFF:
            begin
                // wait for AXI completion
                if (axi_done)
                begin
                    nextreadcnt = readcnt + 1;
                    nextaddr_offset = addr_offset + 16;
                    if (nextreadcnt == 64)
                    begin
                        if (xsum < 0)
                            nextreadcnt = 16'd256 + xsum;
                        else
                            nextreadcnt = 16'd256;
                        nextaddr_offset = offset_tmp;
                        nextstate = INTERP_Z;
                    end
                end
            end
            INTERP_Z:
            // write a new z value every cycle (for 256 cycles)
            begin
                if (xcnt == 0)
                    nextstate = WR_ZBUFF;
                else
                begin
                    nextxcnt = xcnt - 1;
                    nextreadcnt = readcnt - 1;
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
                // wait for AXI completion
                if (axi_done)
                    nextstate = WR_FBUFF;
            end
            WR_FBUFF:
            begin
                // wait for AXI completion
                if (axi_done)
                begin
                    nextstate = LOOP_START;
                    nextaddr_offset = addr_offset + 32'd256;
                end
            end
            DONE: 
            begin
                if (start)
                nextstate = INIT;
            end    
        endcase
    end

endmodule
