/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

// manually edited for milestone 1, includes the rows that are included in the MS1_state table 
// This module generates the protocol signals to communicate 
// with the external SRAM (using a 2 clock cycle latency)
//module SRAM_controller (
//		input logic Clock_50,
//		input logic Resetn,
//		
//		input logic [17:0] SRAM_address,
//		input logic [15:0] SRAM_write_data,
//		input logic SRAM_we_n,
//		output logic [15:0] SRAM_read_data
//);

module milestone1(
   input logic clock,
   input logic resetn,
   input logic [15:0] SRAM_read_data,
	output logic [17:0] SRAM_address,
   output logic [15:0] SRAM_write_data,
   output logic SRAM_we_n,
	input logic M1_start,
   output logic M1_end
);
//M1_MS1_state_type MS1;

logic [17:0] even_pixel_counter;
logic [17:0] red_counter;
logic [17:0] odd_pixel_counter;

MS1_state_type MS1_state;

// For Push button
logic [3:0] PB_pushed;

// For VGA
logic [7:0] VGA_red, VGA_green, VGA_blue;
logic [9:0] pixel_X_pos;
logic [9:0] pixel_Y_pos;

/*
// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;
//logic resetn;
//assign resetn = ~SWITCH_I[17] && SRAM_ready;
*/

logic [15:0] VGA_sram_data[5:0];

logic [2:0] rect_row_count;     // Number of rectangles in a row
logic [2:0] rect_col_count;     // Number of rectangles in a column
logic [5:0] rect_width_count;   // Width of each rectangle
logic [4:0] rect_height_count;  // Height of each rectangle
logic [2:0] color;

logic [15:0] VGA_sram_data_green [5:0];
logic [15:0] VGA_sram_data_blue [5:0];
logic [15:0] VGA_sram_data_red [5:0];

logic [15:0] u_buffer, v_buffer;

// rgb values from the matrix, have to do hex signed due to negative values

parameter signed a = 32'h129FC; //76284S_MS1_LEAD_OUT
//parameter signed b = 32'h0; //0
parameter signed c = 32'h19893; //104595
//parameter signed d = 32'h129FC; // same as a but just for formality
parameter signed e = 32'hFFFF9BE8; // -25624
parameter signed f = 32'hFFFF2FDF; // -53281
//parameter signed g = 32'h129FC; //76284
parameter signed h = 32'h2049B; //132251
//parameter signed i = 32'h0; //0

logic [17:0] y_counter, uv_counter, rgb_counter, row_counter;
logic signed [8:0] u_plus_5, u_minus_5, u_plus_3, u_minus_3, u_plus_1, u_minus_1;
logic signed [8:0] v_plus_5, v_minus_5, v_plus_3, v_minus_3, v_plus_1, v_minus_1;
logic signed [31:0] u_even_prime, v_even_prime, u_odd_prime, v_odd_prime;

logic [17:0] y_address;
logic [17:0] u_address;
logic [17:0] v_address;
logic [17:0] rgb_address;

//logic dont_write;

logic signed [31:0] r_even, r_odd, g_even, g_odd, b_even, b_odd;
logic [7:0] clipped_r_even, clipped_r_odd, clipped_g_even, clipped_g_odd, clipped_b_even, clipped_b_odd; 

logic unsigned [7:0] y_even, y_odd;

//logic signed [31:0] multi1, multi2, multi3;
logic signed [31:0] adder1, adder2, adder3;
logic signed [63:0] long_res1, long_res2, long_res3, long_res4, long_res5;

// instantiation of a single 32-bit multiplexer
logic [31:0] Multi_op_1, Multi_op_2, Multi_op_3, Multi_op_4, Multi_op_5, Multi_op_6, Multi_result_1, Multi_result_2, Multi_result_3;
logic [63:0] Multi_result_long_1, Multi_result_long_2, Multi_result_long_3;

assign Multi_result_long_1 = $signed(Multi_op_1) * $signed(Multi_op_2);
assign Multi_result_long_2 = $signed(Multi_op_3) * $signed(Multi_op_4);
assign Multi_result_long_3 = $signed(Multi_op_5) * $signed(Multi_op_6);

