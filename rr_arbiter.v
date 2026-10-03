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

    always @* begin

        grant_next       = 4'b0000;
        grant_valid_next = 1'b0;
        rr_ptr_next      = rr_ptr;

        case (rr_ptr)

            2'd0: begin
                if (req[0]) begin
                    grant_next       = 4'b0001;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd1;
                end
                else if (req[1]) begin
                    grant_next       = 4'b0010;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd2;
                end
                else if (req[2]) begin
                    grant_next       = 4'b0100;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd3;
                end
                else if (req[3]) begin
                    grant_next       = 4'b1000;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd0;
                end
            end

            2'd1: begin
                if (req[1]) begin
                    grant_next       = 4'b0010;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd2;
                end
                else if (req[2]) begin
                    grant_next       = 4'b0100;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd3;
                end
                else if (req[3]) begin
                    grant_next       = 4'b1000;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd0;
                end
                else if (req[0]) begin
                    grant_next       = 4'b0001;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd1;
                end
            end

            2'd2: begin
                if (req[2]) begin
                    grant_next       = 4'b0100;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd3;
                end
                else if (req[3]) begin
                    grant_next       = 4'b1000;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd0;
                end
                else if (req[0]) begin
                    grant_next       = 4'b0001;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd1;
                end
                else if (req[1]) begin
                    grant_next       = 4'b0010;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd2;
                end
            end

            2'd3: begin
                if (req[3]) begin
                    grant_next       = 4'b1000;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd0;
                end
                else if (req[0]) begin
                    grant_next       = 4'b0001;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd1;
                end
                else if (req[1]) begin
                    grant_next       = 4'b0010;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd2;
                end
                else if (req[2]) begin
                    grant_next       = 4'b0100;
                    grant_valid_next = 1'b1;
                    rr_ptr_next      = 2'd3;
                end
            end

        endcase
    end

    assign grant       = grant_next;
    assign grant_valid = grant_valid_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rr_ptr <= 2'd0;
        else
            rr_ptr <= rr_ptr_next;
    end

endmodule
