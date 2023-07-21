`include "MMS_4num.v"
module MMS_8num(result, select, number0, number1, number2, number3, number4, number5, number6, number7);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
input  [7:0] number4;
input  [7:0] number5;
input  [7:0] number6;
input  [7:0] number7;
output result; 

/*
	Write Your Design Here ~
*/
wire [7:0] result1,result2;
reg [7:0] result;
MMS_4num m1(result1,select,number0,number1,number2,number3);
MMS_4num m2(result2,select,number4,number5,number6,number7);
always @(*)begin
if(!select)
result = (result1 > result2)? result1 : result2;
else
result = (result1 < result2)? result1 : result2;
end
endmodule