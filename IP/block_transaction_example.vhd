-------------------------------------------------------------------------------
-- Filename: block_transaction_example.vhd
-- Date:     16 Sep 2009
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
-- unlikely to provide a useful function.  Nor does it attempt to maximize
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
-- A"go" bit is then written to the control slave and the DMA starts operation
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
-- This is implemented as a state machine with the following 3 states:
-- IDLE
--   State machine is idle awaiting the go bit
-- FIFO_WAIT
--   The state machine is active and is awaiting room in the fifo.
-- READING
--   This is where the reading occurs.
--   Upon completion of a block the state machine will move to finish_reads,
--   stay in this state or go to fifo_wait depending on whether all of the blocks are
--   completed, they are not completed and there is room in the fifo or if they are
--   not completed and there is no room in the fifo.
--
--
-- Write master operation
--
-- The write master performs 29 word block writes when there is sufficient data in the fifo.
-- The reason for the difference in block size from the read master is three fold:
--  1. to show that block sizes don't have to be 2^n values
--  2. to show that the write and read block sizes don't have to match
--  3. to show the emptying of the fifo when there are not 29 words available
-- The write master is also controlled by a 4 state, state machine.
-- IDLE
--   State machine is idle awaiting the go bit.
-- FIFO_WAIT
--   Waiting for 29 words to become available in the fifo.
--   If the read master state machine is idle then no more words will come and so
--   the state machine jumps to the final block state.
-- WRITING
--   Writes blocks of 29 words.
--   The words are counted and at the end of the block the state machine either goes back
--   to fifo wait or stays in this state and starts the next block if data is available.
-- FINAL_BLOCK
--   This empties the fifo and then goes back to idle upon completion.
--
--
-- Control Slave
--
-- This is a simple memory mapped collection of registers and a readdata mux

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity block_transaction_example is
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
end block_transaction_example;

architecture a of block_transaction_example is

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

-- fifo instanstiation signals
signal fifo_read, fifo_write : std_logic;
signal fifo_words : std_logic_vector (5 downto 0);

-- state machine states
type read_states_T is (idle, fifo_wait, reading);
type write_states_T is (idle, fifo_wait, writing, final_block);
signal read_state : read_states_T;
signal write_state : write_states_T;

-- extra read master signals
signal read_address : std_logic_vector (31 downto 0);         -- the current read address
signal read_blocks_completed : std_logic_vector (2 downto 0); -- tracks the number of blocks of words that have been read
signal room_in_fifo : std_logic_vector (6 downto 0);          -- tracks the available room in the fifo
signal reads_within_block : std_logic_vector (5 downto 0);    -- tracks the words read within a block

-- extra write master signals
signal write_address : std_logic_vector (31 downto 0);        -- the current write address
signal write_word_count : std_logic_vector (4 downto 0);      -- tracks the number of words written within a burst

-- CSR registers
signal csr_status : std_logic_vector (31 downto 0);           -- the status word that will be read from the status register
signal csr_rd_addr : std_logic_vector (31 downto 0);          -- the read start address register
signal csr_wr_addr : std_logic_vector (31 downto 0);          -- the write start address register
signal csr_go_flag : std_logic;                               -- used to start the DMA (when logic 1)
signal active_flag : std_logic;                               -- logic 1 if either state machines are active

begin

-------------------------------------------------------------------------------
-- FIFO INSTANTIATION
-------------------------------------------------------------------------------

