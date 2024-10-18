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

  close(fd);
  printf("Mapping complete.\n");

  // Perform NAND operation on two 32-bit values
  uint32_t a = 0x12345678;
  uint32_t b = 0x87654321;
  uint32_t expected = ~(a & b);

  printf("Performing double-write NAND operation...\n");
  uint32_t result = nand_32bit_double_write(a, b, cfg, sts);
  printf("NAND(0x" PRIx32 ", 0x" PRIx32 ") = 0x" PRIx32 " (expected 0x" PRIx32 ")\n", a, b, result, expected);
  if (result == expected)
  {
    printf("Double-write NAND operation successful!\n");
  }
  else
  {
    printf("Double-write NAND operation failed :(\n");
  }

  a = 0xABCDEF01;
  b = 0x01234567;
  expected = ~(a & b);

  printf("Performing single-write NAND operation...\n");
  result = nand_32bit_single_write(a, b, cfg, sts);
  printf("NAND(0x" PRIx32 ", 0x" PRIx32 ") = 0x" PRIx32 " (expected 0x" PRIx32 ")\n", a, b, result, expected);
  if (result == expected)
  {
    printf("Single-write NAND operation successful!\n");
  }
  else
  {
    printf("Single-write NAND operation failed :(\n");
  }

}
