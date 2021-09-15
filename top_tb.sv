
module top_tb;
    localparam FRECUENCY = 100_000_000;
    bit pos, neg;
    bit mosi, sck, ss;
    bit enable, resetn, clk;

    real period_1 = (1000000000.0/FRECUENCY)/2.0;
    always #(period_1) clk = !clk;

    task SenBit(bit _bit);
        mosi = _bit;
        sck = 1;
        #100;
        sck = 0;
        #100;
    endtask : SenBit

    task SendByte(byte _value);
        for(int i=7; i>=0; i--) begin
            SenBit(_value[i]);
        end
    endtask : SendByte

    task SpiSend(byte _p0, byte _p1, byte _n0, byte _n1, byte _cfg);
        ss = 0;
        SendByte(_p0);
        SendByte(_p1);
        SendByte(_n0);
        SendByte(_n1);
        SendByte(_cfg);
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
        $dumpfile("test-1.vcd");
        $dumpvars(0,top_tb);
        resetn = 0;
        enable = 0;
        ss = 1;
        #1000;
        resetn = 1;
        #200;
        enable = 1;
        #200;
        SpiSend(8'h12, 8'h34, 8'h56, 8'h78, 8'h11);
		#1000000;
		$finish();
    end

//    initial $monitor($stime,, resetn,, clk,,, enable,, sck,, mosi,, pos,, neg);

endmodule : top_tb