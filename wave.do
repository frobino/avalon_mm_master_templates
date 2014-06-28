onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Simple DMA}
add wave -noupdate -format Logic /test_bench/dut/the_simple_dma/csi_clock_clk
add wave -noupdate -format Logic /test_bench/dut/the_simple_dma/simple_dma/csr_go_flag
add wave -noupdate -color {Cornflower Blue} -format Literal /test_bench/dut/the_simple_dma/simple_dma/read_state
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_simple_dma/simple_dma/words_read
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_simple_dma/simple_dma/fifo_full
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_simple_dma/avm_read_master_address
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_simple_dma/avm_read_master_read
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_simple_dma/avm_read_master_waitrequest
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_simple_dma/avm_read_master_readdata
add wave -noupdate -color Red -format Literal /test_bench/dut/the_simple_dma/simple_dma/write_state
add wave -noupdate -color Red -format Logic /test_bench/dut/the_simple_dma/simple_dma/fifo_empty
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_simple_dma/avm_write_master_address
add wave -noupdate -color Red -format Logic /test_bench/dut/the_simple_dma/avm_write_master_write
add wave -noupdate -color Red -format Logic /test_bench/dut/the_simple_dma/avm_write_master_waitrequest
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_simple_dma/avm_write_master_writedata
add wave -noupdate -divider {Block DMA}
add wave -noupdate -format Logic /test_bench/dut/the_block_dma/csi_clock_clk
add wave -noupdate -format Logic /test_bench/dut/the_block_dma/block_dma/csr_go_flag
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/block_dma/room_in_fifo
add wave -noupdate -color {Cornflower Blue} -format Literal /test_bench/dut/the_block_dma/block_dma/read_state
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/block_dma/reads_within_block
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/block_dma/read_blocks_completed
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/avm_read_master_address
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_block_dma/avm_read_master_read
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_block_dma/avm_read_master_waitrequest
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/avm_read_master_readdata
add wave -noupdate -color Red -format Literal /test_bench/dut/the_block_dma/block_dma/write_state
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/block_dma/write_word_count
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/avm_write_master_address
add wave -noupdate -color Red -format Logic /test_bench/dut/the_block_dma/avm_write_master_write
add wave -noupdate -color Red -format Logic /test_bench/dut/the_block_dma/avm_write_master_waitrequest
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_block_dma/avm_write_master_writedata
add wave -noupdate -divider {Pipelined DMA}
add wave -noupdate -format Logic /test_bench/dut/the_pipelined_dma/csi_clock_clk
add wave -noupdate -format Logic /test_bench/dut/the_pipelined_dma/pipelined_dma/csr_go_flag
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/pipelined_dma/room_in_fifo
add wave -noupdate -color {Cornflower Blue} -format Literal /test_bench/dut/the_pipelined_dma/pipelined_dma/read_state
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/pipelined_dma/reads_within_block
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/pipelined_dma/read_blocks_completed
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/pipelined_dma/pending_reads
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/avm_read_master_address
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_pipelined_dma/avm_read_master_read
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_pipelined_dma/avm_read_master_waitrequest
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/avm_read_master_readdata
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_pipelined_dma/avm_read_master_readdatavalid
add wave -noupdate -color Red -format Literal /test_bench/dut/the_pipelined_dma/pipelined_dma/write_state
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/pipelined_dma/write_word_count
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/avm_write_master_address
add wave -noupdate -color Red -format Logic /test_bench/dut/the_pipelined_dma/avm_write_master_write
add wave -noupdate -color Red -format Logic /test_bench/dut/the_pipelined_dma/avm_write_master_waitrequest
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_pipelined_dma/avm_write_master_writedata
add wave -noupdate -divider {Burst DMA}
add wave -noupdate -format Logic /test_bench/dut/the_burst_dma/csi_clock_clk
add wave -noupdate -format Logic /test_bench/dut/the_burst_dma/burst_dma/csr_go_flag
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/burst_dma/room_in_fifo
add wave -noupdate -color {Cornflower Blue} -format Literal /test_bench/dut/the_burst_dma/burst_dma/read_state
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/burst_dma/bursts_completed
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/burst_dma/pending_reads
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_read_master_address
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_burst_dma/avm_read_master_read
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_burst_dma/avm_read_master_waitrequest
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_read_master_burstcount
add wave -noupdate -color {Cornflower Blue} -format Logic /test_bench/dut/the_burst_dma/avm_read_master_readdatavalid
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_read_master_readdata
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_write_master_address
add wave -noupdate -color Red -format Literal /test_bench/dut/the_burst_dma/burst_dma/write_state
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/burst_dma/write_word_count
add wave -noupdate -color Red -format Logic /test_bench/dut/the_burst_dma/avm_write_master_write
add wave -noupdate -color Red -format Logic /test_bench/dut/the_burst_dma/avm_write_master_waitrequest
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_write_master_burstcount
add wave -noupdate -color Red -format Literal -radix hexadecimal /test_bench/dut/the_burst_dma/avm_write_master_writedata
add wave -noupdate -divider src_ram
add wave -noupdate -format Logic /test_bench/dut/the_src_ram/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_src_ram/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_src_ram/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_src_ram/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_src_ram/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_src_ram/writedata
add wave -noupdate -divider dst_ram
add wave -noupdate -format Logic /test_bench/dut/the_dst_ram/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_dst_ram/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_dst_ram/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_dst_ram/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_dst_ram/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_dst_ram/writedata
add wave -noupdate -divider sdram
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/az_addr
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/az_be_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/az_cs
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/az_data
add wave -noupdate -format Logic /test_bench/dut/the_sdram/az_rd_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/az_wr_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/clk
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/za_data
add wave -noupdate -format Logic /test_bench/dut/the_sdram/za_valid
add wave -noupdate -format Logic /test_bench/dut/the_sdram/za_waitrequest
add wave -noupdate -format Literal -radix ascii /test_bench/dut/the_sdram/code
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/zs_addr
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/zs_ba
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/zs_cs_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/zs_ras_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/zs_cas_n
add wave -noupdate -format Logic /test_bench/dut/the_sdram/zs_we_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/zs_dq
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_sdram/zs_dqm
add wave -noupdate -divider cpu
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/i_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/i_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/i_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/i_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/i_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/clk
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/reset_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/d_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/d_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/d_irq
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/d_address
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/d_byteenable
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/d_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/d_write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/d_writedata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/the_cpu_test_bench/w_pcb
add wave -noupdate -format Literal -radix ascii /test_bench/dut/the_cpu/the_cpu_test_bench/w_vinst
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu/the_cpu_test_bench/w_valid
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu/the_cpu_test_bench/w_iw
add wave -noupdate -divider jtag_uart
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart/av_address
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/av_chipselect
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/av_irq
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/av_read_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart/av_readdata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/av_waitrequest
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/av_write_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart/av_writedata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/dataavailable
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart/readyfordata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14453498947 ps} 0}
configure wave -namecolwidth 263
configure wave -valuecolwidth 100
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {14453388635 ps} {14453793675 ps}
