module MMS_4num(result, select, number0, number1, number2, number3);

// add reg
output result; 
input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;

reg [7:0] localmm1, localmm2,result;
always @(*)
begin
if(!select)begin
localmm1 = (number0 > number1)? number0 : number1;
localmm2 = (number2 > number3)? number2 : number3;
end
else
begin
localmm1 = (number0 < number1)? number0 : number1;
localmm2 = (number2 < number3)? number2 : number3;
end
if(!select)
result = (localmm1 > localmm2)? localmm1 : localmm2;
else
result = (localmm1 < localmm2)? localmm1 : localmm2;
end
endmodule
/*
allways @(*)begin
case(select)
	1:
		assign localmm1 = (number0 > number1)? number0 : number1;
	0:
		assign localmm1 = (number0 < number1)? number0 : number1;
case(select)
	1:
		assign localmm2 = (number0 > number1)? number0 : number1;
	0:
		assign localmm2 = (number0 < number1)? number0 : number1;
case(select)
	1:
		assign result = (localmm1 > localmm2)? localmm1 : localmm2;
	0:
		assign result = (localmm1 < localmm2)? localmm1 : localmm2;

end

endmodule
*/