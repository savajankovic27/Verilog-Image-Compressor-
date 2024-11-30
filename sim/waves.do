# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -hex UUT/milestone2_unit/MS2_state
add wave -dec UUT/milestone2_unit/offset_i
add wave -dec UUT/milestone2_unit/offset_j
add wave -dec UUT/milestone2_unit/block_i
add wave -dec UUT/milestone2_unit/block_j
add wave -dec UUT/milestone2_unit/finder

add wave -hex UUT/milestone2_unit/address_counter

add wave -dec UUT/milestone2_unit/address1
add wave -hex UUT/milestone2_unit/write_data_a(0)
add wave -dec UUT/milestone2_unit/write_enable_a(0)

add wave -dec UUT/milestone2_unit/address2
add wave -hex UUT/milestone2_unit/write_data_b(0)
add wave -dec UUT/milestone2_unit/write_enable_b(0)

add wave -hex UUT/SRAM_read_data
add wave -hex UUT/milestone2_unit/buffer
add wave -hex UUT/milestone2_unit/concatinate
add wave -hex UUT/milestone2_unit/even_flag
add wave -hex UUT/milestone2_unit/sprime_flag

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {DP-RAM signals}
add wave -hex UUT/milestone2_unit/RAM_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data
add wave -hex UUT/milestone2_unit/RAM_inst1/altsyncram_component/m_default/altsyncram_inst/mem_data

add wave -hex UUT/milestone2_unit/MS2_state

add wave -hex UUT/milestone2_unit/Multi_op_1
add wave -dec UUT/milestone2_unit/Multi_op_2
add wave -hex UUT/milestone2_unit/Multi_op_3
add wave -dec UUT/milestone2_unit/Multi_op_4
add wave -hex UUT/milestone2_unit/Multi_op_5
add wave -dec UUT/milestone2_unit/Multi_op_6

add wave -dec UUT/milestone2_unit/write_enable_a(1)
add wave -dec UUT/milestone2_unit/write_enable_b(1)
add wave -hex UUT/milestone2_unit/address3
add wave -hex UUT/milestone2_unit/address4

add wave -hex UUT/milestone2_unit/adder
add wave -hex UUT/milestone2_unit/t_val
add wave -dec UUT/milestone2_unit/write_data_a(1)
add wave -dec UUT/milestone2_unit/write_data_b(1)

add wave -hex UUT/milestone2_unit/col
add wave -hex UUT/milestone2_unit/write_count


add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

# Added milestone 1 waves of useful registers
#add wave -hex UUT/milestone1_unit/MS1_state
#add wave -hex UUT/milestone1_unit/rgb_counter
#add wave -hex UUT/milestone1_unit/y_counter
#add wave -hex UUT/milestone1_unit/uv_counter

#useful for m1 end case condition
#add wave -hex UUT/milestone1_unit/row_counter
#add wave -hex UUT/milestone1_unit/M1_end

#add wave -hex UUT/milestone1_unit/u_plus_5
#add wave -hex UUT/milestone1_unit/u_minus_5
#add wave -hex UUT/milestone1_unit/u_plus_3
#add wave -hex UUT/milestone1_unit/u_minus_3
#add wave -hex UUT/milestone1_unit/u_plus_1
#add wave -hex UUT/milestone1_unit/u_minus_1

#add wave -hex UUT/milestone1_unit/v_plus_5
#add wave -hex UUT/milestone1_unit/v_minus_5
#add wave -hex UUT/milestone1_unit/v_plus_3
#add wave -hex UUT/milestone1_unit/v_minus_3
#add wave -hex UUT/milestone1_unit/v_plus_1
#add wave -hex UUT/milestone1_unit/v_minus_1

#add wave -hex UUT/milestone1_unit/y_even
#add wave -hex UUT/milestone1_unit/y_odd
#add wave -hex UUT/milestone1_unit/u_even_prime
#add wave -hex UUT/milestone1_unit/u_odd_prime
#add wave -hex UUT/milestone1_unit/v_even_prime
#add wave -hex UUT/milestone1_unit/v_odd_prime

#add wave -dec UUT/milestone1_unit/a
#add wave -dec UUT/milestone1_unit/c
#add wave -dec UUT/milestone1_unit/e
#add wave -dec UUT/milestone1_unit/f
#add wave -dec UUT/milestone1_unit/h

#add wave -dec UUT/milestone1_unit/Multi_result_1
#add wave -dec UUT/milestone1_unit/Multi_result_2
#add wave -dec UUT/milestone1_unit/Multi_result_3
#add wave -dec UUT/milestone1_unit/adder1
#add wave -dec UUT/milestone1_unit/adder2
#add wave -dec UUT/milestone1_unit/adder3

#add wave -hex UUT/milestone1_unit/r_even
#add wave -hex UUT/milestone1_unit/g_even

#add wave -hex UUT/milestone1_unit/b_even
#add wave -hex UUT/milestone1_unit/r_odd

#add wave -hex UUT/milestone1_unit/g_odd
#add wave -hex UUT/milestone1_unit/b_odd
