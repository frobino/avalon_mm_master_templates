-------------------------------------------------------------------------------
-- Filename: simple_example.vhd
-- Date:     2 Sep 2009
-- Author:   GM
--
-- Description:
--
-- This is a design example showing how to implement read and write transfers in an
-- Avalon Memory Mapped Master.
-- The design implements a simple DMA to illustrate the Avalon MM signals
-- for read and write masters.  The design has been kept
-- deliberately simple so that the complexity of implementing extra features
-- does not obscure the logic associated with Avalon MM transactions.
-- This design is an example only and whilst it operates correctly it is
-- unlikely to provide a useful function.  Nor does it attempt to maximise
-- operating frequency or provide optimal logic implementation.
--
-- The design consists of 4 main elements, these are:
--   Control and Status Avalon MM slave
--     Used to load read and write address into the DMA and for control
--     and status monitoring.
--   Read Master
--     A 32 bit Avalon MM read master that reads from the Avalon MM system.
--   Write Master.
--     A 32 bit Avalon MM write master that writes to the Avalon MM system.
--   FIFO
--     a buffer between the read master and write master.
--
-- The operation of the DMA is as follows:
-- The software writes a read address and a write address into the control
-- registers that form part of the slave interface.
-- A "go" bit is then written to the control slave and the DMA starts operation
-- The DMA will then read 256 32 bit words starting from the read address.
-- The data is buffered in the FIFO and then written to back to the Avalon MM
-- system starting at the write address.
-- There is no stop control or number of words setting, the DMA simply transfers
-- 256 words and then stops and awaits another transaction.
-- The DMA assumes 32 bit aligned read and write addresses.
--
--
-- The FIFO
--
-- This is a 32 bit by 64 word FIFO that was created with the Quartus II MegaWizard
-- PlugIn manager and instantiated within this design.
--
--
-- Read master operation
--
-- The read master performs 8 blocks of 32 word reads and writes the data to the FIFO
-- A read transaction will only be started if there is sufficient room in the FIFO
-- This is implemented as a state machine with the following 2 states:
-- IDLE
--   State machine is idle awaiting the go bit
-- RUNNING
--   This is where the reading occurs.
--   Upon completion of the reads the state machine goes to stopping
-- STOPPING
--   This state allows for one extra cycle before going back to idle
--   this is required because the fifo empty flag is not updated until one
--   cycle after data is written in.
--   Since the write state machine detects completion based upon a read
--   state of idle and an empty fifo this cycle delay becomes necessary.
--
-- a lot of the Avalon control signals are handled in combinatorial logic
--
--
-- Write master operation
--
-- The write master takes data from the fifo and writes to the Avalon MM system
-- until the fifo is empty and the read state machine is idle
--
-- IDLE
--   State machine is idle awaiting the go bit.
-- RUNNING
--   does the writing and waits until read state machine is idle and fifo is empty
--
--
-- Control Slave
--
-- This is a simple memory mapped collection of registers and and readdata mux

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity simple_example is
port (
	-- clock interface
	csi_clock_clk : in std_logic;
	csi_clock_reset : in std_logic;
	
	-- read master
	avm_read_master_read : out std_logic;
	avm_read_master_address : out std_logic_vector (31 downto 0);
	avm_read_master_readdata : in std_logic_vector (31 downto 0);
	avm_read_master_waitrequest : in std_logic;
	
	-- write master
	avm_write_master_write : out std_logic;
	avm_write_master_address : out std_logic_vector (31 downto 0);
	avm_write_master_writedata : out std_logic_vector (31 downto 0);
	avm_write_master_waitrequest : in std_logic;
	
	-- control & status registers (CSR) slave
	avs_csr_address : in std_logic_vector (1 downto 0);
	avs_csr_readdata : out std_logic_vector (31 downto 0);
	avs_csr_write : in std_logic;
	avs_csr_writedata : in std_logic_vector (31 downto 0)
);
end simple_example;

