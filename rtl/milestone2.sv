`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module milestone2(
   input  logic clock,
   input  logic resetn,
   input  logic [15:0] SRAM_read_data,
	input logic MS2_start,
	
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic MS2_end
);
MS2_state_type MS2_state;

logic [6:0] address1, address2, address3, address4, address5, address6;
logic signed [31:0] write_data_a [2:0];
logic signed [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic signed [31:0] read_data_a [2:0];
logic signed [31:0] read_data_b [2:0];

logic [6:0] address_counter, write_count;
logic [18:0] pixel_counter;
logic [15:0] buffer, adder, t_val;

logic [8:0] offset_i, offset_j, block_i, block_j;

logic signed [5:0] col, op1, op2, op3, row_number, col_number, t_col_index; 
logic signed [15:0] out1, out2, out3; 
	
parameter y_address = 18'd0;
parameter u_address = 18'd38400;
parameter v_address = 18'd57600;

logic [17:0] s_prime_y_address;
logic [17:0] s_prime_u_address;
logic [17:0] s_prime_v_address;
logic [31:0] concatinate;
logic [3:0] shift_amount;

logic [1:0] sprime_flag, even_flag;

//parameter s_prime_y_address = 18'd76800;
//parameter s_prime_u_address = 18'd153600;
//parameter s_prime_v_address = 18'd192000;

logic [31:0] Multi_op_1, Multi_op_2, Multi_op_3, Multi_op_4, Multi_op_5, Multi_op_6, Multi_result_1, Multi_result_2, Multi_result_3, finder, block_i_mul, offset_i_mul, block_j_mul, increment_j_block;
logic [63:0] Multi_result_long_1, Multi_result_long_2, Multi_result_long_3, address, finder_y, block_i_mul_y, finder_uv, block_i_mul_uv ;

assign Multi_result_long_1 = $signed(Multi_op_1) * $signed(Multi_op_2);
assign Multi_result_long_2 = $signed(Multi_op_3) * $signed(Multi_op_4);
assign Multi_result_long_3 = $signed(Multi_op_5) * $signed(Multi_op_6);

assign Multi_result_1 = Multi_result_long_1[31:0];
assign Multi_result_2 = Multi_result_long_2[31:0];
assign Multi_result_3 = Multi_result_long_3[31:0];


assign even_flag = (concatinate[0] == 1'b0) ? 1'b1 : 1'b0;

//
// S'
dual_port_RAM0 RAM_inst0 (
	.address_a ( address1 ),
	.address_b ( address2 ),
	.clock ( clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0]  ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
);
// 
// T ram
dual_port_RAM1 RAM_inst1 (
	.address_a ( address3 ),
	.address_b ( address4 ),
	.clock ( clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
);	
//S
dual_port_RAM2 RAM_inst2 (
	.address_a ( address5 ),
	.address_b ( address6 ),
	.clock ( clock ),
	.data_a ( write_data_a[2] ),
	.data_b ( write_data_b[2] ),
	.wren_a ( write_enable_a[2]  ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
);

always_comb begin //address traverse
	block_i_mul_y = (block_i << 8'd11) + (block_i << 8'd9);
	block_i_mul_uv = (block_i << 8'd7) + (block_i << 8'd5);
	offset_i_mul = (offset_i << 8'd8) + (offset_i << 8'd6);
	block_j_mul = (block_j << 3'd3);

	finder_y = block_i_mul_y + offset_i_mul + block_j_mul  + offset_j;
	
	finder_uv = block_i_mul_uv + offset_i_mul + block_j_mul + offset_j;
	
	increment_j_block = (block_j == 8'd39 && offset_j == 7 && offset_i ==7);
	
//	if (SRAM_read_data[7:0] >= 16'h10 && SRAM_read_data[7:0] < 16'h100) 
//		shift_amount = 8;
//	else if (SRAM_read_data[7:0] >= 16'h1 && SRAM_read_data[7:0] < 16'h10)
//		shift_amount = 4;
//	else
//		shift_amount = 0;
	concatinate = {(buffer), SRAM_read_data[15:0]};	
end

always_comb begin // c-matrix
		 case (op1)
			  6'd0:  out1 = 16'sd1448;
			  6'd1:  out1 = 16'sd1448;
			  6'd2:  out1 = 16'sd1448;
			  6'd3:  out1 = 16'sd1448;
			  6'd4:  out1 = 16'sd1448;
			  6'd5:  out1 = 16'sd1448;
			  6'd6:  out1 = 16'sd1448;
			  6'd7:  out1 = 16'sd1448;
			  6'd8:  out1 = 16'sd2008;
			  6'd9:  out1 = 16'sd1702;
			  6'd10: out1 = 16'sd1137;
			  6'd11: out1 = 16'sd399;
			  6'd12: out1 = -16'sd399;
			  6'd13: out1 = -16'sd1137;
			  6'd14: out1 = -16'sd1702;
			  6'd15: out1 = -16'sd2008;
			  6'd16: out1 = 16'sd1892;
			  6'd17: out1 = 16'sd783;
			  6'd18: out1 = -16'sd783;
			  6'd19: out1 = -16'sd1892;
			  6'd20: out1 = -16'sd1892;
			  6'd21: out1 = -16'sd783;
			  6'd22: out1 = 16'sd783;
			  6'd23: out1 = 16'sd1892;
			  6'd24: out1 = 16'sd1702;
			  6'd25: out1 = -16'sd399;
			  6'd26: out1 = -16'sd2008;
			  6'd27: out1 = -16'sd1137;
			  6'd28: out1 = 16'sd1137;
			  6'd29: out1 = 16'sd2008;
			  6'd30: out1 = 16'sd399;
			  6'd31: out1 = -16'sd1702;
			  6'd32: out1 = 16'sd1448;
			  6'd33: out1 = -16'sd1448;
			  6'd34: out1 = -16'sd1448;
			  6'd35: out1 = 16'sd1448;
			  6'd36: out1 = 16'sd1448;
			  6'd37: out1 = -16'sd1448;
			  6'd38: out1 = -16'sd1448;
			  6'd39: out1 = 16'sd1448;
			  6'd40: out1 = 16'sd1137;
			  6'd41: out1 = -16'sd2008;
			  6'd42: out1 = 16'sd399;
			  6'd43: out1 = 16'sd1702;
			  6'd44: out1 = -16'sd1702;
			  6'd45: out1 = -16'sd399;
			  6'd46: out1 = 16'sd2008;
			  6'd47: out1 = -16'sd1137;
			  6'd48: out1 = 16'sd783;
			  6'd49: out1 = -16'sd1892;
			  6'd50: out1 = 16'sd1892;
			  6'd51: out1 = -16'sd783;
			  6'd52: out1 = -16'sd783;
			  6'd53: out1 = 16'sd1892;
			  6'd54: out1 = -16'sd1892;
			  6'd55: out1 = 16'sd783;
			  6'd56: out1 = 16'sd399;
			  6'd57: out1 = -16'sd1137;
			  6'd58: out1 = 16'sd1702;
			  6'd59: out1 = -16'sd2008;
			  6'd60: out1 = 16'sd2008;
			  6'd61: out1 = -16'sd1702;
			  6'd62: out1 = 16'sd1137;
			  6'd63: out1 = -16'sd399;
			  default: out1 = 16'sd0;
		 endcase
		 
	     case (op2)
			 6'd0:  out2 = 16'sd1448;
			 6'd1:  out2 = 16'sd1448;
			 6'd2:  out2 = 16'sd1448;
			 6'd3:  out2 = 16'sd1448;
			 6'd4:  out2 = 16'sd1448;
			 6'd5:  out2 = 16'sd1448;
			 6'd6:  out2 = 16'sd1448;
			 6'd7:  out2 = 16'sd1448;
			 6'd8:  out2 = 16'sd2008;
			 6'd9:  out2 = 16'sd1702;
			 6'd10: out2 = 16'sd1137;
			 6'd11: out2 = 16'sd399;
			 6'd12: out2 = -16'sd399;
			 6'd13: out2 = -16'sd1137;
			 6'd14: out2 = -16'sd1702;
			 6'd15: out2 = -16'sd2008;
			 6'd16: out2 = 16'sd1892;
			 6'd17: out2 = 16'sd783;
			 6'd18: out2 = -16'sd783;
			 6'd19: out2 = -16'sd1892;
			 6'd20: out2 = -16'sd1892;
			 6'd21: out2 = -16'sd783;
			 6'd22: out2 = 16'sd783;
			 6'd23: out2 = 16'sd1892;
			 6'd24: out2 = 16'sd1702;
			 6'd25: out2 = -16'sd399;
			 6'd26: out2 = -16'sd2008;
			 6'd27: out2 = -16'sd1137;
			 6'd28: out2 = 16'sd1137;
			 6'd29: out2 = 16'sd2008;
			 6'd30: out2 = 16'sd399;
			 6'd31: out2 = -16'sd1702;
			 6'd32: out2 = 16'sd1448;
			 6'd33: out2 = -16'sd1448;
			 6'd34: out2 = -16'sd1448;
			 6'd35: out2 = 16'sd1448;
			 6'd36: out2 = 16'sd1448;
			 6'd37: out2 = -16'sd1448;
			 6'd38: out2 = -16'sd1448;
			 6'd39: out2 = 16'sd1448;
			 6'd40: out2 = 16'sd1137;
			 6'd41: out2 = -16'sd2008;
			 6'd42: out2 = 16'sd399;
			 6'd43: out2 = 16'sd1702;
			 6'd44: out2 = -16'sd1702;
			 6'd45: out2 = -16'sd399;
			 6'd46: out2 = 16'sd2008;
			 6'd47: out2 = -16'sd1137;
			 6'd48: out2 = 16'sd783;
			 6'd49: out2 = -16'sd1892;
			 6'd50: out2 = 16'sd1892;
			 6'd51: out2 = -16'sd783;
			 6'd52: out2 = -16'sd783;
			 6'd53: out2 = 16'sd1892;
			 6'd54: out2 = -16'sd1892;
			 6'd55: out2 = 16'sd783;
			 6'd56: out2 = 16'sd399;
			 6'd57: out2 = -16'sd1137;
			 6'd58: out2 = 16'sd1702;
			 6'd59: out2 = -16'sd2008;
			 6'd60: out2 = 16'sd2008;
			 6'd61: out2 = -16'sd1702;
			 6'd62: out2 = 16'sd1137;
			 6'd63: out2 = -16'sd399;
			 default: out2 = 16'sd0;
		endcase
		
		case (op3)
			 6'd0:  out3 = 16'sd1448;
			 6'd1:  out3 = 16'sd1448;
			 6'd2:  out3 = 16'sd1448;
			 6'd3:  out3 = 16'sd1448;
			 6'd4:  out3 = 16'sd1448;
			 6'd5:  out3 = 16'sd1448;
			 6'd6:  out3 = 16'sd1448;
			 6'd7:  out3 = 16'sd1448;
			 6'd8:  out3 = 16'sd2008;
			 6'd9:  out3 = 16'sd1702;
			 6'd10: out3 = 16'sd1137;
			 6'd11: out3 = 16'sd399;
			 6'd12: out3 = -16'sd399;
			 6'd13: out3 = -16'sd1137;
			 6'd14: out3 = -16'sd1702;
			 6'd15: out3 = -16'sd2008;
			 6'd16: out3 = 16'sd1892;
			 6'd17: out3 = 16'sd783;
			 6'd18: out3 = -16'sd783;
			 6'd19: out3 = -16'sd1892;
			 6'd20: out3 = -16'sd1892;
			 6'd21: out3 = -16'sd783;
			 6'd22: out3 = 16'sd783;
			 6'd23: out3 = 16'sd1892;
			 6'd24: out3 = 16'sd1702;
			 6'd25: out3 = -16'sd399;
			 6'd26: out3 = -16'sd2008;
			 6'd27: out3 = -16'sd1137;
			 6'd28: out3 = 16'sd1137;
			 6'd29: out3 = 16'sd2008;
			 6'd30: out3 = 16'sd399;
			 6'd31: out3 = -16'sd1702;
			 6'd32: out3 = 16'sd1448;
			 6'd33: out3 = -16'sd1448;
			 6'd34: out3 = -16'sd1448;
			 6'd35: out3 = 16'sd1448;
			 6'd36: out3 = 16'sd1448;
			 6'd37: out3 = -16'sd1448;
			 6'd38: out3 = -16'sd1448;
			 6'd39: out3 = 16'sd1448;
			 6'd40: out3 = 16'sd1137;
			 6'd41: out3 = -16'sd2008;
			 6'd42: out3 = 16'sd399;
			 6'd43: out3 = 16'sd1702;
			 6'd44: out3 = -16'sd1702;
			 6'd45: out3 = -16'sd399;
			 6'd46: out3 = 16'sd2008;
			 6'd47: out3 = -16'sd1137;
			 6'd48: out3 = 16'sd783;
			 6'd49: out3 = -16'sd1892;
			 6'd50: out3 = 16'sd1892;
			 6'd51: out3 = -16'sd783;
			 6'd52: out3 = -16'sd783;
			 6'd53: out3 = 16'sd1892;
			 6'd54: out3 = -16'sd1892;
			 6'd55: out3 = 16'sd783;
			 6'd56: out3 = 16'sd399;
			 6'd57: out3 = -16'sd1137;
			 6'd58: out3 = 16'sd1702;
			 6'd59: out3 = -16'sd2008;
			 6'd60: out3 = 16'sd2008;
			 6'd61: out3 = -16'sd1702;
			 6'd62: out3 = 16'sd1137;
			 6'd63: out3 = -16'sd399;
			 default: out3 = 16'sd0;
		endcase
end
	

always_ff @ (posedge clock or negedge resetn) begin
	if (resetn == 1'b0) begin
			offset_i <= 18'd0;
			offset_j <= 18'd0;
			block_i <= 18'd0;
			block_j <= 18'd0;
			MS2_end <= 1'b0;
			write_enable_a[0] <= 1'b0;
			SRAM_we_n <= 1'b1;
			SRAM_address <= 18'd0;
			
			adder <= 16'd0;
			t_val <= 16'd0;
			
			address_counter <= 7'd0;
			write_count <= 7'd0;
			
			address1 <= 7'd0;
			address2	<= 7'd0;
			sprime_flag <= 1'd0;
			
			s_prime_y_address <= 18'd76800;
			s_prime_u_address <= 18'd153600;
			s_prime_v_address <= 18'd192000;
		
			MS2_state <= S_MS2_IDLE;
		
	end else begin
		write_enable_a[0]  <= 1'b0;
		
		case (MS2_state)
				S_MS2_IDLE: begin  
									
					if (MS2_start == 1'b1) begin
						pixel_counter <= 18'd0;
						if (MS2_end == 1'b1) begin
							MS2_end <= 1'b1; // if triggered, stays ended
						end else begin
							MS2_end <= 1'b0;
						end
							MS2_state <= S_MS2_FSP_LEAD_IN_0;
						end
            end
				
				S_MS2_FSP_LEAD_IN_0: begin 
					//write_enable_a[0]  <= 1'b1;
					SRAM_address <= s_prime_y_address;
					offset_i <= offset_i;
					offset_j <= offset_j + 1;
					MS2_state <= S_MS2_FSP_LEAD_IN_1;
					
				end
				
				S_MS2_FSP_LEAD_IN_1: begin
					//write_enable_a[0]  <= 1'b1;
					SRAM_address <= s_prime_y_address + finder_y;
					offset_j <= offset_j + 1;
					MS2_state <= S_MS2_FSP_LEAD_IN_2;
					
				end
				
				S_MS2_FSP_LEAD_IN_2: begin
					SRAM_address <= s_prime_y_address + finder_y;
					offset_j <= offset_j + 1;
					buffer <= SRAM_read_data[15:0];
					MS2_state <= S_MS2_FSP_COMMON_CASE;
				end
				
				S_MS2_FSP_COMMON_CASE: begin
					if (write_data_a[0] >= 8'h1 && even_flag == 1'd1) begin
						address_counter <= address_counter + 1'd1;
						if (address_counter[0] == 0) begin
							address1 <= address1 + 2'd2;
						end else begin
							if (address1 == 0) begin //for the first address increment
								address2 <= address2 + 1'd1;
							end else begin
								address2 <= address2 + 2'd2;
							end
						end
					end
					
					if ((offset_j >= 4 || offset_i > 0) && even_flag == 1'd1) begin
						
						address_counter <= address_counter + 1;
						
						if (address_counter[0] == 0) begin
							write_enable_b[0]  <= 1'b0;
							write_enable_a[0]  <= 1'b1;
							write_data_a[0] <= concatinate;
							
						end else begin
							write_enable_a[0]  <= 1'b0;
							write_enable_b[0]  <= 1'b1;
							write_data_b[0] <= concatinate;
						end
					end
					
					if (write_enable_a[0] && even_flag == 1'd1) begin
						buffer <= SRAM_read_data[15:0];
					end

					SRAM_address <= s_prime_y_address + finder_y;
					offset_j <= offset_j + 1;
					buffer <= SRAM_read_data[15:0];
					
					if (offset_j == 4'd7) begin 
						offset_j <= 1'd0;
						offset_i <= offset_i + 1'd1;
					end 
					
					if (offset_j ==4'd7 && offset_i == 4'd7) begin
						offset_j <= 1'd0;
						offset_i <= 1'd0;
						MS2_state <= S_MS2_FSP_LEAD_OUT_0;
					end
				end
				
				S_MS2_FSP_LEAD_OUT_0: begin
					write_enable_a[0]  <= 1'b1;
					write_enable_b[0]  <= 1'b0;
					address1 <= address1 + 2'd2; //30
					buffer <= SRAM_read_data[15:0];
					write_data_a[0] <= concatinate;
					MS2_state <= S_MS2_FSP_LEAD_OUT_1;
				end
				
				S_MS2_FSP_LEAD_OUT_1: begin
					
					buffer <= SRAM_read_data[15:0];
					
					
					write_enable_a[0]  <= 1'b1;
					MS2_state <= S_MS2_FSP_LEAD_OUT_2;
				end
				
				S_MS2_FSP_LEAD_OUT_2: begin
				
					address2 <= address2 + 2'd2; //31
					buffer <= SRAM_read_data[15:0];
					write_data_b[0] <= concatinate;
					
					write_enable_a[0]  <= 1'b0;
					write_enable_b[0]  <= 1'b1;
					
					MS2_state <= S_MS2_COMPUTE_T_LI_0;
				end
				
				S_MS2_COMPUTE_T_LI_0: begin
					address1 <= 1'd0; // starts even reads from Fetch_S_prime port
					address2 <= 1'd1; // starts odd reads from Fetch_S_prime port
					
					address3 <= 1'd0;
					
					write_enable_a[0]  <= 1'b0;
					write_enable_b[0]  <= 1'b0;
					
					write_enable_a[1]  <= 1'b1;
			
					
					
					MS2_state <= S_MS2_COMPUTE_T_LI_1;
				end
				
				S_MS2_COMPUTE_T_LI_1: begin
					address1 <= address1 + 1'd1; // S_prime RAM goes to address 1 next
					address2 <= address2 + 1'd1; // 2 next
					 
					 col <= 6'd0;
					 op1 <= 6'd0;
					 op2 <= 6'd8;
					 op3 <= 6'd16;
					
					 MS2_state <= S_MS2_COMPUTE_T0;
				end


				S_MS2_COMPUTE_T0: begin
				
					 address1 <= address1 + 1'd1; // address 2
					 address2 <= address2 + 1'd1; // address 3 next

					 Multi_op_1 <= read_data_a[0][31:16]; // S00 x c00
					 Multi_op_2 <= out1;

					 Multi_op_3 <= read_data_a[0][15:0]; // S01 x c10
					 Multi_op_4 <= out2;

					 Multi_op_5 <= read_data_b[0][31:16]; // S02 x c20
					 Multi_op_6 <= out3;
					 
					 op1 <= op1 + 24;
					 op2 <= op2 + 24;
					 op3 <= op3 + 24;
					 
					 if (col > 1'd0) begin
						t_val <= adder + Multi_result_1 + Multi_result_2;
					 end
				
					 
					 MS2_state <= S_MS2_COMPUTE_T1;
				end

				S_MS2_COMPUTE_T1: begin
					 address1 <= address1 - 2;
					 address2 <= address2 - 2;

					 Multi_op_1 <= read_data_a[0][15:0]; // S03 x c30
					 Multi_op_2 <= out1;

					 Multi_op_3 <= read_data_b[0][31:16]; // S04 x c40
					 Multi_op_4 <= out2;
					 
					 Multi_op_5 <= read_data_b[0][15:0]; // S05 x c50
					 Multi_op_6 <= out3;
					 
					 if (col == 4'd7) begin
						address1 <= address1 + 18'd2;
						address2 <= address2 + 18'd2;
					 end
					 
					if (col > 1'd0) begin //only starts writing to T after the first iteration of compute T (where it gets its computed matrix multi values)
							
						if (write_count > 0) begin
							address3 <= address3 + 1'd1;
						end else begin
							address3 <= 0;
						end
						write_data_a[1] <= t_val; //writes to port 1 of t ram
						write_count	<= write_count + 1'd1;
					end
	
						op1 <= op1 + 24;
						op2 <= op2 + 24;
					
					 adder <= Multi_result_1 + Multi_result_2 + Multi_result_3;
					 
					 MS2_state <= S_MS2_COMPUTE_T2;
				end

				S_MS2_COMPUTE_T2: begin
					 address1 <= address1 + 1'd1;
					 address2 <= address2 + 1'd1;

					 Multi_op_1 <= read_data_b[0][31:16]; // S06 x c60
					 Multi_op_2 <= out1;

					 Multi_op_3 <= read_data_b[0][15:0]; // S07 x c70
					 Multi_op_4 <= out2;

					 adder <= adder + Multi_result_1 + Multi_result_2 + Multi_result_3;
					 
					 if (col == 4'd7) begin
						col <= 1'd0;
						op1 <= 6'd0;
						op2 <= 6'd8;
						op3 <= 6'd16;
					 end else begin
						col <= col + 1'd1; //next t val
						op1 <= col + 6'd1;
						op2 <= col + 6'd9;
						op3 <= col + 6'd17;
					 end
					 
					 if (write_count < 7'd56) begin // stops reading at 56 writes but it should continue writing until 64 in the next state 
						MS2_state <= S_MS2_COMPUTE_T0;
					 end else begin
						MS2_state <= S_MS2_COMPUTE_S_LI0;
					 end
				end
			
				S_MS2_COMPUTE_S_LI0: begin
				
					 address3 <= 0; //T00
					 col <= 0;
					 t_col_index <= 0;
					 block_j <= block_j + 1;

					 MS2_state <= S_MS2_COMPUTE_S_LI1;
				end
				
				S_MS2_COMPUTE_S_LI1: begin
				
					 address3 <= address3 + 8 + t_col_index; //T10
						
						op1 <= 6'd0 + col;
						op2 <= 6'd8 + col;
						op3 <= 6'd16 + col;
						
					 MS2_state <= S_MS2_COMPUTE_S0;
				end
				
				S_MS2_COMPUTE_S0: begin
				
					 address3 <= address3 + 8 + t_col_index; //T20
						
						op1 <= op1 + 24 + col;
						op2 <= op2 + 24 + col;
						op3 <= op3 + 24 + col;
					 MS2_state <= S_MS2_COMPUTE_S1;
				end
				
				S_MS2_COMPUTE_S1: begin
				
					 address3 <= address3 + 8 + t_col_index; // T30
					 
					 op1 <= op1 + 24 + col;
					 op2 <= op2 + 24 + col;

					 MS2_state <= S_MS2_COMPUTE_S2;
				end
				
				S_MS2_COMPUTE_S2: begin
				
					 address3 <= address3 + 8 + t_col_index;  //T40
					 
					op1 <= 6'd0 + col;
					op2 <= 6'd8 + col;
					op3 <= 6'd16 + col;

					 MS2_state <= S_MS2_COMPUTE_S3;
				end
				
				S_MS2_COMPUTE_S3: begin
				
					 address3 <= address3 + 8 + t_col_index;  //T50
					 
						op1 <= op1 + 24 + col;
						op2 <= op2 + 24 + col;
						op3 <= op3 + 24 + col;

					 MS2_state <= S_MS2_COMPUTE_S4;
				end
				
				S_MS2_COMPUTE_S4: begin
				
					 address3 <= address3 + 8 + t_col_index;  //T60
					 
						op1 <= op1 + 24 + col;
						op2 <= op2 + 24 + col;

					 MS2_state <= S_MS2_COMPUTE_S5;
				end
				
				S_MS2_COMPUTE_S5: begin
				
					 address3 <= address3 + 8 + t_col_index;  //T70
					 
					op1 <= 6'd0 + col;
					op2 <= 6'd8 + col;
					op3 <= 6'd16 + col;
					
					if (t_col_index < 7) begin
						if (address3 > 55) begin
							address3 <= 0;
							t_col_index <= t_col_index + 1;
						end
					end else begin
						if (col < 7) begin
							t_col_index <= 0;
							MS2_state <= S_MS2_COMPUTE_S0;
						end else begin
							MS2_state <= S_MS2_IDLE;
						end
					end
					 
				end
			

				
//				S_MS2_COMPUTE_T3: begin
//					 address1 <= address1 + 1'd1;
//					 address2 <= address2 + 1'd1;
//
//					 Multi_op_1 <= read_data_a[0][31:16]; // S00 x c00
//					 //Multi_op_2 <= row 0 col 0;
//
//					 Multi_op_3 <= read_data_a[0][15:0]; // S01 x op10
//					 // Multi_op_4 <= row 1 col 0;
//
//					 Multi_op_5 <= read_data_b[0][31:16]; // S02 x op20
//					 // Multi_op_6 <= row 2 col 0;
//
//					 adder <= adder + Multi_result_1 + Multi_result_2 + Multi_result_3;
//
//					 MS2_state <= S_MS2_COMPUTE_T3;
//				end

				default: MS2_state <= S_MS2_IDLE;
				endcase

				
		end
	end
	
endmodule
