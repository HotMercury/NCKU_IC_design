module AEC(clk, rst, ascii_in, ready, valid, result);

// Input signal
input clk;
input rst;
input ready;
input [7:0] ascii_in;

// Output signal
output valid;
output [6:0] result;

reg valid;
reg flag = 1;
reg ready2 = 0;
reg ready3 = 0;
reg [7:0] in = 0;
reg [7:0] trace = 0;
reg [7:0] index = 8'b0;
reg [7:0] top = 8'b0;
reg [7:0] top2 = 8'b0;
reg [7:0] ite = 0;
reg [7:0] tmp_ascii = 0;
reg [6:0] result;
reg [7:0] tmp [0:15];
reg [7:0] post [0:15];
reg [7:0] stack [0:15];
reg [7:0] data_in [0:15];

/*
* ( 40
* + 43
* - 45
* * 42
* ) 41
*/


/*need initial value for stack and post
index = 0;
top = 0;
ite = 0;
top2 = 0;

*/
//-----Your design-----//
always @(posedge clk)begin
    if(rst)begin
        valid = 0;
    end
    // else if(valid)begin
	// 	valid = 0;
    //     $display("ascii_in = %b", ascii_in);
	// end
    else if(ready)begin
        flag = 1;
        valid = 0;
        in = 0;
        trace = 0;
        data_in[in] = ascii_in;
    end
    else if(flag)begin
        if(ascii_in == 61)begin
            flag = 0;
            ready2 = 1;
        end
        else begin
            in = in + 1;
            data_in[in] = ascii_in;
        end
    end

    else if(ready2)begin
        if(trace > in)begin
            ready2 = 0;
            ready3 = 1;
        end
        else if(data_in[trace] == 40)begin
            stack[top] = data_in[trace];
            top = top + 1;
            trace = trace + 1;
        end
        else if(data_in[trace] == 41)begin
            if(stack[top-1] != 40)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            else begin
                top = top - 1;
                trace = trace + 1;
            end
        end
        else if(data_in[trace] == 43 || data_in[trace] == 45)begin
            if(top!=0 && stack[top-1]!=40)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            else begin
                stack[top] = data_in[trace];
                top = top + 1;
                trace = trace + 1;
            end
        end
        else if(data_in[trace] == 42)begin
            if(top!=0 && stack[top-1]==42)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            else begin
                stack[top] = data_in[trace];
                top = top + 1;
                trace = trace + 1;
            end
        end
        else begin
            if(data_in[trace] > 47 && data_in[trace] < 58)begin
                post[index] = data_in[trace] - 48;
            end
            else begin
                post[index] = data_in[trace] - 87;
            end
            index = index + 1;
            trace = trace + 1;
        end
    end
    else if(top != 0)begin
        post[index] = stack[top-1];
        top = top - 1;
        index = index + 1;
    end
        
/*-----------------------------------*/
    else if(index != 0)begin
        // $display("operation result");
        flag = 0;
        if(post[ite] == 42 || post[ite] == 43 || post[ite] == 45)begin
            if(post[ite] == 42)begin
                tmp[top2-2] = tmp[top2-2] * tmp[top2-1];
                top2 = top2 - 1;
                ite = ite + 1;
                index = index - 1;
            end
            else if(post[ite] == 43)begin
                tmp[top2-2] = tmp[top2-2] + tmp[top2-1];
                top2 = top2 - 1;
                ite = ite + 1;
                index = index - 1;
            end
            else begin
                tmp[top2-2] = tmp[top2-2] - tmp[top2-1];
                top2 = top2 - 1;
                ite = ite + 1;
                index = index - 1;
            end
        end
        else begin
            tmp[top2] = post[ite];
            top2 = top2 + 1;
            ite = ite + 1;
            index = index - 1;
        end
    end

    else begin
        index = 0;
        top = 0;
        ite = 0;
        top2 = 0;
        result = tmp[0];
        valid = 1;
    end
end
endmodule