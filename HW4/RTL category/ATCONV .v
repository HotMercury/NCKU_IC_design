`timescale 1ns/10ps

module  ATCONV(

	input		clk,

	input		reset,

	output	reg	busy,	

	input		ready,	

			

	output reg	[11:0]	iaddr,

	input signed [12:0]	idata,

	

	output	reg 	cwr,

	output  reg	[11:0]	caddr_wr,

	output reg 	[12:0] 	cdata_wr,

	

	output	reg 	crd,

	output reg	[11:0] 	caddr_rd,

	input 	[12:0] 	cdata_rd,

	

	output reg 	csel

	);



//=================================================

//            write your design below

//=================================================

//implement method 

//reset -> PICK 選出9個pixel place 且選出index

//PICK -> CATCHPIXEL 做9個cycle 得到精確值

//CATCHPIXEL -> PREKERNEL 做1個cycle bus cwr值

//PREKERNEL -> KERNEL CNN + bias + reLu



//max polling

//無條件進位



reg [4:0] nowState,nextState;

reg [12:0] index;

reg [7:0] row;

reg [7:0] col;

reg [5:0] local9;

reg [12:0] pixelval [0:8];

reg [12:0] find [0:7];

reg [12:0] polladdr[0:3];

reg [12:0] pollval[0:3];

reg [6:0] index_i;

reg [6:0] index_j;

reg [2:0] max_index;

reg [10:0] index_layer1;



parameter RESET    = 4'd0,

		  PICK    = 4'd1,

		  CATCHPIXEL   = 4'd2,

		  PREKERNEL  = 4'd3,

		  KERNEL    = 4'd4,

		  K     = 4'd5,

		  FINAL = 4'd6,

		  LAYER1VAL = 4'd7,

		  LAYER1PREWRI = 4'd8,

		  LAYER1CAL = 4'd9,

		  LAST = 4'd10;







always@(posedge clk or posedge reset)begin

	//if reset

	//ready set to 0  代表gray已完成

	//busy set to 1	  當busy為1時，代表gray可以被取得 so ready set to 0

	if(reset)begin

		nowState <= RESET;

		iaddr<=12'd0;

		index <= 0;

 		local9 <= 0;

 		row <= 0;

		col <= 0;

		csel <= 0;

		cwr <= 0;

		busy <= 0;

		index_i <= 0;

		index_j <= 0;

		max_index <= 0;

		index_layer1 <= 0;

	end

	else begin

		nowState <= nextState;

		case(nowState)

			RESET:begin

				if(ready == 1)

					busy <= 1;

			end

			FINAL:begin

			end

			//抓9個pixel place

			PICK:begin

				//左上

				iaddr <= ((row << 6) + col);

				if((row < 2) && (col < 2))begin

					find[0] <= 0;

				end

				else if(row == 1 || row == 0)begin

					find[0] <= (col - 2);

				end

				else if(col == 1 || col == 0)begin

					find[0] <= ((row - 2)<<6);

				end

				else begin

					find[0] <= (((row - 2) << 6) + (col - 2));

				end



				//上

				if(row == 1 || row == 0)begin

					find[1] <= col;

				end

				else begin

					find[1] <= (((row - 2) << 6) + col);

				end



				//右上

				if((row == 1 || row == 0) && (col + 2 )> 63)begin

					find[2] <= 63;

				end

				else if((row == 1 || row == 0))begin

					find[2] <= (col + 2);

				end

				else if(col + 2 > 63)begin

					find[2] <= (((row - 2) << 6 )+ 63);

				end

				else begin

					find[2] <= (((row - 2) << 6) + (col + 2));

				end



				//左

				if(col == 1 || col == 0)begin

					find[3] <= (row << 6);

				end

				else begin

					find[3] <= ((row << 6) +( col - 2));

				end



				//右

				if(col + 2 > 63)begin

					find[4] <= ((row << 6) + 63);

				end

				else begin

					find[4] <= ((row << 6) + (col + 2));

				end

				

				//左下

				if(((row + 2) > 63) && (col == 1 || col == 0))begin

					find[5] <= (63 << 6);

				end

				else if((row + 2) > 63)begin

					find[5] <= ((63 << 6) + (col - 2));

				end

				else if((col == 1 || col == 0))begin

					find[5] <= ((row + 2) << 6);

				end

				else begin

					find[5] <= (((row + 2) << 6 )+ (col - 2));

				end

				

				//下

				if(((row + 2 )> 63))begin

					find[6] <= (((63) << 6) + col);

				end

				else begin

					find[6] <= (((row + 2) << 6 )+ col);

				end



				//右下	

				if(((row + 2 )> 63) && ((col + 2) > 63))begin

					find[7] <= ((63 << 6) + 63);

				end

				else if((row + 2) > 63)begin

					find[7] <= ((63 << 6 )+ (col + 2));

				end

				else if((col + 2) > 63)begin

					find[7] <= (((row + 2) << 6) + 63);

				end

				else begin

					find[7] <= (((row + 2) << 6 )+ (col + 2));

				end

			end

			CATCHPIXEL:begin

				pixelval[local9] <= idata;

				iaddr <= find[local9];

				// $display("%d",iaddr);

				local9 <= (local9 + 1);

			end

			PREKERNEL : begin

				cwr <= 1;

				

			end

			//100

			KERNEL : begin

				

				local9 <= 0;

				caddr_wr <= index;

				if((pixelval[0] - (pixelval[1]>>4) - (pixelval[2]>>3) - (pixelval[3]>>4) - (pixelval[4]>>2)- (pixelval[5]>>2)-(pixelval[6]>>4)-(pixelval[7]>>3)-(pixelval[8]>>4)-13'd12) > pixelval[0]) begin

					cdata_wr <= 0;

					// $display("0000000");

				end

				else begin

					cdata_wr <= (pixelval[0] - (pixelval[1]>>4) - (pixelval[2]>>3) - (pixelval[3]>>4) - (pixelval[4]>>2)- (pixelval[5]>>2)-(pixelval[6]>>4)-(pixelval[7]>>3)-(pixelval[8]>>4)-13'd12);

					// $display("operation");

				end

				index <= (index + 1);

				if(col == 63)begin

					row <= (row + 1);

					col <= 0;

				end

				else begin

					col <= (col + 1);

				end

				

			end

			//------------------------------------------------

			//0101

			K:begin

				// busy <= 0;

				crd <= 1;

				csel <= 0;

				cwr <= 0;

				max_index <= 0;

				polladdr[0] <= ((index_i << 6)+ index_j + 1);

				polladdr[1] <= (((index_i + 1) << 6)+ index_j);

				polladdr[2] <= (((index_i + 1) << 6)+ (index_j + 1));

				caddr_rd <= ((index_i << 6)+ index_j);

			end

			//0111

			LAYER1VAL:begin

				pollval[max_index] <= cdata_rd;

				caddr_rd <= polladdr[max_index];

				max_index <= (max_index + 1);

			end

			//1000

			LAYER1PREWRI:begin

				csel <= 1;

				cwr <= 1;

				crd <= 0;

				

			end

			//1001

			LAYER1CAL:begin

				caddr_wr <= index_layer1;

				if((pollval[0] >= pollval[1]) && (pollval[0] >= pollval[2]) && (pollval[0] >= pollval[3]))begin

					if((pollval[0] & 13'b1111) > 0)

                        cdata_wr <= ({pollval[0][12:4],4'b0000}+13'd16);

                    else

                        cdata_wr <= pollval[0];

				end

				else if((pollval[1] >= pollval[0]) && (pollval[1] >= pollval[2]) &&( pollval[1] >= pollval[3]))begin

					if ((pollval[1] & 13'b1111) > 0)

						cdata_wr <= ({pollval[1][12:4],4'b0000}+13'd16);

					else

						cdata_wr <= pollval[1];

				end

				else if((pollval[2] >= pollval[0]) && (pollval[2] >= pollval[1]) && (pollval[2] >= pollval[3]))begin

					if ((pollval[2] & 13'b1111) > 0)

						cdata_wr <= ({pollval[2][12:4],4'b0000}+13'd16);

					else

						cdata_wr <= pollval[2];

				end

				else begin

					if ((pollval[3] & 13'b1111) > 0)

						cdata_wr <= ({pollval[3][12:4],4'b0000}+13'd16);

					else

						cdata_wr <= pollval[3];

				end

				

				if((index_j+2) == 7'd64)begin

					index_i <= (index_i + 2);

					// $display("%d",index_i);

					index_j <= 0;

				end

				else begin

					index_j <= (index_j + 2);

				end

				index_layer1 <= (index_layer1 + 1);

				// csel <= 0;

				// cwr <= 0;

			end

			//1010

			LAST : begin

				busy <= 0;

			end

			default : begin

				busy <= 0;

			end

		endcase

		

	end

	end



	

always @(*)begin

	case(nowState)

		RESET:begin

			nextState <= PICK;

		end

		FINAL : begin

			nextState <= (index > 4095)?K:PICK;

		end

		PICK:begin

			nextState <= CATCHPIXEL;

		end

		CATCHPIXEL:begin

			nextState <= (local9 > 7)?PREKERNEL:CATCHPIXEL;

			

		end

		PREKERNEL:begin

			nextState <= KERNEL;

		end

		KERNEL:begin

			//結束判斷

			nextState <= FINAL;

		end

		K:begin

			nextState <= (index_layer1 > 1023)?LAST:LAYER1VAL;

		end

		LAYER1VAL:begin

			nextState <= (max_index > 3)?LAYER1PREWRI:LAYER1VAL;

		end

		LAYER1PREWRI : begin

			nextState <= LAYER1CAL;

		end

		LAYER1CAL : begin

			nextState <= K;

		end

		LAST:begin

			nextState <= LAST;

		end

		default :begin

			nextState <= RESET;

		end

	endcase

end

endmodule