architecture a of simple_example is

-- declare FIFO component
-- the FIFO component was generated using the Quartus II MegaWizard Plug-In Manager
component example_master_fifo
port (
	aclr : in std_logic;
	clock : in std_logic;
	data : in std_logic_vector (31 downto 0);
	rdreq : in std_logic;
	wrreq : in std_logic;
	empty : out std_logic;
	full : out std_logic;
	q : out std_logic_vector (31 downto 0);
	usedw : out std_logic_vector (5 downto 0)
);
end component;

-- fifo instantiation signals
signal fifo_read, fifo_write : std_logic;
signal fifo_empty, fifo_full : std_logic;

-- state machine states
type read_states_T is (idle, running, stopping);
type write_states_T is (idle, running);
signal read_state : read_states_T;
signal write_state : write_states_T;

-- extra read master signals
signal read_address : std_logic_vector (31 downto 0);         -- the current read address
signal words_read : std_logic_vector (8 downto 0);            -- tracks the words read

-- extra write master signals
signal write_address : std_logic_vector (31 downto 0);        -- the current write address

-- CSR registers
signal csr_status : std_logic_vector (31 downto 0);           -- the status word that will be read from the status register
signal csr_rd_addr : std_logic_vector (31 downto 0);          -- the read start address register
signal csr_wr_addr : std_logic_vector (31 downto 0);          -- the write start address register
signal csr_go_flag : std_logic;                               -- used to start the DMA (when logic 1)
signal active_flag : std_logic;                               -- logic 1 if either state machines are active

begin

-------------------------------------------------------------------------------
-- FIFO INSTATIATION
-------------------------------------------------------------------------------

fifo_inst: example_master_fifo
port map (
	aclr => csi_clock_reset,
	clock => csi_clock_clk,
	data => avm_read_master_readdata,
	rdreq => fifo_read,
	wrreq => fifo_write,
	empty => fifo_empty,
	full => fifo_full,
	q => avm_write_master_writedata,
	usedw => open
);

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- THE READ MASTER STATE MACHINE
-------------------------------------------------------------------------------

read_FSM: process (csi_clock_clk, csi_clock_reset)
begin
	if csi_clock_reset = '1' then
		read_state <= idle;
		read_address <= (others => '0');
		words_read <= (others => '0');
	elsif rising_edge (csi_clock_clk) then

		case read_state is
			
			-- IDLE
			-- When idle just sit and wait for the go flag.
			-- Only start if the write state machine is idle as it may be
			-- finishing a previous data transfer.
			-- Start the machine by moving to the running state and initialising address and counters.
			when idle =>
				if write_state = idle and csr_go_flag = '1' then
					read_state <= running;
					read_address <= csr_rd_addr;
					words_read <= (others => '0');
				end if;
				
			-- RUNNING
			-- Count reads, inc address and check for completion
			-- The read signal is held inactive by comb logic if fifo full so do nothing if fifo full
			-- also do nothing if waitrequest is active as this means signals need to be held
			when running =>
				-- if waitrequest is active or fifo full do nothing, otherwise...
				if avm_read_master_waitrequest /= '1' and fifo_full /= '1' then
					read_address <= read_address + 4;  -- add 4 per word as masters use byte addressing					
					words_read <= words_read + 1;
					if words_read = 255 then  -- 256 in total (255 previous plus this one)
						read_state <= stopping;
					end if;	
				end if;
				
			-- STOPPING
			-- Required to implement a cycle delay before going idle
			-- This ensures that the fifo empty flag is updated before going idle
			-- so that the write state machine does not register a false completion
			when stopping =>
				read_state <= idle;
		
		end case;
	end if;
end process;