fifo_inst: example_master_fifo
port map (
	aclr => csi_clock_reset,
	clock => csi_clock_clk,
	data => avm_read_master_readdata,
	rdreq => fifo_read,
	wrreq => fifo_write,
	empty => open,
	full => open,
	q => avm_write_master_writedata,
	usedw => fifo_words
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
		read_blocks_completed <= (others => '0');
		reads_within_block <= (others => '0');
	elsif rising_edge (csi_clock_clk) then

		case read_state is
			
			-- IDLE
			-- When idle just sit and wait for the go flag.
			-- Only start if the write state machine is idle as it may be
			-- finishing a previous data transfer.
			-- Start the machine by moving to the fifo_wait state and initialising address and counters.
			when idle =>
				if write_state = idle and csr_go_flag = '1' then
					read_state <= fifo_wait;
					read_address <= csr_rd_addr;
					read_blocks_completed <= (others => '0');
				end if;
			
			-- FIFO WAIT
			-- When in this state wait for the fifo to have sufficient space for another block of 32 words
			-- If so, start a block of reads by moving to the reading state.
			when fifo_wait =>
				-- check that fifo has enough space for 32 words
				if room_in_fifo >= 32 then
					read_state <= reading;
					reads_within_block <= (others => '0');					
				end if;
				
			-- READING
			-- Count blocks of reads
			-- If all blocks complete go to idle state.
			-- Otherwise stay in this state if there is room in fifo or return to fifo_wait if not.
			-- As each block is completed increment blocks completed counter.
			-- Be mindful to do nothing if waitrequest is active
			when reading =>
				-- if waitrequest is active do nothing, otherwise...
				if avm_read_master_waitrequest /= '1' then
				
					read_address <= read_address + 4;  -- add 4 per word as masters use byte addressing					
					reads_within_block <= reads_within_block + 1;
					if reads_within_block = 31 then  -- 32 in total (31 previous plus this one)
						reads_within_block <= (others => '0');
						read_blocks_completed <= read_blocks_completed + 1;

						if read_blocks_completed = 7 then  -- 8 in total (7 previous plus this one)
							read_state <= idle;
						elsif room_in_fifo < 32 then
							read_state <= fifo_wait;
						end if;
					end if;
				end if;
		
		end case;
	end if;
end process;

-- read combinatorial signals

	-- read when in mid_burst state only
	avm_read_master_read <= '1' when read_state = reading else '0';
	
	-- room in the fifo is size of fifo minus words used
	room_in_fifo <= "1000000" - fifo_words;
	
	-- simply write data into the fifo as it comes in
	-- no need for any checks as the read transaction would not be started
	-- if there was insufficient room
	fifo_write <= '1' when read_state = reading and avm_read_master_waitrequest = '0' else '0';
	
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
			-- When the go flag is set start by moving to the fifo wait state and 
			-- set the address and word counter.
			when idle =>
				if csr_go_flag = '1' then
					write_state <= fifo_wait;
					write_address <= csr_wr_addr;
					write_word_count <= (others => '0');
				end if;
			
			-- FIFO_WAIT
			-- wait until the fifo has enough words for a block of writes.
			-- If the read state machine is idle then it means that there will
			-- be no more words written in to the fifo, in this case the transaction
			-- is complete if the fifo is empty so go to the idle state.
			-- Otherwise go to final_block state to empty the fifo.
			when fifo_wait =>
				if fifo_words >= 29 then
					write_state <= writing;
				elsif read_state = idle then
					if fifo_words = 0 then
						write_state <= idle;
					else
						write_state <= final_block;
					end if;
				end if;
			
			-- WRITING
			-- Block of writes in progress
			-- If waitrequest is active do nothing otherwise count words written in this block.
			-- Upon completing a block reset word counter.
			-- Stay in WRITING if there is enough data in fifo or jump to fifo_wait state.
			-- The write data is updated if not in waitrequest by control of the fifo read signal
			-- in the combinatorial section below.
			when writing =>
				if avm_write_master_waitrequest /= '1' then
				
					write_address <= write_address + 4;  -- Masters use byte addressing so inc by 4 for next word
					write_word_count <= write_word_count + 1;
					if write_word_count = 28 then  -- if block complete
						write_word_count <= (others => '0');
						if fifo_words >= 29 then
							write_state <= writing;
						else
							write_state <= fifo_wait;
						end if;
					end if;
				end if;
			
			-- FINAL_BLOCK
			-- Read master is complete so just empty fifo.
			-- wait for fifo to empty and jump to idle state.
			when final_block =>
				if avm_write_master_waitrequest /= '1' then
					write_address <= write_address + 4;  -- Masters use byte addressing so inc by 4 for next word				
					if fifo_words = 1 then  -- fifo_words will be 1 if this is the last
						write_state <= idle;
					end if;
				end if;
				
			when others =>
				write_state <= idle;
			
		end case;
	end if;
end process;

-- write combinatorial signals

	-- the write signal is active if in the mid burst of final burst states
	avm_write_master_write <= '1' when write_state = writing or write_state = final_block else '0';

	-- this maps the internal address directly to the external port	
	avm_write_master_address <= write_address;
	
	-- the fifo_read signal takes data from the fifo and updates it's output with the next word
	-- should be 1 when writing and not in waitrequest
	fifo_read <= '1' when (write_state = writing or write_state = final_block) and avm_write_master_waitrequest = '0' else '0';

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

