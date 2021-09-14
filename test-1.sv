`timescale 1 ns / 1 ns

module fpwm #(
	parameter WIDTH = 7
)
(
	output logic o_Positve,
	output logic o_Negative,
	input i_SCK,
	input i_MOSI,
	input i_SS,
	input i_Clk,
	input i_Enable,
	input i_Resetn
);

logic [WIDTH-1:0] control;

logic [WIDTH-1:0] pos_count;
logic [WIDTH-1:0] neg_count;
logic [WIDTH-1:0] pos_compare0 = '0;
logic [WIDTH-1:0] pos_compare1 = '0;
logic [WIDTH-1:0] neg_compare0 = '0;
logic [WIDTH-1:0] neg_compare1 = '0;

logic [WIDTH-1:0] shift_reg = '0;
logic [5:0] bit_count = 0;

logic pos, neg;

always @(negedge i_SCK) begin
	if(i_SS == 0) begin
		shift_reg[0] <= i_MOSI;
		shift_reg[WIDTH-1:1] <= shift_reg[WIDTH-2:0];
		bit_count <= bit_count + 1;
		if(bit_count == WIDTH-1)
			pos_compare0 <= shift_reg;
		else if(bit_count == (2*WIDTH)-1)
			pos_compare1 <= shift_reg;
		else if(bit_count == (3*WIDTH)-1)
			neg_compare0 <= shift_reg;
		else if(bit_count == (4*WIDTH)-1)
			neg_compare1 <= shift_reg;
		else if(bit_count == (5*WIDTH)-1)
			control <= shift_reg;
	end else begin
		bit_count <= '0;
	end
end

always @(posedge i_Clk or negedge i_Resetn) begin
	if(i_Resetn == 0)begin
		pos_count <= '0;
		neg_count <= '0;
		pos <= 0;
		neg <= 0;
	end else begin
		pos_count <= pos_count + 1'b1;
		neg_count <= neg_count + 1'b1;
		if(pos_count == pos_compare0)
			pos <= 0;
		else if(pos_count == pos_compare1)
			pos <= 1;
			
		if(neg_count == neg_compare0)
			neg <= 0;
		else if(neg_count == neg_compare1)
			neg <= 1;
	end
end

	assign o_Positve = i_Enable ? pos : control[0];
	assign o_Negative = i_Enable ? neg : control[1];

endmodule : fpwm