-- read combinatorial signals

	-- read when in in running state and fifo not full
	avm_read_master_read <= '1' when read_state = running and fifo_full = '0' else '0';
	
	-- simply write data into the fifo as it comes in (read asserted and waitrequest not active)
	fifo_write <= '1' when read_state = running and avm_read_master_waitrequest = '0' and fifo_full = '0' else '0';
	
	-- this maps the internal address directly to the external port
	avm_read_master_address <= read_address;

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- THE WRITE MASTER STATE MACHINE
-------------------------------------------------------------------------------

write_FSM: process (csi_clock_clk, csi_clock_reset)
begin
	if csi_clock_reset = '1' then
		write_state <= idle;
	elsif rising_edge (csi_clock_clk) then


		case write_state is
			
			-- IDLE
			-- Just sit and wait for the go flag
			-- When the go flag is set start by moving to the writing state and 
			-- set the address.
			when idle =>
				if csr_go_flag = '1' then
					write_state <= running;
					write_address <= csr_wr_addr;
				end if;
			
			-- RUNNING
			-- write words out of the fifo
			-- inc address as we go
			-- if no data in fifo go back to fifo wait state
			-- The write signal is held inactive by comb logic if fifo empty so do nothing if fifo empty
			when running =>
				if avm_write_master_waitrequest /= '1' and fifo_empty /= '1' then
					write_address <= write_address + 4;  -- Masters use byte addressing so inc by 4 for next word
				end if;
				if fifo_empty = '1' and read_state = idle then
					write_state <= idle;
				end if;			
		end case;
	end if;
end process;

-- write combinatorial signals

	-- the write signal is active if in running state and fifo not empty
	avm_write_master_write <= '1' when write_state = running and fifo_empty = '0' else '0';

	-- this maps the internal address directly to the external port	
	avm_write_master_address <= write_address;
	
	-- the fifo_read signal takes data from the fifo and updates it's output with the next word
	-- should be 1 when writing and not in waitrequest
	fifo_read <= '1' when write_state = running and fifo_empty = '0' and avm_write_master_waitrequest = '0' else '0';

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- CONTROL AND STATUS REGISTERS
-------------------------------------------------------------------------------

-- control and status registers
--
-- address map
--  00 control (write only)
--  01 status (read only)
--  10 read start address
--  11 write start address
--
-- control register 
--  bit 0 : start control (pulse 1 to start)
--
-- status register
--  bit 0 : active flag (1 when DMA active)

-- write control of read and write address registers
csr: process (csi_clock_clk, csi_clock_reset)
begin
	if csi_clock_reset = '1' then
		csr_rd_addr <= (others => '0');
		csr_wr_addr <= (others => '0');
	elsif rising_edge (csi_clock_clk) then
		if avs_csr_write = '1' then
			case avs_csr_address is
				when "10" =>
					csr_rd_addr <= avs_csr_writedata (31 downto 2) & "00";
					-- ignore 2 lsbs as this component only supports word aligned data
				when "11" =>
					csr_wr_addr <= avs_csr_writedata (31 downto 2) & "00";
					-- ignore 2 lsbs as this component only supports word aligned data
				when others =>
			end case;
		end if;
	end if;
end process;		

-- write control of go flag
-- note that this is a pulsed signal rather than a registered control bit
-- this is because this device is pulsed to start and then runs to completion
-- there is no stop control
csr_go_flag <= avs_csr_writedata(0) when avs_csr_write = '1' and avs_csr_address = "00" else '0';

-- readdata mux
active_flag <= '0' when read_state = idle and write_state = idle else '1';
csr_status <= "0000000000000000000000000000000" & active_flag;

read_mux: process (avs_csr_address, csr_status, csr_rd_addr, csr_wr_addr)
begin
	case avs_csr_address is
		when "10" =>
			avs_csr_readdata <= csr_rd_addr;
		when "11" =>
			avs_csr_readdata <= csr_wr_addr;
		when others =>
			avs_csr_readdata <= csr_status;
	end case;
end process;

-------------------------------------------------------------------------------
end a;

