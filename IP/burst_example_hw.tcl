# TCL File Generated by Component Editor 9.1fb
# Thu Sep 24 14:11:30 BST 2009
# DO NOT MODIFY


# +-----------------------------------
# | 
# | burst_example "Burst Example" v1.2
# | GM 2009.09.24.14:11:30
# | 
# | 
# | C:/Designs/Graham/avalon_templates_91/Example_MM_Masters/burst_example.vhd
# | 
# |    ./example_master_fifo.vhd syn, sim
# |    ./burst_example.vhd syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module burst_example
# | 
set_module_property NAME burst_example
set_module_property VERSION 1.2
set_module_property INTERNAL false
set_module_property GROUP "Avalon MM Master Templates"
set_module_property AUTHOR GM
set_module_property DISPLAY_NAME "Burst Example"
set_module_property TOP_LEVEL_HDL_FILE burst_example.vhd
set_module_property TOP_LEVEL_HDL_MODULE burst_example
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL FALSE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file example_master_fifo.vhd {SYNTHESIS SIMULATION}
add_file burst_example.vhd {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end

set_interface_property clock ENABLED true

add_interface_port clock csi_clock_clk clk Input 1
add_interface_port clock csi_clock_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point read_master
# | 
add_interface read_master avalon start
set_interface_property read_master associatedClock clock
set_interface_property read_master burstOnBurstBoundariesOnly false
set_interface_property read_master doStreamReads false
set_interface_property read_master doStreamWrites false
set_interface_property read_master linewrapBursts false

set_interface_property read_master ASSOCIATED_CLOCK clock
set_interface_property read_master ENABLED true

add_interface_port read_master avm_read_master_read read Output 1
add_interface_port read_master avm_read_master_address address Output 32
add_interface_port read_master avm_read_master_burstcount burstcount Output 6
add_interface_port read_master avm_read_master_readdata readdata Input 32
add_interface_port read_master avm_read_master_readdatavalid readdatavalid Input 1
add_interface_port read_master avm_read_master_waitrequest waitrequest Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point write_master
# | 
add_interface write_master avalon start
set_interface_property write_master associatedClock clock
set_interface_property write_master burstOnBurstBoundariesOnly false
set_interface_property write_master doStreamReads false
set_interface_property write_master doStreamWrites false
set_interface_property write_master linewrapBursts false

set_interface_property write_master ASSOCIATED_CLOCK clock
set_interface_property write_master ENABLED true

add_interface_port write_master avm_write_master_write write Output 1
add_interface_port write_master avm_write_master_address address Output 32
add_interface_port write_master avm_write_master_burstcount burstcount Output 6
add_interface_port write_master avm_write_master_writedata writedata Output 32
add_interface_port write_master avm_write_master_waitrequest waitrequest Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr associatedClock clock
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr isMemoryDevice false
set_interface_property csr isNonVolatileStorage false
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr printableDevice false
set_interface_property csr readLatency 0
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr avs_csr_address address Input 2
add_interface_port csr avs_csr_readdata readdata Output 32
add_interface_port csr avs_csr_write write Input 1
add_interface_port csr avs_csr_writedata writedata Input 32
# | 
# +-----------------------------------