assign Multi_result_1 = Multi_result_long_1[31:0];
assign Multi_result_2 = Multi_result_long_2[31:0];
assign Multi_result_3 = Multi_result_long_3[31:0];

// TO DO CLIPPINGS 

always_comb begin
	if (r_even[31]) begin //since we are checking for negative bit..
		clipped_r_even = 8'd0; // set back to 0
		end else if (|r_even[30:24]) begin // exceeding 255 check
			// set back to 255
			clipped_r_even = 8'd255;	
		end else begin 
			clipped_r_even = r_even[23:16]; 
		end

	if (g_even[31]) begin 
		clipped_g_even = 8'd0;
		end else if (|g_even[30:24]) begin
			clipped_g_even = 8'd255;
		end else begin
			clipped_g_even = g_even[23:16];	
	end

	if (b_even[31]) begin
		clipped_b_even = 8'd0;
	end else if (|b_even[30:24]) begin
		clipped_b_even = 8'd255;
	end else begin
		clipped_b_even = b_even[23:16];	
	end

	if (r_odd[31]) begin
		clipped_r_odd = 8'd0;
	end else if (|r_odd[30:24]) begin
		clipped_r_odd = 8'd255;
	end else begin
		clipped_r_odd = r_odd[23:16];	
	end

	if (g_odd[31]) begin 
		clipped_g_odd = 8'd0;
	end else if (|g_odd[30:24]) begin
		clipped_g_odd = 8'd255;	
	end else begin
		clipped_g_odd = g_odd[23:16];	
	end

	if (b_odd[31]) begin
		clipped_b_odd = 8'd0;
	end else if (|b_odd[30:24]) begin
		clipped_b_odd = 8'd255;
	end else begin
		clipped_b_odd = b_odd[23:16];		
	end
end

