`timescale 1 ns / 1 ns

module fpwm #(
	parameter PWM_WIDTH = 8,
	parameter SPI_WIDTH = 8
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

	logic [PWM_WIDTH-1:0] control;

	logic [PWM_WIDTH-1:0] pos_count;
	logic [PWM_WIDTH-1:0] neg_count;
	logic [PWM_WIDTH-1:0] pos_compare0 = '0;
	logic [PWM_WIDTH-1:0] pos_compare1 = '0;
	logic [PWM_WIDTH-1:0] neg_compare0 = '0;
	logic [PWM_WIDTH-1:0] neg_compare1 = '0;
	logic [PWM_WIDTH-1:0] rx_data;

	logic [SPI_WIDTH-1:0] shift_reg = '0;
	logic [5:0] bit_count = 0;

	logic pos, neg;

	assign rx_data = {shift_reg[PWM_WIDTH-1:1], i_MOSI};

	always @(negedge i_SCK) begin
		if(i_SS == 0) begin
			shift_reg[0] <= i_MOSI;
			shift_reg[SPI_WIDTH-1:1] <= shift_reg[SPI_WIDTH-2:0];
			bit_count <= bit_count + 1;
		end else begin
			bit_count <= '0;
		end
	end

	always @(bit_count) begin
		if(bit_count == SPI_WIDTH) begin
			pos_compare0 <= rx_data;
			$display("Set pos 0 %2d (0x%2x)", rx_data, rx_data);
		end else if(bit_count == (2*SPI_WIDTH)) begin
			$display("Set pos 1 %2d (0x%2x)", rx_data, rx_data);
			pos_compare1 <= rx_data;
		end else if(bit_count == (3*SPI_WIDTH)) begin
			$display("Set neg 0 %2d (0x%2x)", rx_data, rx_data);
			neg_compare0 <= rx_data;
		end else if(bit_count == (4*SPI_WIDTH)) begin
			$display("Set neg 1 %2d (0x%2x)", rx_data, rx_data);
			neg_compare1 <= rx_data;
		end else if(bit_count == (5*SPI_WIDTH)) begin
			$display("Set ctrl %2d (0x%2x)", rx_data, rx_data);
			control <= rx_data;
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

