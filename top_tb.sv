
module top_tb;
    localparam FRECUENCY = 100_000_000;
    bit pos, neg;
    bit mosi, sck, ss;
    bit enable, resetn, clk;

    real period_1 = (1000000000.0/FRECUENCY)/2.0;
    always #(period_1) clk = !clk;

    task SendByte(byte _value);
        for(int i=0; i<8; i++) begin
            mosi = _value[i];
            sck = 1;
            #100;
            sck = 0;
            #100;
        end
    endtask : SendByte

    task automatic SpiSend(const ref byte _array[$]);
        ss = 0;
        for (int i=0; i<_array.size; i++) begin
            SendByte(_array[i]);
        end
        ss = 1;
    endtask : SpiSend

    fpwm fpwm_instance
    (
        .o_Negative(neg),
        .o_Positve(pos),
        .i_MOSI(mosi),
        .i_SCK(sck),
        .i_SS(ss),
        .i_Enable(enable),
        .i_Resetn(resetn),
        .i_Clk(clk)
    );

    initial begin
        byte tx[$];

        $dumpfile("test-1.vcd");
        $dumpvars(0,top_tb);
        resetn = 0;
        enable = 0;
        ss = 1;
        #1000;
        resetn = 1;
        #200;
        enable = 1;
        tx.push_back(8'h12);
        tx.push_back(8'h34);
        tx.push_back(8'h56);
        tx.push_back(8'h78);
        tx.push_back(8'h11);
        SpiSend(tx);
		#100000;
		$finish();
    end

    initial $monitor($stime,, resetn,, clk,,, enable,, sck,, mosi,, pos,, neg);

endmodule : top_tb