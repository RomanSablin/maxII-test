
module top(
	output [3:0]o_Led,
	input i_Clk,
	input i_Resetn
);

logic [23:0] led_count;

always @(posedge i_Clk or negedge i_Resetn) begin
	if(i_Resetn == 0)begin
		led_count <= '0;
	end else begin
		led_count <= led_count + 1'b1;
	end
end

	assign o_Led = led_count[23:20];

endmodule
