`timescale 1ns/1ps

module tb_rr_arbiter;

    reg        clk;
    reg        rst_n;
    reg  [3:0] req;

    wire [3:0] grant;
    wire       grant_valid;

    reg [1:0] model_ptr;

    reg [3:0] expected_grant;
    reg       expected_valid;
    reg [1:0] expected_next_ptr;
    reg       found;

    integer i;
    integer index;

    integer tests;
    integer errors;

    rr_arbiter dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .req         (req),
        .grant       (grant),
        .grant_valid (grant_valid)
    );

    /*
     * Clock generation
     */
    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    /*
     * Reference model for round-robin arbitration.
     */
    task calculate_expected;
        input [3:0] request;

        begin
            expected_grant    = 4'b0000;
            expected_valid    = 1'b0;
            expected_next_ptr = model_ptr;
            found             = 1'b0;

            for (i = 0; i < 4; i = i + 1) begin

                index = model_ptr + i;

                if (index >= 4)
                    index = index - 4;

                if (!found && request[index]) begin

                    expected_grant[index] = 1'b1;
                    expected_valid = 1'b1;
                    found = 1'b1;

                    if (index == 3)
                        expected_next_ptr = 2'd0;
                    else
                        expected_next_ptr = index + 1;
                end
            end
        end
    endtask

    /*
     * Apply a request pattern and check the DUT.
     */
    task check_request;
        input [3:0] request;

        begin
            @(negedge clk);

            req = request;

            #1;

            calculate_expected(request);

            tests = tests + 1;

            /*
             * Check exact grant.
             */
            if (grant !== expected_grant) begin
                $display(
                    "ERROR %0d: req=%b ptr=%0d expected grant=%b actual=%b",
                    tests,
                    request,
                    model_ptr,
                    expected_grant,
                    grant
                );

                errors = errors + 1;
            end

            /*
             * Check grant_valid.
             */
            if (grant_valid !== expected_valid) begin
                $display(
                    "ERROR %0d: req=%b expected valid=%b actual=%b",
                    tests,
                    request,
                    expected_valid,
                    grant_valid
                );

                errors = errors + 1;
            end

            /*
             * An inactive requester must never be granted.
             */
            if ((grant & ~request) != 4'b0000) begin
                $display(
                    "ERROR %0d: inactive requester granted. req=%b grant=%b",
                    tests,
                    request,
                    grant
                );

                errors = errors + 1;
            end

            /*
             * Grant must be one-hot or zero.
             */
            if ((grant != 4'b0000) &&
                (grant != 4'b0001) &&
                (grant != 4'b0010) &&
                (grant != 4'b0100) &&
                (grant != 4'b1000)) begin

                $display(
                    "ERROR %0d: grant is not one-hot. grant=%b",
                    tests,
                    grant
                );

                errors = errors + 1;
            end

            /*
             * grant_valid must agree with grant.
             */
            if (grant_valid !== (grant != 4'b0000)) begin
                $display(
                    "ERROR %0d: grant_valid mismatch. grant=%b valid=%b",
                    tests,
                    grant,
                    grant_valid
                );

                errors = errors + 1;
            end

            /*
             * Update reference pointer only after a valid grant.
             */
            if (expected_valid)
                model_ptr = expected_next_ptr;

            @(posedge clk);
            #1;
        end
    endtask


    /*
     * Main test sequence.
     */
    initial begin

        req    = 4'b0000;
        rst_n  = 1'b0;

        model_ptr = 2'd0;

        tests  = 0;
        errors = 0;

        /*
         * Reset check.
         */
        #2;

        if (grant !== 4'b0000) begin
            $display("ERROR: grant is not zero during reset.");
            errors = errors + 1;
        end

        if (grant_valid !== 1'b0) begin
            $display("ERROR: grant_valid is not zero during reset.");
            errors = errors + 1;
        end

        #8;

        rst_n = 1'b1;

        /*
         * No requests.
         */
        check_request(4'b0000);

        /*
         * Single requester.
         */
        check_request(4'b0001);
        check_request(4'b0010);
        check_request(4'b0100);
        check_request(4'b1000);

        /*
         * Multiple requesters.
         */
        check_request(4'b0011);
        check_request(4'b0101);
        check_request(4'b0110);
        check_request(4'b1001);
        check_request(4'b1010);
        check_request(4'b1100);
        check_request(4'b0111);
        check_request(4'b1011);
        check_request(4'b1101);
        check_request(4'b1110);

        /*
         * All requesters continuously active.
         */
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);
        check_request(4'b1111);

        /*
         * Dynamic request patterns.
         */
        check_request(4'b0011);
        check_request(4'b0101);
        check_request(4'b1001);
        check_request(4'b0110);
        check_request(4'b1010);
        check_request(4'b1100);

        /*
         * Request withdrawal.
         */
        check_request(4'b1110);
        check_request(4'b1100);
        check_request(4'b1000);
        check_request(4'b0000);

        /*
         * Wrap-around sequence.
         */
        check_request(4'b1000);
        check_request(4'b0001);
        check_request(4'b0010);
        check_request(4'b0100);

        /*
         * Exhaustive request patterns.
         */
        check_request(4'b0000);
        check_request(4'b0001);
        check_request(4'b0010);
        check_request(4'b0011);
        check_request(4'b0100);
        check_request(4'b0101);
        check_request(4'b0110);
        check_request(4'b0111);
        check_request(4'b1000);
        check_request(4'b1001);
        check_request(4'b1010);
        check_request(4'b1011);
        check_request(4'b1100);
        check_request(4'b1101);
        check_request(4'b1110);
        check_request(4'b1111);

        /*
         * Final result.
         */
        $display("");
        $display("========================================");
        $display("     SILICON SPRINT VERIFICATION");
        $display("========================================");
        $display("Tests  : %0d", tests);
        $display("Errors : %0d", errors);

        if (errors == 0)
            $display("RESULT : PASS");
        else
            $display("RESULT : FAIL");

        $display("========================================");

        $finish;
    end

endmodule