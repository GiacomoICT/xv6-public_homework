#include"types.h"
#include"x86.h"

#define SECTSIZE 512

void readseg(uchar*, uint, uint);

void splashmain_old() {

  volatile char *addr;
  int i;

  addr = (char *) 0xA0000;
  *addr = 0x0a;
  addr++;

  i = 1;
  while (i< 321*6){
  
    *addr = 0x0a;
    addr++;
    i++;

  }
    


   while(1);
}

void splashmain(){

  // We need to read the whole image (compute size=64 KB)
  // It starts from bootsplash.img + 512 = 0x7c00 + 512 = 0x7e00
  // It needs to be put in 0xA0000

  volatile char *addr;
  int sz;


  sz = 64000;
  addr = (char *) 0xA0000;
    
  readseg((uchar*)addr, sz, 0);

}

void 
waitdisk(void)
{
  while((inb(0x1F7) & 0xC0) != 0x40);
}

void 
readsect(void *dst, uint offset)
{

  waitdisk();
  outb(0x1F2, 1);
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  outb(0x1F5, offset >> 16);
  outb(0x1F6, (offset >> 24) | 0xE0);
  outb(0x1F7, 0x20);

  waitdisk();
  insl(0x1F0, dst, SECTSIZE/4);
}

void
readseg(uchar* pa, uint count, uint offset)
{ 
  uchar* epa;

  epa = pa + count;

  pa -= offset % SECTSIZE;

  offset = (offset / SECTSIZE) + 1;

  for (; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
}


