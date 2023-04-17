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
reg [7:0] index = 8'b0;
reg [7:0] top = 8'b0;
reg [7:0] top2 = 8'b0;
reg [7:0] ite = 0;
reg [7:0] tmp_ascii = 0;
reg [6:0] result;
reg [7:0] tmp [0:15];
reg [7:0] post [0:15];
reg [7:0] stack [0:15];

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
        //if equal
        if(ascii_in == 40)begin
            // $display("(");
            stack[top] = ascii_in;
            top = top + 1;
        end
        else if(ascii_in == 41)begin
            // $display(")");
            while(stack[top-1] != 40)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            top = top - 1;
        end
        else begin
            if(ascii_in > 47 && ascii_in < 58)begin
                post[index] = ascii_in - 48;
            end
            else begin
                post[index] = ascii_in - 87;
            end
            index = index + 1;
        end
        
    end
    else if(ascii_in != 61 && flag)begin
        //if add or minus
        if(ascii_in == 43 || ascii_in == 45)begin
            //push to post
            while(top !=0 && stack[top-1] != 40)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            //push to stack
            stack[top] = ascii_in;
            top = top + 1;
        end
        //if multiply
        else if(ascii_in == 42)begin
            // $display("*");
            while(top != 0 && stack[top-1] == 42)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            stack[top] = ascii_in;
            top = top + 1;
        end
        else if(ascii_in == 40)begin
            // $display("(");
            stack[top] = ascii_in;
            top = top + 1;
        end
        else if(ascii_in == 41)begin
            // $display(")");
            while(stack[top-1] != 40)begin
                post[index] = stack[top-1];
                top = top - 1;
                index = index + 1;
            end
            top = top - 1;
        end
        else begin
            if(ascii_in > 47 && ascii_in < 58)begin
                post[index] = ascii_in - 48;
            end
            else begin
                post[index] = ascii_in - 87;
            end
            index = index + 1;
        end
    end

    else if(top != 0)begin
        flag = 0;
        while(top != 0)begin
            post[index] = stack[top-1];
            top = top - 1;
            index = index + 1;
        end
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