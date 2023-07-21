//step 
// read all data from 0~16382
// store data to r g b
// caculater from 0~16382 and store RGB to 0~16382

module demosaic(clk, reset, in_en, data_in, wr_r, addr_r, wdata_r, rdata_r, wr_g, addr_g, wdata_g, rdata_g, wr_b, addr_b, wdata_b, rdata_b, done);
input clk;
input reset;
input in_en;
input [7:0] data_in;
output reg wr_r;
output reg [13:0] addr_r;
output reg [7:0] wdata_r;
input [7:0] rdata_r;
output reg wr_g;
output reg [13:0] addr_g;
output reg [7:0] wdata_g;
input [7:0] rdata_g;
output reg wr_b;
output reg [13:0] addr_b;
output reg [7:0] wdata_b;
input [7:0] rdata_b;
output reg done;

reg [7:0] read_rgb;
reg [14:0] center;

reg[2:0] now_state;
reg[2:0] next_state;
reg [2:0] situation;
reg [3:0] index;
reg [13:0] read_to_buffer;
reg [9:0] bufer_r [0:7];
reg [9:0] bufer_g [0:7];
reg [9:0] bufer_b [0:7];

localparam READ_RGB = 3'd0; //000
localparam SET = 3'd1; //001
localparam GET_VALUE = 3'd2; //010
localparam STORE_BUFFER = 3'd3; //011
localparam STORE_RGB = 3'd4; //100
localparam FINISH = 3'd5; //101

always @(posedge clk or posedge reset) begin
	if(reset) now_state <= READ_RGB;
	else now_state <= next_state;
end
always @(*)begin
    case(now_state)
    READ_RGB : next_state = (center > 16382)?SET:READ_RGB;
    SET : next_state = GET_VALUE;
    GET_VALUE : next_state = STORE_BUFFER;
    STORE_BUFFER : next_state = (index > 7)?STORE_RGB:STORE_BUFFER;
    STORE_RGB : next_state = (center > 16254)?FINISH:GET_VALUE;
    FINISH : next_state = FINISH;
endcase
end
always@(posedge clk or posedge reset)begin
    if(reset)begin
        center <= 0;
        done <= 0;
        index <= 0;
        wr_r <= 0;
        wr_g <= 0;
        wr_b <= 0;
    end
    else begin
        case(now_state)
        READ_RGB : begin //000
            case(center[7])
                0 : begin
                    if(center[0] == 0)begin
                        wr_g <= 1;
                        addr_g <= center;
                        wdata_g <= data_in;
                    end
                    else begin 
                        wr_r <= 1;
                        addr_r <= center;
                        wdata_r <= data_in;
                    end
                end
                1 : begin
                    if(center[0] == 0)begin
                        wr_b <= 1;
                        addr_b <= center;
                        wdata_b <= data_in;
                    end
                    else begin 
                        wr_g <= 1;
                        addr_g <= center;
                        wdata_g <= data_in;
                    end
                end
                endcase
            center <= center + 1;
        end
        SET: begin //001
            center <= 129;
            wr_r <= 0;
            wr_g <= 0;
            wr_b <= 0;
        end
        GET_VALUE : begin //010
            wr_r <= 0;
            wr_g <= 0;
            wr_b <= 0;
            if((center[13:7] == 0) || (center[13:7] == 127) || (center[6:0] == 0) || (center[6:0] == 127))begin
                situation <= 0;
            end
            else begin
                case(center[7])
                    0 : begin
                    if(center[0] == 0)
                        situation <= 1; //rgr
                    else
                        situation <= 2; //grg
                    end
                    1 : begin
                    if(center[0] == 0)
                        situation <= 3; //gbg
                    else
                        situation <= 4; //bgb
                end
                endcase

                addr_r <= center - 129;
                addr_g <= center - 129;
                addr_b <= center - 129;
                index <= 0;
            end
        end
          
        STORE_BUFFER : begin //011
            bufer_r[index] <= rdata_r;
            bufer_b[index] <= rdata_b;
            bufer_g[index] <= rdata_g;
            case(index)
            0,1,5,6 : begin
                addr_r <= addr_r + 1;
                addr_g <= addr_g + 1;
                addr_b <= addr_b + 1;
            end
            2,4 : begin
                addr_r <= addr_r + 126;
                addr_g <= addr_g + 126;
                addr_b <= addr_b + 126;
            end
            3 : begin
                addr_r <= addr_r + 2;
                addr_g <= addr_g + 2;
                addr_b <= addr_b + 2;
            end
            endcase
            index <= index + 1;
        end
        STORE_RGB : begin //100
            //wr_r <= 1;
            case(situation)
            1 : begin
                wr_r <= 1;
                wr_b <= 1;
                addr_r <= center;
                addr_b <= center;
                wdata_r <= ((bufer_r[3] + bufer_r[4]) >> 1);
                wdata_b <= ((bufer_b[1] + bufer_b[6]) >> 1);
            end
            2 : begin
                wr_g <= 1;
                wr_b <= 1;
                addr_g <= center;
                addr_b <= center;
                wdata_g <= ((bufer_g[1] + bufer_g[3] + bufer_g[4] + bufer_g[6]) >> 2);
                // wdata_g <= ((bufer_g[3] + bufer_g[4]));
                wdata_b <= ((bufer_b[0] + bufer_b[2] + bufer_b[5] + bufer_b[7]) >> 2);
            end
            3 : begin
                wr_r <= 1;
                wr_g <= 1;
                addr_r <= center;
                addr_g <= center;
                wdata_r <= ((bufer_r[0] + bufer_r[2] + bufer_r[5] + bufer_r[7]) >> 2);
                wdata_g <= ((bufer_g[1] + bufer_g[3] + bufer_g[4] + bufer_g[6]) >> 2);
            end
            4 : begin
                wr_r <= 1;
                wr_b <= 1;
                addr_r <= center;
                addr_b <= center;
                wdata_r <= ((bufer_r[1] + bufer_r[6]) >> 1);
                wdata_b <= ((bufer_b[3] + bufer_b[4]) >> 1);
            end
            default:begin
            end
            endcase
            center <= center + 1;
        end   
        FINISH : begin //101
            done <= 1;
        end 
        endcase
    end
end
endmodule
