module rr_arbiter (
    input        clk,
    input        rst_n,
    input  [3:0] req,
    output [3:0] grant,
    output       grant_valid
);

    reg [1:0] rr_ptr;
    reg [1:0] rr_ptr_next;

    reg [3:0] grant_next;
    reg       grant_valid_next;
    reg       found;

    integer offset;
    integer index;

    always @* begin
        grant_next       = 4'b0000;
        grant_valid_next = 1'b0;
        rr_ptr_next      = rr_ptr;
        found            = 1'b0;

        if (rst_n) begin
            for (offset = 0; offset < 4; offset = offset + 1) begin

                index = rr_ptr + offset;

                if (index >= 4)
                    index = index - 4;

                if (!found && req[index]) begin
                    grant_next[index] = 1'b1;
                    grant_valid_next = 1'b1;
                    found = 1'b1;

                    if (index == 3)
                        rr_ptr_next = 2'd0;
                    else
                        rr_ptr_next = index + 1;
                end
            end
        end
    end

    assign grant = grant_next;
    assign grant_valid = grant_valid_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rr_ptr <= 2'd0;
        else
            rr_ptr <= rr_ptr_next;
    end

endmodule