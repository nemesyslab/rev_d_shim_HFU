#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <inttypes.h>

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

#define AXI_HUB_BASE                  0x40000000
#define AXI_HUB_CFG     AXI_HUB_BASE + 0x0000000
#define AXI_HUB_STS     AXI_HUB_BASE + 0x1000000
#define AXI_HUB_FIFO_0  AXI_HUB_BASE + 0x2000000

// Get the write count from the status register
uint32_t wr_count(volatile void *sts)
{
  return *((volatile uint32_t *)sts) & 0b11111;
}

// Get the read count from the status register
uint32_t rd_count(volatile void *sts)
{
  return (*((volatile uint32_t *)sts) >> 7) & 0b11111;
}

int main()
{
  int fd, i; // File descriptor, loop counter
  volatile void *cfg; // CFG register in AXI hub (set to 32 bits wide)
  volatile void *sts; // STS register in AXI hub (set to 32 bits wide)
  volatile void *fifo_0; // FIFO register in AXI hub on port 0

  // Open /dev/mem to access physical memory
  printf("Opening /dev/mem...\n");
  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  // Map CFG and STS registers
  // The base address of the AXI hub is 0x40000000
  // Bits 24-26 are used to indicate the target in the hub
  // 0 is the CFG register and 1 is the STS register
  printf("Mapping CFG and STS registers...\n");
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, AXI_HUB_CFG);
  printf("CFG register mapped to %x\n", AXI_HUB_CFG);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, AXI_HUB_STS);
  printf("STS register mapped to %x\n", AXI_HUB_STS);
  fifo_0 = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, AXI_HUB_FIFO_0);
  printf("FIFO register mapped to %x\n", AXI_HUB_FIFO_0);

  close(fd);
  printf("Mapping complete.\n");

  // Write 10 32-bit words to the FIFO
  printf("Writing 10 lines to FIFO with no delay...\n");
  for(i = 0; i < 10; i++)
  {
    *((volatile uint32_t *)fifo_0) = i; // Write to FIFO
    printf("Wrote %d to FIFO\n", i);
  }

  // Check FIFO status in register
  printf("Checking FIFO status...\n");
  printf("Write count: %d\n", wr_count(sts));
  printf("Read count: %d\n", rd_count(sts));

  // Read 5 32-bit words from the FIFO
  printf("Reading 5 lines from FIFO...\n");
  for(i = 0; i < 5; i++)
  {
    uint32_t data = *((volatile uint32_t *)fifo_0); // Read from FIFO
    printf("Read %d from FIFO\n", data);
  }

  // Check FIFO status in register
  printf("Checking FIFO status...\n");
  printf("Write count: %d\n", wr_count(sts));
  printf("Read count: %d\n", rd_count(sts));
}
