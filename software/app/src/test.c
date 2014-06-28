#include <stdio.h>
#include <io.h>
#include <system.h>
#include <stdlib.h>

#define ram_src (int*)SRC_RAM_BASE
#define ram_dst (int*)DST_RAM_BASE

void burst_dma (int* src_ptr, int* dst_ptr)
{
    IOWR (BURST_DMA_BASE, 2, (int)src_ptr);
    IOWR (BURST_DMA_BASE, 3, (int)dst_ptr);
    IOWR (BURST_DMA_BASE, 0, 0x1);
    while (IORD (BURST_DMA_BASE, 1));
}

void pipelined_dma (int* src_ptr, int* dst_ptr)
{
    IOWR (PIPELINED_DMA_BASE, 2, (int)src_ptr);
    IOWR (PIPELINED_DMA_BASE, 3, (int)dst_ptr);
    IOWR (PIPELINED_DMA_BASE, 0, 0x1);
    while (IORD (PIPELINED_DMA_BASE, 1));
}

void block_dma (int* src_ptr, int* dst_ptr)
{
    IOWR (BLOCK_DMA_BASE, 2, (int)src_ptr);
    IOWR (BLOCK_DMA_BASE, 3, (int)dst_ptr);
    IOWR (BLOCK_DMA_BASE, 0, 0x1);
    while (IORD (BLOCK_DMA_BASE, 1));
}

void simple_dma (int* src_ptr, int* dst_ptr)
{
    IOWR (SIMPLE_DMA_BASE, 2, (int)src_ptr);
    IOWR (SIMPLE_DMA_BASE, 3, (int)dst_ptr);
    IOWR (SIMPLE_DMA_BASE, 0, 0x1);
    while (IORD (SIMPLE_DMA_BASE, 1));
}

void init_src (int* ptr)
{
  int i;
  for (i=0; i<0x100; i++)
  {
    *ptr = i;
    ptr++;
  }
}

int check_dst (int* ptr)
{
  int pass = -1;
  int i;
  for (i=0; i<0x100; i++)
  {
    if (*ptr != i)
        pass = 0;
    ptr++;
  }
  return pass;
}

void clr_dst (int* ptr)
{
  int i;
  for (i=0; i<0x100; i++)
  {
    *ptr = 0;
    ptr++;
  }
}

int main()
{ 
  int* sdram_dst;
  int* sdram_src;
  
  // allocate source and destination memory
  sdram_src = malloc (4 * 0x100);
  sdram_dst = malloc (4 * 0x100);
  
  // initialise memory
  init_src (sdram_src);
  init_src (ram_src);

  puts ("Initialisation done\n");
  
  /************************/
  /* simple example tests */
  /************************/
  puts ("");
  puts ("Simple Master:");
  
  clr_dst (sdram_dst);
  simple_dma (sdram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Balanced slow: Passed");
  else
    puts ("Balanced slow: FAILED!");
  
  clr_dst (ram_dst);
  simple_dma (ram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Balanced fast: Passed");
  else
    puts ("Balanced fast: FAILED!");    
  
  clr_dst (ram_dst);
  simple_dma (sdram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Slow to fast: Passed");
  else
    puts ("Slow to fast: FAILED!"); 
    
  clr_dst (sdram_dst);
  simple_dma (ram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Fast to slow: Passed");
  else
    puts ("Fast to slow: FAILED!");
    
    
  /***********************/
  /* block example tests */
  /***********************/
  puts ("");
  puts ("Block Based Master:");
  
  clr_dst (sdram_dst);
  block_dma (sdram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Balanced slow: Passed");
  else
    puts ("Balanced slow: FAILED!");
  
  clr_dst (ram_dst);
  block_dma (ram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Balanced fast: Passed");
  else
    puts ("Balanced fast: FAILED!");    
  
  clr_dst (ram_dst);
  block_dma (sdram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Slow to fast: Passed");
  else
    puts ("Slow to fast: FAILED!"); 
    
  clr_dst (sdram_dst);
  block_dma (ram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Fast to slow: Passed");
  else
    puts ("Fast to slow: FAILED!");    


  /***************************/
  /* pipelined example tests */
  /***************************/
  puts ("");
  puts ("Pipelined Master:");
  
  clr_dst (sdram_dst);
  pipelined_dma (sdram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Balanced slow: Passed");
  else
    puts ("Balanced slow: FAILED!");
  
  clr_dst (ram_dst);
  pipelined_dma (ram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Balanced fast: Passed");
  else
    puts ("Balanced fast: FAILED!");    
  
  clr_dst (ram_dst);
  pipelined_dma (sdram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Slow to fast: Passed");
  else
    puts ("Slow to fast: FAILED!"); 
    
  clr_dst (sdram_dst);
  pipelined_dma (ram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Fast to slow: Passed");
  else
    puts ("Fast to slow: FAILED!");
    
  
  /***********************/
  /* Burst example tests */
  /***********************/
  puts ("");
  puts ("Burst Master:");
  
  clr_dst (sdram_dst);
  burst_dma (sdram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Balanced slow: Passed");
  else
    puts ("Balanced slow: FAILED!");
  
  clr_dst (ram_dst);
  burst_dma (ram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Balanced fast: Passed");
  else
    puts ("Balanced fast: FAILED!");    
  
  clr_dst (ram_dst);
  burst_dma (sdram_src, ram_dst);
  if (check_dst(ram_dst))
    puts ("Slow to fast: Passed");
  else
    puts ("Slow to fast: FAILED!"); 
    
  clr_dst (sdram_dst);
  burst_dma (ram_src, sdram_dst);
  if (check_dst(sdram_dst))
    puts ("Fast to slow: Passed");
  else
    puts ("Fast to slow: FAILED!");
    
    
  puts ("");
  puts ("Tests Complete!");
  
  /* Event loop never exits. */
  while (1);

  return 0;
}
