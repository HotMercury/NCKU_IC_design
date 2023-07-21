module rails(clk, reset, data, valid, result);

input        clk;
input        reset;
input  [3:0] data;
output       valid;
output       result; 

reg valid;
reg result;
reg flag;
reg [3:0] size;
reg [3:0] ite;
reg [3:0] ite2;
reg [3:0] stack;
reg [3:0] order;
reg [3:0] stack_train [0:9];// stack 
reg [3:0] leave_train [0:9];// input order

initial begin
valid = 0;
result = 0;
ite = 0;
ite2 = 0;
stack = 0;
order = 1; // train abs order 
end

always @(posedge clk)begin
	if(reset)begin
		valid = 0;
		flag = 1;
	end
	else if(valid)begin
		valid = 0;
	end
	else if(flag)begin
		size = data;
		result = 0;
		ite = 0;
		ite2 = 0;
		stack = 0;
		flag = 0;
		order = 1; // train abs order 
	end
	else if(ite < size)begin
		leave_train[ite] = data;
		ite = ite+1;
	end
	else if(order <= size)begin
		//if order not same
		if(leave_train[ite2] != order)begin
			//push
			if(stack == 0)begin
				stack_train[stack] = order;
				stack = stack + 1;
				order = order + 1;	
			end
			else if(stack_train[stack -1 ] != leave_train[ite2])begin
				stack_train[stack] = order;
				stack = stack + 1;
				order = order + 1;
			end
			//pop
			else begin
				stack = stack - 1;
				ite2 = ite2 + 1;
			end
		end
		else begin
			order = order+1;
			ite2 = ite2 + 1;
		end
	end 
	else begin 
		if(stack == 0)begin
			result = 1;
			flag = 1;
			valid = 1;
		end
		else if(stack_train[stack -1] == leave_train[ite2])begin
			stack = stack - 1;
			ite2 = ite2 + 1;
		end
		else begin
			flag = 1;
			valid = 1;
		end
	end
end
endmodule