always_ff @ (posedge clock or negedge resetn) begin
	if (resetn == 1'b0) begin
		rect_row_count <= 3'd0;
		rect_col_count <= 3'd0;
		rect_width_count <= 6'd0;
		rect_height_count <= 5'd0;			
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;
		y_counter <= 18'd0;
		uv_counter <= 18'd0;
		rgb_counter <= 18'd0;
	
		y_address <= 18'd0;
		u_address <= 18'd38400;
		v_address <= 18'd57600;
		rgb_address <= 18'd146944;
		
		row_counter <= 18'd0;
		
		M1_end <= 1'b0;
		MS1_state <= S_MS1_IDLE;
		
	end else begin
		case (MS1_state)

				S_MS1_IDLE: begin
//                if (PB_pushed[0] == 1'b1) begin
//                    // Start filling the SRAM
//                    MS1_state <= S_FILL_SRAM_GREEN_0;
//                    SRAM_address <= 18'h3FFFF;
//                    // Data counter for deriving the RGB data of each pixel
//                    even_pixel_counter <= 18'd0;
//                end
						// need to initiate all the values and have them at 0, not just the counter
						y_address <= y_address + y_counter;
						u_address <= u_address + uv_counter;
						v_address <= v_address + uv_counter;
						rgb_address <= rgb_address + rgb_counter;
						
						adder1 <= 32'd0;
						adder2 <= 32'd0;
						adder3 <= 32'd0;
						

						y_counter <= 18'd0;
						uv_counter <= 18'd0;
						rgb_counter <= 18'd0;
						// indicates we're on the 'n'th row, where n=row_counter
						
						u_plus_5 <= 9'd0;
						u_minus_5 <= 9'd0;
						u_plus_3 <= 9'd0;
						u_minus_3 <= 9'd0;
						u_plus_1 <= 9'd0;
						u_minus_1 <= 9'd0;

						v_plus_5 <= 9'd0;
						v_minus_5 <= 9'd0;
						v_plus_3 <= 9'd0;
						v_minus_3 <= 9'd0;
						v_plus_1 <= 9'd0;
						v_minus_1 <= 9'd0;

						u_even_prime <= 32'd0;
						v_even_prime <= 32'd0;
						u_odd_prime <= 32'd0;
						v_odd_prime <= 32'd0;
						y_even <= 8'd0;
						y_odd <= 8'd0;
												
						if (M1_start == 1'b1) begin
							if (M1_end == 1'b1) begin
								M1_end <= 1'b1; // if triggered, stays ended
							end else begin
								M1_end <= 1'b0;
							end
							MS1_state <= S_MS1_LEAD_IN_0;
						end
            end

            S_MS1_LEAD_IN_0: begin
						  row_counter <= row_counter + 18'd1;

                    SRAM_we_n <= 1'b1;
                    SRAM_address <= y_address + y_counter; //counter
						  y_counter <= y_counter + 2'd1;
						  
                    MS1_state <= S_MS1_LEAD_IN_1;
            end
                
            S_MS1_LEAD_IN_1: begin
                    SRAM_address <= u_address + uv_counter;
                    MS1_state <= S_MS1_LEAD_IN_2;
            end

            S_MS1_LEAD_IN_2: begin
                    SRAM_address <= v_address + uv_counter;
                    uv_counter <= uv_counter + 2'd1; //gets updated after each u AND v are read
						  
						  MS1_state <= S_MS1_LEAD_IN_3;
            end

            S_MS1_LEAD_IN_3: begin
               SRAM_address <= u_address + uv_counter; //next u address
						  
					y_even <= SRAM_read_data[15:8];
					y_odd <= SRAM_read_data[7:0];
               MS1_state <= S_MS1_LEAD_IN_4;
            end

            S_MS1_LEAD_IN_4: begin
               SRAM_address <= v_address + uv_counter; //next v (v2v3)
					uv_counter <= uv_counter + 2'd1;
					
					u_even_prime <= SRAM_read_data[15:8];
					
					u_minus_5 <= SRAM_read_data[15:8];
					u_minus_3 <= SRAM_read_data[15:8];
					u_plus_1 <= SRAM_read_data[7:0];
					u_minus_1 <= SRAM_read_data[15:8];
					
               MS1_state <= S_MS1_LEAD_IN_5;
				end	
				
            S_MS1_LEAD_IN_5: begin
				
					v_even_prime <= SRAM_read_data[15:8];
					
					v_minus_5 <= SRAM_read_data[15:8];
					v_minus_3 <= SRAM_read_data[15:8];
					v_plus_1 <= SRAM_read_data[7:0];
					v_minus_1 <= SRAM_read_data[15:8];
					
               MS1_state <= S_MS1_LEAD_IN_6;
					
            end
				
            S_MS1_LEAD_IN_6: begin
				
					
					u_plus_5 <= SRAM_read_data[7:0];
					u_plus_3 <= SRAM_read_data[15:8];
					
               MS1_state <= S_MS1_LEAD_IN_7;
            end

            S_MS1_LEAD_IN_7: begin
					
					
					v_plus_5 <= SRAM_read_data[7:0];
					v_plus_3 <= SRAM_read_data[15:8];
				
					adder1 <= u_plus_5 + u_minus_5;
					adder2 <= u_plus_3 + u_minus_3;
					adder3 <= u_plus_1 + u_minus_1;
					
					MS1_state <= S_MS1_COMMON_CASE_0;
            end

				S_MS1_COMMON_CASE_0: begin //starts at clk cycle 11
					SRAM_we_n <= 1'b1;
					SRAM_address <= y_address + y_counter; // sram address gets reset to a 0 here?
					if (y_counter < 18'd159) begin // this right?
						y_counter <= y_counter + 2'd1;
					end
					
					Multi_op_1 <= adder1;
					Multi_op_2 <= 32'd21;
					
					Multi_op_3 <= adder2;
					Multi_op_4 <= 32'd52;
					
					Multi_op_5 <= adder3;
					Multi_op_6 <= 32'd159;
					
					adder1 <= v_plus_5 + v_minus_5;
					adder2 <= v_plus_3 + v_minus_3;
					adder3 <= v_plus_1 + v_minus_1;
					
					MS1_state <= S_MS1_COMMON_CASE_1;
            end

            S_MS1_COMMON_CASE_1: begin
					SRAM_address <= u_address + uv_counter;
					u_odd_prime <= (Multi_result_1 - Multi_result_2 + Multi_result_3 + 32'd128) >>> 32'd8; // right shift, dividing by 2^8. (1/256). 
					
					
					Multi_op_1 <= adder1;
					Multi_op_2 <= 32'd21;
					
					Multi_op_3 <= adder2;
					Multi_op_4 <= 32'd52;
					
					Multi_op_5 <= adder3;
					Multi_op_6 <= 32'd159;
					
					adder1 <= y_even-8'd16; // potential issue: it shows a negative number for some reason in deci?
					adder2 <= v_even_prime-32'h80; // u prime or v prime we're dealing with?
					adder3 <= $signed(u_even_prime)-32'h80;
					
					// error, not signed. 
					MS1_state <= S_MS1_COMMON_CASE_2;
            end
				
            S_MS1_COMMON_CASE_2: begin
					SRAM_address <= v_address + uv_counter;
					if (y_counter < 18'd155) begin // because after the Y308Y309 read (where y counter is 155)..
					// we wouldn't want to increment the u/v counter to a value of 160 or greater (since u/v values correspond to (y+5)/2)
						uv_counter <= uv_counter + 2'd1;
					end
					
					v_odd_prime <= (Multi_result_1 - Multi_result_2 + Multi_result_3 + 32'd128) >>> 32'd8;
					
					Multi_op_1 <= a;
					Multi_op_2 <= adder1;
					
					Multi_op_3 <= c;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= e;
					Multi_op_6 <= adder3;
					
					MS1_state <= S_MS1_COMMON_CASE_3;
            end
				
            S_MS1_COMMON_CASE_3: begin
					// avoids writing this usually when its the first pixel of the row
					// because this is for the next iteration of the common case
					if (y_counter > 18'd3) begin 
						SRAM_we_n <= 1'b0;
						SRAM_address <= rgb_address + rgb_counter;
						rgb_counter <= rgb_counter + 1'd1;
					   SRAM_write_data <= {clipped_g_odd[7:0], clipped_b_odd[7:0]};
					end
					
					y_even <= SRAM_read_data[15:8];
					y_odd <= SRAM_read_data[7:0];
					r_even <= (Multi_result_1 + Multi_result_2); //>>> 32'd16;
					g_even <= Multi_result_3; //buffer G even for next clk cycle MS1_state
					
					Multi_op_3 <= f;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= h;
					Multi_op_6 <= adder3;
					
					adder1 <= y_odd-32'd16;
					adder2 <= v_odd_prime-32'd128;
					adder3 <= u_odd_prime-32'd128;
					
					MS1_state <= S_MS1_COMMON_CASE_4;
            end
				
            S_MS1_COMMON_CASE_4: begin //clk cycle 15
					//need to 
					u_buffer <= SRAM_read_data; // we are buffering the U values being read right now before its overwritten
					
					SRAM_we_n <= 1'b1;
					
					g_even <= (Multi_result_1 + Multi_result_2 + g_even) ; //1/65536
					b_even <= (Multi_result_1 + Multi_result_3) ;
					
					Multi_op_1 <= a;
					Multi_op_2 <= adder1;
					
					Multi_op_3 <= c;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= e;
					Multi_op_6 <= adder3;
					
               MS1_state <= S_MS1_COMMON_CASE_5;
            end
				
            S_MS1_COMMON_CASE_5: begin
					v_buffer <= SRAM_read_data;
					SRAM_we_n <= 1'b0;
					SRAM_address <= rgb_address + rgb_counter;
					rgb_counter <= rgb_counter + 1'd1;
					SRAM_write_data <= {clipped_r_even[7:0], clipped_g_even[7:0]};
					// then..
					r_odd <= (Multi_result_1 + Multi_result_2) ;
					g_odd <= Multi_result_3; //buffer G odd for next clk cycle MS1_state
					
					Multi_op_3 <= f;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= h;
					Multi_op_6 <= adder3;
					
					
					//if (y_counter > 32'd3) begin
						u_even_prime <= u_plus_1; //this becomes the old u_plus_1 which is the current u_minus_1
						if (y_counter > 18'd157) begin
							u_plus_5 <= u_buffer[7:0]; //fetches the buffered U159
						end else begin
							u_plus_5 <= u_buffer[15:8];
					
					MS1_state <= S_MS1_COMMON_CASE_13;
					
					
						end 
						u_minus_5 <= u_minus_3;
						u_plus_3 <= u_plus_5;
						u_minus_3 <= u_minus_1;
						u_plus_1 <= u_plus_3;
						u_minus_1 <= u_plus_1;
					//end
					
					MS1_state <= S_MS1_COMMON_CASE_6;
            end
				
            S_MS1_COMMON_CASE_6: begin
						// B even R odd goes to <= SRAM_write_data
						SRAM_we_n <= 1'b0;
						SRAM_address <= rgb_address + rgb_counter;
						rgb_counter <= rgb_counter + 1'd1;
						
						SRAM_write_data <= {clipped_b_even[7:0], clipped_r_odd[7:0]};

						g_odd <= (Multi_result_1 + Multi_result_2 + g_odd);
						b_odd <= (Multi_result_1 + Multi_result_3);
						
						//if (y_counter > 2'd3) begin
							v_even_prime <= v_plus_1;
							if (y_counter > 18'd157) begin
								v_plus_5 <= v_buffer[7:0]; //fetches the buffered V159
							end else begin
								v_plus_5 <= v_buffer[15:8];
							end 

							v_minus_5 <= v_minus_3;
							v_plus_3 <= v_plus_5;
							v_minus_3 <= v_minus_1;
							v_plus_1 <= v_plus_3;
							v_minus_1 <= v_plus_1;
							
							adder1 <= u_plus_5 + u_minus_5;
							adder2 <= u_plus_3 + u_minus_3;
							adder3 <= u_plus_1 + u_minus_1;
						//end
						MS1_state <= S_MS1_COMMON_CASE_7;
            end

            S_MS1_COMMON_CASE_7: begin
					SRAM_we_n <= 1'b1;
					SRAM_address <= y_address + y_counter;
					y_counter <= y_counter + 2'd1;
					
					Multi_op_1 <= adder1;
					Multi_op_2 <= 32'd21;
					
					Multi_op_3 <= adder2;
					Multi_op_4 <= 32'd52;
					
					Multi_op_5 <= adder3;
					Multi_op_6 <= 32'd159;
					
					adder1 <= v_plus_5 + v_minus_5;
					adder2 <= v_plus_3 + v_minus_3;
					adder3 <= v_plus_1 + v_minus_1;
				
					MS1_state <= S_MS1_COMMON_CASE_8;
            end

            S_MS1_COMMON_CASE_8: begin
					u_odd_prime <= (Multi_result_1 - Multi_result_2 + Multi_result_3 + 32'd128) >>> 32'd8; // right shift, dividing by 2^8. (1/256). 
					
					Multi_op_1 <= adder1;
					Multi_op_2 <= 32'd21;
					
					Multi_op_3 <= adder2;
					Multi_op_4 <= 32'd52;
					
					Multi_op_5 <= adder3;
					Multi_op_6 <= 32'd159;
					
					adder1 <= y_even-32'd16;
					adder2 <= v_even_prime-32'd128;
					adder3 <= u_even_prime-32'd128;
					
					MS1_state <= S_MS1_COMMON_CASE_9;
            end
				
            S_MS1_COMMON_CASE_9: begin
					v_odd_prime <= (Multi_result_1 - Multi_result_2 + Multi_result_3 + 32'd128) >>> 32'd8;
					
					Multi_op_1 <= a;
					Multi_op_2 <= adder1;
					
					Multi_op_3 <= c;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= e;
					Multi_op_6 <= adder3;
					MS1_state <= S_MS1_COMMON_CASE_10;
            end
				
            S_MS1_COMMON_CASE_10: begin
					SRAM_we_n <= 1'b0;
					SRAM_address <= rgb_address + rgb_counter;
					rgb_counter <= rgb_counter + 1'd1;
					
					
					// write G ODD B ODD <= SRAM
					
					SRAM_write_data <= {clipped_g_odd[7:0], clipped_b_odd[7:0]};
					y_even <= SRAM_read_data[15:8];
					y_odd <= SRAM_read_data[7:0];
					
					r_even <= (Multi_result_1 + Multi_result_2) ;
					g_even <= Multi_result_3; //buffer G even for next clk cycle MS1_state
					
					Multi_op_3 <= f;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= h;
					Multi_op_6 <= adder3;
					
					adder1 <= y_odd-32'd16;
					adder2 <= v_odd_prime-32'd128; // u prime or u? //, are we accessing specific data indexes? e.g sram even or odd data?
					adder3 <= u_odd_prime-32'd128;

					
					MS1_state <= S_MS1_COMMON_CASE_11;
            end
				
            S_MS1_COMMON_CASE_11: begin
					SRAM_we_n <= 1'b1;
					g_even <= (Multi_result_1 + Multi_result_2 + g_even);
					b_even <= (Multi_result_1 + Multi_result_3);
					
					Multi_op_1 <= a;
					Multi_op_2 <= adder1;
					
					Multi_op_3 <= c;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= e;
					Multi_op_6 <= adder3;
					
               MS1_state <= S_MS1_COMMON_CASE_12;
					
            end
				
            S_MS1_COMMON_CASE_12: begin
					
					SRAM_we_n <= 1'b0;

					SRAM_address <= rgb_address + rgb_counter;
					rgb_counter <= rgb_counter + 1'd1;
					// R even G even goes to <= SRAM_write_data
					
					SRAM_write_data <= {clipped_r_even[7:0], clipped_g_even[7:0]};
					// then..
					r_odd <= (Multi_result_1 + Multi_result_2) ;
					g_odd <= Multi_result_3; //buffer G odd for next clk cycle MS1_state
					
					Multi_op_3 <= f;
					Multi_op_4 <= adder2;
					
					Multi_op_5 <= h;
					Multi_op_6 <= adder3;
					
					u_even_prime <= u_plus_1;
					u_plus_5 <= u_buffer[7:0];

					u_minus_5 <= u_minus_3;
					u_plus_3 <= u_plus_5;
					u_minus_3 <= u_minus_1;
					u_plus_1 <= u_plus_3;
					u_minus_1 <= u_plus_1;
					
					MS1_state <= S_MS1_COMMON_CASE_13;
            end
				
            S_MS1_COMMON_CASE_13: begin
					SRAM_we_n <= 1'b0;

					SRAM_address <= rgb_address + rgb_counter;
					// B even R odd goes to <= SRAM_write_data
					SRAM_write_data <= {clipped_b_even[7:0], clipped_r_odd[7:0]};
					
					g_odd <= (Multi_result_1 + Multi_result_2 + g_odd);
					b_odd <= (Multi_result_1 + Multi_result_3) ;
					 
					v_even_prime <= v_plus_1;
					v_plus_5 <= v_buffer[7:0];

					v_minus_5 <= v_minus_3;
					v_plus_3 <= v_plus_5;
					v_minus_3 <= v_minus_1;
					v_plus_1 <= v_plus_3;
					v_minus_1 <= v_plus_1;
					
					adder1 <= u_plus_5 + u_minus_5;
					adder2 <= u_plus_3 + u_minus_3;
					adder3 <= u_plus_1 + u_minus_1;
					
				   if (rgb_counter > 18'd477) begin // exit case if RGB count is 478
						rgb_counter <= rgb_counter + 18'd1;
						MS1_state <= S_MS1_LEAD_OUT_0;
					end else begin
						rgb_counter <= rgb_counter + 18'd1;
						MS1_state <= S_MS1_COMMON_CASE_0;
					end
            end
				
//				S_MS1_LEAD_OUT_0: begin
//					SRAM_we_n <= 1'b0;
//				
//					multi1 <= adder1 * 32'd21;
//					multi2 <= adder2 * 32'd52;
//					multi3 <= adder3 * 32'd159;
//					
//					MS1_state <= S_MS1_LEAD_OUT_1;
//            end
//				
//				S_MS1_LEAD_OUT_1: begin
//				
//					multi1 <= adder1 * 32'd21;
//					multi2 <= adder2 * 32'd52;
//					multi3 <= adder3 * 32'd159;
//					
//					adder1 <= y_even-32'd16;
//					adder2 <= v_even_prime-32'd128; 
//					adder3 <= u_even_prime-32'd128;
//					
//					MS1_state <= S_MS1_LEAD_OUT_2;
//            end
//				
//				S_MS1_LEAD_OUT_2: begin
//				
//					multi1 <= adder1 * a;
//					multi2 <= adder2 * c;
//					multi3 <= adder3 * e;
//					
//               MS1_state <= S_MS1_LEAD_OUT_3;
//            end
//				
//				S_MS1_LEAD_OUT_3: begin
//					//SRAM_address <= rgb_address + counter;
//					// write G317, B317 to SRAM_Write_Data
//					
//					SRAM_write_data <= {g_odd, b_odd};
//					
//					r_even <= (multi1 + multi2) >>> 32'd16;
//					g_even <= multi3;
//					
//					multi2 <= f * adder2; //f*V 
//					multi3 <= h * adder3; //h*U
//					
//					adder1 <= y_odd-32'd16;
//					adder2 <= v_odd_prime-32'd128; 
//					adder3 <= u_odd_prime-32'd128;
//					
//               MS1_state <= S_MS1_LEAD_OUT_4;
//            end
//				
//				S_MS1_LEAD_OUT_4: begin
//					g_even <= (multi1 + multi2 + g_even) >>> 32'd16;
//					b_even <= (multi1 + multi3) >>> 32'd16;
//					
//					multi1 <= a * adder1;
//					multi2 <= c * adder2;
//					multi3 <= e * adder3;
//					
//               MS1_state <= S_MS1_COMMON_CASE_5;
//            end
//				
//            S_MS1_LEAD_OUT_5: begin
//					//SRAM_address <= rgb_address + counter;
//					// R even G even goes to <= SRAM_write_data
//					SRAM_write_data <= {r_even, g_even};
//					// then..
//					r_odd <= multi1 + multi2;
//					g_odd <= multi3; //buffer G odd for next clk cycle MS1_state
//            
//					
//					multi2 <= f * adder2; //f*V 
//					multi3 <= h * adder3; //h*U
//					
//					u_even_prime <= SRAM_read_data[7:0];
//					u_plus_5 <= SRAM_read_data[15:8];
//					u_minus_5 <= u_minus_3;
//					u_plus_3 <= u_plus_5;
//					u_minus_3 <= u_minus_1;
//					u_plus_1 <= u_plus_3;
//					u_minus_1 <= u_plus_1;
//					
//					MS1_state <= S_MS1_LEAD_OUT_6;
//            end
//				
//            S_MS1_LEAD_OUT_6: begin
//					//SRAM_address <= rgb_address + counter;
//					// B even R odd goes to <= SRAM_write_data
//					SRAM_write_data <= {b_even, r_odd};
//					
//					g_odd <= (multi1 + multi2 + g_odd) >>> 32'd16;
//					b_odd <= (multi1 + multi3) >>> 32'd16;
//					
//					v_even_prime <= SRAM_read_data[7:0];
//					v_plus_5 <= SRAM_read_data[15:8];
//					v_minus_5 <= v_minus_3;
//					v_plus_3 <= v_plus_5;
//					v_minus_3 <= v_minus_1;
//					v_plus_1 <= v_plus_3;
//					v_minus_1 <= v_plus_1;
//				
//            end			
//       
//            S_MS1_LEAD_OUT_7: begin
//					//SRAM_address <= rgb_address + counter;
//					// Final G odd, B odd
//					SRAM_write_data <= {g_odd, b_odd};
//					
//					M1_end <= 1'b1;
//					MS1_state <= S_MS1_IDLE;
//            end
				
				S_MS1_LEAD_OUT_0: begin
					SRAM_address <= rgb_address + rgb_counter;
					// Final G odd, B odd
					SRAM_write_data <= {clipped_g_odd[7:0], clipped_b_odd[7:0]}; //counter number 479
					
					rgb_counter <= rgb_counter + 18'd1; //goes to counter number 480*i due to next row i
					//y_counter <= y_counter + 18'd1; //no need to update y_counter because we already did (so now its at 160)
					uv_counter <= uv_counter + 18'd1;
					
					SRAM_we_n <= 1'b0; // debug fix: we want to write the write the last location per row as well
					//M1_end <= 1'b1;
					MS1_state <= S_MS1_LEAD_OUT_1;
            end
				
				S_MS1_LEAD_OUT_1: begin
					SRAM_we_n <= 1'b1;
					
					if (row_counter > 18'd239) begin // end case
						M1_end <= 1'b1;
						//M1_start <= 1'b0;
						MS1_state <= S_MS1_IDLE;
					end else begin
						MS1_state <= S_MS1_IDLE;
					end
            end
				
				default: MS1_state <= S_MS1_IDLE;
				
				endcase
		end
	end
        
endmodule
