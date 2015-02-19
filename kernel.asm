
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 85 37 10 80       	mov    $0x80103785,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 c4 84 10 80       	push   $0x801084c4
80100042:	68 80 c6 10 80       	push   $0x8010c680
80100047:	e8 81 4e 00 00       	call   80104ecd <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 05 11 80 84 	movl   $0x80110584,0x80110590
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 05 11 80 84 	movl   $0x80110584,0x80110594
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 05 11 80    	mov    0x80110594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 05 11 80       	mov    0x80110594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 05 11 80       	mov    %eax,0x80110594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801000ad:	72 bd                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000af:	c9                   	leave  
801000b0:	c3                   	ret    

801000b1 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b1:	55                   	push   %ebp
801000b2:	89 e5                	mov    %esp,%ebp
801000b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b7:	83 ec 0c             	sub    $0xc,%esp
801000ba:	68 80 c6 10 80       	push   $0x8010c680
801000bf:	e8 2a 4e 00 00       	call   80104eee <acquire>
801000c4:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c7:	a1 94 05 11 80       	mov    0x80110594,%eax
801000cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000cf:	eb 67                	jmp    80100138 <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d4:	8b 40 04             	mov    0x4(%eax),%eax
801000d7:	3b 45 08             	cmp    0x8(%ebp),%eax
801000da:	75 53                	jne    8010012f <bget+0x7e>
801000dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000df:	8b 40 08             	mov    0x8(%eax),%eax
801000e2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e5:	75 48                	jne    8010012f <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ea:	8b 00                	mov    (%eax),%eax
801000ec:	83 e0 01             	and    $0x1,%eax
801000ef:	85 c0                	test   %eax,%eax
801000f1:	75 27                	jne    8010011a <bget+0x69>
        b->flags |= B_BUSY;
801000f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f6:	8b 00                	mov    (%eax),%eax
801000f8:	83 c8 01             	or     $0x1,%eax
801000fb:	89 c2                	mov    %eax,%edx
801000fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100100:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100102:	83 ec 0c             	sub    $0xc,%esp
80100105:	68 80 c6 10 80       	push   $0x8010c680
8010010a:	e8 45 4e 00 00       	call   80104f54 <release>
8010010f:	83 c4 10             	add    $0x10,%esp
        return b;
80100112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100115:	e9 98 00 00 00       	jmp    801001b2 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011a:	83 ec 08             	sub    $0x8,%esp
8010011d:	68 80 c6 10 80       	push   $0x8010c680
80100122:	ff 75 f4             	pushl  -0xc(%ebp)
80100125:	e8 cb 4a 00 00       	call   80104bf5 <sleep>
8010012a:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012d:	eb 98                	jmp    801000c7 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010012f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100132:	8b 40 10             	mov    0x10(%eax),%eax
80100135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100138:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
8010013f:	75 90                	jne    801000d1 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100141:	a1 90 05 11 80       	mov    0x80110590,%eax
80100146:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100149:	eb 51                	jmp    8010019c <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014e:	8b 00                	mov    (%eax),%eax
80100150:	83 e0 01             	and    $0x1,%eax
80100153:	85 c0                	test   %eax,%eax
80100155:	75 3c                	jne    80100193 <bget+0xe2>
80100157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015a:	8b 00                	mov    (%eax),%eax
8010015c:	83 e0 04             	and    $0x4,%eax
8010015f:	85 c0                	test   %eax,%eax
80100161:	75 30                	jne    80100193 <bget+0xe2>
      b->dev = dev;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 08             	mov    0x8(%ebp),%edx
80100169:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	8b 55 0c             	mov    0xc(%ebp),%edx
80100172:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100178:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
8010017e:	83 ec 0c             	sub    $0xc,%esp
80100181:	68 80 c6 10 80       	push   $0x8010c680
80100186:	e8 c9 4d 00 00       	call   80104f54 <release>
8010018b:	83 c4 10             	add    $0x10,%esp
      return b;
8010018e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100191:	eb 1f                	jmp    801001b2 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100196:	8b 40 0c             	mov    0xc(%eax),%eax
80100199:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019c:	81 7d f4 84 05 11 80 	cmpl   $0x80110584,-0xc(%ebp)
801001a3:	75 a6                	jne    8010014b <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	68 cb 84 10 80       	push   $0x801084cb
801001ad:	e8 aa 03 00 00       	call   8010055c <panic>
}
801001b2:	c9                   	leave  
801001b3:	c3                   	ret    

801001b4 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b4:	55                   	push   %ebp
801001b5:	89 e5                	mov    %esp,%ebp
801001b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ba:	83 ec 08             	sub    $0x8,%esp
801001bd:	ff 75 0c             	pushl  0xc(%ebp)
801001c0:	ff 75 08             	pushl  0x8(%ebp)
801001c3:	e8 e9 fe ff ff       	call   801000b1 <bget>
801001c8:	83 c4 10             	add    $0x10,%esp
801001cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d1:	8b 00                	mov    (%eax),%eax
801001d3:	83 e0 02             	and    $0x2,%eax
801001d6:	85 c0                	test   %eax,%eax
801001d8:	75 0e                	jne    801001e8 <bread+0x34>
    iderw(b);
801001da:	83 ec 0c             	sub    $0xc,%esp
801001dd:	ff 75 f4             	pushl  -0xc(%ebp)
801001e0:	e8 50 26 00 00       	call   80102835 <iderw>
801001e5:	83 c4 10             	add    $0x10,%esp
  return b;
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001eb:	c9                   	leave  
801001ec:	c3                   	ret    

801001ed <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ed:	55                   	push   %ebp
801001ee:	89 e5                	mov    %esp,%ebp
801001f0:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f3:	8b 45 08             	mov    0x8(%ebp),%eax
801001f6:	8b 00                	mov    (%eax),%eax
801001f8:	83 e0 01             	and    $0x1,%eax
801001fb:	85 c0                	test   %eax,%eax
801001fd:	75 0d                	jne    8010020c <bwrite+0x1f>
    panic("bwrite");
801001ff:	83 ec 0c             	sub    $0xc,%esp
80100202:	68 dc 84 10 80       	push   $0x801084dc
80100207:	e8 50 03 00 00       	call   8010055c <panic>
  b->flags |= B_DIRTY;
8010020c:	8b 45 08             	mov    0x8(%ebp),%eax
8010020f:	8b 00                	mov    (%eax),%eax
80100211:	83 c8 04             	or     $0x4,%eax
80100214:	89 c2                	mov    %eax,%edx
80100216:	8b 45 08             	mov    0x8(%ebp),%eax
80100219:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021b:	83 ec 0c             	sub    $0xc,%esp
8010021e:	ff 75 08             	pushl  0x8(%ebp)
80100221:	e8 0f 26 00 00       	call   80102835 <iderw>
80100226:	83 c4 10             	add    $0x10,%esp
}
80100229:	c9                   	leave  
8010022a:	c3                   	ret    

8010022b <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022b:	55                   	push   %ebp
8010022c:	89 e5                	mov    %esp,%ebp
8010022e:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 e0 01             	and    $0x1,%eax
80100239:	85 c0                	test   %eax,%eax
8010023b:	75 0d                	jne    8010024a <brelse+0x1f>
    panic("brelse");
8010023d:	83 ec 0c             	sub    $0xc,%esp
80100240:	68 e3 84 10 80       	push   $0x801084e3
80100245:	e8 12 03 00 00       	call   8010055c <panic>

  acquire(&bcache.lock);
8010024a:	83 ec 0c             	sub    $0xc,%esp
8010024d:	68 80 c6 10 80       	push   $0x8010c680
80100252:	e8 97 4c 00 00       	call   80104eee <acquire>
80100257:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025a:	8b 45 08             	mov    0x8(%ebp),%eax
8010025d:	8b 40 10             	mov    0x10(%eax),%eax
80100260:	8b 55 08             	mov    0x8(%ebp),%edx
80100263:	8b 52 0c             	mov    0xc(%edx),%edx
80100266:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100269:	8b 45 08             	mov    0x8(%ebp),%eax
8010026c:	8b 40 0c             	mov    0xc(%eax),%eax
8010026f:	8b 55 08             	mov    0x8(%ebp),%edx
80100272:	8b 52 10             	mov    0x10(%edx),%edx
80100275:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
80100278:	8b 15 94 05 11 80    	mov    0x80110594,%edx
8010027e:	8b 45 08             	mov    0x8(%ebp),%eax
80100281:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100284:	8b 45 08             	mov    0x8(%ebp),%eax
80100287:	c7 40 0c 84 05 11 80 	movl   $0x80110584,0xc(%eax)
  bcache.head.next->prev = b;
8010028e:	a1 94 05 11 80       	mov    0x80110594,%eax
80100293:	8b 55 08             	mov    0x8(%ebp),%edx
80100296:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100299:	8b 45 08             	mov    0x8(%ebp),%eax
8010029c:	a3 94 05 11 80       	mov    %eax,0x80110594

  b->flags &= ~B_BUSY;
801002a1:	8b 45 08             	mov    0x8(%ebp),%eax
801002a4:	8b 00                	mov    (%eax),%eax
801002a6:	83 e0 fe             	and    $0xfffffffe,%eax
801002a9:	89 c2                	mov    %eax,%edx
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b0:	83 ec 0c             	sub    $0xc,%esp
801002b3:	ff 75 08             	pushl  0x8(%ebp)
801002b6:	e8 26 4a 00 00       	call   80104ce1 <wakeup>
801002bb:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 80 c6 10 80       	push   $0x8010c680
801002c6:	e8 89 4c 00 00       	call   80104f54 <release>
801002cb:	83 c4 10             	add    $0x10,%esp
}
801002ce:	c9                   	leave  
801002cf:	c3                   	ret    

801002d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d0:	55                   	push   %ebp
801002d1:	89 e5                	mov    %esp,%ebp
801002d3:	83 ec 14             	sub    $0x14,%esp
801002d6:	8b 45 08             	mov    0x8(%ebp),%eax
801002d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e1:	89 c2                	mov    %eax,%edx
801002e3:	ec                   	in     (%dx),%al
801002e4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002e7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002eb:	c9                   	leave  
801002ec:	c3                   	ret    

801002ed <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002ed:	55                   	push   %ebp
801002ee:	89 e5                	mov    %esp,%ebp
801002f0:	83 ec 08             	sub    $0x8,%esp
801002f3:	8b 55 08             	mov    0x8(%ebp),%edx
801002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002f9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002fd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100300:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100304:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100308:	ee                   	out    %al,(%dx)
}
80100309:	c9                   	leave  
8010030a:	c3                   	ret    

8010030b <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030b:	55                   	push   %ebp
8010030c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010030e:	fa                   	cli    
}
8010030f:	5d                   	pop    %ebp
80100310:	c3                   	ret    

80100311 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100311:	55                   	push   %ebp
80100312:	89 e5                	mov    %esp,%ebp
80100314:	53                   	push   %ebx
80100315:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100318:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010031c:	74 1c                	je     8010033a <printint+0x29>
8010031e:	8b 45 08             	mov    0x8(%ebp),%eax
80100321:	c1 e8 1f             	shr    $0x1f,%eax
80100324:	0f b6 c0             	movzbl %al,%eax
80100327:	89 45 10             	mov    %eax,0x10(%ebp)
8010032a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010032e:	74 0a                	je     8010033a <printint+0x29>
    x = -xx;
80100330:	8b 45 08             	mov    0x8(%ebp),%eax
80100333:	f7 d8                	neg    %eax
80100335:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100338:	eb 06                	jmp    80100340 <printint+0x2f>
  else
    x = xx;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100340:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100347:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034a:	8d 41 01             	lea    0x1(%ecx),%eax
8010034d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100353:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100356:	ba 00 00 00 00       	mov    $0x0,%edx
8010035b:	f7 f3                	div    %ebx
8010035d:	89 d0                	mov    %edx,%eax
8010035f:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100366:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010036d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100370:	ba 00 00 00 00       	mov    $0x0,%edx
80100375:	f7 f3                	div    %ebx
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010037e:	75 c7                	jne    80100347 <printint+0x36>

  if(sign)
80100380:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100384:	74 0e                	je     80100394 <printint+0x83>
    buf[i++] = '-';
80100386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100389:	8d 50 01             	lea    0x1(%eax),%edx
8010038c:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010038f:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100394:	eb 1a                	jmp    801003b0 <printint+0x9f>
    consputc(buf[i]);
80100396:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039c:	01 d0                	add    %edx,%eax
8010039e:	0f b6 00             	movzbl (%eax),%eax
801003a1:	0f be c0             	movsbl %al,%eax
801003a4:	83 ec 0c             	sub    $0xc,%esp
801003a7:	50                   	push   %eax
801003a8:	e8 be 03 00 00       	call   8010076b <consputc>
801003ad:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 dc                	jns    80100396 <printint+0x85>
    consputc(buf[i]);
}
801003ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003bd:	c9                   	leave  
801003be:	c3                   	ret    

801003bf <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003bf:	55                   	push   %ebp
801003c0:	89 e5                	mov    %esp,%ebp
801003c2:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c5:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d1:	74 10                	je     801003e3 <cprintf+0x24>
    acquire(&cons.lock);
801003d3:	83 ec 0c             	sub    $0xc,%esp
801003d6:	68 e0 b5 10 80       	push   $0x8010b5e0
801003db:	e8 0e 4b 00 00       	call   80104eee <acquire>
801003e0:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e3:	8b 45 08             	mov    0x8(%ebp),%eax
801003e6:	85 c0                	test   %eax,%eax
801003e8:	75 0d                	jne    801003f7 <cprintf+0x38>
    panic("null fmt");
801003ea:	83 ec 0c             	sub    $0xc,%esp
801003ed:	68 ea 84 10 80       	push   $0x801084ea
801003f2:	e8 65 01 00 00       	call   8010055c <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f7:	8d 45 0c             	lea    0xc(%ebp),%eax
801003fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100404:	e9 1b 01 00 00       	jmp    80100524 <cprintf+0x165>
    if(c != '%'){
80100409:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040d:	74 13                	je     80100422 <cprintf+0x63>
      consputc(c);
8010040f:	83 ec 0c             	sub    $0xc,%esp
80100412:	ff 75 e4             	pushl  -0x1c(%ebp)
80100415:	e8 51 03 00 00       	call   8010076b <consputc>
8010041a:	83 c4 10             	add    $0x10,%esp
      continue;
8010041d:	e9 fe 00 00 00       	jmp    80100520 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
80100422:	8b 55 08             	mov    0x8(%ebp),%edx
80100425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010042c:	01 d0                	add    %edx,%eax
8010042e:	0f b6 00             	movzbl (%eax),%eax
80100431:	0f be c0             	movsbl %al,%eax
80100434:	25 ff 00 00 00       	and    $0xff,%eax
80100439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010043c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100440:	75 05                	jne    80100447 <cprintf+0x88>
      break;
80100442:	e9 fd 00 00 00       	jmp    80100544 <cprintf+0x185>
    switch(c){
80100447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010044a:	83 f8 70             	cmp    $0x70,%eax
8010044d:	74 47                	je     80100496 <cprintf+0xd7>
8010044f:	83 f8 70             	cmp    $0x70,%eax
80100452:	7f 13                	jg     80100467 <cprintf+0xa8>
80100454:	83 f8 25             	cmp    $0x25,%eax
80100457:	0f 84 98 00 00 00    	je     801004f5 <cprintf+0x136>
8010045d:	83 f8 64             	cmp    $0x64,%eax
80100460:	74 14                	je     80100476 <cprintf+0xb7>
80100462:	e9 9d 00 00 00       	jmp    80100504 <cprintf+0x145>
80100467:	83 f8 73             	cmp    $0x73,%eax
8010046a:	74 47                	je     801004b3 <cprintf+0xf4>
8010046c:	83 f8 78             	cmp    $0x78,%eax
8010046f:	74 25                	je     80100496 <cprintf+0xd7>
80100471:	e9 8e 00 00 00       	jmp    80100504 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
80100476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100479:	8d 50 04             	lea    0x4(%eax),%edx
8010047c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010047f:	8b 00                	mov    (%eax),%eax
80100481:	83 ec 04             	sub    $0x4,%esp
80100484:	6a 01                	push   $0x1
80100486:	6a 0a                	push   $0xa
80100488:	50                   	push   %eax
80100489:	e8 83 fe ff ff       	call   80100311 <printint>
8010048e:	83 c4 10             	add    $0x10,%esp
      break;
80100491:	e9 8a 00 00 00       	jmp    80100520 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	83 ec 04             	sub    $0x4,%esp
801004a4:	6a 00                	push   $0x0
801004a6:	6a 10                	push   $0x10
801004a8:	50                   	push   %eax
801004a9:	e8 63 fe ff ff       	call   80100311 <printint>
801004ae:	83 c4 10             	add    $0x10,%esp
      break;
801004b1:	eb 6d                	jmp    80100520 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b6:	8d 50 04             	lea    0x4(%eax),%edx
801004b9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004bc:	8b 00                	mov    (%eax),%eax
801004be:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004c5:	75 07                	jne    801004ce <cprintf+0x10f>
        s = "(null)";
801004c7:	c7 45 ec f3 84 10 80 	movl   $0x801084f3,-0x14(%ebp)
      for(; *s; s++)
801004ce:	eb 19                	jmp    801004e9 <cprintf+0x12a>
        consputc(*s);
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	0f be c0             	movsbl %al,%eax
801004d9:	83 ec 0c             	sub    $0xc,%esp
801004dc:	50                   	push   %eax
801004dd:	e8 89 02 00 00       	call   8010076b <consputc>
801004e2:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004e5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ec:	0f b6 00             	movzbl (%eax),%eax
801004ef:	84 c0                	test   %al,%al
801004f1:	75 dd                	jne    801004d0 <cprintf+0x111>
        consputc(*s);
      break;
801004f3:	eb 2b                	jmp    80100520 <cprintf+0x161>
    case '%':
      consputc('%');
801004f5:	83 ec 0c             	sub    $0xc,%esp
801004f8:	6a 25                	push   $0x25
801004fa:	e8 6c 02 00 00       	call   8010076b <consputc>
801004ff:	83 c4 10             	add    $0x10,%esp
      break;
80100502:	eb 1c                	jmp    80100520 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100504:	83 ec 0c             	sub    $0xc,%esp
80100507:	6a 25                	push   $0x25
80100509:	e8 5d 02 00 00       	call   8010076b <consputc>
8010050e:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100511:	83 ec 0c             	sub    $0xc,%esp
80100514:	ff 75 e4             	pushl  -0x1c(%ebp)
80100517:	e8 4f 02 00 00       	call   8010076b <consputc>
8010051c:	83 c4 10             	add    $0x10,%esp
      break;
8010051f:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100524:	8b 55 08             	mov    0x8(%ebp),%edx
80100527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010052a:	01 d0                	add    %edx,%eax
8010052c:	0f b6 00             	movzbl (%eax),%eax
8010052f:	0f be c0             	movsbl %al,%eax
80100532:	25 ff 00 00 00       	and    $0xff,%eax
80100537:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010053a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053e:	0f 85 c5 fe ff ff    	jne    80100409 <cprintf+0x4a>
      consputc(c);
      break;
    }
  }

  if(locking)
80100544:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100548:	74 10                	je     8010055a <cprintf+0x19b>
    release(&cons.lock);
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	68 e0 b5 10 80       	push   $0x8010b5e0
80100552:	e8 fd 49 00 00       	call   80104f54 <release>
80100557:	83 c4 10             	add    $0x10,%esp
}
8010055a:	c9                   	leave  
8010055b:	c3                   	ret    

8010055c <panic>:

void
panic(char *s)
{
8010055c:	55                   	push   %ebp
8010055d:	89 e5                	mov    %esp,%ebp
8010055f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
80100562:	e8 a4 fd ff ff       	call   8010030b <cli>
  cons.locking = 0;
80100567:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010056e:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100571:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100577:	0f b6 00             	movzbl (%eax),%eax
8010057a:	0f b6 c0             	movzbl %al,%eax
8010057d:	83 ec 08             	sub    $0x8,%esp
80100580:	50                   	push   %eax
80100581:	68 fa 84 10 80       	push   $0x801084fa
80100586:	e8 34 fe ff ff       	call   801003bf <cprintf>
8010058b:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
8010058e:	8b 45 08             	mov    0x8(%ebp),%eax
80100591:	83 ec 0c             	sub    $0xc,%esp
80100594:	50                   	push   %eax
80100595:	e8 25 fe ff ff       	call   801003bf <cprintf>
8010059a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	68 09 85 10 80       	push   $0x80108509
801005a5:	e8 15 fe ff ff       	call   801003bf <cprintf>
801005aa:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ad:	83 ec 08             	sub    $0x8,%esp
801005b0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005b3:	50                   	push   %eax
801005b4:	8d 45 08             	lea    0x8(%ebp),%eax
801005b7:	50                   	push   %eax
801005b8:	e8 e8 49 00 00       	call   80104fa5 <getcallerpcs>
801005bd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005c7:	eb 1c                	jmp    801005e5 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005cc:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005d0:	83 ec 08             	sub    $0x8,%esp
801005d3:	50                   	push   %eax
801005d4:	68 0b 85 10 80       	push   $0x8010850b
801005d9:	e8 e1 fd ff ff       	call   801003bf <cprintf>
801005de:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005e5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005e9:	7e de                	jle    801005c9 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005eb:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005f2:	00 00 00 
  for(;;)
    ;
801005f5:	eb fe                	jmp    801005f5 <panic+0x99>

801005f7 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005f7:	55                   	push   %ebp
801005f8:	89 e5                	mov    %esp,%ebp
801005fa:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005fd:	6a 0e                	push   $0xe
801005ff:	68 d4 03 00 00       	push   $0x3d4
80100604:	e8 e4 fc ff ff       	call   801002ed <outb>
80100609:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010060c:	68 d5 03 00 00       	push   $0x3d5
80100611:	e8 ba fc ff ff       	call   801002d0 <inb>
80100616:	83 c4 04             	add    $0x4,%esp
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	c1 e0 08             	shl    $0x8,%eax
8010061f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100622:	6a 0f                	push   $0xf
80100624:	68 d4 03 00 00       	push   $0x3d4
80100629:	e8 bf fc ff ff       	call   801002ed <outb>
8010062e:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100631:	68 d5 03 00 00       	push   $0x3d5
80100636:	e8 95 fc ff ff       	call   801002d0 <inb>
8010063b:	83 c4 04             	add    $0x4,%esp
8010063e:	0f b6 c0             	movzbl %al,%eax
80100641:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 30                	jne    8010067a <cgaputc+0x83>
    pos += 80 - pos%80;
8010064a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010064d:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100652:	89 c8                	mov    %ecx,%eax
80100654:	f7 ea                	imul   %edx
80100656:	c1 fa 05             	sar    $0x5,%edx
80100659:	89 c8                	mov    %ecx,%eax
8010065b:	c1 f8 1f             	sar    $0x1f,%eax
8010065e:	29 c2                	sub    %eax,%edx
80100660:	89 d0                	mov    %edx,%eax
80100662:	c1 e0 02             	shl    $0x2,%eax
80100665:	01 d0                	add    %edx,%eax
80100667:	c1 e0 04             	shl    $0x4,%eax
8010066a:	29 c1                	sub    %eax,%ecx
8010066c:	89 ca                	mov    %ecx,%edx
8010066e:	b8 50 00 00 00       	mov    $0x50,%eax
80100673:	29 d0                	sub    %edx,%eax
80100675:	01 45 f4             	add    %eax,-0xc(%ebp)
80100678:	eb 34                	jmp    801006ae <cgaputc+0xb7>
  else if(c == BACKSPACE){
8010067a:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100681:	75 0c                	jne    8010068f <cgaputc+0x98>
    if(pos > 0) --pos;
80100683:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100687:	7e 25                	jle    801006ae <cgaputc+0xb7>
80100689:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010068d:	eb 1f                	jmp    801006ae <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010068f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100698:	8d 50 01             	lea    0x1(%eax),%edx
8010069b:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010069e:	01 c0                	add    %eax,%eax
801006a0:	01 c8                	add    %ecx,%eax
801006a2:	8b 55 08             	mov    0x8(%ebp),%edx
801006a5:	0f b6 d2             	movzbl %dl,%edx
801006a8:	80 ce 07             	or     $0x7,%dh
801006ab:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006ae:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006b5:	7e 4c                	jle    80100703 <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b7:	a1 00 90 10 80       	mov    0x80109000,%eax
801006bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006c2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c7:	83 ec 04             	sub    $0x4,%esp
801006ca:	68 60 0e 00 00       	push   $0xe60
801006cf:	52                   	push   %edx
801006d0:	50                   	push   %eax
801006d1:	e8 33 4b 00 00       	call   80105209 <memmove>
801006d6:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006d9:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006dd:	b8 80 07 00 00       	mov    $0x780,%eax
801006e2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e5:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ed:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006f0:	01 c9                	add    %ecx,%ecx
801006f2:	01 c8                	add    %ecx,%eax
801006f4:	83 ec 04             	sub    $0x4,%esp
801006f7:	52                   	push   %edx
801006f8:	6a 00                	push   $0x0
801006fa:	50                   	push   %eax
801006fb:	e8 4a 4a 00 00       	call   8010514a <memset>
80100700:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100703:	83 ec 08             	sub    $0x8,%esp
80100706:	6a 0e                	push   $0xe
80100708:	68 d4 03 00 00       	push   $0x3d4
8010070d:	e8 db fb ff ff       	call   801002ed <outb>
80100712:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	83 ec 08             	sub    $0x8,%esp
80100721:	50                   	push   %eax
80100722:	68 d5 03 00 00       	push   $0x3d5
80100727:	e8 c1 fb ff ff       	call   801002ed <outb>
8010072c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010072f:	83 ec 08             	sub    $0x8,%esp
80100732:	6a 0f                	push   $0xf
80100734:	68 d4 03 00 00       	push   $0x3d4
80100739:	e8 af fb ff ff       	call   801002ed <outb>
8010073e:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100744:	0f b6 c0             	movzbl %al,%eax
80100747:	83 ec 08             	sub    $0x8,%esp
8010074a:	50                   	push   %eax
8010074b:	68 d5 03 00 00       	push   $0x3d5
80100750:	e8 98 fb ff ff       	call   801002ed <outb>
80100755:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100771:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 8c fb ff ff       	call   8010030b <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 29                	jne    801007b3 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	83 ec 0c             	sub    $0xc,%esp
8010078d:	6a 08                	push   $0x8
8010078f:	e8 c4 63 00 00       	call   80106b58 <uartputc>
80100794:	83 c4 10             	add    $0x10,%esp
80100797:	83 ec 0c             	sub    $0xc,%esp
8010079a:	6a 20                	push   $0x20
8010079c:	e8 b7 63 00 00       	call   80106b58 <uartputc>
801007a1:	83 c4 10             	add    $0x10,%esp
801007a4:	83 ec 0c             	sub    $0xc,%esp
801007a7:	6a 08                	push   $0x8
801007a9:	e8 aa 63 00 00       	call   80106b58 <uartputc>
801007ae:	83 c4 10             	add    $0x10,%esp
801007b1:	eb 0e                	jmp    801007c1 <consputc+0x56>
  } else
    uartputc(c);
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	ff 75 08             	pushl  0x8(%ebp)
801007b9:	e8 9a 63 00 00       	call   80106b58 <uartputc>
801007be:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007c1:	83 ec 0c             	sub    $0xc,%esp
801007c4:	ff 75 08             	pushl  0x8(%ebp)
801007c7:	e8 2b fe ff ff       	call   801005f7 <cgaputc>
801007cc:	83 c4 10             	add    $0x10,%esp
}
801007cf:	c9                   	leave  
801007d0:	c3                   	ret    

801007d1 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d1:	55                   	push   %ebp
801007d2:	89 e5                	mov    %esp,%ebp
801007d4:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007d7:	83 ec 0c             	sub    $0xc,%esp
801007da:	68 c0 07 11 80       	push   $0x801107c0
801007df:	e8 0a 47 00 00       	call   80104eee <acquire>
801007e4:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007e7:	e9 3a 01 00 00       	jmp    80100926 <consoleintr+0x155>
    switch(c){
801007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007ef:	83 f8 10             	cmp    $0x10,%eax
801007f2:	74 1e                	je     80100812 <consoleintr+0x41>
801007f4:	83 f8 10             	cmp    $0x10,%eax
801007f7:	7f 0a                	jg     80100803 <consoleintr+0x32>
801007f9:	83 f8 08             	cmp    $0x8,%eax
801007fc:	74 65                	je     80100863 <consoleintr+0x92>
801007fe:	e9 91 00 00 00       	jmp    80100894 <consoleintr+0xc3>
80100803:	83 f8 15             	cmp    $0x15,%eax
80100806:	74 31                	je     80100839 <consoleintr+0x68>
80100808:	83 f8 7f             	cmp    $0x7f,%eax
8010080b:	74 56                	je     80100863 <consoleintr+0x92>
8010080d:	e9 82 00 00 00       	jmp    80100894 <consoleintr+0xc3>
    case C('P'):  // Process listing.
      procdump();
80100812:	e8 87 45 00 00       	call   80104d9e <procdump>
      break;
80100817:	e9 0a 01 00 00       	jmp    80100926 <consoleintr+0x155>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010081c:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100821:	83 e8 01             	sub    $0x1,%eax
80100824:	a3 7c 08 11 80       	mov    %eax,0x8011087c
        consputc(BACKSPACE);
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	68 00 01 00 00       	push   $0x100
80100831:	e8 35 ff ff ff       	call   8010076b <consputc>
80100836:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100839:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
8010083f:	a1 78 08 11 80       	mov    0x80110878,%eax
80100844:	39 c2                	cmp    %eax,%edx
80100846:	74 16                	je     8010085e <consoleintr+0x8d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100848:	a1 7c 08 11 80       	mov    0x8011087c,%eax
8010084d:	83 e8 01             	sub    $0x1,%eax
80100850:	83 e0 7f             	and    $0x7f,%eax
80100853:	0f b6 80 f4 07 11 80 	movzbl -0x7feef80c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010085a:	3c 0a                	cmp    $0xa,%al
8010085c:	75 be                	jne    8010081c <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010085e:	e9 c3 00 00 00       	jmp    80100926 <consoleintr+0x155>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100863:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
80100869:	a1 78 08 11 80       	mov    0x80110878,%eax
8010086e:	39 c2                	cmp    %eax,%edx
80100870:	74 1d                	je     8010088f <consoleintr+0xbe>
        input.e--;
80100872:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100877:	83 e8 01             	sub    $0x1,%eax
8010087a:	a3 7c 08 11 80       	mov    %eax,0x8011087c
        consputc(BACKSPACE);
8010087f:	83 ec 0c             	sub    $0xc,%esp
80100882:	68 00 01 00 00       	push   $0x100
80100887:	e8 df fe ff ff       	call   8010076b <consputc>
8010088c:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010088f:	e9 92 00 00 00       	jmp    80100926 <consoleintr+0x155>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100894:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100898:	0f 84 87 00 00 00    	je     80100925 <consoleintr+0x154>
8010089e:	8b 15 7c 08 11 80    	mov    0x8011087c,%edx
801008a4:	a1 74 08 11 80       	mov    0x80110874,%eax
801008a9:	29 c2                	sub    %eax,%edx
801008ab:	89 d0                	mov    %edx,%eax
801008ad:	83 f8 7f             	cmp    $0x7f,%eax
801008b0:	77 73                	ja     80100925 <consoleintr+0x154>
        c = (c == '\r') ? '\n' : c;
801008b2:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008b6:	74 05                	je     801008bd <consoleintr+0xec>
801008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bb:	eb 05                	jmp    801008c2 <consoleintr+0xf1>
801008bd:	b8 0a 00 00 00       	mov    $0xa,%eax
801008c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c5:	a1 7c 08 11 80       	mov    0x8011087c,%eax
801008ca:	8d 50 01             	lea    0x1(%eax),%edx
801008cd:	89 15 7c 08 11 80    	mov    %edx,0x8011087c
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008d9:	88 90 f4 07 11 80    	mov    %dl,-0x7feef80c(%eax)
        consputc(c);
801008df:	83 ec 0c             	sub    $0xc,%esp
801008e2:	ff 75 f4             	pushl  -0xc(%ebp)
801008e5:	e8 81 fe ff ff       	call   8010076b <consputc>
801008ea:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008ed:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008f1:	74 18                	je     8010090b <consoleintr+0x13a>
801008f3:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008f7:	74 12                	je     8010090b <consoleintr+0x13a>
801008f9:	a1 7c 08 11 80       	mov    0x8011087c,%eax
801008fe:	8b 15 74 08 11 80    	mov    0x80110874,%edx
80100904:	83 ea 80             	sub    $0xffffff80,%edx
80100907:	39 d0                	cmp    %edx,%eax
80100909:	75 1a                	jne    80100925 <consoleintr+0x154>
          input.w = input.e;
8010090b:	a1 7c 08 11 80       	mov    0x8011087c,%eax
80100910:	a3 78 08 11 80       	mov    %eax,0x80110878
          wakeup(&input.r);
80100915:	83 ec 0c             	sub    $0xc,%esp
80100918:	68 74 08 11 80       	push   $0x80110874
8010091d:	e8 bf 43 00 00       	call   80104ce1 <wakeup>
80100922:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100925:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100926:	8b 45 08             	mov    0x8(%ebp),%eax
80100929:	ff d0                	call   *%eax
8010092b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010092e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100932:	0f 89 b4 fe ff ff    	jns    801007ec <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100938:	83 ec 0c             	sub    $0xc,%esp
8010093b:	68 c0 07 11 80       	push   $0x801107c0
80100940:	e8 0f 46 00 00       	call   80104f54 <release>
80100945:	83 c4 10             	add    $0x10,%esp
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	83 ec 0c             	sub    $0xc,%esp
80100953:	ff 75 08             	pushl  0x8(%ebp)
80100956:	e8 d8 10 00 00       	call   80101a33 <iunlock>
8010095b:	83 c4 10             	add    $0x10,%esp
  target = n;
8010095e:	8b 45 10             	mov    0x10(%ebp),%eax
80100961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100964:	83 ec 0c             	sub    $0xc,%esp
80100967:	68 c0 07 11 80       	push   $0x801107c0
8010096c:	e8 7d 45 00 00       	call   80104eee <acquire>
80100971:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100974:	e9 b2 00 00 00       	jmp    80100a2b <consoleread+0xe1>
    while(input.r == input.w){
80100979:	eb 4a                	jmp    801009c5 <consoleread+0x7b>
      if(proc->killed){
8010097b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100981:	8b 40 24             	mov    0x24(%eax),%eax
80100984:	85 c0                	test   %eax,%eax
80100986:	74 28                	je     801009b0 <consoleread+0x66>
        release(&input.lock);
80100988:	83 ec 0c             	sub    $0xc,%esp
8010098b:	68 c0 07 11 80       	push   $0x801107c0
80100990:	e8 bf 45 00 00       	call   80104f54 <release>
80100995:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100998:	83 ec 0c             	sub    $0xc,%esp
8010099b:	ff 75 08             	pushl  0x8(%ebp)
8010099e:	e8 39 0f 00 00       	call   801018dc <ilock>
801009a3:	83 c4 10             	add    $0x10,%esp
        return -1;
801009a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ab:	e9 ad 00 00 00       	jmp    80100a5d <consoleread+0x113>
      }
      sleep(&input.r, &input.lock);
801009b0:	83 ec 08             	sub    $0x8,%esp
801009b3:	68 c0 07 11 80       	push   $0x801107c0
801009b8:	68 74 08 11 80       	push   $0x80110874
801009bd:	e8 33 42 00 00       	call   80104bf5 <sleep>
801009c2:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009c5:	8b 15 74 08 11 80    	mov    0x80110874,%edx
801009cb:	a1 78 08 11 80       	mov    0x80110878,%eax
801009d0:	39 c2                	cmp    %eax,%edx
801009d2:	74 a7                	je     8010097b <consoleread+0x31>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009d4:	a1 74 08 11 80       	mov    0x80110874,%eax
801009d9:	8d 50 01             	lea    0x1(%eax),%edx
801009dc:	89 15 74 08 11 80    	mov    %edx,0x80110874
801009e2:	83 e0 7f             	and    $0x7f,%eax
801009e5:	0f b6 80 f4 07 11 80 	movzbl -0x7feef80c(%eax),%eax
801009ec:	0f be c0             	movsbl %al,%eax
801009ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009f2:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f6:	75 19                	jne    80100a11 <consoleread+0xc7>
      if(n < target){
801009f8:	8b 45 10             	mov    0x10(%ebp),%eax
801009fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009fe:	73 0f                	jae    80100a0f <consoleread+0xc5>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a00:	a1 74 08 11 80       	mov    0x80110874,%eax
80100a05:	83 e8 01             	sub    $0x1,%eax
80100a08:	a3 74 08 11 80       	mov    %eax,0x80110874
      }
      break;
80100a0d:	eb 26                	jmp    80100a35 <consoleread+0xeb>
80100a0f:	eb 24                	jmp    80100a35 <consoleread+0xeb>
    }
    *dst++ = c;
80100a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a14:	8d 50 01             	lea    0x1(%eax),%edx
80100a17:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a1d:	88 10                	mov    %dl,(%eax)
    --n;
80100a1f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a23:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a27:	75 02                	jne    80100a2b <consoleread+0xe1>
      break;
80100a29:	eb 0a                	jmp    80100a35 <consoleread+0xeb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a2f:	0f 8f 44 ff ff ff    	jg     80100979 <consoleread+0x2f>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
80100a35:	83 ec 0c             	sub    $0xc,%esp
80100a38:	68 c0 07 11 80       	push   $0x801107c0
80100a3d:	e8 12 45 00 00       	call   80104f54 <release>
80100a42:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a45:	83 ec 0c             	sub    $0xc,%esp
80100a48:	ff 75 08             	pushl  0x8(%ebp)
80100a4b:	e8 8c 0e 00 00       	call   801018dc <ilock>
80100a50:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a53:	8b 45 10             	mov    0x10(%ebp),%eax
80100a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a59:	29 c2                	sub    %eax,%edx
80100a5b:	89 d0                	mov    %edx,%eax
}
80100a5d:	c9                   	leave  
80100a5e:	c3                   	ret    

80100a5f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a5f:	55                   	push   %ebp
80100a60:	89 e5                	mov    %esp,%ebp
80100a62:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a65:	83 ec 0c             	sub    $0xc,%esp
80100a68:	ff 75 08             	pushl  0x8(%ebp)
80100a6b:	e8 c3 0f 00 00       	call   80101a33 <iunlock>
80100a70:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a73:	83 ec 0c             	sub    $0xc,%esp
80100a76:	68 e0 b5 10 80       	push   $0x8010b5e0
80100a7b:	e8 6e 44 00 00       	call   80104eee <acquire>
80100a80:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a8a:	eb 21                	jmp    80100aad <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a92:	01 d0                	add    %edx,%eax
80100a94:	0f b6 00             	movzbl (%eax),%eax
80100a97:	0f be c0             	movsbl %al,%eax
80100a9a:	0f b6 c0             	movzbl %al,%eax
80100a9d:	83 ec 0c             	sub    $0xc,%esp
80100aa0:	50                   	push   %eax
80100aa1:	e8 c5 fc ff ff       	call   8010076b <consputc>
80100aa6:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aa9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ab0:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ab3:	7c d7                	jl     80100a8c <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ab5:	83 ec 0c             	sub    $0xc,%esp
80100ab8:	68 e0 b5 10 80       	push   $0x8010b5e0
80100abd:	e8 92 44 00 00       	call   80104f54 <release>
80100ac2:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ac5:	83 ec 0c             	sub    $0xc,%esp
80100ac8:	ff 75 08             	pushl  0x8(%ebp)
80100acb:	e8 0c 0e 00 00       	call   801018dc <ilock>
80100ad0:	83 c4 10             	add    $0x10,%esp

  return n;
80100ad3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ad6:	c9                   	leave  
80100ad7:	c3                   	ret    

80100ad8 <consoleinit>:

void
consoleinit(void)
{
80100ad8:	55                   	push   %ebp
80100ad9:	89 e5                	mov    %esp,%ebp
80100adb:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100ade:	83 ec 08             	sub    $0x8,%esp
80100ae1:	68 0f 85 10 80       	push   $0x8010850f
80100ae6:	68 e0 b5 10 80       	push   $0x8010b5e0
80100aeb:	e8 dd 43 00 00       	call   80104ecd <initlock>
80100af0:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100af3:	83 ec 08             	sub    $0x8,%esp
80100af6:	68 17 85 10 80       	push   $0x80108517
80100afb:	68 c0 07 11 80       	push   $0x801107c0
80100b00:	e8 c8 43 00 00       	call   80104ecd <initlock>
80100b05:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b08:	c7 05 4c 12 11 80 5f 	movl   $0x80100a5f,0x8011124c
80100b0f:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b12:	c7 05 48 12 11 80 4a 	movl   $0x8010094a,0x80111248
80100b19:	09 10 80 
  cons.locking = 1;
80100b1c:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100b23:	00 00 00 

  picenable(IRQ_KBD);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	6a 01                	push   $0x1
80100b2b:	e8 ef 32 00 00       	call   80103e1f <picenable>
80100b30:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b33:	83 ec 08             	sub    $0x8,%esp
80100b36:	6a 00                	push   $0x0
80100b38:	6a 01                	push   $0x1
80100b3a:	e8 bf 1e 00 00       	call   801029fe <ioapicenable>
80100b3f:	83 c4 10             	add    $0x10,%esp
}
80100b42:	c9                   	leave  
80100b43:	c3                   	ret    

80100b44 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b44:	55                   	push   %ebp
80100b45:	89 e5                	mov    %esp,%ebp
80100b47:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b4d:	e8 14 29 00 00       	call   80103466 <begin_op>
  if((ip = namei(path)) == 0){
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	ff 75 08             	pushl  0x8(%ebp)
80100b58:	e8 34 19 00 00       	call   80102491 <namei>
80100b5d:	83 c4 10             	add    $0x10,%esp
80100b60:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b63:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b67:	75 0f                	jne    80100b78 <exec+0x34>
    end_op();
80100b69:	e8 86 29 00 00       	call   801034f4 <end_op>
    return -1;
80100b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b73:	e9 b9 03 00 00       	jmp    80100f31 <exec+0x3ed>
  }
  ilock(ip);
80100b78:	83 ec 0c             	sub    $0xc,%esp
80100b7b:	ff 75 d8             	pushl  -0x28(%ebp)
80100b7e:	e8 59 0d 00 00       	call   801018dc <ilock>
80100b83:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b86:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b8d:	6a 34                	push   $0x34
80100b8f:	6a 00                	push   $0x0
80100b91:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b97:	50                   	push   %eax
80100b98:	ff 75 d8             	pushl  -0x28(%ebp)
80100b9b:	e8 9e 12 00 00       	call   80101e3e <readi>
80100ba0:	83 c4 10             	add    $0x10,%esp
80100ba3:	83 f8 33             	cmp    $0x33,%eax
80100ba6:	77 05                	ja     80100bad <exec+0x69>
    goto bad;
80100ba8:	e9 52 03 00 00       	jmp    80100eff <exec+0x3bb>
  if(elf.magic != ELF_MAGIC)
80100bad:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bb3:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bb8:	74 05                	je     80100bbf <exec+0x7b>
    goto bad;
80100bba:	e9 40 03 00 00       	jmp    80100eff <exec+0x3bb>

  if((pgdir = setupkvm()) == 0)
80100bbf:	e8 e4 70 00 00       	call   80107ca8 <setupkvm>
80100bc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bc7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bcb:	75 05                	jne    80100bd2 <exec+0x8e>
    goto bad;
80100bcd:	e9 2d 03 00 00       	jmp    80100eff <exec+0x3bb>

  // Load program into memory.
  sz = 0;
80100bd2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bd9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100be0:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100be6:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100be9:	e9 ae 00 00 00       	jmp    80100c9c <exec+0x158>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bf1:	6a 20                	push   $0x20
80100bf3:	50                   	push   %eax
80100bf4:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bfa:	50                   	push   %eax
80100bfb:	ff 75 d8             	pushl  -0x28(%ebp)
80100bfe:	e8 3b 12 00 00       	call   80101e3e <readi>
80100c03:	83 c4 10             	add    $0x10,%esp
80100c06:	83 f8 20             	cmp    $0x20,%eax
80100c09:	74 05                	je     80100c10 <exec+0xcc>
      goto bad;
80100c0b:	e9 ef 02 00 00       	jmp    80100eff <exec+0x3bb>
    if(ph.type != ELF_PROG_LOAD)
80100c10:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c16:	83 f8 01             	cmp    $0x1,%eax
80100c19:	74 02                	je     80100c1d <exec+0xd9>
      continue;
80100c1b:	eb 72                	jmp    80100c8f <exec+0x14b>
    if(ph.memsz < ph.filesz)
80100c1d:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c23:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c29:	39 c2                	cmp    %eax,%edx
80100c2b:	73 05                	jae    80100c32 <exec+0xee>
      goto bad;
80100c2d:	e9 cd 02 00 00       	jmp    80100eff <exec+0x3bb>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c32:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c38:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c3e:	01 d0                	add    %edx,%eax
80100c40:	83 ec 04             	sub    $0x4,%esp
80100c43:	50                   	push   %eax
80100c44:	ff 75 e0             	pushl  -0x20(%ebp)
80100c47:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c4a:	e8 fc 73 00 00       	call   8010804b <allocuvm>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c55:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c59:	75 05                	jne    80100c60 <exec+0x11c>
      goto bad;
80100c5b:	e9 9f 02 00 00       	jmp    80100eff <exec+0x3bb>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c60:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c66:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c6c:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c72:	83 ec 0c             	sub    $0xc,%esp
80100c75:	52                   	push   %edx
80100c76:	50                   	push   %eax
80100c77:	ff 75 d8             	pushl  -0x28(%ebp)
80100c7a:	51                   	push   %ecx
80100c7b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c7e:	e8 f1 72 00 00       	call   80107f74 <loaduvm>
80100c83:	83 c4 20             	add    $0x20,%esp
80100c86:	85 c0                	test   %eax,%eax
80100c88:	79 05                	jns    80100c8f <exec+0x14b>
      goto bad;
80100c8a:	e9 70 02 00 00       	jmp    80100eff <exec+0x3bb>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c8f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c93:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c96:	83 c0 20             	add    $0x20,%eax
80100c99:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c9c:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100ca3:	0f b7 c0             	movzwl %ax,%eax
80100ca6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100ca9:	0f 8f 3f ff ff ff    	jg     80100bee <exec+0xaa>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100caf:	83 ec 0c             	sub    $0xc,%esp
80100cb2:	ff 75 d8             	pushl  -0x28(%ebp)
80100cb5:	e8 d9 0e 00 00       	call   80101b93 <iunlockput>
80100cba:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cbd:	e8 32 28 00 00       	call   801034f4 <end_op>
  ip = 0;
80100cc2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ccc:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cdc:	05 00 20 00 00       	add    $0x2000,%eax
80100ce1:	83 ec 04             	sub    $0x4,%esp
80100ce4:	50                   	push   %eax
80100ce5:	ff 75 e0             	pushl  -0x20(%ebp)
80100ce8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ceb:	e8 5b 73 00 00       	call   8010804b <allocuvm>
80100cf0:	83 c4 10             	add    $0x10,%esp
80100cf3:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cfa:	75 05                	jne    80100d01 <exec+0x1bd>
    goto bad;
80100cfc:	e9 fe 01 00 00       	jmp    80100eff <exec+0x3bb>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d04:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d09:	83 ec 08             	sub    $0x8,%esp
80100d0c:	50                   	push   %eax
80100d0d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d10:	e8 5b 75 00 00       	call   80108270 <clearpteu>
80100d15:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d1b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d25:	e9 98 00 00 00       	jmp    80100dc2 <exec+0x27e>
    if(argc >= MAXARG)
80100d2a:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d2e:	76 05                	jbe    80100d35 <exec+0x1f1>
      goto bad;
80100d30:	e9 ca 01 00 00       	jmp    80100eff <exec+0x3bb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d42:	01 d0                	add    %edx,%eax
80100d44:	8b 00                	mov    (%eax),%eax
80100d46:	83 ec 0c             	sub    $0xc,%esp
80100d49:	50                   	push   %eax
80100d4a:	e8 4a 46 00 00       	call   80105399 <strlen>
80100d4f:	83 c4 10             	add    $0x10,%esp
80100d52:	89 c2                	mov    %eax,%edx
80100d54:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d57:	29 d0                	sub    %edx,%eax
80100d59:	83 e8 01             	sub    $0x1,%eax
80100d5c:	83 e0 fc             	and    $0xfffffffc,%eax
80100d5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d6f:	01 d0                	add    %edx,%eax
80100d71:	8b 00                	mov    (%eax),%eax
80100d73:	83 ec 0c             	sub    $0xc,%esp
80100d76:	50                   	push   %eax
80100d77:	e8 1d 46 00 00       	call   80105399 <strlen>
80100d7c:	83 c4 10             	add    $0x10,%esp
80100d7f:	83 c0 01             	add    $0x1,%eax
80100d82:	89 c1                	mov    %eax,%ecx
80100d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d91:	01 d0                	add    %edx,%eax
80100d93:	8b 00                	mov    (%eax),%eax
80100d95:	51                   	push   %ecx
80100d96:	50                   	push   %eax
80100d97:	ff 75 dc             	pushl  -0x24(%ebp)
80100d9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d9d:	e8 84 76 00 00       	call   80108426 <copyout>
80100da2:	83 c4 10             	add    $0x10,%esp
80100da5:	85 c0                	test   %eax,%eax
80100da7:	79 05                	jns    80100dae <exec+0x26a>
      goto bad;
80100da9:	e9 51 01 00 00       	jmp    80100eff <exec+0x3bb>
    ustack[3+argc] = sp;
80100dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db1:	8d 50 03             	lea    0x3(%eax),%edx
80100db4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100db7:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dbe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcf:	01 d0                	add    %edx,%eax
80100dd1:	8b 00                	mov    (%eax),%eax
80100dd3:	85 c0                	test   %eax,%eax
80100dd5:	0f 85 4f ff ff ff    	jne    80100d2a <exec+0x1e6>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dde:	83 c0 03             	add    $0x3,%eax
80100de1:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100de8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100dec:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100df3:	ff ff ff 
  ustack[1] = argc;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 01             	add    $0x1,%eax
80100e05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0f:	29 d0                	sub    %edx,%eax
80100e11:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1a:	83 c0 04             	add    $0x4,%eax
80100e1d:	c1 e0 02             	shl    $0x2,%eax
80100e20:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 04             	add    $0x4,%eax
80100e29:	c1 e0 02             	shl    $0x2,%eax
80100e2c:	50                   	push   %eax
80100e2d:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e33:	50                   	push   %eax
80100e34:	ff 75 dc             	pushl  -0x24(%ebp)
80100e37:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e3a:	e8 e7 75 00 00       	call   80108426 <copyout>
80100e3f:	83 c4 10             	add    $0x10,%esp
80100e42:	85 c0                	test   %eax,%eax
80100e44:	79 05                	jns    80100e4b <exec+0x307>
    goto bad;
80100e46:	e9 b4 00 00 00       	jmp    80100eff <exec+0x3bb>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e57:	eb 17                	jmp    80100e70 <exec+0x32c>
    if(*s == '/')
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	0f b6 00             	movzbl (%eax),%eax
80100e5f:	3c 2f                	cmp    $0x2f,%al
80100e61:	75 09                	jne    80100e6c <exec+0x328>
      last = s+1;
80100e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e66:	83 c0 01             	add    $0x1,%eax
80100e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e73:	0f b6 00             	movzbl (%eax),%eax
80100e76:	84 c0                	test   %al,%al
80100e78:	75 df                	jne    80100e59 <exec+0x315>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e80:	83 c0 6c             	add    $0x6c,%eax
80100e83:	83 ec 04             	sub    $0x4,%esp
80100e86:	6a 10                	push   $0x10
80100e88:	ff 75 f0             	pushl  -0x10(%ebp)
80100e8b:	50                   	push   %eax
80100e8c:	e8 be 44 00 00       	call   8010534f <safestrcpy>
80100e91:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9a:	8b 40 04             	mov    0x4(%eax),%eax
80100e9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb5:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 18             	mov    0x18(%eax),%eax
80100ec0:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec6:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	8b 40 18             	mov    0x18(%eax),%eax
80100ed2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed5:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ede:	83 ec 0c             	sub    $0xc,%esp
80100ee1:	50                   	push   %eax
80100ee2:	e8 a6 6e 00 00       	call   80107d8d <switchuvm>
80100ee7:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100eea:	83 ec 0c             	sub    $0xc,%esp
80100eed:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef0:	e8 dc 72 00 00       	call   801081d1 <freevm>
80100ef5:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ef8:	b8 00 00 00 00       	mov    $0x0,%eax
80100efd:	eb 32                	jmp    80100f31 <exec+0x3ed>

 bad:
  if(pgdir)
80100eff:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f03:	74 0e                	je     80100f13 <exec+0x3cf>
    freevm(pgdir);
80100f05:	83 ec 0c             	sub    $0xc,%esp
80100f08:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f0b:	e8 c1 72 00 00       	call   801081d1 <freevm>
80100f10:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f17:	74 13                	je     80100f2c <exec+0x3e8>
    iunlockput(ip);
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	ff 75 d8             	pushl  -0x28(%ebp)
80100f1f:	e8 6f 0c 00 00       	call   80101b93 <iunlockput>
80100f24:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f27:	e8 c8 25 00 00       	call   801034f4 <end_op>
  }
  return -1;
80100f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f31:	c9                   	leave  
80100f32:	c3                   	ret    

80100f33 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f33:	55                   	push   %ebp
80100f34:	89 e5                	mov    %esp,%ebp
80100f36:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f39:	83 ec 08             	sub    $0x8,%esp
80100f3c:	68 1d 85 10 80       	push   $0x8010851d
80100f41:	68 80 08 11 80       	push   $0x80110880
80100f46:	e8 82 3f 00 00       	call   80104ecd <initlock>
80100f4b:	83 c4 10             	add    $0x10,%esp
}
80100f4e:	c9                   	leave  
80100f4f:	c3                   	ret    

80100f50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f50:	55                   	push   %ebp
80100f51:	89 e5                	mov    %esp,%ebp
80100f53:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f56:	83 ec 0c             	sub    $0xc,%esp
80100f59:	68 80 08 11 80       	push   $0x80110880
80100f5e:	e8 8b 3f 00 00       	call   80104eee <acquire>
80100f63:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f66:	c7 45 f4 b4 08 11 80 	movl   $0x801108b4,-0xc(%ebp)
80100f6d:	eb 2d                	jmp    80100f9c <filealloc+0x4c>
    if(f->ref == 0){
80100f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f72:	8b 40 04             	mov    0x4(%eax),%eax
80100f75:	85 c0                	test   %eax,%eax
80100f77:	75 1f                	jne    80100f98 <filealloc+0x48>
      f->ref = 1;
80100f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f83:	83 ec 0c             	sub    $0xc,%esp
80100f86:	68 80 08 11 80       	push   $0x80110880
80100f8b:	e8 c4 3f 00 00       	call   80104f54 <release>
80100f90:	83 c4 10             	add    $0x10,%esp
      return f;
80100f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f96:	eb 22                	jmp    80100fba <filealloc+0x6a>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f98:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f9c:	81 7d f4 14 12 11 80 	cmpl   $0x80111214,-0xc(%ebp)
80100fa3:	72 ca                	jb     80100f6f <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	68 80 08 11 80       	push   $0x80110880
80100fad:	e8 a2 3f 00 00       	call   80104f54 <release>
80100fb2:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fba:	c9                   	leave  
80100fbb:	c3                   	ret    

80100fbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fbc:	55                   	push   %ebp
80100fbd:	89 e5                	mov    %esp,%ebp
80100fbf:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100fc2:	83 ec 0c             	sub    $0xc,%esp
80100fc5:	68 80 08 11 80       	push   $0x80110880
80100fca:	e8 1f 3f 00 00       	call   80104eee <acquire>
80100fcf:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd5:	8b 40 04             	mov    0x4(%eax),%eax
80100fd8:	85 c0                	test   %eax,%eax
80100fda:	7f 0d                	jg     80100fe9 <filedup+0x2d>
    panic("filedup");
80100fdc:	83 ec 0c             	sub    $0xc,%esp
80100fdf:	68 24 85 10 80       	push   $0x80108524
80100fe4:	e8 73 f5 ff ff       	call   8010055c <panic>
  f->ref++;
80100fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fec:	8b 40 04             	mov    0x4(%eax),%eax
80100fef:	8d 50 01             	lea    0x1(%eax),%edx
80100ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 80 08 11 80       	push   $0x80110880
80101000:	e8 4f 3f 00 00       	call   80104f54 <release>
80101005:	83 c4 10             	add    $0x10,%esp
  return f;
80101008:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010100b:	c9                   	leave  
8010100c:	c3                   	ret    

8010100d <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010100d:	55                   	push   %ebp
8010100e:	89 e5                	mov    %esp,%ebp
80101010:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101013:	83 ec 0c             	sub    $0xc,%esp
80101016:	68 80 08 11 80       	push   $0x80110880
8010101b:	e8 ce 3e 00 00       	call   80104eee <acquire>
80101020:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101023:	8b 45 08             	mov    0x8(%ebp),%eax
80101026:	8b 40 04             	mov    0x4(%eax),%eax
80101029:	85 c0                	test   %eax,%eax
8010102b:	7f 0d                	jg     8010103a <fileclose+0x2d>
    panic("fileclose");
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 2c 85 10 80       	push   $0x8010852c
80101035:	e8 22 f5 ff ff       	call   8010055c <panic>
  if(--f->ref > 0){
8010103a:	8b 45 08             	mov    0x8(%ebp),%eax
8010103d:	8b 40 04             	mov    0x4(%eax),%eax
80101040:	8d 50 ff             	lea    -0x1(%eax),%edx
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	89 50 04             	mov    %edx,0x4(%eax)
80101049:	8b 45 08             	mov    0x8(%ebp),%eax
8010104c:	8b 40 04             	mov    0x4(%eax),%eax
8010104f:	85 c0                	test   %eax,%eax
80101051:	7e 15                	jle    80101068 <fileclose+0x5b>
    release(&ftable.lock);
80101053:	83 ec 0c             	sub    $0xc,%esp
80101056:	68 80 08 11 80       	push   $0x80110880
8010105b:	e8 f4 3e 00 00       	call   80104f54 <release>
80101060:	83 c4 10             	add    $0x10,%esp
80101063:	e9 8b 00 00 00       	jmp    801010f3 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101068:	8b 45 08             	mov    0x8(%ebp),%eax
8010106b:	8b 10                	mov    (%eax),%edx
8010106d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101070:	8b 50 04             	mov    0x4(%eax),%edx
80101073:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101076:	8b 50 08             	mov    0x8(%eax),%edx
80101079:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010107c:	8b 50 0c             	mov    0xc(%eax),%edx
8010107f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101082:	8b 50 10             	mov    0x10(%eax),%edx
80101085:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101088:	8b 40 14             	mov    0x14(%eax),%eax
8010108b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 80 08 11 80       	push   $0x80110880
801010a9:	e8 a6 3e 00 00       	call   80104f54 <release>
801010ae:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010b4:	83 f8 01             	cmp    $0x1,%eax
801010b7:	75 19                	jne    801010d2 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010b9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010bd:	0f be d0             	movsbl %al,%edx
801010c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010c3:	83 ec 08             	sub    $0x8,%esp
801010c6:	52                   	push   %edx
801010c7:	50                   	push   %eax
801010c8:	e8 b9 2f 00 00       	call   80104086 <pipeclose>
801010cd:	83 c4 10             	add    $0x10,%esp
801010d0:	eb 21                	jmp    801010f3 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d5:	83 f8 02             	cmp    $0x2,%eax
801010d8:	75 19                	jne    801010f3 <fileclose+0xe6>
    begin_op();
801010da:	e8 87 23 00 00       	call   80103466 <begin_op>
    iput(ff.ip);
801010df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010e2:	83 ec 0c             	sub    $0xc,%esp
801010e5:	50                   	push   %eax
801010e6:	e8 b9 09 00 00       	call   80101aa4 <iput>
801010eb:	83 c4 10             	add    $0x10,%esp
    end_op();
801010ee:	e8 01 24 00 00       	call   801034f4 <end_op>
  }
}
801010f3:	c9                   	leave  
801010f4:	c3                   	ret    

801010f5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801010fb:	8b 45 08             	mov    0x8(%ebp),%eax
801010fe:	8b 00                	mov    (%eax),%eax
80101100:	83 f8 02             	cmp    $0x2,%eax
80101103:	75 40                	jne    80101145 <filestat+0x50>
    ilock(f->ip);
80101105:	8b 45 08             	mov    0x8(%ebp),%eax
80101108:	8b 40 10             	mov    0x10(%eax),%eax
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	50                   	push   %eax
8010110f:	e8 c8 07 00 00       	call   801018dc <ilock>
80101114:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	8b 40 10             	mov    0x10(%eax),%eax
8010111d:	83 ec 08             	sub    $0x8,%esp
80101120:	ff 75 0c             	pushl  0xc(%ebp)
80101123:	50                   	push   %eax
80101124:	e8 d0 0c 00 00       	call   80101df9 <stati>
80101129:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	83 ec 0c             	sub    $0xc,%esp
80101135:	50                   	push   %eax
80101136:	e8 f8 08 00 00       	call   80101a33 <iunlock>
8010113b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010113e:	b8 00 00 00 00       	mov    $0x0,%eax
80101143:	eb 05                	jmp    8010114a <filestat+0x55>
  }
  return -1;
80101145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010114a:	c9                   	leave  
8010114b:	c3                   	ret    

8010114c <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010114c:	55                   	push   %ebp
8010114d:	89 e5                	mov    %esp,%ebp
8010114f:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101152:	8b 45 08             	mov    0x8(%ebp),%eax
80101155:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101159:	84 c0                	test   %al,%al
8010115b:	75 0a                	jne    80101167 <fileread+0x1b>
    return -1;
8010115d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101162:	e9 9b 00 00 00       	jmp    80101202 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101167:	8b 45 08             	mov    0x8(%ebp),%eax
8010116a:	8b 00                	mov    (%eax),%eax
8010116c:	83 f8 01             	cmp    $0x1,%eax
8010116f:	75 1a                	jne    8010118b <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 0c             	mov    0xc(%eax),%eax
80101177:	83 ec 04             	sub    $0x4,%esp
8010117a:	ff 75 10             	pushl  0x10(%ebp)
8010117d:	ff 75 0c             	pushl  0xc(%ebp)
80101180:	50                   	push   %eax
80101181:	e8 ad 30 00 00       	call   80104233 <piperead>
80101186:	83 c4 10             	add    $0x10,%esp
80101189:	eb 77                	jmp    80101202 <fileread+0xb6>
  if(f->type == FD_INODE){
8010118b:	8b 45 08             	mov    0x8(%ebp),%eax
8010118e:	8b 00                	mov    (%eax),%eax
80101190:	83 f8 02             	cmp    $0x2,%eax
80101193:	75 60                	jne    801011f5 <fileread+0xa9>
    ilock(f->ip);
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	8b 40 10             	mov    0x10(%eax),%eax
8010119b:	83 ec 0c             	sub    $0xc,%esp
8010119e:	50                   	push   %eax
8010119f:	e8 38 07 00 00       	call   801018dc <ilock>
801011a4:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011aa:	8b 45 08             	mov    0x8(%ebp),%eax
801011ad:	8b 50 14             	mov    0x14(%eax),%edx
801011b0:	8b 45 08             	mov    0x8(%ebp),%eax
801011b3:	8b 40 10             	mov    0x10(%eax),%eax
801011b6:	51                   	push   %ecx
801011b7:	52                   	push   %edx
801011b8:	ff 75 0c             	pushl  0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 7d 0c 00 00       	call   80101e3e <readi>
801011c1:	83 c4 10             	add    $0x10,%esp
801011c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011cb:	7e 11                	jle    801011de <fileread+0x92>
      f->off += r;
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 50 14             	mov    0x14(%eax),%edx
801011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011d6:	01 c2                	add    %eax,%edx
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	8b 40 10             	mov    0x10(%eax),%eax
801011e4:	83 ec 0c             	sub    $0xc,%esp
801011e7:	50                   	push   %eax
801011e8:	e8 46 08 00 00       	call   80101a33 <iunlock>
801011ed:	83 c4 10             	add    $0x10,%esp
    return r;
801011f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011f3:	eb 0d                	jmp    80101202 <fileread+0xb6>
  }
  panic("fileread");
801011f5:	83 ec 0c             	sub    $0xc,%esp
801011f8:	68 36 85 10 80       	push   $0x80108536
801011fd:	e8 5a f3 ff ff       	call   8010055c <panic>
}
80101202:	c9                   	leave  
80101203:	c3                   	ret    

80101204 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101204:	55                   	push   %ebp
80101205:	89 e5                	mov    %esp,%ebp
80101207:	53                   	push   %ebx
80101208:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101212:	84 c0                	test   %al,%al
80101214:	75 0a                	jne    80101220 <filewrite+0x1c>
    return -1;
80101216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010121b:	e9 1a 01 00 00       	jmp    8010133a <filewrite+0x136>
  if(f->type == FD_PIPE)
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 00                	mov    (%eax),%eax
80101225:	83 f8 01             	cmp    $0x1,%eax
80101228:	75 1d                	jne    80101247 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 40 0c             	mov    0xc(%eax),%eax
80101230:	83 ec 04             	sub    $0x4,%esp
80101233:	ff 75 10             	pushl  0x10(%ebp)
80101236:	ff 75 0c             	pushl  0xc(%ebp)
80101239:	50                   	push   %eax
8010123a:	e8 f0 2e 00 00       	call   8010412f <pipewrite>
8010123f:	83 c4 10             	add    $0x10,%esp
80101242:	e9 f3 00 00 00       	jmp    8010133a <filewrite+0x136>
  if(f->type == FD_INODE){
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	8b 00                	mov    (%eax),%eax
8010124c:	83 f8 02             	cmp    $0x2,%eax
8010124f:	0f 85 d8 00 00 00    	jne    8010132d <filewrite+0x129>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101255:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010125c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101263:	e9 a5 00 00 00       	jmp    8010130d <filewrite+0x109>
      int n1 = n - i;
80101268:	8b 45 10             	mov    0x10(%ebp),%eax
8010126b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010126e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101274:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101277:	7e 06                	jle    8010127f <filewrite+0x7b>
        n1 = max;
80101279:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010127c:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010127f:	e8 e2 21 00 00       	call   80103466 <begin_op>
      ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	83 ec 0c             	sub    $0xc,%esp
8010128d:	50                   	push   %eax
8010128e:	e8 49 06 00 00       	call   801018dc <ilock>
80101293:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101296:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	8b 50 14             	mov    0x14(%eax),%edx
8010129f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801012a5:	01 c3                	add    %eax,%ebx
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	51                   	push   %ecx
801012ae:	52                   	push   %edx
801012af:	53                   	push   %ebx
801012b0:	50                   	push   %eax
801012b1:	e8 e2 0c 00 00       	call   80101f98 <writei>
801012b6:	83 c4 10             	add    $0x10,%esp
801012b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012c0:	7e 11                	jle    801012d3 <filewrite+0xcf>
        f->off += r;
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012cb:	01 c2                	add    %eax,%edx
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	83 ec 0c             	sub    $0xc,%esp
801012dc:	50                   	push   %eax
801012dd:	e8 51 07 00 00       	call   80101a33 <iunlock>
801012e2:	83 c4 10             	add    $0x10,%esp
      end_op();
801012e5:	e8 0a 22 00 00       	call   801034f4 <end_op>

      if(r < 0)
801012ea:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012ee:	79 02                	jns    801012f2 <filewrite+0xee>
        break;
801012f0:	eb 27                	jmp    80101319 <filewrite+0x115>
      if(r != n1)
801012f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012f8:	74 0d                	je     80101307 <filewrite+0x103>
        panic("short filewrite");
801012fa:	83 ec 0c             	sub    $0xc,%esp
801012fd:	68 3f 85 10 80       	push   $0x8010853f
80101302:	e8 55 f2 ff ff       	call   8010055c <panic>
      i += r;
80101307:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101310:	3b 45 10             	cmp    0x10(%ebp),%eax
80101313:	0f 8c 4f ff ff ff    	jl     80101268 <filewrite+0x64>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010131f:	75 05                	jne    80101326 <filewrite+0x122>
80101321:	8b 45 10             	mov    0x10(%ebp),%eax
80101324:	eb 14                	jmp    8010133a <filewrite+0x136>
80101326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010132b:	eb 0d                	jmp    8010133a <filewrite+0x136>
  }
  panic("filewrite");
8010132d:	83 ec 0c             	sub    $0xc,%esp
80101330:	68 4f 85 10 80       	push   $0x8010854f
80101335:	e8 22 f2 ff ff       	call   8010055c <panic>
}
8010133a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010133d:	c9                   	leave  
8010133e:	c3                   	ret    

8010133f <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010133f:	55                   	push   %ebp
80101340:	89 e5                	mov    %esp,%ebp
80101342:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101345:	8b 45 08             	mov    0x8(%ebp),%eax
80101348:	83 ec 08             	sub    $0x8,%esp
8010134b:	6a 01                	push   $0x1
8010134d:	50                   	push   %eax
8010134e:	e8 61 ee ff ff       	call   801001b4 <bread>
80101353:	83 c4 10             	add    $0x10,%esp
80101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135c:	83 c0 18             	add    $0x18,%eax
8010135f:	83 ec 04             	sub    $0x4,%esp
80101362:	6a 10                	push   $0x10
80101364:	50                   	push   %eax
80101365:	ff 75 0c             	pushl  0xc(%ebp)
80101368:	e8 9c 3e 00 00       	call   80105209 <memmove>
8010136d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101370:	83 ec 0c             	sub    $0xc,%esp
80101373:	ff 75 f4             	pushl  -0xc(%ebp)
80101376:	e8 b0 ee ff ff       	call   8010022b <brelse>
8010137b:	83 c4 10             	add    $0x10,%esp
}
8010137e:	c9                   	leave  
8010137f:	c3                   	ret    

80101380 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101380:	55                   	push   %ebp
80101381:	89 e5                	mov    %esp,%ebp
80101383:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101386:	8b 55 0c             	mov    0xc(%ebp),%edx
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	83 ec 08             	sub    $0x8,%esp
8010138f:	52                   	push   %edx
80101390:	50                   	push   %eax
80101391:	e8 1e ee ff ff       	call   801001b4 <bread>
80101396:	83 c4 10             	add    $0x10,%esp
80101399:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010139c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139f:	83 c0 18             	add    $0x18,%eax
801013a2:	83 ec 04             	sub    $0x4,%esp
801013a5:	68 00 02 00 00       	push   $0x200
801013aa:	6a 00                	push   $0x0
801013ac:	50                   	push   %eax
801013ad:	e8 98 3d 00 00       	call   8010514a <memset>
801013b2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 dd 22 00 00       	call   8010369d <log_write>
801013c0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013c3:	83 ec 0c             	sub    $0xc,%esp
801013c6:	ff 75 f4             	pushl  -0xc(%ebp)
801013c9:	e8 5d ee ff ff       	call   8010022b <brelse>
801013ce:	83 c4 10             	add    $0x10,%esp
}
801013d1:	c9                   	leave  
801013d2:	c3                   	ret    

801013d3 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013d3:	55                   	push   %ebp
801013d4:	89 e5                	mov    %esp,%ebp
801013d6:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	83 ec 08             	sub    $0x8,%esp
801013e6:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013e9:	52                   	push   %edx
801013ea:	50                   	push   %eax
801013eb:	e8 4f ff ff ff       	call   8010133f <readsb>
801013f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801013f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013fa:	e9 15 01 00 00       	jmp    80101514 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101402:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101408:	85 c0                	test   %eax,%eax
8010140a:	0f 48 c2             	cmovs  %edx,%eax
8010140d:	c1 f8 0c             	sar    $0xc,%eax
80101410:	89 c2                	mov    %eax,%edx
80101412:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101415:	c1 e8 03             	shr    $0x3,%eax
80101418:	01 d0                	add    %edx,%eax
8010141a:	83 c0 03             	add    $0x3,%eax
8010141d:	83 ec 08             	sub    $0x8,%esp
80101420:	50                   	push   %eax
80101421:	ff 75 08             	pushl  0x8(%ebp)
80101424:	e8 8b ed ff ff       	call   801001b4 <bread>
80101429:	83 c4 10             	add    $0x10,%esp
8010142c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010142f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101436:	e9 a6 00 00 00       	jmp    801014e1 <balloc+0x10e>
      m = 1 << (bi % 8);
8010143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143e:	99                   	cltd   
8010143f:	c1 ea 1d             	shr    $0x1d,%edx
80101442:	01 d0                	add    %edx,%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	29 d0                	sub    %edx,%eax
80101449:	ba 01 00 00 00       	mov    $0x1,%edx
8010144e:	89 c1                	mov    %eax,%ecx
80101450:	d3 e2                	shl    %cl,%edx
80101452:	89 d0                	mov    %edx,%eax
80101454:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010145a:	8d 50 07             	lea    0x7(%eax),%edx
8010145d:	85 c0                	test   %eax,%eax
8010145f:	0f 48 c2             	cmovs  %edx,%eax
80101462:	c1 f8 03             	sar    $0x3,%eax
80101465:	89 c2                	mov    %eax,%edx
80101467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010146f:	0f b6 c0             	movzbl %al,%eax
80101472:	23 45 e8             	and    -0x18(%ebp),%eax
80101475:	85 c0                	test   %eax,%eax
80101477:	75 64                	jne    801014dd <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
80101479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147c:	8d 50 07             	lea    0x7(%eax),%edx
8010147f:	85 c0                	test   %eax,%eax
80101481:	0f 48 c2             	cmovs  %edx,%eax
80101484:	c1 f8 03             	sar    $0x3,%eax
80101487:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010148a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010148f:	89 d1                	mov    %edx,%ecx
80101491:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101494:	09 ca                	or     %ecx,%edx
80101496:	89 d1                	mov    %edx,%ecx
80101498:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010149b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010149f:	83 ec 0c             	sub    $0xc,%esp
801014a2:	ff 75 ec             	pushl  -0x14(%ebp)
801014a5:	e8 f3 21 00 00       	call   8010369d <log_write>
801014aa:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014ad:	83 ec 0c             	sub    $0xc,%esp
801014b0:	ff 75 ec             	pushl  -0x14(%ebp)
801014b3:	e8 73 ed ff ff       	call   8010022b <brelse>
801014b8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c1:	01 c2                	add    %eax,%edx
801014c3:	8b 45 08             	mov    0x8(%ebp),%eax
801014c6:	83 ec 08             	sub    $0x8,%esp
801014c9:	52                   	push   %edx
801014ca:	50                   	push   %eax
801014cb:	e8 b0 fe ff ff       	call   80101380 <bzero>
801014d0:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d9:	01 d0                	add    %edx,%eax
801014db:	eb 52                	jmp    8010152f <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014dd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014e1:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014e8:	7f 15                	jg     801014ff <balloc+0x12c>
801014ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f0:	01 d0                	add    %edx,%eax
801014f2:	89 c2                	mov    %eax,%edx
801014f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014f7:	39 c2                	cmp    %eax,%edx
801014f9:	0f 82 3c ff ff ff    	jb     8010143b <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ff:	83 ec 0c             	sub    $0xc,%esp
80101502:	ff 75 ec             	pushl  -0x14(%ebp)
80101505:	e8 21 ed ff ff       	call   8010022b <brelse>
8010150a:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010150d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101517:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010151a:	39 c2                	cmp    %eax,%edx
8010151c:	0f 82 dd fe ff ff    	jb     801013ff <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101522:	83 ec 0c             	sub    $0xc,%esp
80101525:	68 59 85 10 80       	push   $0x80108559
8010152a:	e8 2d f0 ff ff       	call   8010055c <panic>
}
8010152f:	c9                   	leave  
80101530:	c3                   	ret    

80101531 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101531:	55                   	push   %ebp
80101532:	89 e5                	mov    %esp,%ebp
80101534:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101537:	83 ec 08             	sub    $0x8,%esp
8010153a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010153d:	50                   	push   %eax
8010153e:	ff 75 08             	pushl  0x8(%ebp)
80101541:	e8 f9 fd ff ff       	call   8010133f <readsb>
80101546:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010154c:	c1 e8 0c             	shr    $0xc,%eax
8010154f:	89 c2                	mov    %eax,%edx
80101551:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101554:	c1 e8 03             	shr    $0x3,%eax
80101557:	01 d0                	add    %edx,%eax
80101559:	8d 50 03             	lea    0x3(%eax),%edx
8010155c:	8b 45 08             	mov    0x8(%ebp),%eax
8010155f:	83 ec 08             	sub    $0x8,%esp
80101562:	52                   	push   %edx
80101563:	50                   	push   %eax
80101564:	e8 4b ec ff ff       	call   801001b4 <bread>
80101569:	83 c4 10             	add    $0x10,%esp
8010156c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010156f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101572:	25 ff 0f 00 00       	and    $0xfff,%eax
80101577:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157d:	99                   	cltd   
8010157e:	c1 ea 1d             	shr    $0x1d,%edx
80101581:	01 d0                	add    %edx,%eax
80101583:	83 e0 07             	and    $0x7,%eax
80101586:	29 d0                	sub    %edx,%eax
80101588:	ba 01 00 00 00       	mov    $0x1,%edx
8010158d:	89 c1                	mov    %eax,%ecx
8010158f:	d3 e2                	shl    %cl,%edx
80101591:	89 d0                	mov    %edx,%eax
80101593:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101599:	8d 50 07             	lea    0x7(%eax),%edx
8010159c:	85 c0                	test   %eax,%eax
8010159e:	0f 48 c2             	cmovs  %edx,%eax
801015a1:	c1 f8 03             	sar    $0x3,%eax
801015a4:	89 c2                	mov    %eax,%edx
801015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a9:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015ae:	0f b6 c0             	movzbl %al,%eax
801015b1:	23 45 ec             	and    -0x14(%ebp),%eax
801015b4:	85 c0                	test   %eax,%eax
801015b6:	75 0d                	jne    801015c5 <bfree+0x94>
    panic("freeing free block");
801015b8:	83 ec 0c             	sub    $0xc,%esp
801015bb:	68 6f 85 10 80       	push   $0x8010856f
801015c0:	e8 97 ef ff ff       	call   8010055c <panic>
  bp->data[bi/8] &= ~m;
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	8d 50 07             	lea    0x7(%eax),%edx
801015cb:	85 c0                	test   %eax,%eax
801015cd:	0f 48 c2             	cmovs  %edx,%eax
801015d0:	c1 f8 03             	sar    $0x3,%eax
801015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015db:	89 d1                	mov    %edx,%ecx
801015dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015e0:	f7 d2                	not    %edx
801015e2:	21 ca                	and    %ecx,%edx
801015e4:	89 d1                	mov    %edx,%ecx
801015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e9:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015ed:	83 ec 0c             	sub    $0xc,%esp
801015f0:	ff 75 f4             	pushl  -0xc(%ebp)
801015f3:	e8 a5 20 00 00       	call   8010369d <log_write>
801015f8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015fb:	83 ec 0c             	sub    $0xc,%esp
801015fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101601:	e8 25 ec ff ff       	call   8010022b <brelse>
80101606:	83 c4 10             	add    $0x10,%esp
}
80101609:	c9                   	leave  
8010160a:	c3                   	ret    

8010160b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010160b:	55                   	push   %ebp
8010160c:	89 e5                	mov    %esp,%ebp
8010160e:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
80101611:	83 ec 08             	sub    $0x8,%esp
80101614:	68 82 85 10 80       	push   $0x80108582
80101619:	68 c0 12 11 80       	push   $0x801112c0
8010161e:	e8 aa 38 00 00       	call   80104ecd <initlock>
80101623:	83 c4 10             	add    $0x10,%esp
}
80101626:	c9                   	leave  
80101627:	c3                   	ret    

80101628 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101628:	55                   	push   %ebp
80101629:	89 e5                	mov    %esp,%ebp
8010162b:	83 ec 38             	sub    $0x38,%esp
8010162e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101631:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101635:	8b 45 08             	mov    0x8(%ebp),%eax
80101638:	83 ec 08             	sub    $0x8,%esp
8010163b:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010163e:	52                   	push   %edx
8010163f:	50                   	push   %eax
80101640:	e8 fa fc ff ff       	call   8010133f <readsb>
80101645:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101648:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010164f:	e9 98 00 00 00       	jmp    801016ec <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
80101654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101657:	c1 e8 03             	shr    $0x3,%eax
8010165a:	83 c0 02             	add    $0x2,%eax
8010165d:	83 ec 08             	sub    $0x8,%esp
80101660:	50                   	push   %eax
80101661:	ff 75 08             	pushl  0x8(%ebp)
80101664:	e8 4b eb ff ff       	call   801001b4 <bread>
80101669:	83 c4 10             	add    $0x10,%esp
8010166c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101672:	8d 50 18             	lea    0x18(%eax),%edx
80101675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101678:	83 e0 07             	and    $0x7,%eax
8010167b:	c1 e0 06             	shl    $0x6,%eax
8010167e:	01 d0                	add    %edx,%eax
80101680:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101683:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101686:	0f b7 00             	movzwl (%eax),%eax
80101689:	66 85 c0             	test   %ax,%ax
8010168c:	75 4c                	jne    801016da <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
8010168e:	83 ec 04             	sub    $0x4,%esp
80101691:	6a 40                	push   $0x40
80101693:	6a 00                	push   $0x0
80101695:	ff 75 ec             	pushl  -0x14(%ebp)
80101698:	e8 ad 3a 00 00       	call   8010514a <memset>
8010169d:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016a3:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016a7:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016aa:	83 ec 0c             	sub    $0xc,%esp
801016ad:	ff 75 f0             	pushl  -0x10(%ebp)
801016b0:	e8 e8 1f 00 00       	call   8010369d <log_write>
801016b5:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016b8:	83 ec 0c             	sub    $0xc,%esp
801016bb:	ff 75 f0             	pushl  -0x10(%ebp)
801016be:	e8 68 eb ff ff       	call   8010022b <brelse>
801016c3:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c9:	83 ec 08             	sub    $0x8,%esp
801016cc:	50                   	push   %eax
801016cd:	ff 75 08             	pushl  0x8(%ebp)
801016d0:	e8 ee 00 00 00       	call   801017c3 <iget>
801016d5:	83 c4 10             	add    $0x10,%esp
801016d8:	eb 2d                	jmp    80101707 <ialloc+0xdf>
    }
    brelse(bp);
801016da:	83 ec 0c             	sub    $0xc,%esp
801016dd:	ff 75 f0             	pushl  -0x10(%ebp)
801016e0:	e8 46 eb ff ff       	call   8010022b <brelse>
801016e5:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016f2:	39 c2                	cmp    %eax,%edx
801016f4:	0f 82 5a ff ff ff    	jb     80101654 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016fa:	83 ec 0c             	sub    $0xc,%esp
801016fd:	68 89 85 10 80       	push   $0x80108589
80101702:	e8 55 ee ff ff       	call   8010055c <panic>
}
80101707:	c9                   	leave  
80101708:	c3                   	ret    

80101709 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101709:	55                   	push   %ebp
8010170a:	89 e5                	mov    %esp,%ebp
8010170c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010170f:	8b 45 08             	mov    0x8(%ebp),%eax
80101712:	8b 40 04             	mov    0x4(%eax),%eax
80101715:	c1 e8 03             	shr    $0x3,%eax
80101718:	8d 50 02             	lea    0x2(%eax),%edx
8010171b:	8b 45 08             	mov    0x8(%ebp),%eax
8010171e:	8b 00                	mov    (%eax),%eax
80101720:	83 ec 08             	sub    $0x8,%esp
80101723:	52                   	push   %edx
80101724:	50                   	push   %eax
80101725:	e8 8a ea ff ff       	call   801001b4 <bread>
8010172a:	83 c4 10             	add    $0x10,%esp
8010172d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101733:	8d 50 18             	lea    0x18(%eax),%edx
80101736:	8b 45 08             	mov    0x8(%ebp),%eax
80101739:	8b 40 04             	mov    0x4(%eax),%eax
8010173c:	83 e0 07             	and    $0x7,%eax
8010173f:	c1 e0 06             	shl    $0x6,%eax
80101742:	01 d0                	add    %edx,%eax
80101744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101747:	8b 45 08             	mov    0x8(%ebp),%eax
8010174a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101751:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101754:	8b 45 08             	mov    0x8(%ebp),%eax
80101757:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010175b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101762:	8b 45 08             	mov    0x8(%ebp),%eax
80101765:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101769:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010176c:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101770:	8b 45 08             	mov    0x8(%ebp),%eax
80101773:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010177e:	8b 45 08             	mov    0x8(%ebp),%eax
80101781:	8b 50 18             	mov    0x18(%eax),%edx
80101784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101787:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010178a:	8b 45 08             	mov    0x8(%ebp),%eax
8010178d:	8d 50 1c             	lea    0x1c(%eax),%edx
80101790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101793:	83 c0 0c             	add    $0xc,%eax
80101796:	83 ec 04             	sub    $0x4,%esp
80101799:	6a 34                	push   $0x34
8010179b:	52                   	push   %edx
8010179c:	50                   	push   %eax
8010179d:	e8 67 3a 00 00       	call   80105209 <memmove>
801017a2:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017a5:	83 ec 0c             	sub    $0xc,%esp
801017a8:	ff 75 f4             	pushl  -0xc(%ebp)
801017ab:	e8 ed 1e 00 00       	call   8010369d <log_write>
801017b0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017b3:	83 ec 0c             	sub    $0xc,%esp
801017b6:	ff 75 f4             	pushl  -0xc(%ebp)
801017b9:	e8 6d ea ff ff       	call   8010022b <brelse>
801017be:	83 c4 10             	add    $0x10,%esp
}
801017c1:	c9                   	leave  
801017c2:	c3                   	ret    

801017c3 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017c3:	55                   	push   %ebp
801017c4:	89 e5                	mov    %esp,%ebp
801017c6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017c9:	83 ec 0c             	sub    $0xc,%esp
801017cc:	68 c0 12 11 80       	push   $0x801112c0
801017d1:	e8 18 37 00 00       	call   80104eee <acquire>
801017d6:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801017d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e0:	c7 45 f4 f4 12 11 80 	movl   $0x801112f4,-0xc(%ebp)
801017e7:	eb 5d                	jmp    80101846 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ec:	8b 40 08             	mov    0x8(%eax),%eax
801017ef:	85 c0                	test   %eax,%eax
801017f1:	7e 39                	jle    8010182c <iget+0x69>
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	8b 00                	mov    (%eax),%eax
801017f8:	3b 45 08             	cmp    0x8(%ebp),%eax
801017fb:	75 2f                	jne    8010182c <iget+0x69>
801017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101800:	8b 40 04             	mov    0x4(%eax),%eax
80101803:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101806:	75 24                	jne    8010182c <iget+0x69>
      ip->ref++;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 40 08             	mov    0x8(%eax),%eax
8010180e:	8d 50 01             	lea    0x1(%eax),%edx
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101817:	83 ec 0c             	sub    $0xc,%esp
8010181a:	68 c0 12 11 80       	push   $0x801112c0
8010181f:	e8 30 37 00 00       	call   80104f54 <release>
80101824:	83 c4 10             	add    $0x10,%esp
      return ip;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	eb 74                	jmp    801018a0 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010182c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101830:	75 10                	jne    80101842 <iget+0x7f>
80101832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101835:	8b 40 08             	mov    0x8(%eax),%eax
80101838:	85 c0                	test   %eax,%eax
8010183a:	75 06                	jne    80101842 <iget+0x7f>
      empty = ip;
8010183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101842:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101846:	81 7d f4 94 22 11 80 	cmpl   $0x80112294,-0xc(%ebp)
8010184d:	72 9a                	jb     801017e9 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010184f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101853:	75 0d                	jne    80101862 <iget+0x9f>
    panic("iget: no inodes");
80101855:	83 ec 0c             	sub    $0xc,%esp
80101858:	68 9b 85 10 80       	push   $0x8010859b
8010185d:	e8 fa ec ff ff       	call   8010055c <panic>

  ip = empty;
80101862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186b:	8b 55 08             	mov    0x8(%ebp),%edx
8010186e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 55 0c             	mov    0xc(%ebp),%edx
80101876:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010188d:	83 ec 0c             	sub    $0xc,%esp
80101890:	68 c0 12 11 80       	push   $0x801112c0
80101895:	e8 ba 36 00 00       	call   80104f54 <release>
8010189a:	83 c4 10             	add    $0x10,%esp

  return ip;
8010189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a0:	c9                   	leave  
801018a1:	c3                   	ret    

801018a2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a2:	55                   	push   %ebp
801018a3:	89 e5                	mov    %esp,%ebp
801018a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018a8:	83 ec 0c             	sub    $0xc,%esp
801018ab:	68 c0 12 11 80       	push   $0x801112c0
801018b0:	e8 39 36 00 00       	call   80104eee <acquire>
801018b5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 08             	mov    0x8(%eax),%eax
801018be:	8d 50 01             	lea    0x1(%eax),%edx
801018c1:	8b 45 08             	mov    0x8(%ebp),%eax
801018c4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c7:	83 ec 0c             	sub    $0xc,%esp
801018ca:	68 c0 12 11 80       	push   $0x801112c0
801018cf:	e8 80 36 00 00       	call   80104f54 <release>
801018d4:	83 c4 10             	add    $0x10,%esp
  return ip;
801018d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018da:	c9                   	leave  
801018db:	c3                   	ret    

801018dc <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018dc:	55                   	push   %ebp
801018dd:	89 e5                	mov    %esp,%ebp
801018df:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018e6:	74 0a                	je     801018f2 <ilock+0x16>
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	8b 40 08             	mov    0x8(%eax),%eax
801018ee:	85 c0                	test   %eax,%eax
801018f0:	7f 0d                	jg     801018ff <ilock+0x23>
    panic("ilock");
801018f2:	83 ec 0c             	sub    $0xc,%esp
801018f5:	68 ab 85 10 80       	push   $0x801085ab
801018fa:	e8 5d ec ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
801018ff:	83 ec 0c             	sub    $0xc,%esp
80101902:	68 c0 12 11 80       	push   $0x801112c0
80101907:	e8 e2 35 00 00       	call   80104eee <acquire>
8010190c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010190f:	eb 13                	jmp    80101924 <ilock+0x48>
    sleep(ip, &icache.lock);
80101911:	83 ec 08             	sub    $0x8,%esp
80101914:	68 c0 12 11 80       	push   $0x801112c0
80101919:	ff 75 08             	pushl  0x8(%ebp)
8010191c:	e8 d4 32 00 00       	call   80104bf5 <sleep>
80101921:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101924:	8b 45 08             	mov    0x8(%ebp),%eax
80101927:	8b 40 0c             	mov    0xc(%eax),%eax
8010192a:	83 e0 01             	and    $0x1,%eax
8010192d:	85 c0                	test   %eax,%eax
8010192f:	75 e0                	jne    80101911 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	8b 40 0c             	mov    0xc(%eax),%eax
80101937:	83 c8 01             	or     $0x1,%eax
8010193a:	89 c2                	mov    %eax,%edx
8010193c:	8b 45 08             	mov    0x8(%ebp),%eax
8010193f:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101942:	83 ec 0c             	sub    $0xc,%esp
80101945:	68 c0 12 11 80       	push   $0x801112c0
8010194a:	e8 05 36 00 00       	call   80104f54 <release>
8010194f:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	8b 40 0c             	mov    0xc(%eax),%eax
80101958:	83 e0 02             	and    $0x2,%eax
8010195b:	85 c0                	test   %eax,%eax
8010195d:	0f 85 ce 00 00 00    	jne    80101a31 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	8b 40 04             	mov    0x4(%eax),%eax
80101969:	c1 e8 03             	shr    $0x3,%eax
8010196c:	8d 50 02             	lea    0x2(%eax),%edx
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	8b 00                	mov    (%eax),%eax
80101974:	83 ec 08             	sub    $0x8,%esp
80101977:	52                   	push   %edx
80101978:	50                   	push   %eax
80101979:	e8 36 e8 ff ff       	call   801001b4 <bread>
8010197e:	83 c4 10             	add    $0x10,%esp
80101981:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	8d 50 18             	lea    0x18(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	8b 40 04             	mov    0x4(%eax),%eax
80101990:	83 e0 07             	and    $0x7,%eax
80101993:	c1 e0 06             	shl    $0x6,%eax
80101996:	01 d0                	add    %edx,%eax
80101998:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199e:	0f b7 10             	movzwl (%eax),%edx
801019a1:	8b 45 08             	mov    0x8(%ebp),%eax
801019a4:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ab:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019bd:	8b 45 08             	mov    0x8(%ebp),%eax
801019c0:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019cb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ce:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d5:	8b 50 08             	mov    0x8(%eax),%edx
801019d8:	8b 45 08             	mov    0x8(%ebp),%eax
801019db:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e1:	8d 50 0c             	lea    0xc(%eax),%edx
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	83 c0 1c             	add    $0x1c,%eax
801019ea:	83 ec 04             	sub    $0x4,%esp
801019ed:	6a 34                	push   $0x34
801019ef:	52                   	push   %edx
801019f0:	50                   	push   %eax
801019f1:	e8 13 38 00 00       	call   80105209 <memmove>
801019f6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801019f9:	83 ec 0c             	sub    $0xc,%esp
801019fc:	ff 75 f4             	pushl  -0xc(%ebp)
801019ff:	e8 27 e8 ff ff       	call   8010022b <brelse>
80101a04:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a0d:	83 c8 02             	or     $0x2,%eax
80101a10:	89 c2                	mov    %eax,%edx
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a18:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a1f:	66 85 c0             	test   %ax,%ax
80101a22:	75 0d                	jne    80101a31 <ilock+0x155>
      panic("ilock: no type");
80101a24:	83 ec 0c             	sub    $0xc,%esp
80101a27:	68 b1 85 10 80       	push   $0x801085b1
80101a2c:	e8 2b eb ff ff       	call   8010055c <panic>
  }
}
80101a31:	c9                   	leave  
80101a32:	c3                   	ret    

80101a33 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a33:	55                   	push   %ebp
80101a34:	89 e5                	mov    %esp,%ebp
80101a36:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a39:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a3d:	74 17                	je     80101a56 <iunlock+0x23>
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 40 0c             	mov    0xc(%eax),%eax
80101a45:	83 e0 01             	and    $0x1,%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	74 0a                	je     80101a56 <iunlock+0x23>
80101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4f:	8b 40 08             	mov    0x8(%eax),%eax
80101a52:	85 c0                	test   %eax,%eax
80101a54:	7f 0d                	jg     80101a63 <iunlock+0x30>
    panic("iunlock");
80101a56:	83 ec 0c             	sub    $0xc,%esp
80101a59:	68 c0 85 10 80       	push   $0x801085c0
80101a5e:	e8 f9 ea ff ff       	call   8010055c <panic>

  acquire(&icache.lock);
80101a63:	83 ec 0c             	sub    $0xc,%esp
80101a66:	68 c0 12 11 80       	push   $0x801112c0
80101a6b:	e8 7e 34 00 00       	call   80104eee <acquire>
80101a70:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101a73:	8b 45 08             	mov    0x8(%ebp),%eax
80101a76:	8b 40 0c             	mov    0xc(%eax),%eax
80101a79:	83 e0 fe             	and    $0xfffffffe,%eax
80101a7c:	89 c2                	mov    %eax,%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	ff 75 08             	pushl  0x8(%ebp)
80101a8a:	e8 52 32 00 00       	call   80104ce1 <wakeup>
80101a8f:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101a92:	83 ec 0c             	sub    $0xc,%esp
80101a95:	68 c0 12 11 80       	push   $0x801112c0
80101a9a:	e8 b5 34 00 00       	call   80104f54 <release>
80101a9f:	83 c4 10             	add    $0x10,%esp
}
80101aa2:	c9                   	leave  
80101aa3:	c3                   	ret    

80101aa4 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101aa4:	55                   	push   %ebp
80101aa5:	89 e5                	mov    %esp,%ebp
80101aa7:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aaa:	83 ec 0c             	sub    $0xc,%esp
80101aad:	68 c0 12 11 80       	push   $0x801112c0
80101ab2:	e8 37 34 00 00       	call   80104eee <acquire>
80101ab7:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 08             	mov    0x8(%eax),%eax
80101ac0:	83 f8 01             	cmp    $0x1,%eax
80101ac3:	0f 85 a9 00 00 00    	jne    80101b72 <iput+0xce>
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 40 0c             	mov    0xc(%eax),%eax
80101acf:	83 e0 02             	and    $0x2,%eax
80101ad2:	85 c0                	test   %eax,%eax
80101ad4:	0f 84 98 00 00 00    	je     80101b72 <iput+0xce>
80101ada:	8b 45 08             	mov    0x8(%ebp),%eax
80101add:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101ae1:	66 85 c0             	test   %ax,%ax
80101ae4:	0f 85 88 00 00 00    	jne    80101b72 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	8b 40 0c             	mov    0xc(%eax),%eax
80101af0:	83 e0 01             	and    $0x1,%eax
80101af3:	85 c0                	test   %eax,%eax
80101af5:	74 0d                	je     80101b04 <iput+0x60>
      panic("iput busy");
80101af7:	83 ec 0c             	sub    $0xc,%esp
80101afa:	68 c8 85 10 80       	push   $0x801085c8
80101aff:	e8 58 ea ff ff       	call   8010055c <panic>
    ip->flags |= I_BUSY;
80101b04:	8b 45 08             	mov    0x8(%ebp),%eax
80101b07:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0a:	83 c8 01             	or     $0x1,%eax
80101b0d:	89 c2                	mov    %eax,%edx
80101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b12:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b15:	83 ec 0c             	sub    $0xc,%esp
80101b18:	68 c0 12 11 80       	push   $0x801112c0
80101b1d:	e8 32 34 00 00       	call   80104f54 <release>
80101b22:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	ff 75 08             	pushl  0x8(%ebp)
80101b2b:	e8 a6 01 00 00       	call   80101cd6 <itrunc>
80101b30:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	ff 75 08             	pushl  0x8(%ebp)
80101b42:	e8 c2 fb ff ff       	call   80101709 <iupdate>
80101b47:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b4a:	83 ec 0c             	sub    $0xc,%esp
80101b4d:	68 c0 12 11 80       	push   $0x801112c0
80101b52:	e8 97 33 00 00       	call   80104eee <acquire>
80101b57:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b64:	83 ec 0c             	sub    $0xc,%esp
80101b67:	ff 75 08             	pushl  0x8(%ebp)
80101b6a:	e8 72 31 00 00       	call   80104ce1 <wakeup>
80101b6f:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 40 08             	mov    0x8(%eax),%eax
80101b78:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 c0 12 11 80       	push   $0x801112c0
80101b89:	e8 c6 33 00 00       	call   80104f54 <release>
80101b8e:	83 c4 10             	add    $0x10,%esp
}
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b93:	55                   	push   %ebp
80101b94:	89 e5                	mov    %esp,%ebp
80101b96:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101b99:	83 ec 0c             	sub    $0xc,%esp
80101b9c:	ff 75 08             	pushl  0x8(%ebp)
80101b9f:	e8 8f fe ff ff       	call   80101a33 <iunlock>
80101ba4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	ff 75 08             	pushl  0x8(%ebp)
80101bad:	e8 f2 fe ff ff       	call   80101aa4 <iput>
80101bb2:	83 c4 10             	add    $0x10,%esp
}
80101bb5:	c9                   	leave  
80101bb6:	c3                   	ret    

80101bb7 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bb7:	55                   	push   %ebp
80101bb8:	89 e5                	mov    %esp,%ebp
80101bba:	53                   	push   %ebx
80101bbb:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bbe:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101bc2:	77 42                	ja     80101c06 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bca:	83 c2 04             	add    $0x4,%edx
80101bcd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd8:	75 24                	jne    80101bfe <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101bda:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdd:	8b 00                	mov    (%eax),%eax
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	50                   	push   %eax
80101be3:	e8 eb f7 ff ff       	call   801013d3 <balloc>
80101be8:	83 c4 10             	add    $0x10,%esp
80101beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bf4:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfa:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c01:	e9 cb 00 00 00       	jmp    80101cd1 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c06:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c0a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c0e:	0f 87 b0 00 00 00    	ja     80101cc4 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c21:	75 1d                	jne    80101c40 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	8b 00                	mov    (%eax),%eax
80101c28:	83 ec 0c             	sub    $0xc,%esp
80101c2b:	50                   	push   %eax
80101c2c:	e8 a2 f7 ff ff       	call   801013d3 <balloc>
80101c31:	83 c4 10             	add    $0x10,%esp
80101c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3d:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	8b 00                	mov    (%eax),%eax
80101c45:	83 ec 08             	sub    $0x8,%esp
80101c48:	ff 75 f4             	pushl  -0xc(%ebp)
80101c4b:	50                   	push   %eax
80101c4c:	e8 63 e5 ff ff       	call   801001b4 <bread>
80101c51:	83 c4 10             	add    $0x10,%esp
80101c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c5a:	83 c0 18             	add    $0x18,%eax
80101c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c6d:	01 d0                	add    %edx,%eax
80101c6f:	8b 00                	mov    (%eax),%eax
80101c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c78:	75 37                	jne    80101cb1 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c7d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c87:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	8b 00                	mov    (%eax),%eax
80101c8f:	83 ec 0c             	sub    $0xc,%esp
80101c92:	50                   	push   %eax
80101c93:	e8 3b f7 ff ff       	call   801013d3 <balloc>
80101c98:	83 c4 10             	add    $0x10,%esp
80101c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ca1:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	ff 75 f0             	pushl  -0x10(%ebp)
80101ca9:	e8 ef 19 00 00       	call   8010369d <log_write>
80101cae:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101cb1:	83 ec 0c             	sub    $0xc,%esp
80101cb4:	ff 75 f0             	pushl  -0x10(%ebp)
80101cb7:	e8 6f e5 ff ff       	call   8010022b <brelse>
80101cbc:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc2:	eb 0d                	jmp    80101cd1 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 d2 85 10 80       	push   $0x801085d2
80101ccc:	e8 8b e8 ff ff       	call   8010055c <panic>
}
80101cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101cd4:	c9                   	leave  
80101cd5:	c3                   	ret    

80101cd6 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101cd6:	55                   	push   %ebp
80101cd7:	89 e5                	mov    %esp,%ebp
80101cd9:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ce3:	eb 45                	jmp    80101d2a <itrunc+0x54>
    if(ip->addrs[i]){
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ceb:	83 c2 04             	add    $0x4,%edx
80101cee:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf2:	85 c0                	test   %eax,%eax
80101cf4:	74 30                	je     80101d26 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cfc:	83 c2 04             	add    $0x4,%edx
80101cff:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d03:	8b 55 08             	mov    0x8(%ebp),%edx
80101d06:	8b 12                	mov    (%edx),%edx
80101d08:	83 ec 08             	sub    $0x8,%esp
80101d0b:	50                   	push   %eax
80101d0c:	52                   	push   %edx
80101d0d:	e8 1f f8 ff ff       	call   80101531 <bfree>
80101d12:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d15:	8b 45 08             	mov    0x8(%ebp),%eax
80101d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1b:	83 c2 04             	add    $0x4,%edx
80101d1e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d25:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d2a:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d2e:	7e b5                	jle    80101ce5 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d36:	85 c0                	test   %eax,%eax
80101d38:	0f 84 a1 00 00 00    	je     80101ddf <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d41:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 00                	mov    (%eax),%eax
80101d49:	83 ec 08             	sub    $0x8,%esp
80101d4c:	52                   	push   %edx
80101d4d:	50                   	push   %eax
80101d4e:	e8 61 e4 ff ff       	call   801001b4 <bread>
80101d53:	83 c4 10             	add    $0x10,%esp
80101d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d5c:	83 c0 18             	add    $0x18,%eax
80101d5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d62:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d69:	eb 3c                	jmp    80101da7 <itrunc+0xd1>
      if(a[j])
80101d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d78:	01 d0                	add    %edx,%eax
80101d7a:	8b 00                	mov    (%eax),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 23                	je     80101da3 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d8d:	01 d0                	add    %edx,%eax
80101d8f:	8b 00                	mov    (%eax),%eax
80101d91:	8b 55 08             	mov    0x8(%ebp),%edx
80101d94:	8b 12                	mov    (%edx),%edx
80101d96:	83 ec 08             	sub    $0x8,%esp
80101d99:	50                   	push   %eax
80101d9a:	52                   	push   %edx
80101d9b:	e8 91 f7 ff ff       	call   80101531 <bfree>
80101da0:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101da3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101daa:	83 f8 7f             	cmp    $0x7f,%eax
80101dad:	76 bc                	jbe    80101d6b <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101daf:	83 ec 0c             	sub    $0xc,%esp
80101db2:	ff 75 ec             	pushl  -0x14(%ebp)
80101db5:	e8 71 e4 ff ff       	call   8010022b <brelse>
80101dba:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dc3:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc6:	8b 12                	mov    (%edx),%edx
80101dc8:	83 ec 08             	sub    $0x8,%esp
80101dcb:	50                   	push   %eax
80101dcc:	52                   	push   %edx
80101dcd:	e8 5f f7 ff ff       	call   80101531 <bfree>
80101dd2:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101de9:	83 ec 0c             	sub    $0xc,%esp
80101dec:	ff 75 08             	pushl  0x8(%ebp)
80101def:	e8 15 f9 ff ff       	call   80101709 <iupdate>
80101df4:	83 c4 10             	add    $0x10,%esp
}
80101df7:	c9                   	leave  
80101df8:	c3                   	ret    

80101df9 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101df9:	55                   	push   %ebp
80101dfa:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 00                	mov    (%eax),%eax
80101e01:	89 c2                	mov    %eax,%edx
80101e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e06:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	8b 50 04             	mov    0x4(%eax),%edx
80101e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e12:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e1f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e29:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e2c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 50 18             	mov    0x18(%eax),%edx
80101e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e39:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e3c:	5d                   	pop    %ebp
80101e3d:	c3                   	ret    

80101e3e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e3e:	55                   	push   %ebp
80101e3f:	89 e5                	mov    %esp,%ebp
80101e41:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e4b:	66 83 f8 03          	cmp    $0x3,%ax
80101e4f:	75 5c                	jne    80101ead <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e58:	66 85 c0             	test   %ax,%ax
80101e5b:	78 20                	js     80101e7d <readi+0x3f>
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e64:	66 83 f8 09          	cmp    $0x9,%ax
80101e68:	7f 13                	jg     80101e7d <readi+0x3f>
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e71:	98                   	cwtl   
80101e72:	8b 04 c5 40 12 11 80 	mov    -0x7feeedc0(,%eax,8),%eax
80101e79:	85 c0                	test   %eax,%eax
80101e7b:	75 0a                	jne    80101e87 <readi+0x49>
      return -1;
80101e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e82:	e9 0f 01 00 00       	jmp    80101f96 <readi+0x158>
    return devsw[ip->major].read(ip, dst, n);
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e8e:	98                   	cwtl   
80101e8f:	8b 04 c5 40 12 11 80 	mov    -0x7feeedc0(,%eax,8),%eax
80101e96:	8b 55 14             	mov    0x14(%ebp),%edx
80101e99:	83 ec 04             	sub    $0x4,%esp
80101e9c:	52                   	push   %edx
80101e9d:	ff 75 0c             	pushl  0xc(%ebp)
80101ea0:	ff 75 08             	pushl  0x8(%ebp)
80101ea3:	ff d0                	call   *%eax
80101ea5:	83 c4 10             	add    $0x10,%esp
80101ea8:	e9 e9 00 00 00       	jmp    80101f96 <readi+0x158>
  }

  if(off > ip->size || off + n < off)
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	8b 40 18             	mov    0x18(%eax),%eax
80101eb3:	3b 45 10             	cmp    0x10(%ebp),%eax
80101eb6:	72 0d                	jb     80101ec5 <readi+0x87>
80101eb8:	8b 55 10             	mov    0x10(%ebp),%edx
80101ebb:	8b 45 14             	mov    0x14(%ebp),%eax
80101ebe:	01 d0                	add    %edx,%eax
80101ec0:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ec3:	73 0a                	jae    80101ecf <readi+0x91>
    return -1;
80101ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eca:	e9 c7 00 00 00       	jmp    80101f96 <readi+0x158>
  if(off + n > ip->size)
80101ecf:	8b 55 10             	mov    0x10(%ebp),%edx
80101ed2:	8b 45 14             	mov    0x14(%ebp),%eax
80101ed5:	01 c2                	add    %eax,%edx
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	8b 40 18             	mov    0x18(%eax),%eax
80101edd:	39 c2                	cmp    %eax,%edx
80101edf:	76 0c                	jbe    80101eed <readi+0xaf>
    n = ip->size - off;
80101ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee4:	8b 40 18             	mov    0x18(%eax),%eax
80101ee7:	2b 45 10             	sub    0x10(%ebp),%eax
80101eea:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ef4:	e9 8e 00 00 00       	jmp    80101f87 <readi+0x149>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ef9:	8b 45 10             	mov    0x10(%ebp),%eax
80101efc:	c1 e8 09             	shr    $0x9,%eax
80101eff:	83 ec 08             	sub    $0x8,%esp
80101f02:	50                   	push   %eax
80101f03:	ff 75 08             	pushl  0x8(%ebp)
80101f06:	e8 ac fc ff ff       	call   80101bb7 <bmap>
80101f0b:	83 c4 10             	add    $0x10,%esp
80101f0e:	89 c2                	mov    %eax,%edx
80101f10:	8b 45 08             	mov    0x8(%ebp),%eax
80101f13:	8b 00                	mov    (%eax),%eax
80101f15:	83 ec 08             	sub    $0x8,%esp
80101f18:	52                   	push   %edx
80101f19:	50                   	push   %eax
80101f1a:	e8 95 e2 ff ff       	call   801001b4 <bread>
80101f1f:	83 c4 10             	add    $0x10,%esp
80101f22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f25:	8b 45 10             	mov    0x10(%ebp),%eax
80101f28:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f2d:	ba 00 02 00 00       	mov    $0x200,%edx
80101f32:	29 c2                	sub    %eax,%edx
80101f34:	8b 45 14             	mov    0x14(%ebp),%eax
80101f37:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f3a:	39 c2                	cmp    %eax,%edx
80101f3c:	0f 46 c2             	cmovbe %edx,%eax
80101f3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f42:	8b 45 10             	mov    0x10(%ebp),%eax
80101f45:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f4a:	8d 50 10             	lea    0x10(%eax),%edx
80101f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f50:	01 d0                	add    %edx,%eax
80101f52:	83 c0 08             	add    $0x8,%eax
80101f55:	83 ec 04             	sub    $0x4,%esp
80101f58:	ff 75 ec             	pushl  -0x14(%ebp)
80101f5b:	50                   	push   %eax
80101f5c:	ff 75 0c             	pushl  0xc(%ebp)
80101f5f:	e8 a5 32 00 00       	call   80105209 <memmove>
80101f64:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f67:	83 ec 0c             	sub    $0xc,%esp
80101f6a:	ff 75 f0             	pushl  -0x10(%ebp)
80101f6d:	e8 b9 e2 ff ff       	call   8010022b <brelse>
80101f72:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f78:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f7e:	01 45 10             	add    %eax,0x10(%ebp)
80101f81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f84:	01 45 0c             	add    %eax,0xc(%ebp)
80101f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f8a:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f8d:	0f 82 66 ff ff ff    	jb     80101ef9 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f93:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f96:	c9                   	leave  
80101f97:	c3                   	ret    

80101f98 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f98:	55                   	push   %ebp
80101f99:	89 e5                	mov    %esp,%ebp
80101f9b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fa5:	66 83 f8 03          	cmp    $0x3,%ax
80101fa9:	75 5c                	jne    80102007 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fb2:	66 85 c0             	test   %ax,%ax
80101fb5:	78 20                	js     80101fd7 <writei+0x3f>
80101fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fba:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fbe:	66 83 f8 09          	cmp    $0x9,%ax
80101fc2:	7f 13                	jg     80101fd7 <writei+0x3f>
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fcb:	98                   	cwtl   
80101fcc:	8b 04 c5 44 12 11 80 	mov    -0x7feeedbc(,%eax,8),%eax
80101fd3:	85 c0                	test   %eax,%eax
80101fd5:	75 0a                	jne    80101fe1 <writei+0x49>
      return -1;
80101fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdc:	e9 40 01 00 00       	jmp    80102121 <writei+0x189>
    return devsw[ip->major].write(ip, src, n);
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fe8:	98                   	cwtl   
80101fe9:	8b 04 c5 44 12 11 80 	mov    -0x7feeedbc(,%eax,8),%eax
80101ff0:	8b 55 14             	mov    0x14(%ebp),%edx
80101ff3:	83 ec 04             	sub    $0x4,%esp
80101ff6:	52                   	push   %edx
80101ff7:	ff 75 0c             	pushl  0xc(%ebp)
80101ffa:	ff 75 08             	pushl  0x8(%ebp)
80101ffd:	ff d0                	call   *%eax
80101fff:	83 c4 10             	add    $0x10,%esp
80102002:	e9 1a 01 00 00       	jmp    80102121 <writei+0x189>
  }

  if(off > ip->size || off + n < off)
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	8b 40 18             	mov    0x18(%eax),%eax
8010200d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102010:	72 0d                	jb     8010201f <writei+0x87>
80102012:	8b 55 10             	mov    0x10(%ebp),%edx
80102015:	8b 45 14             	mov    0x14(%ebp),%eax
80102018:	01 d0                	add    %edx,%eax
8010201a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010201d:	73 0a                	jae    80102029 <writei+0x91>
    return -1;
8010201f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102024:	e9 f8 00 00 00       	jmp    80102121 <writei+0x189>
  if(off + n > MAXFILE*BSIZE)
80102029:	8b 55 10             	mov    0x10(%ebp),%edx
8010202c:	8b 45 14             	mov    0x14(%ebp),%eax
8010202f:	01 d0                	add    %edx,%eax
80102031:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102036:	76 0a                	jbe    80102042 <writei+0xaa>
    return -1;
80102038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010203d:	e9 df 00 00 00       	jmp    80102121 <writei+0x189>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102042:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102049:	e9 9c 00 00 00       	jmp    801020ea <writei+0x152>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010204e:	8b 45 10             	mov    0x10(%ebp),%eax
80102051:	c1 e8 09             	shr    $0x9,%eax
80102054:	83 ec 08             	sub    $0x8,%esp
80102057:	50                   	push   %eax
80102058:	ff 75 08             	pushl  0x8(%ebp)
8010205b:	e8 57 fb ff ff       	call   80101bb7 <bmap>
80102060:	83 c4 10             	add    $0x10,%esp
80102063:	89 c2                	mov    %eax,%edx
80102065:	8b 45 08             	mov    0x8(%ebp),%eax
80102068:	8b 00                	mov    (%eax),%eax
8010206a:	83 ec 08             	sub    $0x8,%esp
8010206d:	52                   	push   %edx
8010206e:	50                   	push   %eax
8010206f:	e8 40 e1 ff ff       	call   801001b4 <bread>
80102074:	83 c4 10             	add    $0x10,%esp
80102077:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010207a:	8b 45 10             	mov    0x10(%ebp),%eax
8010207d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102082:	ba 00 02 00 00       	mov    $0x200,%edx
80102087:	29 c2                	sub    %eax,%edx
80102089:	8b 45 14             	mov    0x14(%ebp),%eax
8010208c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010208f:	39 c2                	cmp    %eax,%edx
80102091:	0f 46 c2             	cmovbe %edx,%eax
80102094:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102097:	8b 45 10             	mov    0x10(%ebp),%eax
8010209a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010209f:	8d 50 10             	lea    0x10(%eax),%edx
801020a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020a5:	01 d0                	add    %edx,%eax
801020a7:	83 c0 08             	add    $0x8,%eax
801020aa:	83 ec 04             	sub    $0x4,%esp
801020ad:	ff 75 ec             	pushl  -0x14(%ebp)
801020b0:	ff 75 0c             	pushl  0xc(%ebp)
801020b3:	50                   	push   %eax
801020b4:	e8 50 31 00 00       	call   80105209 <memmove>
801020b9:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020bc:	83 ec 0c             	sub    $0xc,%esp
801020bf:	ff 75 f0             	pushl  -0x10(%ebp)
801020c2:	e8 d6 15 00 00       	call   8010369d <log_write>
801020c7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ca:	83 ec 0c             	sub    $0xc,%esp
801020cd:	ff 75 f0             	pushl  -0x10(%ebp)
801020d0:	e8 56 e1 ff ff       	call   8010022b <brelse>
801020d5:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020db:	01 45 f4             	add    %eax,-0xc(%ebp)
801020de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e1:	01 45 10             	add    %eax,0x10(%ebp)
801020e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e7:	01 45 0c             	add    %eax,0xc(%ebp)
801020ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ed:	3b 45 14             	cmp    0x14(%ebp),%eax
801020f0:	0f 82 58 ff ff ff    	jb     8010204e <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020f6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020fa:	74 22                	je     8010211e <writei+0x186>
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	8b 40 18             	mov    0x18(%eax),%eax
80102102:	3b 45 10             	cmp    0x10(%ebp),%eax
80102105:	73 17                	jae    8010211e <writei+0x186>
    ip->size = off;
80102107:	8b 45 08             	mov    0x8(%ebp),%eax
8010210a:	8b 55 10             	mov    0x10(%ebp),%edx
8010210d:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102110:	83 ec 0c             	sub    $0xc,%esp
80102113:	ff 75 08             	pushl  0x8(%ebp)
80102116:	e8 ee f5 ff ff       	call   80101709 <iupdate>
8010211b:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010211e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102121:	c9                   	leave  
80102122:	c3                   	ret    

80102123 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102123:	55                   	push   %ebp
80102124:	89 e5                	mov    %esp,%ebp
80102126:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102129:	83 ec 04             	sub    $0x4,%esp
8010212c:	6a 0e                	push   $0xe
8010212e:	ff 75 0c             	pushl  0xc(%ebp)
80102131:	ff 75 08             	pushl  0x8(%ebp)
80102134:	e8 68 31 00 00       	call   801052a1 <strncmp>
80102139:	83 c4 10             	add    $0x10,%esp
}
8010213c:	c9                   	leave  
8010213d:	c3                   	ret    

8010213e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010213e:	55                   	push   %ebp
8010213f:	89 e5                	mov    %esp,%ebp
80102141:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102144:	8b 45 08             	mov    0x8(%ebp),%eax
80102147:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010214b:	66 83 f8 01          	cmp    $0x1,%ax
8010214f:	74 0d                	je     8010215e <dirlookup+0x20>
    panic("dirlookup not DIR");
80102151:	83 ec 0c             	sub    $0xc,%esp
80102154:	68 e5 85 10 80       	push   $0x801085e5
80102159:	e8 fe e3 ff ff       	call   8010055c <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010215e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102165:	eb 7c                	jmp    801021e3 <dirlookup+0xa5>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102167:	6a 10                	push   $0x10
80102169:	ff 75 f4             	pushl  -0xc(%ebp)
8010216c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010216f:	50                   	push   %eax
80102170:	ff 75 08             	pushl  0x8(%ebp)
80102173:	e8 c6 fc ff ff       	call   80101e3e <readi>
80102178:	83 c4 10             	add    $0x10,%esp
8010217b:	83 f8 10             	cmp    $0x10,%eax
8010217e:	74 0d                	je     8010218d <dirlookup+0x4f>
      panic("dirlink read");
80102180:	83 ec 0c             	sub    $0xc,%esp
80102183:	68 f7 85 10 80       	push   $0x801085f7
80102188:	e8 cf e3 ff ff       	call   8010055c <panic>
    if(de.inum == 0)
8010218d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102191:	66 85 c0             	test   %ax,%ax
80102194:	75 02                	jne    80102198 <dirlookup+0x5a>
      continue;
80102196:	eb 47                	jmp    801021df <dirlookup+0xa1>
    if(namecmp(name, de.name) == 0){
80102198:	83 ec 08             	sub    $0x8,%esp
8010219b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219e:	83 c0 02             	add    $0x2,%eax
801021a1:	50                   	push   %eax
801021a2:	ff 75 0c             	pushl  0xc(%ebp)
801021a5:	e8 79 ff ff ff       	call   80102123 <namecmp>
801021aa:	83 c4 10             	add    $0x10,%esp
801021ad:	85 c0                	test   %eax,%eax
801021af:	75 2e                	jne    801021df <dirlookup+0xa1>
      // entry matches path element
      if(poff)
801021b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021b5:	74 08                	je     801021bf <dirlookup+0x81>
        *poff = off;
801021b7:	8b 45 10             	mov    0x10(%ebp),%eax
801021ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021bd:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021bf:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c3:	0f b7 c0             	movzwl %ax,%eax
801021c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021c9:	8b 45 08             	mov    0x8(%ebp),%eax
801021cc:	8b 00                	mov    (%eax),%eax
801021ce:	83 ec 08             	sub    $0x8,%esp
801021d1:	ff 75 f0             	pushl  -0x10(%ebp)
801021d4:	50                   	push   %eax
801021d5:	e8 e9 f5 ff ff       	call   801017c3 <iget>
801021da:	83 c4 10             	add    $0x10,%esp
801021dd:	eb 18                	jmp    801021f7 <dirlookup+0xb9>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021df:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 40 18             	mov    0x18(%eax),%eax
801021e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021ec:	0f 87 75 ff ff ff    	ja     80102167 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021f7:	c9                   	leave  
801021f8:	c3                   	ret    

801021f9 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021f9:	55                   	push   %ebp
801021fa:	89 e5                	mov    %esp,%ebp
801021fc:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021ff:	83 ec 04             	sub    $0x4,%esp
80102202:	6a 00                	push   $0x0
80102204:	ff 75 0c             	pushl  0xc(%ebp)
80102207:	ff 75 08             	pushl  0x8(%ebp)
8010220a:	e8 2f ff ff ff       	call   8010213e <dirlookup>
8010220f:	83 c4 10             	add    $0x10,%esp
80102212:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102219:	74 18                	je     80102233 <dirlink+0x3a>
    iput(ip);
8010221b:	83 ec 0c             	sub    $0xc,%esp
8010221e:	ff 75 f0             	pushl  -0x10(%ebp)
80102221:	e8 7e f8 ff ff       	call   80101aa4 <iput>
80102226:	83 c4 10             	add    $0x10,%esp
    return -1;
80102229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010222e:	e9 9b 00 00 00       	jmp    801022ce <dirlink+0xd5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102233:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010223a:	eb 3b                	jmp    80102277 <dirlink+0x7e>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010223c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010223f:	6a 10                	push   $0x10
80102241:	50                   	push   %eax
80102242:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102245:	50                   	push   %eax
80102246:	ff 75 08             	pushl  0x8(%ebp)
80102249:	e8 f0 fb ff ff       	call   80101e3e <readi>
8010224e:	83 c4 10             	add    $0x10,%esp
80102251:	83 f8 10             	cmp    $0x10,%eax
80102254:	74 0d                	je     80102263 <dirlink+0x6a>
      panic("dirlink read");
80102256:	83 ec 0c             	sub    $0xc,%esp
80102259:	68 f7 85 10 80       	push   $0x801085f7
8010225e:	e8 f9 e2 ff ff       	call   8010055c <panic>
    if(de.inum == 0)
80102263:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102267:	66 85 c0             	test   %ax,%ax
8010226a:	75 02                	jne    8010226e <dirlink+0x75>
      break;
8010226c:	eb 16                	jmp    80102284 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102271:	83 c0 10             	add    $0x10,%eax
80102274:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102277:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	8b 40 18             	mov    0x18(%eax),%eax
80102280:	39 c2                	cmp    %eax,%edx
80102282:	72 b8                	jb     8010223c <dirlink+0x43>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102284:	83 ec 04             	sub    $0x4,%esp
80102287:	6a 0e                	push   $0xe
80102289:	ff 75 0c             	pushl  0xc(%ebp)
8010228c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010228f:	83 c0 02             	add    $0x2,%eax
80102292:	50                   	push   %eax
80102293:	e8 5f 30 00 00       	call   801052f7 <strncpy>
80102298:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010229b:	8b 45 10             	mov    0x10(%ebp),%eax
8010229e:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a5:	6a 10                	push   $0x10
801022a7:	50                   	push   %eax
801022a8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ab:	50                   	push   %eax
801022ac:	ff 75 08             	pushl  0x8(%ebp)
801022af:	e8 e4 fc ff ff       	call   80101f98 <writei>
801022b4:	83 c4 10             	add    $0x10,%esp
801022b7:	83 f8 10             	cmp    $0x10,%eax
801022ba:	74 0d                	je     801022c9 <dirlink+0xd0>
    panic("dirlink");
801022bc:	83 ec 0c             	sub    $0xc,%esp
801022bf:	68 04 86 10 80       	push   $0x80108604
801022c4:	e8 93 e2 ff ff       	call   8010055c <panic>
  
  return 0;
801022c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ce:	c9                   	leave  
801022cf:	c3                   	ret    

801022d0 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022d0:	55                   	push   %ebp
801022d1:	89 e5                	mov    %esp,%ebp
801022d3:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801022d6:	eb 04                	jmp    801022dc <skipelem+0xc>
    path++;
801022d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022dc:	8b 45 08             	mov    0x8(%ebp),%eax
801022df:	0f b6 00             	movzbl (%eax),%eax
801022e2:	3c 2f                	cmp    $0x2f,%al
801022e4:	74 f2                	je     801022d8 <skipelem+0x8>
    path++;
  if(*path == 0)
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	0f b6 00             	movzbl (%eax),%eax
801022ec:	84 c0                	test   %al,%al
801022ee:	75 07                	jne    801022f7 <skipelem+0x27>
    return 0;
801022f0:	b8 00 00 00 00       	mov    $0x0,%eax
801022f5:	eb 7b                	jmp    80102372 <skipelem+0xa2>
  s = path;
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
801022fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022fd:	eb 04                	jmp    80102303 <skipelem+0x33>
    path++;
801022ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	0f b6 00             	movzbl (%eax),%eax
80102309:	3c 2f                	cmp    $0x2f,%al
8010230b:	74 0a                	je     80102317 <skipelem+0x47>
8010230d:	8b 45 08             	mov    0x8(%ebp),%eax
80102310:	0f b6 00             	movzbl (%eax),%eax
80102313:	84 c0                	test   %al,%al
80102315:	75 e8                	jne    801022ff <skipelem+0x2f>
    path++;
  len = path - s;
80102317:	8b 55 08             	mov    0x8(%ebp),%edx
8010231a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231d:	29 c2                	sub    %eax,%edx
8010231f:	89 d0                	mov    %edx,%eax
80102321:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102324:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102328:	7e 15                	jle    8010233f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010232a:	83 ec 04             	sub    $0x4,%esp
8010232d:	6a 0e                	push   $0xe
8010232f:	ff 75 f4             	pushl  -0xc(%ebp)
80102332:	ff 75 0c             	pushl  0xc(%ebp)
80102335:	e8 cf 2e 00 00       	call   80105209 <memmove>
8010233a:	83 c4 10             	add    $0x10,%esp
8010233d:	eb 20                	jmp    8010235f <skipelem+0x8f>
  else {
    memmove(name, s, len);
8010233f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102342:	83 ec 04             	sub    $0x4,%esp
80102345:	50                   	push   %eax
80102346:	ff 75 f4             	pushl  -0xc(%ebp)
80102349:	ff 75 0c             	pushl  0xc(%ebp)
8010234c:	e8 b8 2e 00 00       	call   80105209 <memmove>
80102351:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102354:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102357:	8b 45 0c             	mov    0xc(%ebp),%eax
8010235a:	01 d0                	add    %edx,%eax
8010235c:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010235f:	eb 04                	jmp    80102365 <skipelem+0x95>
    path++;
80102361:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102365:	8b 45 08             	mov    0x8(%ebp),%eax
80102368:	0f b6 00             	movzbl (%eax),%eax
8010236b:	3c 2f                	cmp    $0x2f,%al
8010236d:	74 f2                	je     80102361 <skipelem+0x91>
    path++;
  return path;
8010236f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102372:	c9                   	leave  
80102373:	c3                   	ret    

80102374 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102374:	55                   	push   %ebp
80102375:	89 e5                	mov    %esp,%ebp
80102377:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	0f b6 00             	movzbl (%eax),%eax
80102380:	3c 2f                	cmp    $0x2f,%al
80102382:	75 14                	jne    80102398 <namex+0x24>
    ip = iget(ROOTDEV, ROOTINO);
80102384:	83 ec 08             	sub    $0x8,%esp
80102387:	6a 01                	push   $0x1
80102389:	6a 01                	push   $0x1
8010238b:	e8 33 f4 ff ff       	call   801017c3 <iget>
80102390:	83 c4 10             	add    $0x10,%esp
80102393:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102396:	eb 18                	jmp    801023b0 <namex+0x3c>
  else
    ip = idup(proc->cwd);
80102398:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010239e:	8b 40 68             	mov    0x68(%eax),%eax
801023a1:	83 ec 0c             	sub    $0xc,%esp
801023a4:	50                   	push   %eax
801023a5:	e8 f8 f4 ff ff       	call   801018a2 <idup>
801023aa:	83 c4 10             	add    $0x10,%esp
801023ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023b0:	e9 9e 00 00 00       	jmp    80102453 <namex+0xdf>
    ilock(ip);
801023b5:	83 ec 0c             	sub    $0xc,%esp
801023b8:	ff 75 f4             	pushl  -0xc(%ebp)
801023bb:	e8 1c f5 ff ff       	call   801018dc <ilock>
801023c0:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801023c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023ca:	66 83 f8 01          	cmp    $0x1,%ax
801023ce:	74 18                	je     801023e8 <namex+0x74>
      iunlockput(ip);
801023d0:	83 ec 0c             	sub    $0xc,%esp
801023d3:	ff 75 f4             	pushl  -0xc(%ebp)
801023d6:	e8 b8 f7 ff ff       	call   80101b93 <iunlockput>
801023db:	83 c4 10             	add    $0x10,%esp
      return 0;
801023de:	b8 00 00 00 00       	mov    $0x0,%eax
801023e3:	e9 a7 00 00 00       	jmp    8010248f <namex+0x11b>
    }
    if(nameiparent && *path == '\0'){
801023e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023ec:	74 20                	je     8010240e <namex+0x9a>
801023ee:	8b 45 08             	mov    0x8(%ebp),%eax
801023f1:	0f b6 00             	movzbl (%eax),%eax
801023f4:	84 c0                	test   %al,%al
801023f6:	75 16                	jne    8010240e <namex+0x9a>
      // Stop one level early.
      iunlock(ip);
801023f8:	83 ec 0c             	sub    $0xc,%esp
801023fb:	ff 75 f4             	pushl  -0xc(%ebp)
801023fe:	e8 30 f6 ff ff       	call   80101a33 <iunlock>
80102403:	83 c4 10             	add    $0x10,%esp
      return ip;
80102406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102409:	e9 81 00 00 00       	jmp    8010248f <namex+0x11b>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010240e:	83 ec 04             	sub    $0x4,%esp
80102411:	6a 00                	push   $0x0
80102413:	ff 75 10             	pushl  0x10(%ebp)
80102416:	ff 75 f4             	pushl  -0xc(%ebp)
80102419:	e8 20 fd ff ff       	call   8010213e <dirlookup>
8010241e:	83 c4 10             	add    $0x10,%esp
80102421:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102424:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102428:	75 15                	jne    8010243f <namex+0xcb>
      iunlockput(ip);
8010242a:	83 ec 0c             	sub    $0xc,%esp
8010242d:	ff 75 f4             	pushl  -0xc(%ebp)
80102430:	e8 5e f7 ff ff       	call   80101b93 <iunlockput>
80102435:	83 c4 10             	add    $0x10,%esp
      return 0;
80102438:	b8 00 00 00 00       	mov    $0x0,%eax
8010243d:	eb 50                	jmp    8010248f <namex+0x11b>
    }
    iunlockput(ip);
8010243f:	83 ec 0c             	sub    $0xc,%esp
80102442:	ff 75 f4             	pushl  -0xc(%ebp)
80102445:	e8 49 f7 ff ff       	call   80101b93 <iunlockput>
8010244a:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010244d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102453:	83 ec 08             	sub    $0x8,%esp
80102456:	ff 75 10             	pushl  0x10(%ebp)
80102459:	ff 75 08             	pushl  0x8(%ebp)
8010245c:	e8 6f fe ff ff       	call   801022d0 <skipelem>
80102461:	83 c4 10             	add    $0x10,%esp
80102464:	89 45 08             	mov    %eax,0x8(%ebp)
80102467:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010246b:	0f 85 44 ff ff ff    	jne    801023b5 <namex+0x41>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102471:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102475:	74 15                	je     8010248c <namex+0x118>
    iput(ip);
80102477:	83 ec 0c             	sub    $0xc,%esp
8010247a:	ff 75 f4             	pushl  -0xc(%ebp)
8010247d:	e8 22 f6 ff ff       	call   80101aa4 <iput>
80102482:	83 c4 10             	add    $0x10,%esp
    return 0;
80102485:	b8 00 00 00 00       	mov    $0x0,%eax
8010248a:	eb 03                	jmp    8010248f <namex+0x11b>
  }
  return ip;
8010248c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010248f:	c9                   	leave  
80102490:	c3                   	ret    

80102491 <namei>:

struct inode*
namei(char *path)
{
80102491:	55                   	push   %ebp
80102492:	89 e5                	mov    %esp,%ebp
80102494:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102497:	83 ec 04             	sub    $0x4,%esp
8010249a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010249d:	50                   	push   %eax
8010249e:	6a 00                	push   $0x0
801024a0:	ff 75 08             	pushl  0x8(%ebp)
801024a3:	e8 cc fe ff ff       	call   80102374 <namex>
801024a8:	83 c4 10             	add    $0x10,%esp
}
801024ab:	c9                   	leave  
801024ac:	c3                   	ret    

801024ad <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024ad:	55                   	push   %ebp
801024ae:	89 e5                	mov    %esp,%ebp
801024b0:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024b3:	83 ec 04             	sub    $0x4,%esp
801024b6:	ff 75 0c             	pushl  0xc(%ebp)
801024b9:	6a 01                	push   $0x1
801024bb:	ff 75 08             	pushl  0x8(%ebp)
801024be:	e8 b1 fe ff ff       	call   80102374 <namex>
801024c3:	83 c4 10             	add    $0x10,%esp
}
801024c6:	c9                   	leave  
801024c7:	c3                   	ret    

801024c8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 14             	sub    $0x14,%esp
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024d9:	89 c2                	mov    %eax,%edx
801024db:	ec                   	in     (%dx),%al
801024dc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024df:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024e3:	c9                   	leave  
801024e4:	c3                   	ret    

801024e5 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e5:	55                   	push   %ebp
801024e6:	89 e5                	mov    %esp,%ebp
801024e8:	57                   	push   %edi
801024e9:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024ea:	8b 55 08             	mov    0x8(%ebp),%edx
801024ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024f0:	8b 45 10             	mov    0x10(%ebp),%eax
801024f3:	89 cb                	mov    %ecx,%ebx
801024f5:	89 df                	mov    %ebx,%edi
801024f7:	89 c1                	mov    %eax,%ecx
801024f9:	fc                   	cld    
801024fa:	f3 6d                	rep insl (%dx),%es:(%edi)
801024fc:	89 c8                	mov    %ecx,%eax
801024fe:	89 fb                	mov    %edi,%ebx
80102500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102503:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102506:	5b                   	pop    %ebx
80102507:	5f                   	pop    %edi
80102508:	5d                   	pop    %ebp
80102509:	c3                   	ret    

8010250a <outb>:

static inline void
outb(ushort port, uchar data)
{
8010250a:	55                   	push   %ebp
8010250b:	89 e5                	mov    %esp,%ebp
8010250d:	83 ec 08             	sub    $0x8,%esp
80102510:	8b 55 08             	mov    0x8(%ebp),%edx
80102513:	8b 45 0c             	mov    0xc(%ebp),%eax
80102516:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010251a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102521:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102525:	ee                   	out    %al,(%dx)
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	56                   	push   %esi
8010252c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252d:	8b 55 08             	mov    0x8(%ebp),%edx
80102530:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102533:	8b 45 10             	mov    0x10(%ebp),%eax
80102536:	89 cb                	mov    %ecx,%ebx
80102538:	89 de                	mov    %ebx,%esi
8010253a:	89 c1                	mov    %eax,%ecx
8010253c:	fc                   	cld    
8010253d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010253f:	89 c8                	mov    %ecx,%eax
80102541:	89 f3                	mov    %esi,%ebx
80102543:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102546:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102549:	5b                   	pop    %ebx
8010254a:	5e                   	pop    %esi
8010254b:	5d                   	pop    %ebp
8010254c:	c3                   	ret    

8010254d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254d:	55                   	push   %ebp
8010254e:	89 e5                	mov    %esp,%ebp
80102550:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102553:	90                   	nop
80102554:	68 f7 01 00 00       	push   $0x1f7
80102559:	e8 6a ff ff ff       	call   801024c8 <inb>
8010255e:	83 c4 04             	add    $0x4,%esp
80102561:	0f b6 c0             	movzbl %al,%eax
80102564:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010256a:	25 c0 00 00 00       	and    $0xc0,%eax
8010256f:	83 f8 40             	cmp    $0x40,%eax
80102572:	75 e0                	jne    80102554 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102574:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102578:	74 11                	je     8010258b <idewait+0x3e>
8010257a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010257d:	83 e0 21             	and    $0x21,%eax
80102580:	85 c0                	test   %eax,%eax
80102582:	74 07                	je     8010258b <idewait+0x3e>
    return -1;
80102584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102589:	eb 05                	jmp    80102590 <idewait+0x43>
  return 0;
8010258b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102590:	c9                   	leave  
80102591:	c3                   	ret    

80102592 <ideinit>:

void
ideinit(void)
{
80102592:	55                   	push   %ebp
80102593:	89 e5                	mov    %esp,%ebp
80102595:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102598:	83 ec 08             	sub    $0x8,%esp
8010259b:	68 0c 86 10 80       	push   $0x8010860c
801025a0:	68 20 b6 10 80       	push   $0x8010b620
801025a5:	e8 23 29 00 00       	call   80104ecd <initlock>
801025aa:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025ad:	83 ec 0c             	sub    $0xc,%esp
801025b0:	6a 0e                	push   $0xe
801025b2:	e8 68 18 00 00       	call   80103e1f <picenable>
801025b7:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025ba:	a1 20 2a 11 80       	mov    0x80112a20,%eax
801025bf:	83 e8 01             	sub    $0x1,%eax
801025c2:	83 ec 08             	sub    $0x8,%esp
801025c5:	50                   	push   %eax
801025c6:	6a 0e                	push   $0xe
801025c8:	e8 31 04 00 00       	call   801029fe <ioapicenable>
801025cd:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801025d0:	83 ec 0c             	sub    $0xc,%esp
801025d3:	6a 00                	push   $0x0
801025d5:	e8 73 ff ff ff       	call   8010254d <idewait>
801025da:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025dd:	83 ec 08             	sub    $0x8,%esp
801025e0:	68 f0 00 00 00       	push   $0xf0
801025e5:	68 f6 01 00 00       	push   $0x1f6
801025ea:	e8 1b ff ff ff       	call   8010250a <outb>
801025ef:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801025f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f9:	eb 24                	jmp    8010261f <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801025fb:	83 ec 0c             	sub    $0xc,%esp
801025fe:	68 f7 01 00 00       	push   $0x1f7
80102603:	e8 c0 fe ff ff       	call   801024c8 <inb>
80102608:	83 c4 10             	add    $0x10,%esp
8010260b:	84 c0                	test   %al,%al
8010260d:	74 0c                	je     8010261b <ideinit+0x89>
      havedisk1 = 1;
8010260f:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
80102616:	00 00 00 
      break;
80102619:	eb 0d                	jmp    80102628 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010261b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010261f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102626:	7e d3                	jle    801025fb <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102628:	83 ec 08             	sub    $0x8,%esp
8010262b:	68 e0 00 00 00       	push   $0xe0
80102630:	68 f6 01 00 00       	push   $0x1f6
80102635:	e8 d0 fe ff ff       	call   8010250a <outb>
8010263a:	83 c4 10             	add    $0x10,%esp
}
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    

8010263f <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010263f:	55                   	push   %ebp
80102640:	89 e5                	mov    %esp,%ebp
80102642:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
80102645:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102649:	75 0d                	jne    80102658 <idestart+0x19>
    panic("idestart");
8010264b:	83 ec 0c             	sub    $0xc,%esp
8010264e:	68 10 86 10 80       	push   $0x80108610
80102653:	e8 04 df ff ff       	call   8010055c <panic>

  idewait(0);
80102658:	83 ec 0c             	sub    $0xc,%esp
8010265b:	6a 00                	push   $0x0
8010265d:	e8 eb fe ff ff       	call   8010254d <idewait>
80102662:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102665:	83 ec 08             	sub    $0x8,%esp
80102668:	6a 00                	push   $0x0
8010266a:	68 f6 03 00 00       	push   $0x3f6
8010266f:	e8 96 fe ff ff       	call   8010250a <outb>
80102674:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
80102677:	83 ec 08             	sub    $0x8,%esp
8010267a:	6a 01                	push   $0x1
8010267c:	68 f2 01 00 00       	push   $0x1f2
80102681:	e8 84 fe ff ff       	call   8010250a <outb>
80102686:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
80102689:	8b 45 08             	mov    0x8(%ebp),%eax
8010268c:	8b 40 08             	mov    0x8(%eax),%eax
8010268f:	0f b6 c0             	movzbl %al,%eax
80102692:	83 ec 08             	sub    $0x8,%esp
80102695:	50                   	push   %eax
80102696:	68 f3 01 00 00       	push   $0x1f3
8010269b:	e8 6a fe ff ff       	call   8010250a <outb>
801026a0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026a3:	8b 45 08             	mov    0x8(%ebp),%eax
801026a6:	8b 40 08             	mov    0x8(%eax),%eax
801026a9:	c1 e8 08             	shr    $0x8,%eax
801026ac:	0f b6 c0             	movzbl %al,%eax
801026af:	83 ec 08             	sub    $0x8,%esp
801026b2:	50                   	push   %eax
801026b3:	68 f4 01 00 00       	push   $0x1f4
801026b8:	e8 4d fe ff ff       	call   8010250a <outb>
801026bd:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026c0:	8b 45 08             	mov    0x8(%ebp),%eax
801026c3:	8b 40 08             	mov    0x8(%eax),%eax
801026c6:	c1 e8 10             	shr    $0x10,%eax
801026c9:	0f b6 c0             	movzbl %al,%eax
801026cc:	83 ec 08             	sub    $0x8,%esp
801026cf:	50                   	push   %eax
801026d0:	68 f5 01 00 00       	push   $0x1f5
801026d5:	e8 30 fe ff ff       	call   8010250a <outb>
801026da:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026dd:	8b 45 08             	mov    0x8(%ebp),%eax
801026e0:	8b 40 04             	mov    0x4(%eax),%eax
801026e3:	83 e0 01             	and    $0x1,%eax
801026e6:	c1 e0 04             	shl    $0x4,%eax
801026e9:	89 c2                	mov    %eax,%edx
801026eb:	8b 45 08             	mov    0x8(%ebp),%eax
801026ee:	8b 40 08             	mov    0x8(%eax),%eax
801026f1:	c1 e8 18             	shr    $0x18,%eax
801026f4:	83 e0 0f             	and    $0xf,%eax
801026f7:	09 d0                	or     %edx,%eax
801026f9:	83 c8 e0             	or     $0xffffffe0,%eax
801026fc:	0f b6 c0             	movzbl %al,%eax
801026ff:	83 ec 08             	sub    $0x8,%esp
80102702:	50                   	push   %eax
80102703:	68 f6 01 00 00       	push   $0x1f6
80102708:	e8 fd fd ff ff       	call   8010250a <outb>
8010270d:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102710:	8b 45 08             	mov    0x8(%ebp),%eax
80102713:	8b 00                	mov    (%eax),%eax
80102715:	83 e0 04             	and    $0x4,%eax
80102718:	85 c0                	test   %eax,%eax
8010271a:	74 30                	je     8010274c <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
8010271c:	83 ec 08             	sub    $0x8,%esp
8010271f:	6a 30                	push   $0x30
80102721:	68 f7 01 00 00       	push   $0x1f7
80102726:	e8 df fd ff ff       	call   8010250a <outb>
8010272b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
8010272e:	8b 45 08             	mov    0x8(%ebp),%eax
80102731:	83 c0 18             	add    $0x18,%eax
80102734:	83 ec 04             	sub    $0x4,%esp
80102737:	68 80 00 00 00       	push   $0x80
8010273c:	50                   	push   %eax
8010273d:	68 f0 01 00 00       	push   $0x1f0
80102742:	e8 e1 fd ff ff       	call   80102528 <outsl>
80102747:	83 c4 10             	add    $0x10,%esp
8010274a:	eb 12                	jmp    8010275e <idestart+0x11f>
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010274c:	83 ec 08             	sub    $0x8,%esp
8010274f:	6a 20                	push   $0x20
80102751:	68 f7 01 00 00       	push   $0x1f7
80102756:	e8 af fd ff ff       	call   8010250a <outb>
8010275b:	83 c4 10             	add    $0x10,%esp
  }
}
8010275e:	c9                   	leave  
8010275f:	c3                   	ret    

80102760 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102760:	55                   	push   %ebp
80102761:	89 e5                	mov    %esp,%ebp
80102763:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102766:	83 ec 0c             	sub    $0xc,%esp
80102769:	68 20 b6 10 80       	push   $0x8010b620
8010276e:	e8 7b 27 00 00       	call   80104eee <acquire>
80102773:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102776:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010277b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010277e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102782:	75 15                	jne    80102799 <ideintr+0x39>
    release(&idelock);
80102784:	83 ec 0c             	sub    $0xc,%esp
80102787:	68 20 b6 10 80       	push   $0x8010b620
8010278c:	e8 c3 27 00 00       	call   80104f54 <release>
80102791:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102794:	e9 9a 00 00 00       	jmp    80102833 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279c:	8b 40 14             	mov    0x14(%eax),%eax
8010279f:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a7:	8b 00                	mov    (%eax),%eax
801027a9:	83 e0 04             	and    $0x4,%eax
801027ac:	85 c0                	test   %eax,%eax
801027ae:	75 2d                	jne    801027dd <ideintr+0x7d>
801027b0:	83 ec 0c             	sub    $0xc,%esp
801027b3:	6a 01                	push   $0x1
801027b5:	e8 93 fd ff ff       	call   8010254d <idewait>
801027ba:	83 c4 10             	add    $0x10,%esp
801027bd:	85 c0                	test   %eax,%eax
801027bf:	78 1c                	js     801027dd <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801027c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c4:	83 c0 18             	add    $0x18,%eax
801027c7:	83 ec 04             	sub    $0x4,%esp
801027ca:	68 80 00 00 00       	push   $0x80
801027cf:	50                   	push   %eax
801027d0:	68 f0 01 00 00       	push   $0x1f0
801027d5:	e8 0b fd ff ff       	call   801024e5 <insl>
801027da:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e0:	8b 00                	mov    (%eax),%eax
801027e2:	83 c8 02             	or     $0x2,%eax
801027e5:	89 c2                	mov    %eax,%edx
801027e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ea:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ef:	8b 00                	mov    (%eax),%eax
801027f1:	83 e0 fb             	and    $0xfffffffb,%eax
801027f4:	89 c2                	mov    %eax,%edx
801027f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f9:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027fb:	83 ec 0c             	sub    $0xc,%esp
801027fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102801:	e8 db 24 00 00       	call   80104ce1 <wakeup>
80102806:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102809:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010280e:	85 c0                	test   %eax,%eax
80102810:	74 11                	je     80102823 <ideintr+0xc3>
    idestart(idequeue);
80102812:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102817:	83 ec 0c             	sub    $0xc,%esp
8010281a:	50                   	push   %eax
8010281b:	e8 1f fe ff ff       	call   8010263f <idestart>
80102820:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102823:	83 ec 0c             	sub    $0xc,%esp
80102826:	68 20 b6 10 80       	push   $0x8010b620
8010282b:	e8 24 27 00 00       	call   80104f54 <release>
80102830:	83 c4 10             	add    $0x10,%esp
}
80102833:	c9                   	leave  
80102834:	c3                   	ret    

80102835 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102835:	55                   	push   %ebp
80102836:	89 e5                	mov    %esp,%ebp
80102838:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
8010283b:	8b 45 08             	mov    0x8(%ebp),%eax
8010283e:	8b 00                	mov    (%eax),%eax
80102840:	83 e0 01             	and    $0x1,%eax
80102843:	85 c0                	test   %eax,%eax
80102845:	75 0d                	jne    80102854 <iderw+0x1f>
    panic("iderw: buf not busy");
80102847:	83 ec 0c             	sub    $0xc,%esp
8010284a:	68 19 86 10 80       	push   $0x80108619
8010284f:	e8 08 dd ff ff       	call   8010055c <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102854:	8b 45 08             	mov    0x8(%ebp),%eax
80102857:	8b 00                	mov    (%eax),%eax
80102859:	83 e0 06             	and    $0x6,%eax
8010285c:	83 f8 02             	cmp    $0x2,%eax
8010285f:	75 0d                	jne    8010286e <iderw+0x39>
    panic("iderw: nothing to do");
80102861:	83 ec 0c             	sub    $0xc,%esp
80102864:	68 2d 86 10 80       	push   $0x8010862d
80102869:	e8 ee dc ff ff       	call   8010055c <panic>
  if(b->dev != 0 && !havedisk1)
8010286e:	8b 45 08             	mov    0x8(%ebp),%eax
80102871:	8b 40 04             	mov    0x4(%eax),%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 16                	je     8010288e <iderw+0x59>
80102878:	a1 58 b6 10 80       	mov    0x8010b658,%eax
8010287d:	85 c0                	test   %eax,%eax
8010287f:	75 0d                	jne    8010288e <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102881:	83 ec 0c             	sub    $0xc,%esp
80102884:	68 42 86 10 80       	push   $0x80108642
80102889:	e8 ce dc ff ff       	call   8010055c <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 20 b6 10 80       	push   $0x8010b620
80102896:	e8 53 26 00 00       	call   80104eee <acquire>
8010289b:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010289e:	8b 45 08             	mov    0x8(%ebp),%eax
801028a1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028a8:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801028af:	eb 0b                	jmp    801028bc <iderw+0x87>
801028b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b4:	8b 00                	mov    (%eax),%eax
801028b6:	83 c0 14             	add    $0x14,%eax
801028b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bf:	8b 00                	mov    (%eax),%eax
801028c1:	85 c0                	test   %eax,%eax
801028c3:	75 ec                	jne    801028b1 <iderw+0x7c>
    ;
  *pp = b;
801028c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c8:	8b 55 08             	mov    0x8(%ebp),%edx
801028cb:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028cd:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801028d5:	75 0e                	jne    801028e5 <iderw+0xb0>
    idestart(b);
801028d7:	83 ec 0c             	sub    $0xc,%esp
801028da:	ff 75 08             	pushl  0x8(%ebp)
801028dd:	e8 5d fd ff ff       	call   8010263f <idestart>
801028e2:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028e5:	eb 13                	jmp    801028fa <iderw+0xc5>
    sleep(b, &idelock);
801028e7:	83 ec 08             	sub    $0x8,%esp
801028ea:	68 20 b6 10 80       	push   $0x8010b620
801028ef:	ff 75 08             	pushl  0x8(%ebp)
801028f2:	e8 fe 22 00 00       	call   80104bf5 <sleep>
801028f7:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028fa:	8b 45 08             	mov    0x8(%ebp),%eax
801028fd:	8b 00                	mov    (%eax),%eax
801028ff:	83 e0 06             	and    $0x6,%eax
80102902:	83 f8 02             	cmp    $0x2,%eax
80102905:	75 e0                	jne    801028e7 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102907:	83 ec 0c             	sub    $0xc,%esp
8010290a:	68 20 b6 10 80       	push   $0x8010b620
8010290f:	e8 40 26 00 00       	call   80104f54 <release>
80102914:	83 c4 10             	add    $0x10,%esp
}
80102917:	c9                   	leave  
80102918:	c3                   	ret    

80102919 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102919:	55                   	push   %ebp
8010291a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010291c:	a1 94 22 11 80       	mov    0x80112294,%eax
80102921:	8b 55 08             	mov    0x8(%ebp),%edx
80102924:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102926:	a1 94 22 11 80       	mov    0x80112294,%eax
8010292b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010292e:	5d                   	pop    %ebp
8010292f:	c3                   	ret    

80102930 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102930:	55                   	push   %ebp
80102931:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102933:	a1 94 22 11 80       	mov    0x80112294,%eax
80102938:	8b 55 08             	mov    0x8(%ebp),%edx
8010293b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010293d:	a1 94 22 11 80       	mov    0x80112294,%eax
80102942:	8b 55 0c             	mov    0xc(%ebp),%edx
80102945:	89 50 10             	mov    %edx,0x10(%eax)
}
80102948:	5d                   	pop    %ebp
80102949:	c3                   	ret    

8010294a <ioapicinit>:

void
ioapicinit(void)
{
8010294a:	55                   	push   %ebp
8010294b:	89 e5                	mov    %esp,%ebp
8010294d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102950:	a1 04 24 11 80       	mov    0x80112404,%eax
80102955:	85 c0                	test   %eax,%eax
80102957:	75 05                	jne    8010295e <ioapicinit+0x14>
    return;
80102959:	e9 9e 00 00 00       	jmp    801029fc <ioapicinit+0xb2>

  ioapic = (volatile struct ioapic*)IOAPIC;
8010295e:	c7 05 94 22 11 80 00 	movl   $0xfec00000,0x80112294
80102965:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102968:	6a 01                	push   $0x1
8010296a:	e8 aa ff ff ff       	call   80102919 <ioapicread>
8010296f:	83 c4 04             	add    $0x4,%esp
80102972:	c1 e8 10             	shr    $0x10,%eax
80102975:	25 ff 00 00 00       	and    $0xff,%eax
8010297a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010297d:	6a 00                	push   $0x0
8010297f:	e8 95 ff ff ff       	call   80102919 <ioapicread>
80102984:	83 c4 04             	add    $0x4,%esp
80102987:	c1 e8 18             	shr    $0x18,%eax
8010298a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010298d:	0f b6 05 00 24 11 80 	movzbl 0x80112400,%eax
80102994:	0f b6 c0             	movzbl %al,%eax
80102997:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010299a:	74 10                	je     801029ac <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010299c:	83 ec 0c             	sub    $0xc,%esp
8010299f:	68 60 86 10 80       	push   $0x80108660
801029a4:	e8 16 da ff ff       	call   801003bf <cprintf>
801029a9:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029b3:	eb 3f                	jmp    801029f4 <ioapicinit+0xaa>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b8:	83 c0 20             	add    $0x20,%eax
801029bb:	0d 00 00 01 00       	or     $0x10000,%eax
801029c0:	89 c2                	mov    %eax,%edx
801029c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c5:	83 c0 08             	add    $0x8,%eax
801029c8:	01 c0                	add    %eax,%eax
801029ca:	83 ec 08             	sub    $0x8,%esp
801029cd:	52                   	push   %edx
801029ce:	50                   	push   %eax
801029cf:	e8 5c ff ff ff       	call   80102930 <ioapicwrite>
801029d4:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029da:	83 c0 08             	add    $0x8,%eax
801029dd:	01 c0                	add    %eax,%eax
801029df:	83 c0 01             	add    $0x1,%eax
801029e2:	83 ec 08             	sub    $0x8,%esp
801029e5:	6a 00                	push   $0x0
801029e7:	50                   	push   %eax
801029e8:	e8 43 ff ff ff       	call   80102930 <ioapicwrite>
801029ed:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801029f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029fa:	7e b9                	jle    801029b5 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029fc:	c9                   	leave  
801029fd:	c3                   	ret    

801029fe <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029fe:	55                   	push   %ebp
801029ff:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a01:	a1 04 24 11 80       	mov    0x80112404,%eax
80102a06:	85 c0                	test   %eax,%eax
80102a08:	75 02                	jne    80102a0c <ioapicenable+0xe>
    return;
80102a0a:	eb 37                	jmp    80102a43 <ioapicenable+0x45>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0f:	83 c0 20             	add    $0x20,%eax
80102a12:	89 c2                	mov    %eax,%edx
80102a14:	8b 45 08             	mov    0x8(%ebp),%eax
80102a17:	83 c0 08             	add    $0x8,%eax
80102a1a:	01 c0                	add    %eax,%eax
80102a1c:	52                   	push   %edx
80102a1d:	50                   	push   %eax
80102a1e:	e8 0d ff ff ff       	call   80102930 <ioapicwrite>
80102a23:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a26:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a29:	c1 e0 18             	shl    $0x18,%eax
80102a2c:	89 c2                	mov    %eax,%edx
80102a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a31:	83 c0 08             	add    $0x8,%eax
80102a34:	01 c0                	add    %eax,%eax
80102a36:	83 c0 01             	add    $0x1,%eax
80102a39:	52                   	push   %edx
80102a3a:	50                   	push   %eax
80102a3b:	e8 f0 fe ff ff       	call   80102930 <ioapicwrite>
80102a40:	83 c4 08             	add    $0x8,%esp
}
80102a43:	c9                   	leave  
80102a44:	c3                   	ret    

80102a45 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a45:	55                   	push   %ebp
80102a46:	89 e5                	mov    %esp,%ebp
80102a48:	8b 45 08             	mov    0x8(%ebp),%eax
80102a4b:	05 00 00 00 80       	add    $0x80000000,%eax
80102a50:	5d                   	pop    %ebp
80102a51:	c3                   	ret    

80102a52 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a52:	55                   	push   %ebp
80102a53:	89 e5                	mov    %esp,%ebp
80102a55:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102a58:	83 ec 08             	sub    $0x8,%esp
80102a5b:	68 92 86 10 80       	push   $0x80108692
80102a60:	68 a0 22 11 80       	push   $0x801122a0
80102a65:	e8 63 24 00 00       	call   80104ecd <initlock>
80102a6a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102a6d:	c7 05 d4 22 11 80 00 	movl   $0x0,0x801122d4
80102a74:	00 00 00 
  freerange(vstart, vend);
80102a77:	83 ec 08             	sub    $0x8,%esp
80102a7a:	ff 75 0c             	pushl  0xc(%ebp)
80102a7d:	ff 75 08             	pushl  0x8(%ebp)
80102a80:	e8 28 00 00 00       	call   80102aad <freerange>
80102a85:	83 c4 10             	add    $0x10,%esp
}
80102a88:	c9                   	leave  
80102a89:	c3                   	ret    

80102a8a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a8a:	55                   	push   %ebp
80102a8b:	89 e5                	mov    %esp,%ebp
80102a8d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102a90:	83 ec 08             	sub    $0x8,%esp
80102a93:	ff 75 0c             	pushl  0xc(%ebp)
80102a96:	ff 75 08             	pushl  0x8(%ebp)
80102a99:	e8 0f 00 00 00       	call   80102aad <freerange>
80102a9e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102aa1:	c7 05 d4 22 11 80 01 	movl   $0x1,0x801122d4
80102aa8:	00 00 00 
}
80102aab:	c9                   	leave  
80102aac:	c3                   	ret    

80102aad <freerange>:

void
freerange(void *vstart, void *vend)
{
80102aad:	55                   	push   %ebp
80102aae:	89 e5                	mov    %esp,%ebp
80102ab0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab6:	05 ff 0f 00 00       	add    $0xfff,%eax
80102abb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ac3:	eb 15                	jmp    80102ada <freerange+0x2d>
    kfree(p);
80102ac5:	83 ec 0c             	sub    $0xc,%esp
80102ac8:	ff 75 f4             	pushl  -0xc(%ebp)
80102acb:	e8 19 00 00 00       	call   80102ae9 <kfree>
80102ad0:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ad3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	05 00 10 00 00       	add    $0x1000,%eax
80102ae2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ae5:	76 de                	jbe    80102ac5 <freerange+0x18>
    kfree(p);
}
80102ae7:	c9                   	leave  
80102ae8:	c3                   	ret    

80102ae9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102ae9:	55                   	push   %ebp
80102aea:	89 e5                	mov    %esp,%ebp
80102aec:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102aef:	8b 45 08             	mov    0x8(%ebp),%eax
80102af2:	25 ff 0f 00 00       	and    $0xfff,%eax
80102af7:	85 c0                	test   %eax,%eax
80102af9:	75 1b                	jne    80102b16 <kfree+0x2d>
80102afb:	81 7d 08 1c 54 11 80 	cmpl   $0x8011541c,0x8(%ebp)
80102b02:	72 12                	jb     80102b16 <kfree+0x2d>
80102b04:	ff 75 08             	pushl  0x8(%ebp)
80102b07:	e8 39 ff ff ff       	call   80102a45 <v2p>
80102b0c:	83 c4 04             	add    $0x4,%esp
80102b0f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b14:	76 0d                	jbe    80102b23 <kfree+0x3a>
    panic("kfree");
80102b16:	83 ec 0c             	sub    $0xc,%esp
80102b19:	68 97 86 10 80       	push   $0x80108697
80102b1e:	e8 39 da ff ff       	call   8010055c <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b23:	83 ec 04             	sub    $0x4,%esp
80102b26:	68 00 10 00 00       	push   $0x1000
80102b2b:	6a 01                	push   $0x1
80102b2d:	ff 75 08             	pushl  0x8(%ebp)
80102b30:	e8 15 26 00 00       	call   8010514a <memset>
80102b35:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b38:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102b3d:	85 c0                	test   %eax,%eax
80102b3f:	74 10                	je     80102b51 <kfree+0x68>
    acquire(&kmem.lock);
80102b41:	83 ec 0c             	sub    $0xc,%esp
80102b44:	68 a0 22 11 80       	push   $0x801122a0
80102b49:	e8 a0 23 00 00       	call   80104eee <acquire>
80102b4e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b51:	8b 45 08             	mov    0x8(%ebp),%eax
80102b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b57:	8b 15 d8 22 11 80    	mov    0x801122d8,%edx
80102b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b60:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b65:	a3 d8 22 11 80       	mov    %eax,0x801122d8
  if(kmem.use_lock)
80102b6a:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102b6f:	85 c0                	test   %eax,%eax
80102b71:	74 10                	je     80102b83 <kfree+0x9a>
    release(&kmem.lock);
80102b73:	83 ec 0c             	sub    $0xc,%esp
80102b76:	68 a0 22 11 80       	push   $0x801122a0
80102b7b:	e8 d4 23 00 00       	call   80104f54 <release>
80102b80:	83 c4 10             	add    $0x10,%esp
}
80102b83:	c9                   	leave  
80102b84:	c3                   	ret    

80102b85 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b85:	55                   	push   %ebp
80102b86:	89 e5                	mov    %esp,%ebp
80102b88:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102b8b:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102b90:	85 c0                	test   %eax,%eax
80102b92:	74 10                	je     80102ba4 <kalloc+0x1f>
    acquire(&kmem.lock);
80102b94:	83 ec 0c             	sub    $0xc,%esp
80102b97:	68 a0 22 11 80       	push   $0x801122a0
80102b9c:	e8 4d 23 00 00       	call   80104eee <acquire>
80102ba1:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ba4:	a1 d8 22 11 80       	mov    0x801122d8,%eax
80102ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bb0:	74 0a                	je     80102bbc <kalloc+0x37>
    kmem.freelist = r->next;
80102bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb5:	8b 00                	mov    (%eax),%eax
80102bb7:	a3 d8 22 11 80       	mov    %eax,0x801122d8
  if(kmem.use_lock)
80102bbc:	a1 d4 22 11 80       	mov    0x801122d4,%eax
80102bc1:	85 c0                	test   %eax,%eax
80102bc3:	74 10                	je     80102bd5 <kalloc+0x50>
    release(&kmem.lock);
80102bc5:	83 ec 0c             	sub    $0xc,%esp
80102bc8:	68 a0 22 11 80       	push   $0x801122a0
80102bcd:	e8 82 23 00 00       	call   80104f54 <release>
80102bd2:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bd8:	c9                   	leave  
80102bd9:	c3                   	ret    

80102bda <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bda:	55                   	push   %ebp
80102bdb:	89 e5                	mov    %esp,%ebp
80102bdd:	83 ec 14             	sub    $0x14,%esp
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102be7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102beb:	89 c2                	mov    %eax,%edx
80102bed:	ec                   	in     (%dx),%al
80102bee:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102bf1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102bf5:	c9                   	leave  
80102bf6:	c3                   	ret    

80102bf7 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bf7:	55                   	push   %ebp
80102bf8:	89 e5                	mov    %esp,%ebp
80102bfa:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bfd:	6a 64                	push   $0x64
80102bff:	e8 d6 ff ff ff       	call   80102bda <inb>
80102c04:	83 c4 04             	add    $0x4,%esp
80102c07:	0f b6 c0             	movzbl %al,%eax
80102c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c10:	83 e0 01             	and    $0x1,%eax
80102c13:	85 c0                	test   %eax,%eax
80102c15:	75 0a                	jne    80102c21 <kbdgetc+0x2a>
    return -1;
80102c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c1c:	e9 23 01 00 00       	jmp    80102d44 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c21:	6a 60                	push   $0x60
80102c23:	e8 b2 ff ff ff       	call   80102bda <inb>
80102c28:	83 c4 04             	add    $0x4,%esp
80102c2b:	0f b6 c0             	movzbl %al,%eax
80102c2e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c31:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c38:	75 17                	jne    80102c51 <kbdgetc+0x5a>
    shift |= E0ESC;
80102c3a:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c3f:	83 c8 40             	or     $0x40,%eax
80102c42:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c47:	b8 00 00 00 00       	mov    $0x0,%eax
80102c4c:	e9 f3 00 00 00       	jmp    80102d44 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c54:	25 80 00 00 00       	and    $0x80,%eax
80102c59:	85 c0                	test   %eax,%eax
80102c5b:	74 45                	je     80102ca2 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c5d:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c62:	83 e0 40             	and    $0x40,%eax
80102c65:	85 c0                	test   %eax,%eax
80102c67:	75 08                	jne    80102c71 <kbdgetc+0x7a>
80102c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6c:	83 e0 7f             	and    $0x7f,%eax
80102c6f:	eb 03                	jmp    80102c74 <kbdgetc+0x7d>
80102c71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c74:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c7a:	05 40 90 10 80       	add    $0x80109040,%eax
80102c7f:	0f b6 00             	movzbl (%eax),%eax
80102c82:	83 c8 40             	or     $0x40,%eax
80102c85:	0f b6 c0             	movzbl %al,%eax
80102c88:	f7 d0                	not    %eax
80102c8a:	89 c2                	mov    %eax,%edx
80102c8c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c91:	21 d0                	and    %edx,%eax
80102c93:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c98:	b8 00 00 00 00       	mov    $0x0,%eax
80102c9d:	e9 a2 00 00 00       	jmp    80102d44 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102ca2:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102ca7:	83 e0 40             	and    $0x40,%eax
80102caa:	85 c0                	test   %eax,%eax
80102cac:	74 14                	je     80102cc2 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cae:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cb5:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cba:	83 e0 bf             	and    $0xffffffbf,%eax
80102cbd:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102cc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc5:	05 40 90 10 80       	add    $0x80109040,%eax
80102cca:	0f b6 00             	movzbl (%eax),%eax
80102ccd:	0f b6 d0             	movzbl %al,%edx
80102cd0:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cd5:	09 d0                	or     %edx,%eax
80102cd7:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cdf:	05 40 91 10 80       	add    $0x80109140,%eax
80102ce4:	0f b6 00             	movzbl (%eax),%eax
80102ce7:	0f b6 d0             	movzbl %al,%edx
80102cea:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cef:	31 d0                	xor    %edx,%eax
80102cf1:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102cf6:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cfb:	83 e0 03             	and    $0x3,%eax
80102cfe:	8b 14 85 40 95 10 80 	mov    -0x7fef6ac0(,%eax,4),%edx
80102d05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d08:	01 d0                	add    %edx,%eax
80102d0a:	0f b6 00             	movzbl (%eax),%eax
80102d0d:	0f b6 c0             	movzbl %al,%eax
80102d10:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d13:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d18:	83 e0 08             	and    $0x8,%eax
80102d1b:	85 c0                	test   %eax,%eax
80102d1d:	74 22                	je     80102d41 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d1f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d23:	76 0c                	jbe    80102d31 <kbdgetc+0x13a>
80102d25:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d29:	77 06                	ja     80102d31 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d2b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d2f:	eb 10                	jmp    80102d41 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d31:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d35:	76 0a                	jbe    80102d41 <kbdgetc+0x14a>
80102d37:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d3b:	77 04                	ja     80102d41 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d3d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d41:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d44:	c9                   	leave  
80102d45:	c3                   	ret    

80102d46 <kbdintr>:

void
kbdintr(void)
{
80102d46:	55                   	push   %ebp
80102d47:	89 e5                	mov    %esp,%ebp
80102d49:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d4c:	83 ec 0c             	sub    $0xc,%esp
80102d4f:	68 f7 2b 10 80       	push   $0x80102bf7
80102d54:	e8 78 da ff ff       	call   801007d1 <consoleintr>
80102d59:	83 c4 10             	add    $0x10,%esp
}
80102d5c:	c9                   	leave  
80102d5d:	c3                   	ret    

80102d5e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d5e:	55                   	push   %ebp
80102d5f:	89 e5                	mov    %esp,%ebp
80102d61:	83 ec 14             	sub    $0x14,%esp
80102d64:	8b 45 08             	mov    0x8(%ebp),%eax
80102d67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d6f:	89 c2                	mov    %eax,%edx
80102d71:	ec                   	in     (%dx),%al
80102d72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d79:	c9                   	leave  
80102d7a:	c3                   	ret    

80102d7b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d7b:	55                   	push   %ebp
80102d7c:	89 e5                	mov    %esp,%ebp
80102d7e:	83 ec 08             	sub    $0x8,%esp
80102d81:	8b 55 08             	mov    0x8(%ebp),%edx
80102d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d87:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d8b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d8e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d92:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d96:	ee                   	out    %al,(%dx)
}
80102d97:	c9                   	leave  
80102d98:	c3                   	ret    

80102d99 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d99:	55                   	push   %ebp
80102d9a:	89 e5                	mov    %esp,%ebp
80102d9c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d9f:	9c                   	pushf  
80102da0:	58                   	pop    %eax
80102da1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102da4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102da7:	c9                   	leave  
80102da8:	c3                   	ret    

80102da9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102da9:	55                   	push   %ebp
80102daa:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dac:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102db1:	8b 55 08             	mov    0x8(%ebp),%edx
80102db4:	c1 e2 02             	shl    $0x2,%edx
80102db7:	01 c2                	add    %eax,%edx
80102db9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dbc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dbe:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102dc3:	83 c0 20             	add    $0x20,%eax
80102dc6:	8b 00                	mov    (%eax),%eax
}
80102dc8:	5d                   	pop    %ebp
80102dc9:	c3                   	ret    

80102dca <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102dca:	55                   	push   %ebp
80102dcb:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102dcd:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102dd2:	85 c0                	test   %eax,%eax
80102dd4:	75 05                	jne    80102ddb <lapicinit+0x11>
    return;
80102dd6:	e9 09 01 00 00       	jmp    80102ee4 <lapicinit+0x11a>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ddb:	68 3f 01 00 00       	push   $0x13f
80102de0:	6a 3c                	push   $0x3c
80102de2:	e8 c2 ff ff ff       	call   80102da9 <lapicw>
80102de7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dea:	6a 0b                	push   $0xb
80102dec:	68 f8 00 00 00       	push   $0xf8
80102df1:	e8 b3 ff ff ff       	call   80102da9 <lapicw>
80102df6:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102df9:	68 20 00 02 00       	push   $0x20020
80102dfe:	68 c8 00 00 00       	push   $0xc8
80102e03:	e8 a1 ff ff ff       	call   80102da9 <lapicw>
80102e08:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e0b:	68 80 96 98 00       	push   $0x989680
80102e10:	68 e0 00 00 00       	push   $0xe0
80102e15:	e8 8f ff ff ff       	call   80102da9 <lapicw>
80102e1a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e1d:	68 00 00 01 00       	push   $0x10000
80102e22:	68 d4 00 00 00       	push   $0xd4
80102e27:	e8 7d ff ff ff       	call   80102da9 <lapicw>
80102e2c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e2f:	68 00 00 01 00       	push   $0x10000
80102e34:	68 d8 00 00 00       	push   $0xd8
80102e39:	e8 6b ff ff ff       	call   80102da9 <lapicw>
80102e3e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e41:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102e46:	83 c0 30             	add    $0x30,%eax
80102e49:	8b 00                	mov    (%eax),%eax
80102e4b:	c1 e8 10             	shr    $0x10,%eax
80102e4e:	0f b6 c0             	movzbl %al,%eax
80102e51:	83 f8 03             	cmp    $0x3,%eax
80102e54:	76 12                	jbe    80102e68 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102e56:	68 00 00 01 00       	push   $0x10000
80102e5b:	68 d0 00 00 00       	push   $0xd0
80102e60:	e8 44 ff ff ff       	call   80102da9 <lapicw>
80102e65:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e68:	6a 33                	push   $0x33
80102e6a:	68 dc 00 00 00       	push   $0xdc
80102e6f:	e8 35 ff ff ff       	call   80102da9 <lapicw>
80102e74:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e77:	6a 00                	push   $0x0
80102e79:	68 a0 00 00 00       	push   $0xa0
80102e7e:	e8 26 ff ff ff       	call   80102da9 <lapicw>
80102e83:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102e86:	6a 00                	push   $0x0
80102e88:	68 a0 00 00 00       	push   $0xa0
80102e8d:	e8 17 ff ff ff       	call   80102da9 <lapicw>
80102e92:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e95:	6a 00                	push   $0x0
80102e97:	6a 2c                	push   $0x2c
80102e99:	e8 0b ff ff ff       	call   80102da9 <lapicw>
80102e9e:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ea1:	6a 00                	push   $0x0
80102ea3:	68 c4 00 00 00       	push   $0xc4
80102ea8:	e8 fc fe ff ff       	call   80102da9 <lapicw>
80102ead:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102eb0:	68 00 85 08 00       	push   $0x88500
80102eb5:	68 c0 00 00 00       	push   $0xc0
80102eba:	e8 ea fe ff ff       	call   80102da9 <lapicw>
80102ebf:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ec2:	90                   	nop
80102ec3:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102ec8:	05 00 03 00 00       	add    $0x300,%eax
80102ecd:	8b 00                	mov    (%eax),%eax
80102ecf:	25 00 10 00 00       	and    $0x1000,%eax
80102ed4:	85 c0                	test   %eax,%eax
80102ed6:	75 eb                	jne    80102ec3 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ed8:	6a 00                	push   $0x0
80102eda:	6a 20                	push   $0x20
80102edc:	e8 c8 fe ff ff       	call   80102da9 <lapicw>
80102ee1:	83 c4 08             	add    $0x8,%esp
}
80102ee4:	c9                   	leave  
80102ee5:	c3                   	ret    

80102ee6 <cpunum>:

int
cpunum(void)
{
80102ee6:	55                   	push   %ebp
80102ee7:	89 e5                	mov    %esp,%ebp
80102ee9:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102eec:	e8 a8 fe ff ff       	call   80102d99 <readeflags>
80102ef1:	25 00 02 00 00       	and    $0x200,%eax
80102ef6:	85 c0                	test   %eax,%eax
80102ef8:	74 26                	je     80102f20 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102efa:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102eff:	8d 50 01             	lea    0x1(%eax),%edx
80102f02:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102f08:	85 c0                	test   %eax,%eax
80102f0a:	75 14                	jne    80102f20 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f0c:	8b 45 04             	mov    0x4(%ebp),%eax
80102f0f:	83 ec 08             	sub    $0x8,%esp
80102f12:	50                   	push   %eax
80102f13:	68 a0 86 10 80       	push   $0x801086a0
80102f18:	e8 a2 d4 ff ff       	call   801003bf <cprintf>
80102f1d:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f20:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102f25:	85 c0                	test   %eax,%eax
80102f27:	74 0f                	je     80102f38 <cpunum+0x52>
    return lapic[ID]>>24;
80102f29:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102f2e:	83 c0 20             	add    $0x20,%eax
80102f31:	8b 00                	mov    (%eax),%eax
80102f33:	c1 e8 18             	shr    $0x18,%eax
80102f36:	eb 05                	jmp    80102f3d <cpunum+0x57>
  return 0;
80102f38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f3d:	c9                   	leave  
80102f3e:	c3                   	ret    

80102f3f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f3f:	55                   	push   %ebp
80102f40:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f42:	a1 dc 22 11 80       	mov    0x801122dc,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 0c                	je     80102f57 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f4b:	6a 00                	push   $0x0
80102f4d:	6a 2c                	push   $0x2c
80102f4f:	e8 55 fe ff ff       	call   80102da9 <lapicw>
80102f54:	83 c4 08             	add    $0x8,%esp
}
80102f57:	c9                   	leave  
80102f58:	c3                   	ret    

80102f59 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f59:	55                   	push   %ebp
80102f5a:	89 e5                	mov    %esp,%ebp
}
80102f5c:	5d                   	pop    %ebp
80102f5d:	c3                   	ret    

80102f5e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f5e:	55                   	push   %ebp
80102f5f:	89 e5                	mov    %esp,%ebp
80102f61:	83 ec 14             	sub    $0x14,%esp
80102f64:	8b 45 08             	mov    0x8(%ebp),%eax
80102f67:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f6a:	6a 0f                	push   $0xf
80102f6c:	6a 70                	push   $0x70
80102f6e:	e8 08 fe ff ff       	call   80102d7b <outb>
80102f73:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102f76:	6a 0a                	push   $0xa
80102f78:	6a 71                	push   $0x71
80102f7a:	e8 fc fd ff ff       	call   80102d7b <outb>
80102f7f:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f82:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f8c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f91:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f94:	83 c0 02             	add    $0x2,%eax
80102f97:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f9a:	c1 ea 04             	shr    $0x4,%edx
80102f9d:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fa0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fa4:	c1 e0 18             	shl    $0x18,%eax
80102fa7:	50                   	push   %eax
80102fa8:	68 c4 00 00 00       	push   $0xc4
80102fad:	e8 f7 fd ff ff       	call   80102da9 <lapicw>
80102fb2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fb5:	68 00 c5 00 00       	push   $0xc500
80102fba:	68 c0 00 00 00       	push   $0xc0
80102fbf:	e8 e5 fd ff ff       	call   80102da9 <lapicw>
80102fc4:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102fc7:	68 c8 00 00 00       	push   $0xc8
80102fcc:	e8 88 ff ff ff       	call   80102f59 <microdelay>
80102fd1:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102fd4:	68 00 85 00 00       	push   $0x8500
80102fd9:	68 c0 00 00 00       	push   $0xc0
80102fde:	e8 c6 fd ff ff       	call   80102da9 <lapicw>
80102fe3:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fe6:	6a 64                	push   $0x64
80102fe8:	e8 6c ff ff ff       	call   80102f59 <microdelay>
80102fed:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ff7:	eb 3d                	jmp    80103036 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80102ff9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102ffd:	c1 e0 18             	shl    $0x18,%eax
80103000:	50                   	push   %eax
80103001:	68 c4 00 00 00       	push   $0xc4
80103006:	e8 9e fd ff ff       	call   80102da9 <lapicw>
8010300b:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010300e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103011:	c1 e8 0c             	shr    $0xc,%eax
80103014:	80 cc 06             	or     $0x6,%ah
80103017:	50                   	push   %eax
80103018:	68 c0 00 00 00       	push   $0xc0
8010301d:	e8 87 fd ff ff       	call   80102da9 <lapicw>
80103022:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103025:	68 c8 00 00 00       	push   $0xc8
8010302a:	e8 2a ff ff ff       	call   80102f59 <microdelay>
8010302f:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103032:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103036:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010303a:	7e bd                	jle    80102ff9 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010303c:	c9                   	leave  
8010303d:	c3                   	ret    

8010303e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103041:	8b 45 08             	mov    0x8(%ebp),%eax
80103044:	0f b6 c0             	movzbl %al,%eax
80103047:	50                   	push   %eax
80103048:	6a 70                	push   $0x70
8010304a:	e8 2c fd ff ff       	call   80102d7b <outb>
8010304f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103052:	68 c8 00 00 00       	push   $0xc8
80103057:	e8 fd fe ff ff       	call   80102f59 <microdelay>
8010305c:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010305f:	6a 71                	push   $0x71
80103061:	e8 f8 fc ff ff       	call   80102d5e <inb>
80103066:	83 c4 04             	add    $0x4,%esp
80103069:	0f b6 c0             	movzbl %al,%eax
}
8010306c:	c9                   	leave  
8010306d:	c3                   	ret    

8010306e <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010306e:	55                   	push   %ebp
8010306f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103071:	6a 00                	push   $0x0
80103073:	e8 c6 ff ff ff       	call   8010303e <cmos_read>
80103078:	83 c4 04             	add    $0x4,%esp
8010307b:	89 c2                	mov    %eax,%edx
8010307d:	8b 45 08             	mov    0x8(%ebp),%eax
80103080:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103082:	6a 02                	push   $0x2
80103084:	e8 b5 ff ff ff       	call   8010303e <cmos_read>
80103089:	83 c4 04             	add    $0x4,%esp
8010308c:	89 c2                	mov    %eax,%edx
8010308e:	8b 45 08             	mov    0x8(%ebp),%eax
80103091:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103094:	6a 04                	push   $0x4
80103096:	e8 a3 ff ff ff       	call   8010303e <cmos_read>
8010309b:	83 c4 04             	add    $0x4,%esp
8010309e:	89 c2                	mov    %eax,%edx
801030a0:	8b 45 08             	mov    0x8(%ebp),%eax
801030a3:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801030a6:	6a 07                	push   $0x7
801030a8:	e8 91 ff ff ff       	call   8010303e <cmos_read>
801030ad:	83 c4 04             	add    $0x4,%esp
801030b0:	89 c2                	mov    %eax,%edx
801030b2:	8b 45 08             	mov    0x8(%ebp),%eax
801030b5:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801030b8:	6a 08                	push   $0x8
801030ba:	e8 7f ff ff ff       	call   8010303e <cmos_read>
801030bf:	83 c4 04             	add    $0x4,%esp
801030c2:	89 c2                	mov    %eax,%edx
801030c4:	8b 45 08             	mov    0x8(%ebp),%eax
801030c7:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801030ca:	6a 09                	push   $0x9
801030cc:	e8 6d ff ff ff       	call   8010303e <cmos_read>
801030d1:	83 c4 04             	add    $0x4,%esp
801030d4:	89 c2                	mov    %eax,%edx
801030d6:	8b 45 08             	mov    0x8(%ebp),%eax
801030d9:	89 50 14             	mov    %edx,0x14(%eax)
}
801030dc:	c9                   	leave  
801030dd:	c3                   	ret    

801030de <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030de:	55                   	push   %ebp
801030df:	89 e5                	mov    %esp,%ebp
801030e1:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030e4:	6a 0b                	push   $0xb
801030e6:	e8 53 ff ff ff       	call   8010303e <cmos_read>
801030eb:	83 c4 04             	add    $0x4,%esp
801030ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801030f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030f4:	83 e0 04             	and    $0x4,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	0f 94 c0             	sete   %al
801030fc:	0f b6 c0             	movzbl %al,%eax
801030ff:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103102:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103105:	50                   	push   %eax
80103106:	e8 63 ff ff ff       	call   8010306e <fill_rtcdate>
8010310b:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010310e:	6a 0a                	push   $0xa
80103110:	e8 29 ff ff ff       	call   8010303e <cmos_read>
80103115:	83 c4 04             	add    $0x4,%esp
80103118:	25 80 00 00 00       	and    $0x80,%eax
8010311d:	85 c0                	test   %eax,%eax
8010311f:	74 02                	je     80103123 <cmostime+0x45>
        continue;
80103121:	eb 32                	jmp    80103155 <cmostime+0x77>
    fill_rtcdate(&t2);
80103123:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103126:	50                   	push   %eax
80103127:	e8 42 ff ff ff       	call   8010306e <fill_rtcdate>
8010312c:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010312f:	83 ec 04             	sub    $0x4,%esp
80103132:	6a 18                	push   $0x18
80103134:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103137:	50                   	push   %eax
80103138:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010313b:	50                   	push   %eax
8010313c:	e8 70 20 00 00       	call   801051b1 <memcmp>
80103141:	83 c4 10             	add    $0x10,%esp
80103144:	85 c0                	test   %eax,%eax
80103146:	75 0d                	jne    80103155 <cmostime+0x77>
      break;
80103148:	90                   	nop
  }

  // convert
  if (bcd) {
80103149:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010314d:	0f 84 b8 00 00 00    	je     8010320b <cmostime+0x12d>
80103153:	eb 02                	jmp    80103157 <cmostime+0x79>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103155:	eb ab                	jmp    80103102 <cmostime+0x24>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103157:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010315a:	c1 e8 04             	shr    $0x4,%eax
8010315d:	89 c2                	mov    %eax,%edx
8010315f:	89 d0                	mov    %edx,%eax
80103161:	c1 e0 02             	shl    $0x2,%eax
80103164:	01 d0                	add    %edx,%eax
80103166:	01 c0                	add    %eax,%eax
80103168:	89 c2                	mov    %eax,%edx
8010316a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010316d:	83 e0 0f             	and    $0xf,%eax
80103170:	01 d0                	add    %edx,%eax
80103172:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103175:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103178:	c1 e8 04             	shr    $0x4,%eax
8010317b:	89 c2                	mov    %eax,%edx
8010317d:	89 d0                	mov    %edx,%eax
8010317f:	c1 e0 02             	shl    $0x2,%eax
80103182:	01 d0                	add    %edx,%eax
80103184:	01 c0                	add    %eax,%eax
80103186:	89 c2                	mov    %eax,%edx
80103188:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010318b:	83 e0 0f             	and    $0xf,%eax
8010318e:	01 d0                	add    %edx,%eax
80103190:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103193:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103196:	c1 e8 04             	shr    $0x4,%eax
80103199:	89 c2                	mov    %eax,%edx
8010319b:	89 d0                	mov    %edx,%eax
8010319d:	c1 e0 02             	shl    $0x2,%eax
801031a0:	01 d0                	add    %edx,%eax
801031a2:	01 c0                	add    %eax,%eax
801031a4:	89 c2                	mov    %eax,%edx
801031a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031a9:	83 e0 0f             	and    $0xf,%eax
801031ac:	01 d0                	add    %edx,%eax
801031ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031b4:	c1 e8 04             	shr    $0x4,%eax
801031b7:	89 c2                	mov    %eax,%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	89 c2                	mov    %eax,%edx
801031c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031c7:	83 e0 0f             	and    $0xf,%eax
801031ca:	01 d0                	add    %edx,%eax
801031cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031d2:	c1 e8 04             	shr    $0x4,%eax
801031d5:	89 c2                	mov    %eax,%edx
801031d7:	89 d0                	mov    %edx,%eax
801031d9:	c1 e0 02             	shl    $0x2,%eax
801031dc:	01 d0                	add    %edx,%eax
801031de:	01 c0                	add    %eax,%eax
801031e0:	89 c2                	mov    %eax,%edx
801031e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031e5:	83 e0 0f             	and    $0xf,%eax
801031e8:	01 d0                	add    %edx,%eax
801031ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031f0:	c1 e8 04             	shr    $0x4,%eax
801031f3:	89 c2                	mov    %eax,%edx
801031f5:	89 d0                	mov    %edx,%eax
801031f7:	c1 e0 02             	shl    $0x2,%eax
801031fa:	01 d0                	add    %edx,%eax
801031fc:	01 c0                	add    %eax,%eax
801031fe:	89 c2                	mov    %eax,%edx
80103200:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103203:	83 e0 0f             	and    $0xf,%eax
80103206:	01 d0                	add    %edx,%eax
80103208:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010320b:	8b 45 08             	mov    0x8(%ebp),%eax
8010320e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103211:	89 10                	mov    %edx,(%eax)
80103213:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103216:	89 50 04             	mov    %edx,0x4(%eax)
80103219:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010321c:	89 50 08             	mov    %edx,0x8(%eax)
8010321f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103222:	89 50 0c             	mov    %edx,0xc(%eax)
80103225:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103228:	89 50 10             	mov    %edx,0x10(%eax)
8010322b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010322e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103231:	8b 45 08             	mov    0x8(%ebp),%eax
80103234:	8b 40 14             	mov    0x14(%eax),%eax
80103237:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010323d:	8b 45 08             	mov    0x8(%ebp),%eax
80103240:	89 50 14             	mov    %edx,0x14(%eax)
}
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010324b:	83 ec 08             	sub    $0x8,%esp
8010324e:	68 cc 86 10 80       	push   $0x801086cc
80103253:	68 00 23 11 80       	push   $0x80112300
80103258:	e8 70 1c 00 00       	call   80104ecd <initlock>
8010325d:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
80103260:	83 ec 08             	sub    $0x8,%esp
80103263:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103266:	50                   	push   %eax
80103267:	6a 01                	push   $0x1
80103269:	e8 d1 e0 ff ff       	call   8010133f <readsb>
8010326e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
80103271:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103277:	29 c2                	sub    %eax,%edx
80103279:	89 d0                	mov    %edx,%eax
8010327b:	a3 34 23 11 80       	mov    %eax,0x80112334
  log.size = sb.nlog;
80103280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103283:	a3 38 23 11 80       	mov    %eax,0x80112338
  log.dev = ROOTDEV;
80103288:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
8010328f:	00 00 00 
  recover_from_log();
80103292:	e8 ae 01 00 00       	call   80103445 <recover_from_log>
}
80103297:	c9                   	leave  
80103298:	c3                   	ret    

80103299 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103299:	55                   	push   %ebp
8010329a:	89 e5                	mov    %esp,%ebp
8010329c:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010329f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032a6:	e9 95 00 00 00       	jmp    80103340 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032ab:	8b 15 34 23 11 80    	mov    0x80112334,%edx
801032b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b4:	01 d0                	add    %edx,%eax
801032b6:	83 c0 01             	add    $0x1,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	a1 44 23 11 80       	mov    0x80112344,%eax
801032c0:	83 ec 08             	sub    $0x8,%esp
801032c3:	52                   	push   %edx
801032c4:	50                   	push   %eax
801032c5:	e8 ea ce ff ff       	call   801001b4 <bread>
801032ca:	83 c4 10             	add    $0x10,%esp
801032cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801032d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d3:	83 c0 10             	add    $0x10,%eax
801032d6:	8b 04 85 0c 23 11 80 	mov    -0x7feedcf4(,%eax,4),%eax
801032dd:	89 c2                	mov    %eax,%edx
801032df:	a1 44 23 11 80       	mov    0x80112344,%eax
801032e4:	83 ec 08             	sub    $0x8,%esp
801032e7:	52                   	push   %edx
801032e8:	50                   	push   %eax
801032e9:	e8 c6 ce ff ff       	call   801001b4 <bread>
801032ee:	83 c4 10             	add    $0x10,%esp
801032f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801032f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032f7:	8d 50 18             	lea    0x18(%eax),%edx
801032fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032fd:	83 c0 18             	add    $0x18,%eax
80103300:	83 ec 04             	sub    $0x4,%esp
80103303:	68 00 02 00 00       	push   $0x200
80103308:	52                   	push   %edx
80103309:	50                   	push   %eax
8010330a:	e8 fa 1e 00 00       	call   80105209 <memmove>
8010330f:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103312:	83 ec 0c             	sub    $0xc,%esp
80103315:	ff 75 ec             	pushl  -0x14(%ebp)
80103318:	e8 d0 ce ff ff       	call   801001ed <bwrite>
8010331d:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103320:	83 ec 0c             	sub    $0xc,%esp
80103323:	ff 75 f0             	pushl  -0x10(%ebp)
80103326:	e8 00 cf ff ff       	call   8010022b <brelse>
8010332b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010332e:	83 ec 0c             	sub    $0xc,%esp
80103331:	ff 75 ec             	pushl  -0x14(%ebp)
80103334:	e8 f2 ce ff ff       	call   8010022b <brelse>
80103339:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010333c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103340:	a1 48 23 11 80       	mov    0x80112348,%eax
80103345:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103348:	0f 8f 5d ff ff ff    	jg     801032ab <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010334e:	c9                   	leave  
8010334f:	c3                   	ret    

80103350 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103350:	55                   	push   %ebp
80103351:	89 e5                	mov    %esp,%ebp
80103353:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103356:	a1 34 23 11 80       	mov    0x80112334,%eax
8010335b:	89 c2                	mov    %eax,%edx
8010335d:	a1 44 23 11 80       	mov    0x80112344,%eax
80103362:	83 ec 08             	sub    $0x8,%esp
80103365:	52                   	push   %edx
80103366:	50                   	push   %eax
80103367:	e8 48 ce ff ff       	call   801001b4 <bread>
8010336c:	83 c4 10             	add    $0x10,%esp
8010336f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103372:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103375:	83 c0 18             	add    $0x18,%eax
80103378:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010337b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337e:	8b 00                	mov    (%eax),%eax
80103380:	a3 48 23 11 80       	mov    %eax,0x80112348
  for (i = 0; i < log.lh.n; i++) {
80103385:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010338c:	eb 1b                	jmp    801033a9 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
8010338e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103391:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103394:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103398:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010339b:	83 c2 10             	add    $0x10,%edx
8010339e:	89 04 95 0c 23 11 80 	mov    %eax,-0x7feedcf4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033a9:	a1 48 23 11 80       	mov    0x80112348,%eax
801033ae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b1:	7f db                	jg     8010338e <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033b3:	83 ec 0c             	sub    $0xc,%esp
801033b6:	ff 75 f0             	pushl  -0x10(%ebp)
801033b9:	e8 6d ce ff ff       	call   8010022b <brelse>
801033be:	83 c4 10             	add    $0x10,%esp
}
801033c1:	c9                   	leave  
801033c2:	c3                   	ret    

801033c3 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033c3:	55                   	push   %ebp
801033c4:	89 e5                	mov    %esp,%ebp
801033c6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033c9:	a1 34 23 11 80       	mov    0x80112334,%eax
801033ce:	89 c2                	mov    %eax,%edx
801033d0:	a1 44 23 11 80       	mov    0x80112344,%eax
801033d5:	83 ec 08             	sub    $0x8,%esp
801033d8:	52                   	push   %edx
801033d9:	50                   	push   %eax
801033da:	e8 d5 cd ff ff       	call   801001b4 <bread>
801033df:	83 c4 10             	add    $0x10,%esp
801033e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e8:	83 c0 18             	add    $0x18,%eax
801033eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ee:	8b 15 48 23 11 80    	mov    0x80112348,%edx
801033f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103400:	eb 1b                	jmp    8010341d <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
80103402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103405:	83 c0 10             	add    $0x10,%eax
80103408:	8b 0c 85 0c 23 11 80 	mov    -0x7feedcf4(,%eax,4),%ecx
8010340f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103412:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103415:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103419:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010341d:	a1 48 23 11 80       	mov    0x80112348,%eax
80103422:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103425:	7f db                	jg     80103402 <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103427:	83 ec 0c             	sub    $0xc,%esp
8010342a:	ff 75 f0             	pushl  -0x10(%ebp)
8010342d:	e8 bb cd ff ff       	call   801001ed <bwrite>
80103432:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103435:	83 ec 0c             	sub    $0xc,%esp
80103438:	ff 75 f0             	pushl  -0x10(%ebp)
8010343b:	e8 eb cd ff ff       	call   8010022b <brelse>
80103440:	83 c4 10             	add    $0x10,%esp
}
80103443:	c9                   	leave  
80103444:	c3                   	ret    

80103445 <recover_from_log>:

static void
recover_from_log(void)
{
80103445:	55                   	push   %ebp
80103446:	89 e5                	mov    %esp,%ebp
80103448:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010344b:	e8 00 ff ff ff       	call   80103350 <read_head>
  install_trans(); // if committed, copy from log to disk
80103450:	e8 44 fe ff ff       	call   80103299 <install_trans>
  log.lh.n = 0;
80103455:	c7 05 48 23 11 80 00 	movl   $0x0,0x80112348
8010345c:	00 00 00 
  write_head(); // clear the log
8010345f:	e8 5f ff ff ff       	call   801033c3 <write_head>
}
80103464:	c9                   	leave  
80103465:	c3                   	ret    

80103466 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103466:	55                   	push   %ebp
80103467:	89 e5                	mov    %esp,%ebp
80103469:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010346c:	83 ec 0c             	sub    $0xc,%esp
8010346f:	68 00 23 11 80       	push   $0x80112300
80103474:	e8 75 1a 00 00       	call   80104eee <acquire>
80103479:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010347c:	a1 40 23 11 80       	mov    0x80112340,%eax
80103481:	85 c0                	test   %eax,%eax
80103483:	74 17                	je     8010349c <begin_op+0x36>
      sleep(&log, &log.lock);
80103485:	83 ec 08             	sub    $0x8,%esp
80103488:	68 00 23 11 80       	push   $0x80112300
8010348d:	68 00 23 11 80       	push   $0x80112300
80103492:	e8 5e 17 00 00       	call   80104bf5 <sleep>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	eb 54                	jmp    801034f0 <begin_op+0x8a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010349c:	8b 0d 48 23 11 80    	mov    0x80112348,%ecx
801034a2:	a1 3c 23 11 80       	mov    0x8011233c,%eax
801034a7:	8d 50 01             	lea    0x1(%eax),%edx
801034aa:	89 d0                	mov    %edx,%eax
801034ac:	c1 e0 02             	shl    $0x2,%eax
801034af:	01 d0                	add    %edx,%eax
801034b1:	01 c0                	add    %eax,%eax
801034b3:	01 c8                	add    %ecx,%eax
801034b5:	83 f8 1e             	cmp    $0x1e,%eax
801034b8:	7e 17                	jle    801034d1 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	68 00 23 11 80       	push   $0x80112300
801034c2:	68 00 23 11 80       	push   $0x80112300
801034c7:	e8 29 17 00 00       	call   80104bf5 <sleep>
801034cc:	83 c4 10             	add    $0x10,%esp
801034cf:	eb 1f                	jmp    801034f0 <begin_op+0x8a>
    } else {
      log.outstanding += 1;
801034d1:	a1 3c 23 11 80       	mov    0x8011233c,%eax
801034d6:	83 c0 01             	add    $0x1,%eax
801034d9:	a3 3c 23 11 80       	mov    %eax,0x8011233c
      release(&log.lock);
801034de:	83 ec 0c             	sub    $0xc,%esp
801034e1:	68 00 23 11 80       	push   $0x80112300
801034e6:	e8 69 1a 00 00       	call   80104f54 <release>
801034eb:	83 c4 10             	add    $0x10,%esp
      break;
801034ee:	eb 02                	jmp    801034f2 <begin_op+0x8c>
    }
  }
801034f0:	eb 8a                	jmp    8010347c <begin_op+0x16>
}
801034f2:	c9                   	leave  
801034f3:	c3                   	ret    

801034f4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034f4:	55                   	push   %ebp
801034f5:	89 e5                	mov    %esp,%ebp
801034f7:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801034fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103501:	83 ec 0c             	sub    $0xc,%esp
80103504:	68 00 23 11 80       	push   $0x80112300
80103509:	e8 e0 19 00 00       	call   80104eee <acquire>
8010350e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103511:	a1 3c 23 11 80       	mov    0x8011233c,%eax
80103516:	83 e8 01             	sub    $0x1,%eax
80103519:	a3 3c 23 11 80       	mov    %eax,0x8011233c
  if(log.committing)
8010351e:	a1 40 23 11 80       	mov    0x80112340,%eax
80103523:	85 c0                	test   %eax,%eax
80103525:	74 0d                	je     80103534 <end_op+0x40>
    panic("log.committing");
80103527:	83 ec 0c             	sub    $0xc,%esp
8010352a:	68 d0 86 10 80       	push   $0x801086d0
8010352f:	e8 28 d0 ff ff       	call   8010055c <panic>
  if(log.outstanding == 0){
80103534:	a1 3c 23 11 80       	mov    0x8011233c,%eax
80103539:	85 c0                	test   %eax,%eax
8010353b:	75 13                	jne    80103550 <end_op+0x5c>
    do_commit = 1;
8010353d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103544:	c7 05 40 23 11 80 01 	movl   $0x1,0x80112340
8010354b:	00 00 00 
8010354e:	eb 10                	jmp    80103560 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103550:	83 ec 0c             	sub    $0xc,%esp
80103553:	68 00 23 11 80       	push   $0x80112300
80103558:	e8 84 17 00 00       	call   80104ce1 <wakeup>
8010355d:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103560:	83 ec 0c             	sub    $0xc,%esp
80103563:	68 00 23 11 80       	push   $0x80112300
80103568:	e8 e7 19 00 00       	call   80104f54 <release>
8010356d:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103570:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103574:	74 3f                	je     801035b5 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103576:	e8 f3 00 00 00       	call   8010366e <commit>
    acquire(&log.lock);
8010357b:	83 ec 0c             	sub    $0xc,%esp
8010357e:	68 00 23 11 80       	push   $0x80112300
80103583:	e8 66 19 00 00       	call   80104eee <acquire>
80103588:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010358b:	c7 05 40 23 11 80 00 	movl   $0x0,0x80112340
80103592:	00 00 00 
    wakeup(&log);
80103595:	83 ec 0c             	sub    $0xc,%esp
80103598:	68 00 23 11 80       	push   $0x80112300
8010359d:	e8 3f 17 00 00       	call   80104ce1 <wakeup>
801035a2:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801035a5:	83 ec 0c             	sub    $0xc,%esp
801035a8:	68 00 23 11 80       	push   $0x80112300
801035ad:	e8 a2 19 00 00       	call   80104f54 <release>
801035b2:	83 c4 10             	add    $0x10,%esp
  }
}
801035b5:	c9                   	leave  
801035b6:	c3                   	ret    

801035b7 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035b7:	55                   	push   %ebp
801035b8:	89 e5                	mov    %esp,%ebp
801035ba:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035c4:	e9 95 00 00 00       	jmp    8010365e <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035c9:	8b 15 34 23 11 80    	mov    0x80112334,%edx
801035cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d2:	01 d0                	add    %edx,%eax
801035d4:	83 c0 01             	add    $0x1,%eax
801035d7:	89 c2                	mov    %eax,%edx
801035d9:	a1 44 23 11 80       	mov    0x80112344,%eax
801035de:	83 ec 08             	sub    $0x8,%esp
801035e1:	52                   	push   %edx
801035e2:	50                   	push   %eax
801035e3:	e8 cc cb ff ff       	call   801001b4 <bread>
801035e8:	83 c4 10             	add    $0x10,%esp
801035eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f1:	83 c0 10             	add    $0x10,%eax
801035f4:	8b 04 85 0c 23 11 80 	mov    -0x7feedcf4(,%eax,4),%eax
801035fb:	89 c2                	mov    %eax,%edx
801035fd:	a1 44 23 11 80       	mov    0x80112344,%eax
80103602:	83 ec 08             	sub    $0x8,%esp
80103605:	52                   	push   %edx
80103606:	50                   	push   %eax
80103607:	e8 a8 cb ff ff       	call   801001b4 <bread>
8010360c:	83 c4 10             	add    $0x10,%esp
8010360f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103615:	8d 50 18             	lea    0x18(%eax),%edx
80103618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361b:	83 c0 18             	add    $0x18,%eax
8010361e:	83 ec 04             	sub    $0x4,%esp
80103621:	68 00 02 00 00       	push   $0x200
80103626:	52                   	push   %edx
80103627:	50                   	push   %eax
80103628:	e8 dc 1b 00 00       	call   80105209 <memmove>
8010362d:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103630:	83 ec 0c             	sub    $0xc,%esp
80103633:	ff 75 f0             	pushl  -0x10(%ebp)
80103636:	e8 b2 cb ff ff       	call   801001ed <bwrite>
8010363b:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010363e:	83 ec 0c             	sub    $0xc,%esp
80103641:	ff 75 ec             	pushl  -0x14(%ebp)
80103644:	e8 e2 cb ff ff       	call   8010022b <brelse>
80103649:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010364c:	83 ec 0c             	sub    $0xc,%esp
8010364f:	ff 75 f0             	pushl  -0x10(%ebp)
80103652:	e8 d4 cb ff ff       	call   8010022b <brelse>
80103657:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010365a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010365e:	a1 48 23 11 80       	mov    0x80112348,%eax
80103663:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103666:	0f 8f 5d ff ff ff    	jg     801035c9 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010366c:	c9                   	leave  
8010366d:	c3                   	ret    

8010366e <commit>:

static void
commit()
{
8010366e:	55                   	push   %ebp
8010366f:	89 e5                	mov    %esp,%ebp
80103671:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103674:	a1 48 23 11 80       	mov    0x80112348,%eax
80103679:	85 c0                	test   %eax,%eax
8010367b:	7e 1e                	jle    8010369b <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010367d:	e8 35 ff ff ff       	call   801035b7 <write_log>
    write_head();    // Write header to disk -- the real commit
80103682:	e8 3c fd ff ff       	call   801033c3 <write_head>
    install_trans(); // Now install writes to home locations
80103687:	e8 0d fc ff ff       	call   80103299 <install_trans>
    log.lh.n = 0; 
8010368c:	c7 05 48 23 11 80 00 	movl   $0x0,0x80112348
80103693:	00 00 00 
    write_head();    // Erase the transaction from the log
80103696:	e8 28 fd ff ff       	call   801033c3 <write_head>
  }
}
8010369b:	c9                   	leave  
8010369c:	c3                   	ret    

8010369d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010369d:	55                   	push   %ebp
8010369e:	89 e5                	mov    %esp,%ebp
801036a0:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036a3:	a1 48 23 11 80       	mov    0x80112348,%eax
801036a8:	83 f8 1d             	cmp    $0x1d,%eax
801036ab:	7f 12                	jg     801036bf <log_write+0x22>
801036ad:	a1 48 23 11 80       	mov    0x80112348,%eax
801036b2:	8b 15 38 23 11 80    	mov    0x80112338,%edx
801036b8:	83 ea 01             	sub    $0x1,%edx
801036bb:	39 d0                	cmp    %edx,%eax
801036bd:	7c 0d                	jl     801036cc <log_write+0x2f>
    panic("too big a transaction");
801036bf:	83 ec 0c             	sub    $0xc,%esp
801036c2:	68 df 86 10 80       	push   $0x801086df
801036c7:	e8 90 ce ff ff       	call   8010055c <panic>
  if (log.outstanding < 1)
801036cc:	a1 3c 23 11 80       	mov    0x8011233c,%eax
801036d1:	85 c0                	test   %eax,%eax
801036d3:	7f 0d                	jg     801036e2 <log_write+0x45>
    panic("log_write outside of trans");
801036d5:	83 ec 0c             	sub    $0xc,%esp
801036d8:	68 f5 86 10 80       	push   $0x801086f5
801036dd:	e8 7a ce ff ff       	call   8010055c <panic>

  for (i = 0; i < log.lh.n; i++) {
801036e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036e9:	eb 1f                	jmp    8010370a <log_write+0x6d>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ee:	83 c0 10             	add    $0x10,%eax
801036f1:	8b 04 85 0c 23 11 80 	mov    -0x7feedcf4(,%eax,4),%eax
801036f8:	89 c2                	mov    %eax,%edx
801036fa:	8b 45 08             	mov    0x8(%ebp),%eax
801036fd:	8b 40 08             	mov    0x8(%eax),%eax
80103700:	39 c2                	cmp    %eax,%edx
80103702:	75 02                	jne    80103706 <log_write+0x69>
      break;
80103704:	eb 0e                	jmp    80103714 <log_write+0x77>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103706:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010370a:	a1 48 23 11 80       	mov    0x80112348,%eax
8010370f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103712:	7f d7                	jg     801036eb <log_write+0x4e>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
  }
  log.lh.sector[i] = b->sector;
80103714:	8b 45 08             	mov    0x8(%ebp),%eax
80103717:	8b 40 08             	mov    0x8(%eax),%eax
8010371a:	89 c2                	mov    %eax,%edx
8010371c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371f:	83 c0 10             	add    $0x10,%eax
80103722:	89 14 85 0c 23 11 80 	mov    %edx,-0x7feedcf4(,%eax,4)
  if (i == log.lh.n)
80103729:	a1 48 23 11 80       	mov    0x80112348,%eax
8010372e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103731:	75 0d                	jne    80103740 <log_write+0xa3>
    log.lh.n++;
80103733:	a1 48 23 11 80       	mov    0x80112348,%eax
80103738:	83 c0 01             	add    $0x1,%eax
8010373b:	a3 48 23 11 80       	mov    %eax,0x80112348
  b->flags |= B_DIRTY; // prevent eviction
80103740:	8b 45 08             	mov    0x8(%ebp),%eax
80103743:	8b 00                	mov    (%eax),%eax
80103745:	83 c8 04             	or     $0x4,%eax
80103748:	89 c2                	mov    %eax,%edx
8010374a:	8b 45 08             	mov    0x8(%ebp),%eax
8010374d:	89 10                	mov    %edx,(%eax)
}
8010374f:	c9                   	leave  
80103750:	c3                   	ret    

80103751 <v2p>:
80103751:	55                   	push   %ebp
80103752:	89 e5                	mov    %esp,%ebp
80103754:	8b 45 08             	mov    0x8(%ebp),%eax
80103757:	05 00 00 00 80       	add    $0x80000000,%eax
8010375c:	5d                   	pop    %ebp
8010375d:	c3                   	ret    

8010375e <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010375e:	55                   	push   %ebp
8010375f:	89 e5                	mov    %esp,%ebp
80103761:	8b 45 08             	mov    0x8(%ebp),%eax
80103764:	05 00 00 00 80       	add    $0x80000000,%eax
80103769:	5d                   	pop    %ebp
8010376a:	c3                   	ret    

8010376b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103771:	8b 55 08             	mov    0x8(%ebp),%edx
80103774:	8b 45 0c             	mov    0xc(%ebp),%eax
80103777:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010377a:	f0 87 02             	lock xchg %eax,(%edx)
8010377d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103780:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103783:	c9                   	leave  
80103784:	c3                   	ret    

80103785 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103785:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103789:	83 e4 f0             	and    $0xfffffff0,%esp
8010378c:	ff 71 fc             	pushl  -0x4(%ecx)
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	51                   	push   %ecx
80103793:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103796:	83 ec 08             	sub    $0x8,%esp
80103799:	68 00 00 40 80       	push   $0x80400000
8010379e:	68 1c 54 11 80       	push   $0x8011541c
801037a3:	e8 aa f2 ff ff       	call   80102a52 <kinit1>
801037a8:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801037ab:	e8 aa 45 00 00       	call   80107d5a <kvmalloc>
  mpinit();        // collect info about this machine
801037b0:	e8 45 04 00 00       	call   80103bfa <mpinit>
  lapicinit();
801037b5:	e8 10 f6 ff ff       	call   80102dca <lapicinit>
  seginit();       // set up segments
801037ba:	e8 43 3f 00 00       	call   80107702 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037c5:	0f b6 00             	movzbl (%eax),%eax
801037c8:	0f b6 c0             	movzbl %al,%eax
801037cb:	83 ec 08             	sub    $0x8,%esp
801037ce:	50                   	push   %eax
801037cf:	68 10 87 10 80       	push   $0x80108710
801037d4:	e8 e6 cb ff ff       	call   801003bf <cprintf>
801037d9:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801037dc:	e8 6a 06 00 00       	call   80103e4b <picinit>
  ioapicinit();    // another interrupt controller
801037e1:	e8 64 f1 ff ff       	call   8010294a <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037e6:	e8 ed d2 ff ff       	call   80100ad8 <consoleinit>
  uartinit();      // serial port
801037eb:	e8 75 32 00 00       	call   80106a65 <uartinit>
  pinit();         // process table
801037f0:	e8 55 0b 00 00       	call   8010434a <pinit>
  tvinit();        // trap vectors
801037f5:	e8 3a 2e 00 00       	call   80106634 <tvinit>
  binit();         // buffer cache
801037fa:	e8 35 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037ff:	e8 2f d7 ff ff       	call   80100f33 <fileinit>
  iinit();         // inode cache
80103804:	e8 02 de ff ff       	call   8010160b <iinit>
  ideinit();       // disk
80103809:	e8 84 ed ff ff       	call   80102592 <ideinit>
  if(!ismp)
8010380e:	a1 04 24 11 80       	mov    0x80112404,%eax
80103813:	85 c0                	test   %eax,%eax
80103815:	75 05                	jne    8010381c <main+0x97>
    timerinit();   // uniprocessor timer
80103817:	e8 77 2d 00 00       	call   80106593 <timerinit>
  startothers();   // start other processors
8010381c:	e8 7f 00 00 00       	call   801038a0 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103821:	83 ec 08             	sub    $0x8,%esp
80103824:	68 00 00 00 8e       	push   $0x8e000000
80103829:	68 00 00 40 80       	push   $0x80400000
8010382e:	e8 57 f2 ff ff       	call   80102a8a <kinit2>
80103833:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103836:	e8 3e 0c 00 00       	call   80104479 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010383b:	e8 1a 00 00 00       	call   8010385a <mpmain>

80103840 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103840:	55                   	push   %ebp
80103841:	89 e5                	mov    %esp,%ebp
80103843:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103846:	e8 26 45 00 00       	call   80107d71 <switchkvm>
  seginit();
8010384b:	e8 b2 3e 00 00       	call   80107702 <seginit>
  lapicinit();
80103850:	e8 75 f5 ff ff       	call   80102dca <lapicinit>
  mpmain();
80103855:	e8 00 00 00 00       	call   8010385a <mpmain>

8010385a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010385a:	55                   	push   %ebp
8010385b:	89 e5                	mov    %esp,%ebp
8010385d:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103860:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103866:	0f b6 00             	movzbl (%eax),%eax
80103869:	0f b6 c0             	movzbl %al,%eax
8010386c:	83 ec 08             	sub    $0x8,%esp
8010386f:	50                   	push   %eax
80103870:	68 27 87 10 80       	push   $0x80108727
80103875:	e8 45 cb ff ff       	call   801003bf <cprintf>
8010387a:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010387d:	e8 27 2f 00 00       	call   801067a9 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103882:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103888:	05 a8 00 00 00       	add    $0xa8,%eax
8010388d:	83 ec 08             	sub    $0x8,%esp
80103890:	6a 01                	push   $0x1
80103892:	50                   	push   %eax
80103893:	e8 d3 fe ff ff       	call   8010376b <xchg>
80103898:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010389b:	e8 89 11 00 00       	call   80104a29 <scheduler>

801038a0 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038a0:	55                   	push   %ebp
801038a1:	89 e5                	mov    %esp,%ebp
801038a3:	53                   	push   %ebx
801038a4:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038a7:	68 00 70 00 00       	push   $0x7000
801038ac:	e8 ad fe ff ff       	call   8010375e <p2v>
801038b1:	83 c4 04             	add    $0x4,%esp
801038b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038b7:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038bc:	83 ec 04             	sub    $0x4,%esp
801038bf:	50                   	push   %eax
801038c0:	68 2c b5 10 80       	push   $0x8010b52c
801038c5:	ff 75 f0             	pushl  -0x10(%ebp)
801038c8:	e8 3c 19 00 00       	call   80105209 <memmove>
801038cd:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801038d0:	c7 45 f4 40 24 11 80 	movl   $0x80112440,-0xc(%ebp)
801038d7:	e9 8f 00 00 00       	jmp    8010396b <startothers+0xcb>
    if(c == cpus+cpunum())  // We've started already.
801038dc:	e8 05 f6 ff ff       	call   80102ee6 <cpunum>
801038e1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038e7:	05 40 24 11 80       	add    $0x80112440,%eax
801038ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ef:	75 02                	jne    801038f3 <startothers+0x53>
      continue;
801038f1:	eb 71                	jmp    80103964 <startothers+0xc4>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038f3:	e8 8d f2 ff ff       	call   80102b85 <kalloc>
801038f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fe:	83 e8 04             	sub    $0x4,%eax
80103901:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103904:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010390a:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010390c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390f:	83 e8 08             	sub    $0x8,%eax
80103912:	c7 00 40 38 10 80    	movl   $0x80103840,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391b:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010391e:	83 ec 0c             	sub    $0xc,%esp
80103921:	68 00 a0 10 80       	push   $0x8010a000
80103926:	e8 26 fe ff ff       	call   80103751 <v2p>
8010392b:	83 c4 10             	add    $0x10,%esp
8010392e:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103930:	83 ec 0c             	sub    $0xc,%esp
80103933:	ff 75 f0             	pushl  -0x10(%ebp)
80103936:	e8 16 fe ff ff       	call   80103751 <v2p>
8010393b:	83 c4 10             	add    $0x10,%esp
8010393e:	89 c2                	mov    %eax,%edx
80103940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103943:	0f b6 00             	movzbl (%eax),%eax
80103946:	0f b6 c0             	movzbl %al,%eax
80103949:	83 ec 08             	sub    $0x8,%esp
8010394c:	52                   	push   %edx
8010394d:	50                   	push   %eax
8010394e:	e8 0b f6 ff ff       	call   80102f5e <lapicstartap>
80103953:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103956:	90                   	nop
80103957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010395a:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103960:	85 c0                	test   %eax,%eax
80103962:	74 f3                	je     80103957 <startothers+0xb7>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103964:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010396b:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103970:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103976:	05 40 24 11 80       	add    $0x80112440,%eax
8010397b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010397e:	0f 87 58 ff ff ff    	ja     801038dc <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103987:	c9                   	leave  
80103988:	c3                   	ret    

80103989 <p2v>:
80103989:	55                   	push   %ebp
8010398a:	89 e5                	mov    %esp,%ebp
8010398c:	8b 45 08             	mov    0x8(%ebp),%eax
8010398f:	05 00 00 00 80       	add    $0x80000000,%eax
80103994:	5d                   	pop    %ebp
80103995:	c3                   	ret    

80103996 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103996:	55                   	push   %ebp
80103997:	89 e5                	mov    %esp,%ebp
80103999:	83 ec 14             	sub    $0x14,%esp
8010399c:	8b 45 08             	mov    0x8(%ebp),%eax
8010399f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039a3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801039a7:	89 c2                	mov    %eax,%edx
801039a9:	ec                   	in     (%dx),%al
801039aa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039ad:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801039b1:	c9                   	leave  
801039b2:	c3                   	ret    

801039b3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039b3:	55                   	push   %ebp
801039b4:	89 e5                	mov    %esp,%ebp
801039b6:	83 ec 08             	sub    $0x8,%esp
801039b9:	8b 55 08             	mov    0x8(%ebp),%edx
801039bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801039bf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039c3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039c6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039ce:	ee                   	out    %al,(%dx)
}
801039cf:	c9                   	leave  
801039d0:	c3                   	ret    

801039d1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039d1:	55                   	push   %ebp
801039d2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039d4:	a1 64 b6 10 80       	mov    0x8010b664,%eax
801039d9:	89 c2                	mov    %eax,%edx
801039db:	b8 40 24 11 80       	mov    $0x80112440,%eax
801039e0:	29 c2                	sub    %eax,%edx
801039e2:	89 d0                	mov    %edx,%eax
801039e4:	c1 f8 02             	sar    $0x2,%eax
801039e7:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039ed:	5d                   	pop    %ebp
801039ee:	c3                   	ret    

801039ef <sum>:

static uchar
sum(uchar *addr, int len)
{
801039ef:	55                   	push   %ebp
801039f0:	89 e5                	mov    %esp,%ebp
801039f2:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039f5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a03:	eb 15                	jmp    80103a1a <sum+0x2b>
    sum += addr[i];
80103a05:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a08:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0b:	01 d0                	add    %edx,%eax
80103a0d:	0f b6 00             	movzbl (%eax),%eax
80103a10:	0f b6 c0             	movzbl %al,%eax
80103a13:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a20:	7c e3                	jl     80103a05 <sum+0x16>
    sum += addr[i];
  return sum;
80103a22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a25:	c9                   	leave  
80103a26:	c3                   	ret    

80103a27 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a27:	55                   	push   %ebp
80103a28:	89 e5                	mov    %esp,%ebp
80103a2a:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a2d:	ff 75 08             	pushl  0x8(%ebp)
80103a30:	e8 54 ff ff ff       	call   80103989 <p2v>
80103a35:	83 c4 04             	add    $0x4,%esp
80103a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a41:	01 d0                	add    %edx,%eax
80103a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a4c:	eb 36                	jmp    80103a84 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a4e:	83 ec 04             	sub    $0x4,%esp
80103a51:	6a 04                	push   $0x4
80103a53:	68 38 87 10 80       	push   $0x80108738
80103a58:	ff 75 f4             	pushl  -0xc(%ebp)
80103a5b:	e8 51 17 00 00       	call   801051b1 <memcmp>
80103a60:	83 c4 10             	add    $0x10,%esp
80103a63:	85 c0                	test   %eax,%eax
80103a65:	75 19                	jne    80103a80 <mpsearch1+0x59>
80103a67:	83 ec 08             	sub    $0x8,%esp
80103a6a:	6a 10                	push   $0x10
80103a6c:	ff 75 f4             	pushl  -0xc(%ebp)
80103a6f:	e8 7b ff ff ff       	call   801039ef <sum>
80103a74:	83 c4 10             	add    $0x10,%esp
80103a77:	84 c0                	test   %al,%al
80103a79:	75 05                	jne    80103a80 <mpsearch1+0x59>
      return (struct mp*)p;
80103a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7e:	eb 11                	jmp    80103a91 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a80:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a87:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a8a:	72 c2                	jb     80103a4e <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a91:	c9                   	leave  
80103a92:	c3                   	ret    

80103a93 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a93:	55                   	push   %ebp
80103a94:	89 e5                	mov    %esp,%ebp
80103a96:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a99:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	83 c0 0f             	add    $0xf,%eax
80103aa6:	0f b6 00             	movzbl (%eax),%eax
80103aa9:	0f b6 c0             	movzbl %al,%eax
80103aac:	c1 e0 08             	shl    $0x8,%eax
80103aaf:	89 c2                	mov    %eax,%edx
80103ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab4:	83 c0 0e             	add    $0xe,%eax
80103ab7:	0f b6 00             	movzbl (%eax),%eax
80103aba:	0f b6 c0             	movzbl %al,%eax
80103abd:	09 d0                	or     %edx,%eax
80103abf:	c1 e0 04             	shl    $0x4,%eax
80103ac2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ac5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ac9:	74 21                	je     80103aec <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103acb:	83 ec 08             	sub    $0x8,%esp
80103ace:	68 00 04 00 00       	push   $0x400
80103ad3:	ff 75 f0             	pushl  -0x10(%ebp)
80103ad6:	e8 4c ff ff ff       	call   80103a27 <mpsearch1>
80103adb:	83 c4 10             	add    $0x10,%esp
80103ade:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ae5:	74 51                	je     80103b38 <mpsearch+0xa5>
      return mp;
80103ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aea:	eb 61                	jmp    80103b4d <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aef:	83 c0 14             	add    $0x14,%eax
80103af2:	0f b6 00             	movzbl (%eax),%eax
80103af5:	0f b6 c0             	movzbl %al,%eax
80103af8:	c1 e0 08             	shl    $0x8,%eax
80103afb:	89 c2                	mov    %eax,%edx
80103afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b00:	83 c0 13             	add    $0x13,%eax
80103b03:	0f b6 00             	movzbl (%eax),%eax
80103b06:	0f b6 c0             	movzbl %al,%eax
80103b09:	09 d0                	or     %edx,%eax
80103b0b:	c1 e0 0a             	shl    $0xa,%eax
80103b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b14:	2d 00 04 00 00       	sub    $0x400,%eax
80103b19:	83 ec 08             	sub    $0x8,%esp
80103b1c:	68 00 04 00 00       	push   $0x400
80103b21:	50                   	push   %eax
80103b22:	e8 00 ff ff ff       	call   80103a27 <mpsearch1>
80103b27:	83 c4 10             	add    $0x10,%esp
80103b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b31:	74 05                	je     80103b38 <mpsearch+0xa5>
      return mp;
80103b33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b36:	eb 15                	jmp    80103b4d <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b38:	83 ec 08             	sub    $0x8,%esp
80103b3b:	68 00 00 01 00       	push   $0x10000
80103b40:	68 00 00 0f 00       	push   $0xf0000
80103b45:	e8 dd fe ff ff       	call   80103a27 <mpsearch1>
80103b4a:	83 c4 10             	add    $0x10,%esp
}
80103b4d:	c9                   	leave  
80103b4e:	c3                   	ret    

80103b4f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b55:	e8 39 ff ff ff       	call   80103a93 <mpsearch>
80103b5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b61:	74 0a                	je     80103b6d <mpconfig+0x1e>
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	8b 40 04             	mov    0x4(%eax),%eax
80103b69:	85 c0                	test   %eax,%eax
80103b6b:	75 0a                	jne    80103b77 <mpconfig+0x28>
    return 0;
80103b6d:	b8 00 00 00 00       	mov    $0x0,%eax
80103b72:	e9 81 00 00 00       	jmp    80103bf8 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7a:	8b 40 04             	mov    0x4(%eax),%eax
80103b7d:	83 ec 0c             	sub    $0xc,%esp
80103b80:	50                   	push   %eax
80103b81:	e8 03 fe ff ff       	call   80103989 <p2v>
80103b86:	83 c4 10             	add    $0x10,%esp
80103b89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b8c:	83 ec 04             	sub    $0x4,%esp
80103b8f:	6a 04                	push   $0x4
80103b91:	68 3d 87 10 80       	push   $0x8010873d
80103b96:	ff 75 f0             	pushl  -0x10(%ebp)
80103b99:	e8 13 16 00 00       	call   801051b1 <memcmp>
80103b9e:	83 c4 10             	add    $0x10,%esp
80103ba1:	85 c0                	test   %eax,%eax
80103ba3:	74 07                	je     80103bac <mpconfig+0x5d>
    return 0;
80103ba5:	b8 00 00 00 00       	mov    $0x0,%eax
80103baa:	eb 4c                	jmp    80103bf8 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103baf:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bb3:	3c 01                	cmp    $0x1,%al
80103bb5:	74 12                	je     80103bc9 <mpconfig+0x7a>
80103bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bba:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bbe:	3c 04                	cmp    $0x4,%al
80103bc0:	74 07                	je     80103bc9 <mpconfig+0x7a>
    return 0;
80103bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc7:	eb 2f                	jmp    80103bf8 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bd0:	0f b7 c0             	movzwl %ax,%eax
80103bd3:	83 ec 08             	sub    $0x8,%esp
80103bd6:	50                   	push   %eax
80103bd7:	ff 75 f0             	pushl  -0x10(%ebp)
80103bda:	e8 10 fe ff ff       	call   801039ef <sum>
80103bdf:	83 c4 10             	add    $0x10,%esp
80103be2:	84 c0                	test   %al,%al
80103be4:	74 07                	je     80103bed <mpconfig+0x9e>
    return 0;
80103be6:	b8 00 00 00 00       	mov    $0x0,%eax
80103beb:	eb 0b                	jmp    80103bf8 <mpconfig+0xa9>
  *pmp = mp;
80103bed:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bf3:	89 10                	mov    %edx,(%eax)
  return conf;
80103bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bf8:	c9                   	leave  
80103bf9:	c3                   	ret    

80103bfa <mpinit>:

void
mpinit(void)
{
80103bfa:	55                   	push   %ebp
80103bfb:	89 e5                	mov    %esp,%ebp
80103bfd:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c00:	c7 05 64 b6 10 80 40 	movl   $0x80112440,0x8010b664
80103c07:	24 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c10:	50                   	push   %eax
80103c11:	e8 39 ff ff ff       	call   80103b4f <mpconfig>
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c20:	75 05                	jne    80103c27 <mpinit+0x2d>
    return;
80103c22:	e9 94 01 00 00       	jmp    80103dbb <mpinit+0x1c1>
  ismp = 1;
80103c27:	c7 05 04 24 11 80 01 	movl   $0x1,0x80112404
80103c2e:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c34:	8b 40 24             	mov    0x24(%eax),%eax
80103c37:	a3 dc 22 11 80       	mov    %eax,0x801122dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3f:	83 c0 2c             	add    $0x2c,%eax
80103c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c48:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c4c:	0f b7 d0             	movzwl %ax,%edx
80103c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c52:	01 d0                	add    %edx,%eax
80103c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c57:	e9 f2 00 00 00       	jmp    80103d4e <mpinit+0x154>
    switch(*p){
80103c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5f:	0f b6 00             	movzbl (%eax),%eax
80103c62:	0f b6 c0             	movzbl %al,%eax
80103c65:	83 f8 04             	cmp    $0x4,%eax
80103c68:	0f 87 bc 00 00 00    	ja     80103d2a <mpinit+0x130>
80103c6e:	8b 04 85 80 87 10 80 	mov    -0x7fef7880(,%eax,4),%eax
80103c75:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c80:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c84:	0f b6 d0             	movzbl %al,%edx
80103c87:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103c8c:	39 c2                	cmp    %eax,%edx
80103c8e:	74 2b                	je     80103cbb <mpinit+0xc1>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c93:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c97:	0f b6 d0             	movzbl %al,%edx
80103c9a:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103c9f:	83 ec 04             	sub    $0x4,%esp
80103ca2:	52                   	push   %edx
80103ca3:	50                   	push   %eax
80103ca4:	68 42 87 10 80       	push   $0x80108742
80103ca9:	e8 11 c7 ff ff       	call   801003bf <cprintf>
80103cae:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103cb1:	c7 05 04 24 11 80 00 	movl   $0x0,0x80112404
80103cb8:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cbe:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cc2:	0f b6 c0             	movzbl %al,%eax
80103cc5:	83 e0 02             	and    $0x2,%eax
80103cc8:	85 c0                	test   %eax,%eax
80103cca:	74 15                	je     80103ce1 <mpinit+0xe7>
        bcpu = &cpus[ncpu];
80103ccc:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103cd1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cd7:	05 40 24 11 80       	add    $0x80112440,%eax
80103cdc:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103ce1:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103ce6:	8b 15 20 2a 11 80    	mov    0x80112a20,%edx
80103cec:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cf2:	05 40 24 11 80       	add    $0x80112440,%eax
80103cf7:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103cf9:	a1 20 2a 11 80       	mov    0x80112a20,%eax
80103cfe:	83 c0 01             	add    $0x1,%eax
80103d01:	a3 20 2a 11 80       	mov    %eax,0x80112a20
      p += sizeof(struct mpproc);
80103d06:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d0a:	eb 42                	jmp    80103d4e <mpinit+0x154>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d15:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d19:	a2 00 24 11 80       	mov    %al,0x80112400
      p += sizeof(struct mpioapic);
80103d1e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d22:	eb 2a                	jmp    80103d4e <mpinit+0x154>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d24:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d28:	eb 24                	jmp    80103d4e <mpinit+0x154>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2d:	0f b6 00             	movzbl (%eax),%eax
80103d30:	0f b6 c0             	movzbl %al,%eax
80103d33:	83 ec 08             	sub    $0x8,%esp
80103d36:	50                   	push   %eax
80103d37:	68 60 87 10 80       	push   $0x80108760
80103d3c:	e8 7e c6 ff ff       	call   801003bf <cprintf>
80103d41:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103d44:	c7 05 04 24 11 80 00 	movl   $0x0,0x80112404
80103d4b:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d51:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d54:	0f 82 02 ff ff ff    	jb     80103c5c <mpinit+0x62>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d5a:	a1 04 24 11 80       	mov    0x80112404,%eax
80103d5f:	85 c0                	test   %eax,%eax
80103d61:	75 1d                	jne    80103d80 <mpinit+0x186>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d63:	c7 05 20 2a 11 80 01 	movl   $0x1,0x80112a20
80103d6a:	00 00 00 
    lapic = 0;
80103d6d:	c7 05 dc 22 11 80 00 	movl   $0x0,0x801122dc
80103d74:	00 00 00 
    ioapicid = 0;
80103d77:	c6 05 00 24 11 80 00 	movb   $0x0,0x80112400
    return;
80103d7e:	eb 3b                	jmp    80103dbb <mpinit+0x1c1>
  }

  if(mp->imcrp){
80103d80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d83:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d87:	84 c0                	test   %al,%al
80103d89:	74 30                	je     80103dbb <mpinit+0x1c1>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d8b:	83 ec 08             	sub    $0x8,%esp
80103d8e:	6a 70                	push   $0x70
80103d90:	6a 22                	push   $0x22
80103d92:	e8 1c fc ff ff       	call   801039b3 <outb>
80103d97:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d9a:	83 ec 0c             	sub    $0xc,%esp
80103d9d:	6a 23                	push   $0x23
80103d9f:	e8 f2 fb ff ff       	call   80103996 <inb>
80103da4:	83 c4 10             	add    $0x10,%esp
80103da7:	83 c8 01             	or     $0x1,%eax
80103daa:	0f b6 c0             	movzbl %al,%eax
80103dad:	83 ec 08             	sub    $0x8,%esp
80103db0:	50                   	push   %eax
80103db1:	6a 23                	push   $0x23
80103db3:	e8 fb fb ff ff       	call   801039b3 <outb>
80103db8:	83 c4 10             	add    $0x10,%esp
  }
}
80103dbb:	c9                   	leave  
80103dbc:	c3                   	ret    

80103dbd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dbd:	55                   	push   %ebp
80103dbe:	89 e5                	mov    %esp,%ebp
80103dc0:	83 ec 08             	sub    $0x8,%esp
80103dc3:	8b 55 08             	mov    0x8(%ebp),%edx
80103dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dcd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dd0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dd4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dd8:	ee                   	out    %al,(%dx)
}
80103dd9:	c9                   	leave  
80103dda:	c3                   	ret    

80103ddb <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ddb:	55                   	push   %ebp
80103ddc:	89 e5                	mov    %esp,%ebp
80103dde:	83 ec 04             	sub    $0x4,%esp
80103de1:	8b 45 08             	mov    0x8(%ebp),%eax
80103de4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103de8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dec:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103df2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103df6:	0f b6 c0             	movzbl %al,%eax
80103df9:	50                   	push   %eax
80103dfa:	6a 21                	push   $0x21
80103dfc:	e8 bc ff ff ff       	call   80103dbd <outb>
80103e01:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103e04:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e08:	66 c1 e8 08          	shr    $0x8,%ax
80103e0c:	0f b6 c0             	movzbl %al,%eax
80103e0f:	50                   	push   %eax
80103e10:	68 a1 00 00 00       	push   $0xa1
80103e15:	e8 a3 ff ff ff       	call   80103dbd <outb>
80103e1a:	83 c4 08             	add    $0x8,%esp
}
80103e1d:	c9                   	leave  
80103e1e:	c3                   	ret    

80103e1f <picenable>:

void
picenable(int irq)
{
80103e1f:	55                   	push   %ebp
80103e20:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103e22:	8b 45 08             	mov    0x8(%ebp),%eax
80103e25:	ba 01 00 00 00       	mov    $0x1,%edx
80103e2a:	89 c1                	mov    %eax,%ecx
80103e2c:	d3 e2                	shl    %cl,%edx
80103e2e:	89 d0                	mov    %edx,%eax
80103e30:	f7 d0                	not    %eax
80103e32:	89 c2                	mov    %eax,%edx
80103e34:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e3b:	21 d0                	and    %edx,%eax
80103e3d:	0f b7 c0             	movzwl %ax,%eax
80103e40:	50                   	push   %eax
80103e41:	e8 95 ff ff ff       	call   80103ddb <picsetmask>
80103e46:	83 c4 04             	add    $0x4,%esp
}
80103e49:	c9                   	leave  
80103e4a:	c3                   	ret    

80103e4b <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e4b:	55                   	push   %ebp
80103e4c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e4e:	68 ff 00 00 00       	push   $0xff
80103e53:	6a 21                	push   $0x21
80103e55:	e8 63 ff ff ff       	call   80103dbd <outb>
80103e5a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103e5d:	68 ff 00 00 00       	push   $0xff
80103e62:	68 a1 00 00 00       	push   $0xa1
80103e67:	e8 51 ff ff ff       	call   80103dbd <outb>
80103e6c:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e6f:	6a 11                	push   $0x11
80103e71:	6a 20                	push   $0x20
80103e73:	e8 45 ff ff ff       	call   80103dbd <outb>
80103e78:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e7b:	6a 20                	push   $0x20
80103e7d:	6a 21                	push   $0x21
80103e7f:	e8 39 ff ff ff       	call   80103dbd <outb>
80103e84:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e87:	6a 04                	push   $0x4
80103e89:	6a 21                	push   $0x21
80103e8b:	e8 2d ff ff ff       	call   80103dbd <outb>
80103e90:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e93:	6a 03                	push   $0x3
80103e95:	6a 21                	push   $0x21
80103e97:	e8 21 ff ff ff       	call   80103dbd <outb>
80103e9c:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e9f:	6a 11                	push   $0x11
80103ea1:	68 a0 00 00 00       	push   $0xa0
80103ea6:	e8 12 ff ff ff       	call   80103dbd <outb>
80103eab:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103eae:	6a 28                	push   $0x28
80103eb0:	68 a1 00 00 00       	push   $0xa1
80103eb5:	e8 03 ff ff ff       	call   80103dbd <outb>
80103eba:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ebd:	6a 02                	push   $0x2
80103ebf:	68 a1 00 00 00       	push   $0xa1
80103ec4:	e8 f4 fe ff ff       	call   80103dbd <outb>
80103ec9:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ecc:	6a 03                	push   $0x3
80103ece:	68 a1 00 00 00       	push   $0xa1
80103ed3:	e8 e5 fe ff ff       	call   80103dbd <outb>
80103ed8:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103edb:	6a 68                	push   $0x68
80103edd:	6a 20                	push   $0x20
80103edf:	e8 d9 fe ff ff       	call   80103dbd <outb>
80103ee4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ee7:	6a 0a                	push   $0xa
80103ee9:	6a 20                	push   $0x20
80103eeb:	e8 cd fe ff ff       	call   80103dbd <outb>
80103ef0:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103ef3:	6a 68                	push   $0x68
80103ef5:	68 a0 00 00 00       	push   $0xa0
80103efa:	e8 be fe ff ff       	call   80103dbd <outb>
80103eff:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103f02:	6a 0a                	push   $0xa
80103f04:	68 a0 00 00 00       	push   $0xa0
80103f09:	e8 af fe ff ff       	call   80103dbd <outb>
80103f0e:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103f11:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f18:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f1c:	74 13                	je     80103f31 <picinit+0xe6>
    picsetmask(irqmask);
80103f1e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f25:	0f b7 c0             	movzwl %ax,%eax
80103f28:	50                   	push   %eax
80103f29:	e8 ad fe ff ff       	call   80103ddb <picsetmask>
80103f2e:	83 c4 04             	add    $0x4,%esp
}
80103f31:	c9                   	leave  
80103f32:	c3                   	ret    

80103f33 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f4c:	8b 10                	mov    (%eax),%edx
80103f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f51:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f53:	e8 f8 cf ff ff       	call   80100f50 <filealloc>
80103f58:	89 c2                	mov    %eax,%edx
80103f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5d:	89 10                	mov    %edx,(%eax)
80103f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f62:	8b 00                	mov    (%eax),%eax
80103f64:	85 c0                	test   %eax,%eax
80103f66:	0f 84 cb 00 00 00    	je     80104037 <pipealloc+0x104>
80103f6c:	e8 df cf ff ff       	call   80100f50 <filealloc>
80103f71:	89 c2                	mov    %eax,%edx
80103f73:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f76:	89 10                	mov    %edx,(%eax)
80103f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f7b:	8b 00                	mov    (%eax),%eax
80103f7d:	85 c0                	test   %eax,%eax
80103f7f:	0f 84 b2 00 00 00    	je     80104037 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f85:	e8 fb eb ff ff       	call   80102b85 <kalloc>
80103f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f91:	75 05                	jne    80103f98 <pipealloc+0x65>
    goto bad;
80103f93:	e9 9f 00 00 00       	jmp    80104037 <pipealloc+0x104>
  p->readopen = 1;
80103f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fa2:	00 00 00 
  p->writeopen = 1;
80103fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103faf:	00 00 00 
  p->nwrite = 0;
80103fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fbc:	00 00 00 
  p->nread = 0;
80103fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fc9:	00 00 00 
  initlock(&p->lock, "pipe");
80103fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcf:	83 ec 08             	sub    $0x8,%esp
80103fd2:	68 94 87 10 80       	push   $0x80108794
80103fd7:	50                   	push   %eax
80103fd8:	e8 f0 0e 00 00       	call   80104ecd <initlock>
80103fdd:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	8b 00                	mov    (%eax),%eax
80103fe5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103feb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fee:	8b 00                	mov    (%eax),%eax
80103ff0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff7:	8b 00                	mov    (%eax),%eax
80103ff9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80104000:	8b 00                	mov    (%eax),%eax
80104002:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104005:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010400b:	8b 00                	mov    (%eax),%eax
8010400d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104013:	8b 45 0c             	mov    0xc(%ebp),%eax
80104016:	8b 00                	mov    (%eax),%eax
80104018:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010401c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401f:	8b 00                	mov    (%eax),%eax
80104021:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104025:	8b 45 0c             	mov    0xc(%ebp),%eax
80104028:	8b 00                	mov    (%eax),%eax
8010402a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010402d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104030:	b8 00 00 00 00       	mov    $0x0,%eax
80104035:	eb 4d                	jmp    80104084 <pipealloc+0x151>

//PAGEBREAK: 20
 bad:
  if(p)
80104037:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010403b:	74 0e                	je     8010404b <pipealloc+0x118>
    kfree((char*)p);
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	ff 75 f4             	pushl  -0xc(%ebp)
80104043:	e8 a1 ea ff ff       	call   80102ae9 <kfree>
80104048:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010404b:	8b 45 08             	mov    0x8(%ebp),%eax
8010404e:	8b 00                	mov    (%eax),%eax
80104050:	85 c0                	test   %eax,%eax
80104052:	74 11                	je     80104065 <pipealloc+0x132>
    fileclose(*f0);
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 00                	mov    (%eax),%eax
80104059:	83 ec 0c             	sub    $0xc,%esp
8010405c:	50                   	push   %eax
8010405d:	e8 ab cf ff ff       	call   8010100d <fileclose>
80104062:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104065:	8b 45 0c             	mov    0xc(%ebp),%eax
80104068:	8b 00                	mov    (%eax),%eax
8010406a:	85 c0                	test   %eax,%eax
8010406c:	74 11                	je     8010407f <pipealloc+0x14c>
    fileclose(*f1);
8010406e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	83 ec 0c             	sub    $0xc,%esp
80104076:	50                   	push   %eax
80104077:	e8 91 cf ff ff       	call   8010100d <fileclose>
8010407c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010407f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104084:	c9                   	leave  
80104085:	c3                   	ret    

80104086 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104086:	55                   	push   %ebp
80104087:	89 e5                	mov    %esp,%ebp
80104089:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010408c:	8b 45 08             	mov    0x8(%ebp),%eax
8010408f:	83 ec 0c             	sub    $0xc,%esp
80104092:	50                   	push   %eax
80104093:	e8 56 0e 00 00       	call   80104eee <acquire>
80104098:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010409b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010409f:	74 23                	je     801040c4 <pipeclose+0x3e>
    p->writeopen = 0;
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040ab:	00 00 00 
    wakeup(&p->nread);
801040ae:	8b 45 08             	mov    0x8(%ebp),%eax
801040b1:	05 34 02 00 00       	add    $0x234,%eax
801040b6:	83 ec 0c             	sub    $0xc,%esp
801040b9:	50                   	push   %eax
801040ba:	e8 22 0c 00 00       	call   80104ce1 <wakeup>
801040bf:	83 c4 10             	add    $0x10,%esp
801040c2:	eb 21                	jmp    801040e5 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040ce:	00 00 00 
    wakeup(&p->nwrite);
801040d1:	8b 45 08             	mov    0x8(%ebp),%eax
801040d4:	05 38 02 00 00       	add    $0x238,%eax
801040d9:	83 ec 0c             	sub    $0xc,%esp
801040dc:	50                   	push   %eax
801040dd:	e8 ff 0b 00 00       	call   80104ce1 <wakeup>
801040e2:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040e5:	8b 45 08             	mov    0x8(%ebp),%eax
801040e8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040ee:	85 c0                	test   %eax,%eax
801040f0:	75 2c                	jne    8010411e <pipeclose+0x98>
801040f2:	8b 45 08             	mov    0x8(%ebp),%eax
801040f5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040fb:	85 c0                	test   %eax,%eax
801040fd:	75 1f                	jne    8010411e <pipeclose+0x98>
    release(&p->lock);
801040ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104102:	83 ec 0c             	sub    $0xc,%esp
80104105:	50                   	push   %eax
80104106:	e8 49 0e 00 00       	call   80104f54 <release>
8010410b:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010410e:	83 ec 0c             	sub    $0xc,%esp
80104111:	ff 75 08             	pushl  0x8(%ebp)
80104114:	e8 d0 e9 ff ff       	call   80102ae9 <kfree>
80104119:	83 c4 10             	add    $0x10,%esp
8010411c:	eb 0f                	jmp    8010412d <pipeclose+0xa7>
  } else
    release(&p->lock);
8010411e:	8b 45 08             	mov    0x8(%ebp),%eax
80104121:	83 ec 0c             	sub    $0xc,%esp
80104124:	50                   	push   %eax
80104125:	e8 2a 0e 00 00       	call   80104f54 <release>
8010412a:	83 c4 10             	add    $0x10,%esp
}
8010412d:	c9                   	leave  
8010412e:	c3                   	ret    

8010412f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010412f:	55                   	push   %ebp
80104130:	89 e5                	mov    %esp,%ebp
80104132:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104135:	8b 45 08             	mov    0x8(%ebp),%eax
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	50                   	push   %eax
8010413c:	e8 ad 0d 00 00       	call   80104eee <acquire>
80104141:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104144:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010414b:	e9 af 00 00 00       	jmp    801041ff <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104150:	eb 60                	jmp    801041b2 <pipewrite+0x83>
      if(p->readopen == 0 || proc->killed){
80104152:	8b 45 08             	mov    0x8(%ebp),%eax
80104155:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010415b:	85 c0                	test   %eax,%eax
8010415d:	74 0d                	je     8010416c <pipewrite+0x3d>
8010415f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104165:	8b 40 24             	mov    0x24(%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	74 19                	je     80104185 <pipewrite+0x56>
        release(&p->lock);
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	83 ec 0c             	sub    $0xc,%esp
80104172:	50                   	push   %eax
80104173:	e8 dc 0d 00 00       	call   80104f54 <release>
80104178:	83 c4 10             	add    $0x10,%esp
        return -1;
8010417b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104180:	e9 ac 00 00 00       	jmp    80104231 <pipewrite+0x102>
      }
      wakeup(&p->nread);
80104185:	8b 45 08             	mov    0x8(%ebp),%eax
80104188:	05 34 02 00 00       	add    $0x234,%eax
8010418d:	83 ec 0c             	sub    $0xc,%esp
80104190:	50                   	push   %eax
80104191:	e8 4b 0b 00 00       	call   80104ce1 <wakeup>
80104196:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	8b 55 08             	mov    0x8(%ebp),%edx
8010419f:	81 c2 38 02 00 00    	add    $0x238,%edx
801041a5:	83 ec 08             	sub    $0x8,%esp
801041a8:	50                   	push   %eax
801041a9:	52                   	push   %edx
801041aa:	e8 46 0a 00 00       	call   80104bf5 <sleep>
801041af:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041bb:	8b 45 08             	mov    0x8(%ebp),%eax
801041be:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041c4:	05 00 02 00 00       	add    $0x200,%eax
801041c9:	39 c2                	cmp    %eax,%edx
801041cb:	74 85                	je     80104152 <pipewrite+0x23>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041cd:	8b 45 08             	mov    0x8(%ebp),%eax
801041d0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041d6:	8d 48 01             	lea    0x1(%eax),%ecx
801041d9:	8b 55 08             	mov    0x8(%ebp),%edx
801041dc:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041e2:	25 ff 01 00 00       	and    $0x1ff,%eax
801041e7:	89 c1                	mov    %eax,%ecx
801041e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ef:	01 d0                	add    %edx,%eax
801041f1:	0f b6 10             	movzbl (%eax),%edx
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104202:	3b 45 10             	cmp    0x10(%ebp),%eax
80104205:	0f 8c 45 ff ff ff    	jl     80104150 <pipewrite+0x21>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010420b:	8b 45 08             	mov    0x8(%ebp),%eax
8010420e:	05 34 02 00 00       	add    $0x234,%eax
80104213:	83 ec 0c             	sub    $0xc,%esp
80104216:	50                   	push   %eax
80104217:	e8 c5 0a 00 00       	call   80104ce1 <wakeup>
8010421c:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010421f:	8b 45 08             	mov    0x8(%ebp),%eax
80104222:	83 ec 0c             	sub    $0xc,%esp
80104225:	50                   	push   %eax
80104226:	e8 29 0d 00 00       	call   80104f54 <release>
8010422b:	83 c4 10             	add    $0x10,%esp
  return n;
8010422e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104231:	c9                   	leave  
80104232:	c3                   	ret    

80104233 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104233:	55                   	push   %ebp
80104234:	89 e5                	mov    %esp,%ebp
80104236:	53                   	push   %ebx
80104237:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010423a:	8b 45 08             	mov    0x8(%ebp),%eax
8010423d:	83 ec 0c             	sub    $0xc,%esp
80104240:	50                   	push   %eax
80104241:	e8 a8 0c 00 00       	call   80104eee <acquire>
80104246:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104249:	eb 3f                	jmp    8010428a <piperead+0x57>
    if(proc->killed){
8010424b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104251:	8b 40 24             	mov    0x24(%eax),%eax
80104254:	85 c0                	test   %eax,%eax
80104256:	74 19                	je     80104271 <piperead+0x3e>
      release(&p->lock);
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	50                   	push   %eax
8010425f:	e8 f0 0c 00 00       	call   80104f54 <release>
80104264:	83 c4 10             	add    $0x10,%esp
      return -1;
80104267:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426c:	e9 be 00 00 00       	jmp    8010432f <piperead+0xfc>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 55 08             	mov    0x8(%ebp),%edx
80104277:	81 c2 34 02 00 00    	add    $0x234,%edx
8010427d:	83 ec 08             	sub    $0x8,%esp
80104280:	50                   	push   %eax
80104281:	52                   	push   %edx
80104282:	e8 6e 09 00 00       	call   80104bf5 <sleep>
80104287:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010428a:	8b 45 08             	mov    0x8(%ebp),%eax
8010428d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010429c:	39 c2                	cmp    %eax,%edx
8010429e:	75 0d                	jne    801042ad <piperead+0x7a>
801042a0:	8b 45 08             	mov    0x8(%ebp),%eax
801042a3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	75 9e                	jne    8010424b <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042b4:	eb 4b                	jmp    80104301 <piperead+0xce>
    if(p->nread == p->nwrite)
801042b6:	8b 45 08             	mov    0x8(%ebp),%eax
801042b9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c8:	39 c2                	cmp    %eax,%edx
801042ca:	75 02                	jne    801042ce <piperead+0x9b>
      break;
801042cc:	eb 3b                	jmp    80104309 <piperead+0xd6>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042d7:	8b 45 08             	mov    0x8(%ebp),%eax
801042da:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042e0:	8d 48 01             	lea    0x1(%eax),%ecx
801042e3:	8b 55 08             	mov    0x8(%ebp),%edx
801042e6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042ec:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f1:	89 c2                	mov    %eax,%edx
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801042fb:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104304:	3b 45 10             	cmp    0x10(%ebp),%eax
80104307:	7c ad                	jl     801042b6 <piperead+0x83>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104309:	8b 45 08             	mov    0x8(%ebp),%eax
8010430c:	05 38 02 00 00       	add    $0x238,%eax
80104311:	83 ec 0c             	sub    $0xc,%esp
80104314:	50                   	push   %eax
80104315:	e8 c7 09 00 00       	call   80104ce1 <wakeup>
8010431a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010431d:	8b 45 08             	mov    0x8(%ebp),%eax
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	50                   	push   %eax
80104324:	e8 2b 0c 00 00       	call   80104f54 <release>
80104329:	83 c4 10             	add    $0x10,%esp
  return i;
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010432f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104332:	c9                   	leave  
80104333:	c3                   	ret    

80104334 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104334:	55                   	push   %ebp
80104335:	89 e5                	mov    %esp,%ebp
80104337:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010433a:	9c                   	pushf  
8010433b:	58                   	pop    %eax
8010433c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010433f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104342:	c9                   	leave  
80104343:	c3                   	ret    

80104344 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104347:	fb                   	sti    
}
80104348:	5d                   	pop    %ebp
80104349:	c3                   	ret    

8010434a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010434a:	55                   	push   %ebp
8010434b:	89 e5                	mov    %esp,%ebp
8010434d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104350:	83 ec 08             	sub    $0x8,%esp
80104353:	68 99 87 10 80       	push   $0x80108799
80104358:	68 40 2a 11 80       	push   $0x80112a40
8010435d:	e8 6b 0b 00 00       	call   80104ecd <initlock>
80104362:	83 c4 10             	add    $0x10,%esp
}
80104365:	c9                   	leave  
80104366:	c3                   	ret    

80104367 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104367:	55                   	push   %ebp
80104368:	89 e5                	mov    %esp,%ebp
8010436a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	68 40 2a 11 80       	push   $0x80112a40
80104375:	e8 74 0b 00 00       	call   80104eee <acquire>
8010437a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010437d:	c7 45 f4 74 2a 11 80 	movl   $0x80112a74,-0xc(%ebp)
80104384:	eb 59                	jmp    801043df <allocproc+0x78>
    if(p->state == UNUSED)
80104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104389:	8b 40 0c             	mov    0xc(%eax),%eax
8010438c:	85 c0                	test   %eax,%eax
8010438e:	75 48                	jne    801043d8 <allocproc+0x71>
      goto found;
80104390:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104394:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010439b:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043a0:	8d 50 01             	lea    0x1(%eax),%edx
801043a3:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801043a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ac:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	68 40 2a 11 80       	push   $0x80112a40
801043b7:	e8 98 0b 00 00       	call   80104f54 <release>
801043bc:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043bf:	e8 c1 e7 ff ff       	call   80102b85 <kalloc>
801043c4:	89 c2                	mov    %eax,%edx
801043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c9:	89 50 08             	mov    %edx,0x8(%eax)
801043cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cf:	8b 40 08             	mov    0x8(%eax),%eax
801043d2:	85 c0                	test   %eax,%eax
801043d4:	75 3a                	jne    80104410 <allocproc+0xa9>
801043d6:	eb 27                	jmp    801043ff <allocproc+0x98>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d8:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801043df:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
801043e6:	72 9e                	jb     80104386 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043e8:	83 ec 0c             	sub    $0xc,%esp
801043eb:	68 40 2a 11 80       	push   $0x80112a40
801043f0:	e8 5f 0b 00 00       	call   80104f54 <release>
801043f5:	83 c4 10             	add    $0x10,%esp
  return 0;
801043f8:	b8 00 00 00 00       	mov    $0x0,%eax
801043fd:	eb 78                	jmp    80104477 <allocproc+0x110>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104402:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104409:	b8 00 00 00 00       	mov    $0x0,%eax
8010440e:	eb 67                	jmp    80104477 <allocproc+0x110>
  }
  sp = p->kstack + KSTACKSIZE;
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 40 08             	mov    0x8(%eax),%eax
80104416:	05 00 10 00 00       	add    $0x1000,%eax
8010441b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010441e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104425:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104428:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010442b:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010442f:	ba ef 65 10 80       	mov    $0x801065ef,%edx
80104434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104437:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104439:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010443d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104440:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104443:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 40 1c             	mov    0x1c(%eax),%eax
8010444c:	83 ec 04             	sub    $0x4,%esp
8010444f:	6a 14                	push   $0x14
80104451:	6a 00                	push   $0x0
80104453:	50                   	push   %eax
80104454:	e8 f1 0c 00 00       	call   8010514a <memset>
80104459:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104462:	ba c5 4b 10 80       	mov    $0x80104bc5,%edx
80104467:	89 50 10             	mov    %edx,0x10(%eax)

  p->traceFlag = 0;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  return p;
80104474:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104477:	c9                   	leave  
80104478:	c3                   	ret    

80104479 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104479:	55                   	push   %ebp
8010447a:	89 e5                	mov    %esp,%ebp
8010447c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010447f:	e8 e3 fe ff ff       	call   80104367 <allocproc>
80104484:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448a:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
8010448f:	e8 14 38 00 00       	call   80107ca8 <setupkvm>
80104494:	89 c2                	mov    %eax,%edx
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	89 50 04             	mov    %edx,0x4(%eax)
8010449c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449f:	8b 40 04             	mov    0x4(%eax),%eax
801044a2:	85 c0                	test   %eax,%eax
801044a4:	75 0d                	jne    801044b3 <userinit+0x3a>
    panic("userinit: out of memory?");
801044a6:	83 ec 0c             	sub    $0xc,%esp
801044a9:	68 a0 87 10 80       	push   $0x801087a0
801044ae:	e8 a9 c0 ff ff       	call   8010055c <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044b3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bb:	8b 40 04             	mov    0x4(%eax),%eax
801044be:	83 ec 04             	sub    $0x4,%esp
801044c1:	52                   	push   %edx
801044c2:	68 00 b5 10 80       	push   $0x8010b500
801044c7:	50                   	push   %eax
801044c8:	e8 32 3a 00 00       	call   80107eff <inituvm>
801044cd:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	8b 40 18             	mov    0x18(%eax),%eax
801044df:	83 ec 04             	sub    $0x4,%esp
801044e2:	6a 4c                	push   $0x4c
801044e4:	6a 00                	push   $0x0
801044e6:	50                   	push   %eax
801044e7:	e8 5e 0c 00 00       	call   8010514a <memset>
801044ec:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f2:	8b 40 18             	mov    0x18(%eax),%eax
801044f5:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	8b 40 18             	mov    0x18(%eax),%eax
80104501:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450a:	8b 40 18             	mov    0x18(%eax),%eax
8010450d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104510:	8b 52 18             	mov    0x18(%edx),%edx
80104513:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104517:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	8b 40 18             	mov    0x18(%eax),%eax
80104521:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104524:	8b 52 18             	mov    0x18(%edx),%edx
80104527:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010452b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	8b 40 18             	mov    0x18(%eax),%eax
80104535:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453f:	8b 40 18             	mov    0x18(%eax),%eax
80104542:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	8b 40 18             	mov    0x18(%eax),%eax
8010454f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104559:	83 c0 6c             	add    $0x6c,%eax
8010455c:	83 ec 04             	sub    $0x4,%esp
8010455f:	6a 10                	push   $0x10
80104561:	68 b9 87 10 80       	push   $0x801087b9
80104566:	50                   	push   %eax
80104567:	e8 e3 0d 00 00       	call   8010534f <safestrcpy>
8010456c:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010456f:	83 ec 0c             	sub    $0xc,%esp
80104572:	68 c2 87 10 80       	push   $0x801087c2
80104577:	e8 15 df ff ff       	call   80102491 <namei>
8010457c:	83 c4 10             	add    $0x10,%esp
8010457f:	89 c2                	mov    %eax,%edx
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104591:	c9                   	leave  
80104592:	c3                   	ret    

80104593 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104593:	55                   	push   %ebp
80104594:	89 e5                	mov    %esp,%ebp
80104596:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104599:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010459f:	8b 00                	mov    (%eax),%eax
801045a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045a8:	7e 31                	jle    801045db <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045aa:	8b 55 08             	mov    0x8(%ebp),%edx
801045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b0:	01 c2                	add    %eax,%edx
801045b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b8:	8b 40 04             	mov    0x4(%eax),%eax
801045bb:	83 ec 04             	sub    $0x4,%esp
801045be:	52                   	push   %edx
801045bf:	ff 75 f4             	pushl  -0xc(%ebp)
801045c2:	50                   	push   %eax
801045c3:	e8 83 3a 00 00       	call   8010804b <allocuvm>
801045c8:	83 c4 10             	add    $0x10,%esp
801045cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045d2:	75 3e                	jne    80104612 <growproc+0x7f>
      return -1;
801045d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045d9:	eb 59                	jmp    80104634 <growproc+0xa1>
  } else if(n < 0){
801045db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045df:	79 31                	jns    80104612 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045e1:	8b 55 08             	mov    0x8(%ebp),%edx
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	01 c2                	add    %eax,%edx
801045e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ef:	8b 40 04             	mov    0x4(%eax),%eax
801045f2:	83 ec 04             	sub    $0x4,%esp
801045f5:	52                   	push   %edx
801045f6:	ff 75 f4             	pushl  -0xc(%ebp)
801045f9:	50                   	push   %eax
801045fa:	e8 15 3b 00 00       	call   80108114 <deallocuvm>
801045ff:	83 c4 10             	add    $0x10,%esp
80104602:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104605:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104609:	75 07                	jne    80104612 <growproc+0x7f>
      return -1;
8010460b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104610:	eb 22                	jmp    80104634 <growproc+0xa1>
  }
  proc->sz = sz;
80104612:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010461b:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010461d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104623:	83 ec 0c             	sub    $0xc,%esp
80104626:	50                   	push   %eax
80104627:	e8 61 37 00 00       	call   80107d8d <switchuvm>
8010462c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010462f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104634:	c9                   	leave  
80104635:	c3                   	ret    

80104636 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104636:	55                   	push   %ebp
80104637:	89 e5                	mov    %esp,%ebp
80104639:	57                   	push   %edi
8010463a:	56                   	push   %esi
8010463b:	53                   	push   %ebx
8010463c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010463f:	e8 23 fd ff ff       	call   80104367 <allocproc>
80104644:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104647:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010464b:	75 0a                	jne    80104657 <fork+0x21>
    return -1;
8010464d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104652:	e9 68 01 00 00       	jmp    801047bf <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104657:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010465d:	8b 10                	mov    (%eax),%edx
8010465f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104665:	8b 40 04             	mov    0x4(%eax),%eax
80104668:	83 ec 08             	sub    $0x8,%esp
8010466b:	52                   	push   %edx
8010466c:	50                   	push   %eax
8010466d:	e8 3e 3c 00 00       	call   801082b0 <copyuvm>
80104672:	83 c4 10             	add    $0x10,%esp
80104675:	89 c2                	mov    %eax,%edx
80104677:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010467a:	89 50 04             	mov    %edx,0x4(%eax)
8010467d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104680:	8b 40 04             	mov    0x4(%eax),%eax
80104683:	85 c0                	test   %eax,%eax
80104685:	75 30                	jne    801046b7 <fork+0x81>
    kfree(np->kstack);
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	8b 40 08             	mov    0x8(%eax),%eax
8010468d:	83 ec 0c             	sub    $0xc,%esp
80104690:	50                   	push   %eax
80104691:	e8 53 e4 ff ff       	call   80102ae9 <kfree>
80104696:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104699:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b2:	e9 08 01 00 00       	jmp    801047bf <fork+0x189>
  }
  np->sz = proc->sz;
801046b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bd:	8b 10                	mov    (%eax),%edx
801046bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046c4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ce:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d4:	8b 50 18             	mov    0x18(%eax),%edx
801046d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046dd:	8b 40 18             	mov    0x18(%eax),%eax
801046e0:	89 c3                	mov    %eax,%ebx
801046e2:	b8 13 00 00 00       	mov    $0x13,%eax
801046e7:	89 d7                	mov    %edx,%edi
801046e9:	89 de                	mov    %ebx,%esi
801046eb:	89 c1                	mov    %eax,%ecx
801046ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f2:	8b 40 18             	mov    0x18(%eax),%eax
801046f5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104703:	eb 43                	jmp    80104748 <fork+0x112>
    if(proc->ofile[i])
80104705:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010470e:	83 c2 08             	add    $0x8,%edx
80104711:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104715:	85 c0                	test   %eax,%eax
80104717:	74 2b                	je     80104744 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104719:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104722:	83 c2 08             	add    $0x8,%edx
80104725:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104729:	83 ec 0c             	sub    $0xc,%esp
8010472c:	50                   	push   %eax
8010472d:	e8 8a c8 ff ff       	call   80100fbc <filedup>
80104732:	83 c4 10             	add    $0x10,%esp
80104735:	89 c1                	mov    %eax,%ecx
80104737:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010473d:	83 c2 08             	add    $0x8,%edx
80104740:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104744:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104748:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010474c:	7e b7                	jle    80104705 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010474e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104754:	8b 40 68             	mov    0x68(%eax),%eax
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	50                   	push   %eax
8010475b:	e8 42 d1 ff ff       	call   801018a2 <idup>
80104760:	83 c4 10             	add    $0x10,%esp
80104763:	89 c2                	mov    %eax,%edx
80104765:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104768:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010476b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104771:	8d 50 6c             	lea    0x6c(%eax),%edx
80104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104777:	83 c0 6c             	add    $0x6c,%eax
8010477a:	83 ec 04             	sub    $0x4,%esp
8010477d:	6a 10                	push   $0x10
8010477f:	52                   	push   %edx
80104780:	50                   	push   %eax
80104781:	e8 c9 0b 00 00       	call   8010534f <safestrcpy>
80104786:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104789:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478c:	8b 40 10             	mov    0x10(%eax),%eax
8010478f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 40 2a 11 80       	push   $0x80112a40
8010479a:	e8 4f 07 00 00       	call   80104eee <acquire>
8010479f:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801047a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047ac:	83 ec 0c             	sub    $0xc,%esp
801047af:	68 40 2a 11 80       	push   $0x80112a40
801047b4:	e8 9b 07 00 00       	call   80104f54 <release>
801047b9:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801047bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047c2:	5b                   	pop    %ebx
801047c3:	5e                   	pop    %esi
801047c4:	5f                   	pop    %edi
801047c5:	5d                   	pop    %ebp
801047c6:	c3                   	ret    

801047c7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047c7:	55                   	push   %ebp
801047c8:	89 e5                	mov    %esp,%ebp
801047ca:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047cd:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047d4:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801047d9:	39 c2                	cmp    %eax,%edx
801047db:	75 0d                	jne    801047ea <exit+0x23>
    panic("init exiting");
801047dd:	83 ec 0c             	sub    $0xc,%esp
801047e0:	68 c4 87 10 80       	push   $0x801087c4
801047e5:	e8 72 bd ff ff       	call   8010055c <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047f1:	eb 48                	jmp    8010483b <exit+0x74>
    if(proc->ofile[fd]){
801047f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fc:	83 c2 08             	add    $0x8,%edx
801047ff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104803:	85 c0                	test   %eax,%eax
80104805:	74 30                	je     80104837 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104807:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104810:	83 c2 08             	add    $0x8,%edx
80104813:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104817:	83 ec 0c             	sub    $0xc,%esp
8010481a:	50                   	push   %eax
8010481b:	e8 ed c7 ff ff       	call   8010100d <fileclose>
80104820:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104823:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104829:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010482c:	83 c2 08             	add    $0x8,%edx
8010482f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104836:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104837:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010483b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010483f:	7e b2                	jle    801047f3 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104841:	e8 20 ec ff ff       	call   80103466 <begin_op>
  iput(proc->cwd);
80104846:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484c:	8b 40 68             	mov    0x68(%eax),%eax
8010484f:	83 ec 0c             	sub    $0xc,%esp
80104852:	50                   	push   %eax
80104853:	e8 4c d2 ff ff       	call   80101aa4 <iput>
80104858:	83 c4 10             	add    $0x10,%esp
  end_op();
8010485b:	e8 94 ec ff ff       	call   801034f4 <end_op>
  proc->cwd = 0;
80104860:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104866:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010486d:	83 ec 0c             	sub    $0xc,%esp
80104870:	68 40 2a 11 80       	push   $0x80112a40
80104875:	e8 74 06 00 00       	call   80104eee <acquire>
8010487a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010487d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104883:	8b 40 14             	mov    0x14(%eax),%eax
80104886:	83 ec 0c             	sub    $0xc,%esp
80104889:	50                   	push   %eax
8010488a:	e8 11 04 00 00       	call   80104ca0 <wakeup1>
8010488f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104892:	c7 45 f4 74 2a 11 80 	movl   $0x80112a74,-0xc(%ebp)
80104899:	eb 3f                	jmp    801048da <exit+0x113>
    if(p->parent == proc){
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	8b 50 14             	mov    0x14(%eax),%edx
801048a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a7:	39 c2                	cmp    %eax,%edx
801048a9:	75 28                	jne    801048d3 <exit+0x10c>
      p->parent = initproc;
801048ab:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801048b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	8b 40 0c             	mov    0xc(%eax),%eax
801048bd:	83 f8 05             	cmp    $0x5,%eax
801048c0:	75 11                	jne    801048d3 <exit+0x10c>
        wakeup1(initproc);
801048c2:	a1 68 b6 10 80       	mov    0x8010b668,%eax
801048c7:	83 ec 0c             	sub    $0xc,%esp
801048ca:	50                   	push   %eax
801048cb:	e8 d0 03 00 00       	call   80104ca0 <wakeup1>
801048d0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d3:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048da:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
801048e1:	72 b8                	jb     8010489b <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048f0:	e8 db 01 00 00       	call   80104ad0 <sched>
  panic("zombie exit");
801048f5:	83 ec 0c             	sub    $0xc,%esp
801048f8:	68 d1 87 10 80       	push   $0x801087d1
801048fd:	e8 5a bc ff ff       	call   8010055c <panic>

80104902 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104902:	55                   	push   %ebp
80104903:	89 e5                	mov    %esp,%ebp
80104905:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104908:	83 ec 0c             	sub    $0xc,%esp
8010490b:	68 40 2a 11 80       	push   $0x80112a40
80104910:	e8 d9 05 00 00       	call   80104eee <acquire>
80104915:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104918:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010491f:	c7 45 f4 74 2a 11 80 	movl   $0x80112a74,-0xc(%ebp)
80104926:	e9 a9 00 00 00       	jmp    801049d4 <wait+0xd2>
      if(p->parent != proc)
8010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492e:	8b 50 14             	mov    0x14(%eax),%edx
80104931:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104937:	39 c2                	cmp    %eax,%edx
80104939:	74 05                	je     80104940 <wait+0x3e>
        continue;
8010493b:	e9 8d 00 00 00       	jmp    801049cd <wait+0xcb>
      havekids = 1;
80104940:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494a:	8b 40 0c             	mov    0xc(%eax),%eax
8010494d:	83 f8 05             	cmp    $0x5,%eax
80104950:	75 7b                	jne    801049cd <wait+0xcb>
        // Found one.
        pid = p->pid;
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 40 10             	mov    0x10(%eax),%eax
80104958:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 40 08             	mov    0x8(%eax),%eax
80104961:	83 ec 0c             	sub    $0xc,%esp
80104964:	50                   	push   %eax
80104965:	e8 7f e1 ff ff       	call   80102ae9 <kfree>
8010496a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010496d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104970:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 04             	mov    0x4(%eax),%eax
8010497d:	83 ec 0c             	sub    $0xc,%esp
80104980:	50                   	push   %eax
80104981:	e8 4b 38 00 00       	call   801081d1 <freevm>
80104986:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104996:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049b8:	83 ec 0c             	sub    $0xc,%esp
801049bb:	68 40 2a 11 80       	push   $0x80112a40
801049c0:	e8 8f 05 00 00       	call   80104f54 <release>
801049c5:	83 c4 10             	add    $0x10,%esp
        return pid;
801049c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049cb:	eb 5a                	jmp    80104a27 <wait+0x125>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049cd:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049d4:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
801049db:	0f 82 4a ff ff ff    	jb     8010492b <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049e5:	74 0d                	je     801049f4 <wait+0xf2>
801049e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ed:	8b 40 24             	mov    0x24(%eax),%eax
801049f0:	85 c0                	test   %eax,%eax
801049f2:	74 17                	je     80104a0b <wait+0x109>
      release(&ptable.lock);
801049f4:	83 ec 0c             	sub    $0xc,%esp
801049f7:	68 40 2a 11 80       	push   $0x80112a40
801049fc:	e8 53 05 00 00       	call   80104f54 <release>
80104a01:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a09:	eb 1c                	jmp    80104a27 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a11:	83 ec 08             	sub    $0x8,%esp
80104a14:	68 40 2a 11 80       	push   $0x80112a40
80104a19:	50                   	push   %eax
80104a1a:	e8 d6 01 00 00       	call   80104bf5 <sleep>
80104a1f:	83 c4 10             	add    $0x10,%esp
  }
80104a22:	e9 f1 fe ff ff       	jmp    80104918 <wait+0x16>
}
80104a27:	c9                   	leave  
80104a28:	c3                   	ret    

80104a29 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a29:	55                   	push   %ebp
80104a2a:	89 e5                	mov    %esp,%ebp
80104a2c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a2f:	e8 10 f9 ff ff       	call   80104344 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a34:	83 ec 0c             	sub    $0xc,%esp
80104a37:	68 40 2a 11 80       	push   $0x80112a40
80104a3c:	e8 ad 04 00 00       	call   80104eee <acquire>
80104a41:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a44:	c7 45 f4 74 2a 11 80 	movl   $0x80112a74,-0xc(%ebp)
80104a4b:	eb 65                	jmp    80104ab2 <scheduler+0x89>
      if(p->state != RUNNABLE)
80104a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a50:	8b 40 0c             	mov    0xc(%eax),%eax
80104a53:	83 f8 03             	cmp    $0x3,%eax
80104a56:	74 02                	je     80104a5a <scheduler+0x31>
        continue;
80104a58:	eb 51                	jmp    80104aab <scheduler+0x82>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a63:	83 ec 0c             	sub    $0xc,%esp
80104a66:	ff 75 f4             	pushl  -0xc(%ebp)
80104a69:	e8 1f 33 00 00       	call   80107d8d <switchuvm>
80104a6e:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a74:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a81:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a84:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a8b:	83 c2 04             	add    $0x4,%edx
80104a8e:	83 ec 08             	sub    $0x8,%esp
80104a91:	50                   	push   %eax
80104a92:	52                   	push   %edx
80104a93:	e8 28 09 00 00       	call   801053c0 <swtch>
80104a98:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104a9b:	e8 d1 32 00 00       	call   80107d71 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104aa0:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104aa7:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aab:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ab2:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104ab9:	72 92                	jb     80104a4d <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104abb:	83 ec 0c             	sub    $0xc,%esp
80104abe:	68 40 2a 11 80       	push   $0x80112a40
80104ac3:	e8 8c 04 00 00       	call   80104f54 <release>
80104ac8:	83 c4 10             	add    $0x10,%esp

  }
80104acb:	e9 5f ff ff ff       	jmp    80104a2f <scheduler+0x6>

80104ad0 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	68 40 2a 11 80       	push   $0x80112a40
80104ade:	e8 3b 05 00 00       	call   8010501e <holding>
80104ae3:	83 c4 10             	add    $0x10,%esp
80104ae6:	85 c0                	test   %eax,%eax
80104ae8:	75 0d                	jne    80104af7 <sched+0x27>
    panic("sched ptable.lock");
80104aea:	83 ec 0c             	sub    $0xc,%esp
80104aed:	68 dd 87 10 80       	push   $0x801087dd
80104af2:	e8 65 ba ff ff       	call   8010055c <panic>
  if(cpu->ncli != 1)
80104af7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104afd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104b03:	83 f8 01             	cmp    $0x1,%eax
80104b06:	74 0d                	je     80104b15 <sched+0x45>
    panic("sched locks");
80104b08:	83 ec 0c             	sub    $0xc,%esp
80104b0b:	68 ef 87 10 80       	push   $0x801087ef
80104b10:	e8 47 ba ff ff       	call   8010055c <panic>
  if(proc->state == RUNNING)
80104b15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b1e:	83 f8 04             	cmp    $0x4,%eax
80104b21:	75 0d                	jne    80104b30 <sched+0x60>
    panic("sched running");
80104b23:	83 ec 0c             	sub    $0xc,%esp
80104b26:	68 fb 87 10 80       	push   $0x801087fb
80104b2b:	e8 2c ba ff ff       	call   8010055c <panic>
  if(readeflags()&FL_IF)
80104b30:	e8 ff f7 ff ff       	call   80104334 <readeflags>
80104b35:	25 00 02 00 00       	and    $0x200,%eax
80104b3a:	85 c0                	test   %eax,%eax
80104b3c:	74 0d                	je     80104b4b <sched+0x7b>
    panic("sched interruptible");
80104b3e:	83 ec 0c             	sub    $0xc,%esp
80104b41:	68 09 88 10 80       	push   $0x80108809
80104b46:	e8 11 ba ff ff       	call   8010055c <panic>
  intena = cpu->intena;
80104b4b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b51:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b5a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b60:	8b 40 04             	mov    0x4(%eax),%eax
80104b63:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b6a:	83 c2 1c             	add    $0x1c,%edx
80104b6d:	83 ec 08             	sub    $0x8,%esp
80104b70:	50                   	push   %eax
80104b71:	52                   	push   %edx
80104b72:	e8 49 08 00 00       	call   801053c0 <swtch>
80104b77:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104b7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b83:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b89:	c9                   	leave  
80104b8a:	c3                   	ret    

80104b8b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b8b:	55                   	push   %ebp
80104b8c:	89 e5                	mov    %esp,%ebp
80104b8e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b91:	83 ec 0c             	sub    $0xc,%esp
80104b94:	68 40 2a 11 80       	push   $0x80112a40
80104b99:	e8 50 03 00 00       	call   80104eee <acquire>
80104b9e:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bae:	e8 1d ff ff ff       	call   80104ad0 <sched>
  release(&ptable.lock);
80104bb3:	83 ec 0c             	sub    $0xc,%esp
80104bb6:	68 40 2a 11 80       	push   $0x80112a40
80104bbb:	e8 94 03 00 00       	call   80104f54 <release>
80104bc0:	83 c4 10             	add    $0x10,%esp
}
80104bc3:	c9                   	leave  
80104bc4:	c3                   	ret    

80104bc5 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bc5:	55                   	push   %ebp
80104bc6:	89 e5                	mov    %esp,%ebp
80104bc8:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bcb:	83 ec 0c             	sub    $0xc,%esp
80104bce:	68 40 2a 11 80       	push   $0x80112a40
80104bd3:	e8 7c 03 00 00       	call   80104f54 <release>
80104bd8:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bdb:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104be0:	85 c0                	test   %eax,%eax
80104be2:	74 0f                	je     80104bf3 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104be4:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104beb:	00 00 00 
    initlog();
80104bee:	e8 52 e6 ff ff       	call   80103245 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104bf3:	c9                   	leave  
80104bf4:	c3                   	ret    

80104bf5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bf5:	55                   	push   %ebp
80104bf6:	89 e5                	mov    %esp,%ebp
80104bf8:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104bfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c01:	85 c0                	test   %eax,%eax
80104c03:	75 0d                	jne    80104c12 <sleep+0x1d>
    panic("sleep");
80104c05:	83 ec 0c             	sub    $0xc,%esp
80104c08:	68 1d 88 10 80       	push   $0x8010881d
80104c0d:	e8 4a b9 ff ff       	call   8010055c <panic>

  if(lk == 0)
80104c12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c16:	75 0d                	jne    80104c25 <sleep+0x30>
    panic("sleep without lk");
80104c18:	83 ec 0c             	sub    $0xc,%esp
80104c1b:	68 23 88 10 80       	push   $0x80108823
80104c20:	e8 37 b9 ff ff       	call   8010055c <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c25:	81 7d 0c 40 2a 11 80 	cmpl   $0x80112a40,0xc(%ebp)
80104c2c:	74 1e                	je     80104c4c <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c2e:	83 ec 0c             	sub    $0xc,%esp
80104c31:	68 40 2a 11 80       	push   $0x80112a40
80104c36:	e8 b3 02 00 00       	call   80104eee <acquire>
80104c3b:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c3e:	83 ec 0c             	sub    $0xc,%esp
80104c41:	ff 75 0c             	pushl  0xc(%ebp)
80104c44:	e8 0b 03 00 00       	call   80104f54 <release>
80104c49:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104c4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c52:	8b 55 08             	mov    0x8(%ebp),%edx
80104c55:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104c58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c5e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c65:	e8 66 fe ff ff       	call   80104ad0 <sched>

  // Tidy up.
  proc->chan = 0;
80104c6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c70:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c77:	81 7d 0c 40 2a 11 80 	cmpl   $0x80112a40,0xc(%ebp)
80104c7e:	74 1e                	je     80104c9e <sleep+0xa9>
    release(&ptable.lock);
80104c80:	83 ec 0c             	sub    $0xc,%esp
80104c83:	68 40 2a 11 80       	push   $0x80112a40
80104c88:	e8 c7 02 00 00       	call   80104f54 <release>
80104c8d:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104c90:	83 ec 0c             	sub    $0xc,%esp
80104c93:	ff 75 0c             	pushl  0xc(%ebp)
80104c96:	e8 53 02 00 00       	call   80104eee <acquire>
80104c9b:	83 c4 10             	add    $0x10,%esp
  }
}
80104c9e:	c9                   	leave  
80104c9f:	c3                   	ret    

80104ca0 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ca6:	c7 45 fc 74 2a 11 80 	movl   $0x80112a74,-0x4(%ebp)
80104cad:	eb 27                	jmp    80104cd6 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cb2:	8b 40 0c             	mov    0xc(%eax),%eax
80104cb5:	83 f8 02             	cmp    $0x2,%eax
80104cb8:	75 15                	jne    80104ccf <wakeup1+0x2f>
80104cba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cbd:	8b 40 20             	mov    0x20(%eax),%eax
80104cc0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cc3:	75 0a                	jne    80104ccf <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cc8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ccf:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104cd6:	81 7d fc 74 4b 11 80 	cmpl   $0x80114b74,-0x4(%ebp)
80104cdd:	72 d0                	jb     80104caf <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cdf:	c9                   	leave  
80104ce0:	c3                   	ret    

80104ce1 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ce1:	55                   	push   %ebp
80104ce2:	89 e5                	mov    %esp,%ebp
80104ce4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ce7:	83 ec 0c             	sub    $0xc,%esp
80104cea:	68 40 2a 11 80       	push   $0x80112a40
80104cef:	e8 fa 01 00 00       	call   80104eee <acquire>
80104cf4:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104cf7:	83 ec 0c             	sub    $0xc,%esp
80104cfa:	ff 75 08             	pushl  0x8(%ebp)
80104cfd:	e8 9e ff ff ff       	call   80104ca0 <wakeup1>
80104d02:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	68 40 2a 11 80       	push   $0x80112a40
80104d0d:	e8 42 02 00 00       	call   80104f54 <release>
80104d12:	83 c4 10             	add    $0x10,%esp
}
80104d15:	c9                   	leave  
80104d16:	c3                   	ret    

80104d17 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d17:	55                   	push   %ebp
80104d18:	89 e5                	mov    %esp,%ebp
80104d1a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d1d:	83 ec 0c             	sub    $0xc,%esp
80104d20:	68 40 2a 11 80       	push   $0x80112a40
80104d25:	e8 c4 01 00 00       	call   80104eee <acquire>
80104d2a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d2d:	c7 45 f4 74 2a 11 80 	movl   $0x80112a74,-0xc(%ebp)
80104d34:	eb 48                	jmp    80104d7e <kill+0x67>
    if(p->pid == pid){
80104d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d39:	8b 40 10             	mov    0x10(%eax),%eax
80104d3c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d3f:	75 36                	jne    80104d77 <kill+0x60>
      p->killed = 1;
80104d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d44:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d51:	83 f8 02             	cmp    $0x2,%eax
80104d54:	75 0a                	jne    80104d60 <kill+0x49>
        p->state = RUNNABLE;
80104d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d59:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d60:	83 ec 0c             	sub    $0xc,%esp
80104d63:	68 40 2a 11 80       	push   $0x80112a40
80104d68:	e8 e7 01 00 00       	call   80104f54 <release>
80104d6d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d70:	b8 00 00 00 00       	mov    $0x0,%eax
80104d75:	eb 25                	jmp    80104d9c <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d77:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d7e:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104d85:	72 af                	jb     80104d36 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d87:	83 ec 0c             	sub    $0xc,%esp
80104d8a:	68 40 2a 11 80       	push   $0x80112a40
80104d8f:	e8 c0 01 00 00       	call   80104f54 <release>
80104d94:	83 c4 10             	add    $0x10,%esp
  return -1;
80104d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d9c:	c9                   	leave  
80104d9d:	c3                   	ret    

80104d9e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d9e:	55                   	push   %ebp
80104d9f:	89 e5                	mov    %esp,%ebp
80104da1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104da4:	c7 45 f0 74 2a 11 80 	movl   $0x80112a74,-0x10(%ebp)
80104dab:	e9 d8 00 00 00       	jmp    80104e88 <procdump+0xea>
    if(p->state == UNUSED)
80104db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db3:	8b 40 0c             	mov    0xc(%eax),%eax
80104db6:	85 c0                	test   %eax,%eax
80104db8:	75 05                	jne    80104dbf <procdump+0x21>
      continue;
80104dba:	e9 c2 00 00 00       	jmp    80104e81 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc2:	8b 40 0c             	mov    0xc(%eax),%eax
80104dc5:	83 f8 05             	cmp    $0x5,%eax
80104dc8:	77 23                	ja     80104ded <procdump+0x4f>
80104dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcd:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd0:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104dd7:	85 c0                	test   %eax,%eax
80104dd9:	74 12                	je     80104ded <procdump+0x4f>
      state = states[p->state];
80104ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dde:	8b 40 0c             	mov    0xc(%eax),%eax
80104de1:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104de8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104deb:	eb 07                	jmp    80104df4 <procdump+0x56>
    else
      state = "???";
80104ded:	c7 45 ec 34 88 10 80 	movl   $0x80108834,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df7:	8d 50 6c             	lea    0x6c(%eax),%edx
80104dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfd:	8b 40 10             	mov    0x10(%eax),%eax
80104e00:	52                   	push   %edx
80104e01:	ff 75 ec             	pushl  -0x14(%ebp)
80104e04:	50                   	push   %eax
80104e05:	68 38 88 10 80       	push   $0x80108838
80104e0a:	e8 b0 b5 ff ff       	call   801003bf <cprintf>
80104e0f:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e15:	8b 40 0c             	mov    0xc(%eax),%eax
80104e18:	83 f8 02             	cmp    $0x2,%eax
80104e1b:	75 54                	jne    80104e71 <procdump+0xd3>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e20:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e23:	8b 40 0c             	mov    0xc(%eax),%eax
80104e26:	83 c0 08             	add    $0x8,%eax
80104e29:	89 c2                	mov    %eax,%edx
80104e2b:	83 ec 08             	sub    $0x8,%esp
80104e2e:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e31:	50                   	push   %eax
80104e32:	52                   	push   %edx
80104e33:	e8 6d 01 00 00       	call   80104fa5 <getcallerpcs>
80104e38:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e42:	eb 1c                	jmp    80104e60 <procdump+0xc2>
        cprintf(" %p", pc[i]);
80104e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e47:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e4b:	83 ec 08             	sub    $0x8,%esp
80104e4e:	50                   	push   %eax
80104e4f:	68 41 88 10 80       	push   $0x80108841
80104e54:	e8 66 b5 ff ff       	call   801003bf <cprintf>
80104e59:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104e5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e60:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e64:	7f 0b                	jg     80104e71 <procdump+0xd3>
80104e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e69:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e6d:	85 c0                	test   %eax,%eax
80104e6f:	75 d3                	jne    80104e44 <procdump+0xa6>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e71:	83 ec 0c             	sub    $0xc,%esp
80104e74:	68 45 88 10 80       	push   $0x80108845
80104e79:	e8 41 b5 ff ff       	call   801003bf <cprintf>
80104e7e:	83 c4 10             	add    $0x10,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e81:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104e88:	81 7d f0 74 4b 11 80 	cmpl   $0x80114b74,-0x10(%ebp)
80104e8f:	0f 82 1b ff ff ff    	jb     80104db0 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e95:	c9                   	leave  
80104e96:	c3                   	ret    

80104e97 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e97:	55                   	push   %ebp
80104e98:	89 e5                	mov    %esp,%ebp
80104e9a:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e9d:	9c                   	pushf  
80104e9e:	58                   	pop    %eax
80104e9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ea2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ea5:	c9                   	leave  
80104ea6:	c3                   	ret    

80104ea7 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104ea7:	55                   	push   %ebp
80104ea8:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104eaa:	fa                   	cli    
}
80104eab:	5d                   	pop    %ebp
80104eac:	c3                   	ret    

80104ead <sti>:

static inline void
sti(void)
{
80104ead:	55                   	push   %ebp
80104eae:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104eb0:	fb                   	sti    
}
80104eb1:	5d                   	pop    %ebp
80104eb2:	c3                   	ret    

80104eb3 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104eb3:	55                   	push   %ebp
80104eb4:	89 e5                	mov    %esp,%ebp
80104eb6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104eb9:	8b 55 08             	mov    0x8(%ebp),%edx
80104ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ec2:	f0 87 02             	lock xchg %eax,(%edx)
80104ec5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ecb:	c9                   	leave  
80104ecc:	c3                   	ret    

80104ecd <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ecd:	55                   	push   %ebp
80104ece:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ed6:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104eec:	5d                   	pop    %ebp
80104eed:	c3                   	ret    

80104eee <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104eee:	55                   	push   %ebp
80104eef:	89 e5                	mov    %esp,%ebp
80104ef1:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ef4:	e8 4f 01 00 00       	call   80105048 <pushcli>
  if(holding(lk))
80104ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80104efc:	83 ec 0c             	sub    $0xc,%esp
80104eff:	50                   	push   %eax
80104f00:	e8 19 01 00 00       	call   8010501e <holding>
80104f05:	83 c4 10             	add    $0x10,%esp
80104f08:	85 c0                	test   %eax,%eax
80104f0a:	74 0d                	je     80104f19 <acquire+0x2b>
    panic("acquire");
80104f0c:	83 ec 0c             	sub    $0xc,%esp
80104f0f:	68 71 88 10 80       	push   $0x80108871
80104f14:	e8 43 b6 ff ff       	call   8010055c <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104f19:	90                   	nop
80104f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1d:	83 ec 08             	sub    $0x8,%esp
80104f20:	6a 01                	push   $0x1
80104f22:	50                   	push   %eax
80104f23:	e8 8b ff ff ff       	call   80104eb3 <xchg>
80104f28:	83 c4 10             	add    $0x10,%esp
80104f2b:	85 c0                	test   %eax,%eax
80104f2d:	75 eb                	jne    80104f1a <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f32:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f39:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3f:	83 c0 0c             	add    $0xc,%eax
80104f42:	83 ec 08             	sub    $0x8,%esp
80104f45:	50                   	push   %eax
80104f46:	8d 45 08             	lea    0x8(%ebp),%eax
80104f49:	50                   	push   %eax
80104f4a:	e8 56 00 00 00       	call   80104fa5 <getcallerpcs>
80104f4f:	83 c4 10             	add    $0x10,%esp
}
80104f52:	c9                   	leave  
80104f53:	c3                   	ret    

80104f54 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f54:	55                   	push   %ebp
80104f55:	89 e5                	mov    %esp,%ebp
80104f57:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104f5a:	83 ec 0c             	sub    $0xc,%esp
80104f5d:	ff 75 08             	pushl  0x8(%ebp)
80104f60:	e8 b9 00 00 00       	call   8010501e <holding>
80104f65:	83 c4 10             	add    $0x10,%esp
80104f68:	85 c0                	test   %eax,%eax
80104f6a:	75 0d                	jne    80104f79 <release+0x25>
    panic("release");
80104f6c:	83 ec 0c             	sub    $0xc,%esp
80104f6f:	68 79 88 10 80       	push   $0x80108879
80104f74:	e8 e3 b5 ff ff       	call   8010055c <panic>

  lk->pcs[0] = 0;
80104f79:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f83:	8b 45 08             	mov    0x8(%ebp),%eax
80104f86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f90:	83 ec 08             	sub    $0x8,%esp
80104f93:	6a 00                	push   $0x0
80104f95:	50                   	push   %eax
80104f96:	e8 18 ff ff ff       	call   80104eb3 <xchg>
80104f9b:	83 c4 10             	add    $0x10,%esp

  popcli();
80104f9e:	e8 e9 00 00 00       	call   8010508c <popcli>
}
80104fa3:	c9                   	leave  
80104fa4:	c3                   	ret    

80104fa5 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104fa5:	55                   	push   %ebp
80104fa6:	89 e5                	mov    %esp,%ebp
80104fa8:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104fab:	8b 45 08             	mov    0x8(%ebp),%eax
80104fae:	83 e8 08             	sub    $0x8,%eax
80104fb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104fb4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104fbb:	eb 38                	jmp    80104ff5 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104fbd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104fc1:	74 38                	je     80104ffb <getcallerpcs+0x56>
80104fc3:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104fca:	76 2f                	jbe    80104ffb <getcallerpcs+0x56>
80104fcc:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104fd0:	74 29                	je     80104ffb <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104fd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdf:	01 c2                	add    %eax,%edx
80104fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe4:	8b 40 04             	mov    0x4(%eax),%eax
80104fe7:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104fe9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fec:	8b 00                	mov    (%eax),%eax
80104fee:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104ff1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ff5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ff9:	7e c2                	jle    80104fbd <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104ffb:	eb 19                	jmp    80105016 <getcallerpcs+0x71>
    pcs[i] = 0;
80104ffd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105000:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500a:	01 d0                	add    %edx,%eax
8010500c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105012:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105016:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010501a:	7e e1                	jle    80104ffd <getcallerpcs+0x58>
    pcs[i] = 0;
}
8010501c:	c9                   	leave  
8010501d:	c3                   	ret    

8010501e <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010501e:	55                   	push   %ebp
8010501f:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105021:	8b 45 08             	mov    0x8(%ebp),%eax
80105024:	8b 00                	mov    (%eax),%eax
80105026:	85 c0                	test   %eax,%eax
80105028:	74 17                	je     80105041 <holding+0x23>
8010502a:	8b 45 08             	mov    0x8(%ebp),%eax
8010502d:	8b 50 08             	mov    0x8(%eax),%edx
80105030:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105036:	39 c2                	cmp    %eax,%edx
80105038:	75 07                	jne    80105041 <holding+0x23>
8010503a:	b8 01 00 00 00       	mov    $0x1,%eax
8010503f:	eb 05                	jmp    80105046 <holding+0x28>
80105041:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105046:	5d                   	pop    %ebp
80105047:	c3                   	ret    

80105048 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010504e:	e8 44 fe ff ff       	call   80104e97 <readeflags>
80105053:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105056:	e8 4c fe ff ff       	call   80104ea7 <cli>
  if(cpu->ncli++ == 0)
8010505b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105062:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105068:	8d 48 01             	lea    0x1(%eax),%ecx
8010506b:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105071:	85 c0                	test   %eax,%eax
80105073:	75 15                	jne    8010508a <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105075:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010507b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010507e:	81 e2 00 02 00 00    	and    $0x200,%edx
80105084:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <popcli>:

void
popcli(void)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105092:	e8 00 fe ff ff       	call   80104e97 <readeflags>
80105097:	25 00 02 00 00       	and    $0x200,%eax
8010509c:	85 c0                	test   %eax,%eax
8010509e:	74 0d                	je     801050ad <popcli+0x21>
    panic("popcli - interruptible");
801050a0:	83 ec 0c             	sub    $0xc,%esp
801050a3:	68 81 88 10 80       	push   $0x80108881
801050a8:	e8 af b4 ff ff       	call   8010055c <panic>
  if(--cpu->ncli < 0)
801050ad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050b3:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801050b9:	83 ea 01             	sub    $0x1,%edx
801050bc:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801050c2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050c8:	85 c0                	test   %eax,%eax
801050ca:	79 0d                	jns    801050d9 <popcli+0x4d>
    panic("popcli");
801050cc:	83 ec 0c             	sub    $0xc,%esp
801050cf:	68 98 88 10 80       	push   $0x80108898
801050d4:	e8 83 b4 ff ff       	call   8010055c <panic>
  if(cpu->ncli == 0 && cpu->intena)
801050d9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050df:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801050e5:	85 c0                	test   %eax,%eax
801050e7:	75 15                	jne    801050fe <popcli+0x72>
801050e9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801050ef:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801050f5:	85 c0                	test   %eax,%eax
801050f7:	74 05                	je     801050fe <popcli+0x72>
    sti();
801050f9:	e8 af fd ff ff       	call   80104ead <sti>
}
801050fe:	c9                   	leave  
801050ff:	c3                   	ret    

80105100 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	57                   	push   %edi
80105104:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105105:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105108:	8b 55 10             	mov    0x10(%ebp),%edx
8010510b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510e:	89 cb                	mov    %ecx,%ebx
80105110:	89 df                	mov    %ebx,%edi
80105112:	89 d1                	mov    %edx,%ecx
80105114:	fc                   	cld    
80105115:	f3 aa                	rep stos %al,%es:(%edi)
80105117:	89 ca                	mov    %ecx,%edx
80105119:	89 fb                	mov    %edi,%ebx
8010511b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010511e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105121:	5b                   	pop    %ebx
80105122:	5f                   	pop    %edi
80105123:	5d                   	pop    %ebp
80105124:	c3                   	ret    

80105125 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	57                   	push   %edi
80105129:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010512a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010512d:	8b 55 10             	mov    0x10(%ebp),%edx
80105130:	8b 45 0c             	mov    0xc(%ebp),%eax
80105133:	89 cb                	mov    %ecx,%ebx
80105135:	89 df                	mov    %ebx,%edi
80105137:	89 d1                	mov    %edx,%ecx
80105139:	fc                   	cld    
8010513a:	f3 ab                	rep stos %eax,%es:(%edi)
8010513c:	89 ca                	mov    %ecx,%edx
8010513e:	89 fb                	mov    %edi,%ebx
80105140:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105143:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105146:	5b                   	pop    %ebx
80105147:	5f                   	pop    %edi
80105148:	5d                   	pop    %ebp
80105149:	c3                   	ret    

8010514a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010514d:	8b 45 08             	mov    0x8(%ebp),%eax
80105150:	83 e0 03             	and    $0x3,%eax
80105153:	85 c0                	test   %eax,%eax
80105155:	75 43                	jne    8010519a <memset+0x50>
80105157:	8b 45 10             	mov    0x10(%ebp),%eax
8010515a:	83 e0 03             	and    $0x3,%eax
8010515d:	85 c0                	test   %eax,%eax
8010515f:	75 39                	jne    8010519a <memset+0x50>
    c &= 0xFF;
80105161:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105168:	8b 45 10             	mov    0x10(%ebp),%eax
8010516b:	c1 e8 02             	shr    $0x2,%eax
8010516e:	89 c1                	mov    %eax,%ecx
80105170:	8b 45 0c             	mov    0xc(%ebp),%eax
80105173:	c1 e0 18             	shl    $0x18,%eax
80105176:	89 c2                	mov    %eax,%edx
80105178:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517b:	c1 e0 10             	shl    $0x10,%eax
8010517e:	09 c2                	or     %eax,%edx
80105180:	8b 45 0c             	mov    0xc(%ebp),%eax
80105183:	c1 e0 08             	shl    $0x8,%eax
80105186:	09 d0                	or     %edx,%eax
80105188:	0b 45 0c             	or     0xc(%ebp),%eax
8010518b:	51                   	push   %ecx
8010518c:	50                   	push   %eax
8010518d:	ff 75 08             	pushl  0x8(%ebp)
80105190:	e8 90 ff ff ff       	call   80105125 <stosl>
80105195:	83 c4 0c             	add    $0xc,%esp
80105198:	eb 12                	jmp    801051ac <memset+0x62>
  } else
    stosb(dst, c, n);
8010519a:	8b 45 10             	mov    0x10(%ebp),%eax
8010519d:	50                   	push   %eax
8010519e:	ff 75 0c             	pushl  0xc(%ebp)
801051a1:	ff 75 08             	pushl  0x8(%ebp)
801051a4:	e8 57 ff ff ff       	call   80105100 <stosb>
801051a9:	83 c4 0c             	add    $0xc,%esp
  return dst;
801051ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051af:	c9                   	leave  
801051b0:	c3                   	ret    

801051b1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801051b1:	55                   	push   %ebp
801051b2:	89 e5                	mov    %esp,%ebp
801051b4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801051b7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801051bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801051c3:	eb 30                	jmp    801051f5 <memcmp+0x44>
    if(*s1 != *s2)
801051c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c8:	0f b6 10             	movzbl (%eax),%edx
801051cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ce:	0f b6 00             	movzbl (%eax),%eax
801051d1:	38 c2                	cmp    %al,%dl
801051d3:	74 18                	je     801051ed <memcmp+0x3c>
      return *s1 - *s2;
801051d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d8:	0f b6 00             	movzbl (%eax),%eax
801051db:	0f b6 d0             	movzbl %al,%edx
801051de:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051e1:	0f b6 00             	movzbl (%eax),%eax
801051e4:	0f b6 c0             	movzbl %al,%eax
801051e7:	29 c2                	sub    %eax,%edx
801051e9:	89 d0                	mov    %edx,%eax
801051eb:	eb 1a                	jmp    80105207 <memcmp+0x56>
    s1++, s2++;
801051ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051f1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051f5:	8b 45 10             	mov    0x10(%ebp),%eax
801051f8:	8d 50 ff             	lea    -0x1(%eax),%edx
801051fb:	89 55 10             	mov    %edx,0x10(%ebp)
801051fe:	85 c0                	test   %eax,%eax
80105200:	75 c3                	jne    801051c5 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105202:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105207:	c9                   	leave  
80105208:	c3                   	ret    

80105209 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010520f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105212:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010521b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010521e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105221:	73 3d                	jae    80105260 <memmove+0x57>
80105223:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105226:	8b 45 10             	mov    0x10(%ebp),%eax
80105229:	01 d0                	add    %edx,%eax
8010522b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010522e:	76 30                	jbe    80105260 <memmove+0x57>
    s += n;
80105230:	8b 45 10             	mov    0x10(%ebp),%eax
80105233:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105236:	8b 45 10             	mov    0x10(%ebp),%eax
80105239:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010523c:	eb 13                	jmp    80105251 <memmove+0x48>
      *--d = *--s;
8010523e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105242:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105246:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105249:	0f b6 10             	movzbl (%eax),%edx
8010524c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010524f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105251:	8b 45 10             	mov    0x10(%ebp),%eax
80105254:	8d 50 ff             	lea    -0x1(%eax),%edx
80105257:	89 55 10             	mov    %edx,0x10(%ebp)
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 e0                	jne    8010523e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010525e:	eb 26                	jmp    80105286 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105260:	eb 17                	jmp    80105279 <memmove+0x70>
      *d++ = *s++;
80105262:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105265:	8d 50 01             	lea    0x1(%eax),%edx
80105268:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010526b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010526e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105271:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105274:	0f b6 12             	movzbl (%edx),%edx
80105277:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105279:	8b 45 10             	mov    0x10(%ebp),%eax
8010527c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010527f:	89 55 10             	mov    %edx,0x10(%ebp)
80105282:	85 c0                	test   %eax,%eax
80105284:	75 dc                	jne    80105262 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105286:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105289:	c9                   	leave  
8010528a:	c3                   	ret    

8010528b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010528b:	55                   	push   %ebp
8010528c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010528e:	ff 75 10             	pushl  0x10(%ebp)
80105291:	ff 75 0c             	pushl  0xc(%ebp)
80105294:	ff 75 08             	pushl  0x8(%ebp)
80105297:	e8 6d ff ff ff       	call   80105209 <memmove>
8010529c:	83 c4 0c             	add    $0xc,%esp
}
8010529f:	c9                   	leave  
801052a0:	c3                   	ret    

801052a1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801052a4:	eb 0c                	jmp    801052b2 <strncmp+0x11>
    n--, p++, q++;
801052a6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052ae:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801052b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052b6:	74 1a                	je     801052d2 <strncmp+0x31>
801052b8:	8b 45 08             	mov    0x8(%ebp),%eax
801052bb:	0f b6 00             	movzbl (%eax),%eax
801052be:	84 c0                	test   %al,%al
801052c0:	74 10                	je     801052d2 <strncmp+0x31>
801052c2:	8b 45 08             	mov    0x8(%ebp),%eax
801052c5:	0f b6 10             	movzbl (%eax),%edx
801052c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cb:	0f b6 00             	movzbl (%eax),%eax
801052ce:	38 c2                	cmp    %al,%dl
801052d0:	74 d4                	je     801052a6 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801052d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052d6:	75 07                	jne    801052df <strncmp+0x3e>
    return 0;
801052d8:	b8 00 00 00 00       	mov    $0x0,%eax
801052dd:	eb 16                	jmp    801052f5 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801052df:	8b 45 08             	mov    0x8(%ebp),%eax
801052e2:	0f b6 00             	movzbl (%eax),%eax
801052e5:	0f b6 d0             	movzbl %al,%edx
801052e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052eb:	0f b6 00             	movzbl (%eax),%eax
801052ee:	0f b6 c0             	movzbl %al,%eax
801052f1:	29 c2                	sub    %eax,%edx
801052f3:	89 d0                	mov    %edx,%eax
}
801052f5:	5d                   	pop    %ebp
801052f6:	c3                   	ret    

801052f7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052f7:	55                   	push   %ebp
801052f8:	89 e5                	mov    %esp,%ebp
801052fa:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105300:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105303:	90                   	nop
80105304:	8b 45 10             	mov    0x10(%ebp),%eax
80105307:	8d 50 ff             	lea    -0x1(%eax),%edx
8010530a:	89 55 10             	mov    %edx,0x10(%ebp)
8010530d:	85 c0                	test   %eax,%eax
8010530f:	7e 1e                	jle    8010532f <strncpy+0x38>
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
80105314:	8d 50 01             	lea    0x1(%eax),%edx
80105317:	89 55 08             	mov    %edx,0x8(%ebp)
8010531a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010531d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105320:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105323:	0f b6 12             	movzbl (%edx),%edx
80105326:	88 10                	mov    %dl,(%eax)
80105328:	0f b6 00             	movzbl (%eax),%eax
8010532b:	84 c0                	test   %al,%al
8010532d:	75 d5                	jne    80105304 <strncpy+0xd>
    ;
  while(n-- > 0)
8010532f:	eb 0c                	jmp    8010533d <strncpy+0x46>
    *s++ = 0;
80105331:	8b 45 08             	mov    0x8(%ebp),%eax
80105334:	8d 50 01             	lea    0x1(%eax),%edx
80105337:	89 55 08             	mov    %edx,0x8(%ebp)
8010533a:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010533d:	8b 45 10             	mov    0x10(%ebp),%eax
80105340:	8d 50 ff             	lea    -0x1(%eax),%edx
80105343:	89 55 10             	mov    %edx,0x10(%ebp)
80105346:	85 c0                	test   %eax,%eax
80105348:	7f e7                	jg     80105331 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010534a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010534d:	c9                   	leave  
8010534e:	c3                   	ret    

8010534f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010534f:	55                   	push   %ebp
80105350:	89 e5                	mov    %esp,%ebp
80105352:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105355:	8b 45 08             	mov    0x8(%ebp),%eax
80105358:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010535b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010535f:	7f 05                	jg     80105366 <safestrcpy+0x17>
    return os;
80105361:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105364:	eb 31                	jmp    80105397 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105366:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010536a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010536e:	7e 1e                	jle    8010538e <safestrcpy+0x3f>
80105370:	8b 45 08             	mov    0x8(%ebp),%eax
80105373:	8d 50 01             	lea    0x1(%eax),%edx
80105376:	89 55 08             	mov    %edx,0x8(%ebp)
80105379:	8b 55 0c             	mov    0xc(%ebp),%edx
8010537c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010537f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105382:	0f b6 12             	movzbl (%edx),%edx
80105385:	88 10                	mov    %dl,(%eax)
80105387:	0f b6 00             	movzbl (%eax),%eax
8010538a:	84 c0                	test   %al,%al
8010538c:	75 d8                	jne    80105366 <safestrcpy+0x17>
    ;
  *s = 0;
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105394:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105397:	c9                   	leave  
80105398:	c3                   	ret    

80105399 <strlen>:

int
strlen(const char *s)
{
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010539f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053a6:	eb 04                	jmp    801053ac <strlen+0x13>
801053a8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053af:	8b 45 08             	mov    0x8(%ebp),%eax
801053b2:	01 d0                	add    %edx,%eax
801053b4:	0f b6 00             	movzbl (%eax),%eax
801053b7:	84 c0                	test   %al,%al
801053b9:	75 ed                	jne    801053a8 <strlen+0xf>
    ;
  return n;
801053bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053be:	c9                   	leave  
801053bf:	c3                   	ret    

801053c0 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801053c0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801053c4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801053c8:	55                   	push   %ebp
  pushl %ebx
801053c9:	53                   	push   %ebx
  pushl %esi
801053ca:	56                   	push   %esi
  pushl %edi
801053cb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053cc:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053ce:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053d0:	5f                   	pop    %edi
  popl %esi
801053d1:	5e                   	pop    %esi
  popl %ebx
801053d2:	5b                   	pop    %ebx
  popl %ebp
801053d3:	5d                   	pop    %ebp
  ret
801053d4:	c3                   	ret    

801053d5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801053d5:	55                   	push   %ebp
801053d6:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801053d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053de:	8b 00                	mov    (%eax),%eax
801053e0:	3b 45 08             	cmp    0x8(%ebp),%eax
801053e3:	76 12                	jbe    801053f7 <fetchint+0x22>
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	8d 50 04             	lea    0x4(%eax),%edx
801053eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f1:	8b 00                	mov    (%eax),%eax
801053f3:	39 c2                	cmp    %eax,%edx
801053f5:	76 07                	jbe    801053fe <fetchint+0x29>
    return -1;
801053f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fc:	eb 0f                	jmp    8010540d <fetchint+0x38>
  *ip = *(int*)(addr);
801053fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105401:	8b 10                	mov    (%eax),%edx
80105403:	8b 45 0c             	mov    0xc(%ebp),%eax
80105406:	89 10                	mov    %edx,(%eax)
  return 0;
80105408:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010540d:	5d                   	pop    %ebp
8010540e:	c3                   	ret    

8010540f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010540f:	55                   	push   %ebp
80105410:	89 e5                	mov    %esp,%ebp
80105412:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105415:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010541b:	8b 00                	mov    (%eax),%eax
8010541d:	3b 45 08             	cmp    0x8(%ebp),%eax
80105420:	77 07                	ja     80105429 <fetchstr+0x1a>
    return -1;
80105422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105427:	eb 46                	jmp    8010546f <fetchstr+0x60>
  *pp = (char*)addr;
80105429:	8b 55 08             	mov    0x8(%ebp),%edx
8010542c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542f:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105431:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105437:	8b 00                	mov    (%eax),%eax
80105439:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010543c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543f:	8b 00                	mov    (%eax),%eax
80105441:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105444:	eb 1c                	jmp    80105462 <fetchstr+0x53>
    if(*s == 0)
80105446:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105449:	0f b6 00             	movzbl (%eax),%eax
8010544c:	84 c0                	test   %al,%al
8010544e:	75 0e                	jne    8010545e <fetchstr+0x4f>
      return s - *pp;
80105450:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105453:	8b 45 0c             	mov    0xc(%ebp),%eax
80105456:	8b 00                	mov    (%eax),%eax
80105458:	29 c2                	sub    %eax,%edx
8010545a:	89 d0                	mov    %edx,%eax
8010545c:	eb 11                	jmp    8010546f <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010545e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105462:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105465:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105468:	72 dc                	jb     80105446 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010546a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105474:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547a:	8b 40 18             	mov    0x18(%eax),%eax
8010547d:	8b 40 44             	mov    0x44(%eax),%eax
80105480:	8b 55 08             	mov    0x8(%ebp),%edx
80105483:	c1 e2 02             	shl    $0x2,%edx
80105486:	01 d0                	add    %edx,%eax
80105488:	83 c0 04             	add    $0x4,%eax
8010548b:	ff 75 0c             	pushl  0xc(%ebp)
8010548e:	50                   	push   %eax
8010548f:	e8 41 ff ff ff       	call   801053d5 <fetchint>
80105494:	83 c4 08             	add    $0x8,%esp
}
80105497:	c9                   	leave  
80105498:	c3                   	ret    

80105499 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105499:	55                   	push   %ebp
8010549a:	89 e5                	mov    %esp,%ebp
8010549c:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010549f:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054a2:	50                   	push   %eax
801054a3:	ff 75 08             	pushl  0x8(%ebp)
801054a6:	e8 c6 ff ff ff       	call   80105471 <argint>
801054ab:	83 c4 08             	add    $0x8,%esp
801054ae:	85 c0                	test   %eax,%eax
801054b0:	79 07                	jns    801054b9 <argptr+0x20>
    return -1;
801054b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b7:	eb 3d                	jmp    801054f6 <argptr+0x5d>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801054b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054bc:	89 c2                	mov    %eax,%edx
801054be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054c4:	8b 00                	mov    (%eax),%eax
801054c6:	39 c2                	cmp    %eax,%edx
801054c8:	73 16                	jae    801054e0 <argptr+0x47>
801054ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cd:	89 c2                	mov    %eax,%edx
801054cf:	8b 45 10             	mov    0x10(%ebp),%eax
801054d2:	01 c2                	add    %eax,%edx
801054d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054da:	8b 00                	mov    (%eax),%eax
801054dc:	39 c2                	cmp    %eax,%edx
801054de:	76 07                	jbe    801054e7 <argptr+0x4e>
    return -1;
801054e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e5:	eb 0f                	jmp    801054f6 <argptr+0x5d>
  *pp = (char*)i;
801054e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ea:	89 c2                	mov    %eax,%edx
801054ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ef:	89 10                	mov    %edx,(%eax)
  return 0;
801054f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105501:	50                   	push   %eax
80105502:	ff 75 08             	pushl  0x8(%ebp)
80105505:	e8 67 ff ff ff       	call   80105471 <argint>
8010550a:	83 c4 08             	add    $0x8,%esp
8010550d:	85 c0                	test   %eax,%eax
8010550f:	79 07                	jns    80105518 <argstr+0x20>
    return -1;
80105511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105516:	eb 0f                	jmp    80105527 <argstr+0x2f>
  return fetchstr(addr, pp);
80105518:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010551b:	ff 75 0c             	pushl  0xc(%ebp)
8010551e:	50                   	push   %eax
8010551f:	e8 eb fe ff ff       	call   8010540f <fetchstr>
80105524:	83 c4 08             	add    $0x8,%esp
}
80105527:	c9                   	leave  
80105528:	c3                   	ret    

80105529 <syscall>:
[SYS_trace]   sys_trace,
};

void
syscall(void)
{
80105529:	55                   	push   %ebp
8010552a:	89 e5                	mov    %esp,%ebp
8010552c:	53                   	push   %ebx
8010552d:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105530:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105536:	8b 40 18             	mov    0x18(%eax),%eax
80105539:	8b 40 1c             	mov    0x1c(%eax),%eax
8010553c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010553f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105543:	7e 77                	jle    801055bc <syscall+0x93>
80105545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105548:	83 f8 16             	cmp    $0x16,%eax
8010554b:	77 6f                	ja     801055bc <syscall+0x93>
8010554d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105550:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105557:	85 c0                	test   %eax,%eax
80105559:	74 61                	je     801055bc <syscall+0x93>
    if(proc->traceFlag == true){
8010555b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105561:	8b 40 7c             	mov    0x7c(%eax),%eax
80105564:	83 f8 01             	cmp    $0x1,%eax
80105567:	75 39                	jne    801055a2 <syscall+0x79>
		proc->totalSysCall = proc->totalSysCall +1;
80105569:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010556f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105576:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
8010557c:	83 c2 01             	add    $0x1,%edx
8010557f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
		cprintf("\npid %d invoked call %d\n", proc->pid, num);
80105585:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558b:	8b 40 10             	mov    0x10(%eax),%eax
8010558e:	83 ec 04             	sub    $0x4,%esp
80105591:	ff 75 f4             	pushl  -0xc(%ebp)
80105594:	50                   	push   %eax
80105595:	68 9f 88 10 80       	push   $0x8010889f
8010559a:	e8 20 ae ff ff       	call   801003bf <cprintf>
8010559f:	83 c4 10             	add    $0x10,%esp
    }
    proc->tf->eax = syscalls[num]();
801055a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a8:	8b 58 18             	mov    0x18(%eax),%ebx
801055ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ae:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801055b5:	ff d0                	call   *%eax
801055b7:	89 43 1c             	mov    %eax,0x1c(%ebx)
801055ba:	eb 34                	jmp    801055f0 <syscall+0xc7>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801055bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055c2:	8d 50 6c             	lea    0x6c(%eax),%edx
801055c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
		proc->totalSysCall = proc->totalSysCall +1;
		cprintf("\npid %d invoked call %d\n", proc->pid, num);
    }
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801055cb:	8b 40 10             	mov    0x10(%eax),%eax
801055ce:	ff 75 f4             	pushl  -0xc(%ebp)
801055d1:	52                   	push   %edx
801055d2:	50                   	push   %eax
801055d3:	68 b8 88 10 80       	push   $0x801088b8
801055d8:	e8 e2 ad ff ff       	call   801003bf <cprintf>
801055dd:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801055e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e6:	8b 40 18             	mov    0x18(%eax),%eax
801055e9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801055f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801055f3:	c9                   	leave  
801055f4:	c3                   	ret    

801055f5 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055f5:	55                   	push   %ebp
801055f6:	89 e5                	mov    %esp,%ebp
801055f8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055fb:	83 ec 08             	sub    $0x8,%esp
801055fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105601:	50                   	push   %eax
80105602:	ff 75 08             	pushl  0x8(%ebp)
80105605:	e8 67 fe ff ff       	call   80105471 <argint>
8010560a:	83 c4 10             	add    $0x10,%esp
8010560d:	85 c0                	test   %eax,%eax
8010560f:	79 07                	jns    80105618 <argfd+0x23>
    return -1;
80105611:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105616:	eb 50                	jmp    80105668 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010561b:	85 c0                	test   %eax,%eax
8010561d:	78 21                	js     80105640 <argfd+0x4b>
8010561f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105622:	83 f8 0f             	cmp    $0xf,%eax
80105625:	7f 19                	jg     80105640 <argfd+0x4b>
80105627:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105630:	83 c2 08             	add    $0x8,%edx
80105633:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105637:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010563a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010563e:	75 07                	jne    80105647 <argfd+0x52>
    return -1;
80105640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105645:	eb 21                	jmp    80105668 <argfd+0x73>
  if(pfd)
80105647:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010564b:	74 08                	je     80105655 <argfd+0x60>
    *pfd = fd;
8010564d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105650:	8b 45 0c             	mov    0xc(%ebp),%eax
80105653:	89 10                	mov    %edx,(%eax)
  if(pf)
80105655:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105659:	74 08                	je     80105663 <argfd+0x6e>
    *pf = f;
8010565b:	8b 45 10             	mov    0x10(%ebp),%eax
8010565e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105661:	89 10                	mov    %edx,(%eax)
  return 0;
80105663:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105668:	c9                   	leave  
80105669:	c3                   	ret    

8010566a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010566a:	55                   	push   %ebp
8010566b:	89 e5                	mov    %esp,%ebp
8010566d:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105670:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105677:	eb 30                	jmp    801056a9 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105679:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010567f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105682:	83 c2 08             	add    $0x8,%edx
80105685:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105689:	85 c0                	test   %eax,%eax
8010568b:	75 18                	jne    801056a5 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010568d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105693:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105696:	8d 4a 08             	lea    0x8(%edx),%ecx
80105699:	8b 55 08             	mov    0x8(%ebp),%edx
8010569c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801056a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a3:	eb 0f                	jmp    801056b4 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801056a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056a9:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801056ad:	7e ca                	jle    80105679 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801056af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b4:	c9                   	leave  
801056b5:	c3                   	ret    

801056b6 <sys_dup>:

int
sys_dup(void)
{
801056b6:	55                   	push   %ebp
801056b7:	89 e5                	mov    %esp,%ebp
801056b9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801056bc:	83 ec 04             	sub    $0x4,%esp
801056bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056c2:	50                   	push   %eax
801056c3:	6a 00                	push   $0x0
801056c5:	6a 00                	push   $0x0
801056c7:	e8 29 ff ff ff       	call   801055f5 <argfd>
801056cc:	83 c4 10             	add    $0x10,%esp
801056cf:	85 c0                	test   %eax,%eax
801056d1:	79 07                	jns    801056da <sys_dup+0x24>
    return -1;
801056d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d8:	eb 31                	jmp    8010570b <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801056da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056dd:	83 ec 0c             	sub    $0xc,%esp
801056e0:	50                   	push   %eax
801056e1:	e8 84 ff ff ff       	call   8010566a <fdalloc>
801056e6:	83 c4 10             	add    $0x10,%esp
801056e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056f0:	79 07                	jns    801056f9 <sys_dup+0x43>
    return -1;
801056f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f7:	eb 12                	jmp    8010570b <sys_dup+0x55>
  filedup(f);
801056f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056fc:	83 ec 0c             	sub    $0xc,%esp
801056ff:	50                   	push   %eax
80105700:	e8 b7 b8 ff ff       	call   80100fbc <filedup>
80105705:	83 c4 10             	add    $0x10,%esp
  return fd;
80105708:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010570b:	c9                   	leave  
8010570c:	c3                   	ret    

8010570d <sys_read>:

int
sys_read(void)
{
8010570d:	55                   	push   %ebp
8010570e:	89 e5                	mov    %esp,%ebp
80105710:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105713:	83 ec 04             	sub    $0x4,%esp
80105716:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105719:	50                   	push   %eax
8010571a:	6a 00                	push   $0x0
8010571c:	6a 00                	push   $0x0
8010571e:	e8 d2 fe ff ff       	call   801055f5 <argfd>
80105723:	83 c4 10             	add    $0x10,%esp
80105726:	85 c0                	test   %eax,%eax
80105728:	78 2e                	js     80105758 <sys_read+0x4b>
8010572a:	83 ec 08             	sub    $0x8,%esp
8010572d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105730:	50                   	push   %eax
80105731:	6a 02                	push   $0x2
80105733:	e8 39 fd ff ff       	call   80105471 <argint>
80105738:	83 c4 10             	add    $0x10,%esp
8010573b:	85 c0                	test   %eax,%eax
8010573d:	78 19                	js     80105758 <sys_read+0x4b>
8010573f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105742:	83 ec 04             	sub    $0x4,%esp
80105745:	50                   	push   %eax
80105746:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105749:	50                   	push   %eax
8010574a:	6a 01                	push   $0x1
8010574c:	e8 48 fd ff ff       	call   80105499 <argptr>
80105751:	83 c4 10             	add    $0x10,%esp
80105754:	85 c0                	test   %eax,%eax
80105756:	79 07                	jns    8010575f <sys_read+0x52>
    return -1;
80105758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010575d:	eb 17                	jmp    80105776 <sys_read+0x69>
  return fileread(f, p, n);
8010575f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105762:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105768:	83 ec 04             	sub    $0x4,%esp
8010576b:	51                   	push   %ecx
8010576c:	52                   	push   %edx
8010576d:	50                   	push   %eax
8010576e:	e8 d9 b9 ff ff       	call   8010114c <fileread>
80105773:	83 c4 10             	add    $0x10,%esp
}
80105776:	c9                   	leave  
80105777:	c3                   	ret    

80105778 <sys_write>:

int
sys_write(void)
{
80105778:	55                   	push   %ebp
80105779:	89 e5                	mov    %esp,%ebp
8010577b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010577e:	83 ec 04             	sub    $0x4,%esp
80105781:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105784:	50                   	push   %eax
80105785:	6a 00                	push   $0x0
80105787:	6a 00                	push   $0x0
80105789:	e8 67 fe ff ff       	call   801055f5 <argfd>
8010578e:	83 c4 10             	add    $0x10,%esp
80105791:	85 c0                	test   %eax,%eax
80105793:	78 2e                	js     801057c3 <sys_write+0x4b>
80105795:	83 ec 08             	sub    $0x8,%esp
80105798:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010579b:	50                   	push   %eax
8010579c:	6a 02                	push   $0x2
8010579e:	e8 ce fc ff ff       	call   80105471 <argint>
801057a3:	83 c4 10             	add    $0x10,%esp
801057a6:	85 c0                	test   %eax,%eax
801057a8:	78 19                	js     801057c3 <sys_write+0x4b>
801057aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ad:	83 ec 04             	sub    $0x4,%esp
801057b0:	50                   	push   %eax
801057b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057b4:	50                   	push   %eax
801057b5:	6a 01                	push   $0x1
801057b7:	e8 dd fc ff ff       	call   80105499 <argptr>
801057bc:	83 c4 10             	add    $0x10,%esp
801057bf:	85 c0                	test   %eax,%eax
801057c1:	79 07                	jns    801057ca <sys_write+0x52>
    return -1;
801057c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c8:	eb 17                	jmp    801057e1 <sys_write+0x69>
  return filewrite(f, p, n);
801057ca:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801057cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801057d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d3:	83 ec 04             	sub    $0x4,%esp
801057d6:	51                   	push   %ecx
801057d7:	52                   	push   %edx
801057d8:	50                   	push   %eax
801057d9:	e8 26 ba ff ff       	call   80101204 <filewrite>
801057de:	83 c4 10             	add    $0x10,%esp
}
801057e1:	c9                   	leave  
801057e2:	c3                   	ret    

801057e3 <sys_close>:

int
sys_close(void)
{
801057e3:	55                   	push   %ebp
801057e4:	89 e5                	mov    %esp,%ebp
801057e6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801057e9:	83 ec 04             	sub    $0x4,%esp
801057ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057ef:	50                   	push   %eax
801057f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057f3:	50                   	push   %eax
801057f4:	6a 00                	push   $0x0
801057f6:	e8 fa fd ff ff       	call   801055f5 <argfd>
801057fb:	83 c4 10             	add    $0x10,%esp
801057fe:	85 c0                	test   %eax,%eax
80105800:	79 07                	jns    80105809 <sys_close+0x26>
    return -1;
80105802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105807:	eb 28                	jmp    80105831 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105812:	83 c2 08             	add    $0x8,%edx
80105815:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010581c:	00 
  fileclose(f);
8010581d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	50                   	push   %eax
80105824:	e8 e4 b7 ff ff       	call   8010100d <fileclose>
80105829:	83 c4 10             	add    $0x10,%esp
  return 0;
8010582c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105831:	c9                   	leave  
80105832:	c3                   	ret    

80105833 <sys_fstat>:

int
sys_fstat(void)
{
80105833:	55                   	push   %ebp
80105834:	89 e5                	mov    %esp,%ebp
80105836:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105839:	83 ec 04             	sub    $0x4,%esp
8010583c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010583f:	50                   	push   %eax
80105840:	6a 00                	push   $0x0
80105842:	6a 00                	push   $0x0
80105844:	e8 ac fd ff ff       	call   801055f5 <argfd>
80105849:	83 c4 10             	add    $0x10,%esp
8010584c:	85 c0                	test   %eax,%eax
8010584e:	78 17                	js     80105867 <sys_fstat+0x34>
80105850:	83 ec 04             	sub    $0x4,%esp
80105853:	6a 14                	push   $0x14
80105855:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105858:	50                   	push   %eax
80105859:	6a 01                	push   $0x1
8010585b:	e8 39 fc ff ff       	call   80105499 <argptr>
80105860:	83 c4 10             	add    $0x10,%esp
80105863:	85 c0                	test   %eax,%eax
80105865:	79 07                	jns    8010586e <sys_fstat+0x3b>
    return -1;
80105867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010586c:	eb 13                	jmp    80105881 <sys_fstat+0x4e>
  return filestat(f, st);
8010586e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105874:	83 ec 08             	sub    $0x8,%esp
80105877:	52                   	push   %edx
80105878:	50                   	push   %eax
80105879:	e8 77 b8 ff ff       	call   801010f5 <filestat>
8010587e:	83 c4 10             	add    $0x10,%esp
}
80105881:	c9                   	leave  
80105882:	c3                   	ret    

80105883 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105883:	55                   	push   %ebp
80105884:	89 e5                	mov    %esp,%ebp
80105886:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105889:	83 ec 08             	sub    $0x8,%esp
8010588c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010588f:	50                   	push   %eax
80105890:	6a 00                	push   $0x0
80105892:	e8 61 fc ff ff       	call   801054f8 <argstr>
80105897:	83 c4 10             	add    $0x10,%esp
8010589a:	85 c0                	test   %eax,%eax
8010589c:	78 15                	js     801058b3 <sys_link+0x30>
8010589e:	83 ec 08             	sub    $0x8,%esp
801058a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058a4:	50                   	push   %eax
801058a5:	6a 01                	push   $0x1
801058a7:	e8 4c fc ff ff       	call   801054f8 <argstr>
801058ac:	83 c4 10             	add    $0x10,%esp
801058af:	85 c0                	test   %eax,%eax
801058b1:	79 0a                	jns    801058bd <sys_link+0x3a>
    return -1;
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	e9 69 01 00 00       	jmp    80105a26 <sys_link+0x1a3>

  begin_op();
801058bd:	e8 a4 db ff ff       	call   80103466 <begin_op>
  if((ip = namei(old)) == 0){
801058c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058c5:	83 ec 0c             	sub    $0xc,%esp
801058c8:	50                   	push   %eax
801058c9:	e8 c3 cb ff ff       	call   80102491 <namei>
801058ce:	83 c4 10             	add    $0x10,%esp
801058d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058d8:	75 0f                	jne    801058e9 <sys_link+0x66>
    end_op();
801058da:	e8 15 dc ff ff       	call   801034f4 <end_op>
    return -1;
801058df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e4:	e9 3d 01 00 00       	jmp    80105a26 <sys_link+0x1a3>
  }

  ilock(ip);
801058e9:	83 ec 0c             	sub    $0xc,%esp
801058ec:	ff 75 f4             	pushl  -0xc(%ebp)
801058ef:	e8 e8 bf ff ff       	call   801018dc <ilock>
801058f4:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801058f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058fe:	66 83 f8 01          	cmp    $0x1,%ax
80105902:	75 1d                	jne    80105921 <sys_link+0x9e>
    iunlockput(ip);
80105904:	83 ec 0c             	sub    $0xc,%esp
80105907:	ff 75 f4             	pushl  -0xc(%ebp)
8010590a:	e8 84 c2 ff ff       	call   80101b93 <iunlockput>
8010590f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105912:	e8 dd db ff ff       	call   801034f4 <end_op>
    return -1;
80105917:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591c:	e9 05 01 00 00       	jmp    80105a26 <sys_link+0x1a3>
  }

  ip->nlink++;
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105928:	83 c0 01             	add    $0x1,%eax
8010592b:	89 c2                	mov    %eax,%edx
8010592d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105930:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105934:	83 ec 0c             	sub    $0xc,%esp
80105937:	ff 75 f4             	pushl  -0xc(%ebp)
8010593a:	e8 ca bd ff ff       	call   80101709 <iupdate>
8010593f:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105942:	83 ec 0c             	sub    $0xc,%esp
80105945:	ff 75 f4             	pushl  -0xc(%ebp)
80105948:	e8 e6 c0 ff ff       	call   80101a33 <iunlock>
8010594d:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105950:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105953:	83 ec 08             	sub    $0x8,%esp
80105956:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105959:	52                   	push   %edx
8010595a:	50                   	push   %eax
8010595b:	e8 4d cb ff ff       	call   801024ad <nameiparent>
80105960:	83 c4 10             	add    $0x10,%esp
80105963:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105966:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010596a:	75 02                	jne    8010596e <sys_link+0xeb>
    goto bad;
8010596c:	eb 71                	jmp    801059df <sys_link+0x15c>
  ilock(dp);
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	ff 75 f0             	pushl  -0x10(%ebp)
80105974:	e8 63 bf ff ff       	call   801018dc <ilock>
80105979:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	8b 10                	mov    (%eax),%edx
80105981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105984:	8b 00                	mov    (%eax),%eax
80105986:	39 c2                	cmp    %eax,%edx
80105988:	75 1d                	jne    801059a7 <sys_link+0x124>
8010598a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598d:	8b 40 04             	mov    0x4(%eax),%eax
80105990:	83 ec 04             	sub    $0x4,%esp
80105993:	50                   	push   %eax
80105994:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105997:	50                   	push   %eax
80105998:	ff 75 f0             	pushl  -0x10(%ebp)
8010599b:	e8 59 c8 ff ff       	call   801021f9 <dirlink>
801059a0:	83 c4 10             	add    $0x10,%esp
801059a3:	85 c0                	test   %eax,%eax
801059a5:	79 10                	jns    801059b7 <sys_link+0x134>
    iunlockput(dp);
801059a7:	83 ec 0c             	sub    $0xc,%esp
801059aa:	ff 75 f0             	pushl  -0x10(%ebp)
801059ad:	e8 e1 c1 ff ff       	call   80101b93 <iunlockput>
801059b2:	83 c4 10             	add    $0x10,%esp
    goto bad;
801059b5:	eb 28                	jmp    801059df <sys_link+0x15c>
  }
  iunlockput(dp);
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 f0             	pushl  -0x10(%ebp)
801059bd:	e8 d1 c1 ff ff       	call   80101b93 <iunlockput>
801059c2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801059c5:	83 ec 0c             	sub    $0xc,%esp
801059c8:	ff 75 f4             	pushl  -0xc(%ebp)
801059cb:	e8 d4 c0 ff ff       	call   80101aa4 <iput>
801059d0:	83 c4 10             	add    $0x10,%esp

  end_op();
801059d3:	e8 1c db ff ff       	call   801034f4 <end_op>

  return 0;
801059d8:	b8 00 00 00 00       	mov    $0x0,%eax
801059dd:	eb 47                	jmp    80105a26 <sys_link+0x1a3>

bad:
  ilock(ip);
801059df:	83 ec 0c             	sub    $0xc,%esp
801059e2:	ff 75 f4             	pushl  -0xc(%ebp)
801059e5:	e8 f2 be ff ff       	call   801018dc <ilock>
801059ea:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059f4:	83 e8 01             	sub    $0x1,%eax
801059f7:	89 c2                	mov    %eax,%edx
801059f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a00:	83 ec 0c             	sub    $0xc,%esp
80105a03:	ff 75 f4             	pushl  -0xc(%ebp)
80105a06:	e8 fe bc ff ff       	call   80101709 <iupdate>
80105a0b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a0e:	83 ec 0c             	sub    $0xc,%esp
80105a11:	ff 75 f4             	pushl  -0xc(%ebp)
80105a14:	e8 7a c1 ff ff       	call   80101b93 <iunlockput>
80105a19:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a1c:	e8 d3 da ff ff       	call   801034f4 <end_op>
  return -1;
80105a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a26:	c9                   	leave  
80105a27:	c3                   	ret    

80105a28 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a28:	55                   	push   %ebp
80105a29:	89 e5                	mov    %esp,%ebp
80105a2b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a2e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a35:	eb 40                	jmp    80105a77 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3a:	6a 10                	push   $0x10
80105a3c:	50                   	push   %eax
80105a3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a40:	50                   	push   %eax
80105a41:	ff 75 08             	pushl  0x8(%ebp)
80105a44:	e8 f5 c3 ff ff       	call   80101e3e <readi>
80105a49:	83 c4 10             	add    $0x10,%esp
80105a4c:	83 f8 10             	cmp    $0x10,%eax
80105a4f:	74 0d                	je     80105a5e <isdirempty+0x36>
      panic("isdirempty: readi");
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	68 d4 88 10 80       	push   $0x801088d4
80105a59:	e8 fe aa ff ff       	call   8010055c <panic>
    if(de.inum != 0)
80105a5e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105a62:	66 85 c0             	test   %ax,%ax
80105a65:	74 07                	je     80105a6e <isdirempty+0x46>
      return 0;
80105a67:	b8 00 00 00 00       	mov    $0x0,%eax
80105a6c:	eb 1b                	jmp    80105a89 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a71:	83 c0 10             	add    $0x10,%eax
80105a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a7d:	8b 40 18             	mov    0x18(%eax),%eax
80105a80:	39 c2                	cmp    %eax,%edx
80105a82:	72 b3                	jb     80105a37 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a84:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a89:	c9                   	leave  
80105a8a:	c3                   	ret    

80105a8b <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a8b:	55                   	push   %ebp
80105a8c:	89 e5                	mov    %esp,%ebp
80105a8e:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a91:	83 ec 08             	sub    $0x8,%esp
80105a94:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a97:	50                   	push   %eax
80105a98:	6a 00                	push   $0x0
80105a9a:	e8 59 fa ff ff       	call   801054f8 <argstr>
80105a9f:	83 c4 10             	add    $0x10,%esp
80105aa2:	85 c0                	test   %eax,%eax
80105aa4:	79 0a                	jns    80105ab0 <sys_unlink+0x25>
    return -1;
80105aa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aab:	e9 bc 01 00 00       	jmp    80105c6c <sys_unlink+0x1e1>

  begin_op();
80105ab0:	e8 b1 d9 ff ff       	call   80103466 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ab5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105ab8:	83 ec 08             	sub    $0x8,%esp
80105abb:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105abe:	52                   	push   %edx
80105abf:	50                   	push   %eax
80105ac0:	e8 e8 c9 ff ff       	call   801024ad <nameiparent>
80105ac5:	83 c4 10             	add    $0x10,%esp
80105ac8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105acb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105acf:	75 0f                	jne    80105ae0 <sys_unlink+0x55>
    end_op();
80105ad1:	e8 1e da ff ff       	call   801034f4 <end_op>
    return -1;
80105ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adb:	e9 8c 01 00 00       	jmp    80105c6c <sys_unlink+0x1e1>
  }

  ilock(dp);
80105ae0:	83 ec 0c             	sub    $0xc,%esp
80105ae3:	ff 75 f4             	pushl  -0xc(%ebp)
80105ae6:	e8 f1 bd ff ff       	call   801018dc <ilock>
80105aeb:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105aee:	83 ec 08             	sub    $0x8,%esp
80105af1:	68 e6 88 10 80       	push   $0x801088e6
80105af6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105af9:	50                   	push   %eax
80105afa:	e8 24 c6 ff ff       	call   80102123 <namecmp>
80105aff:	83 c4 10             	add    $0x10,%esp
80105b02:	85 c0                	test   %eax,%eax
80105b04:	0f 84 4a 01 00 00    	je     80105c54 <sys_unlink+0x1c9>
80105b0a:	83 ec 08             	sub    $0x8,%esp
80105b0d:	68 e8 88 10 80       	push   $0x801088e8
80105b12:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b15:	50                   	push   %eax
80105b16:	e8 08 c6 ff ff       	call   80102123 <namecmp>
80105b1b:	83 c4 10             	add    $0x10,%esp
80105b1e:	85 c0                	test   %eax,%eax
80105b20:	0f 84 2e 01 00 00    	je     80105c54 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b26:	83 ec 04             	sub    $0x4,%esp
80105b29:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b2c:	50                   	push   %eax
80105b2d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b30:	50                   	push   %eax
80105b31:	ff 75 f4             	pushl  -0xc(%ebp)
80105b34:	e8 05 c6 ff ff       	call   8010213e <dirlookup>
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b43:	75 05                	jne    80105b4a <sys_unlink+0xbf>
    goto bad;
80105b45:	e9 0a 01 00 00       	jmp    80105c54 <sys_unlink+0x1c9>
  ilock(ip);
80105b4a:	83 ec 0c             	sub    $0xc,%esp
80105b4d:	ff 75 f0             	pushl  -0x10(%ebp)
80105b50:	e8 87 bd ff ff       	call   801018dc <ilock>
80105b55:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b5f:	66 85 c0             	test   %ax,%ax
80105b62:	7f 0d                	jg     80105b71 <sys_unlink+0xe6>
    panic("unlink: nlink < 1");
80105b64:	83 ec 0c             	sub    $0xc,%esp
80105b67:	68 eb 88 10 80       	push   $0x801088eb
80105b6c:	e8 eb a9 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b74:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b78:	66 83 f8 01          	cmp    $0x1,%ax
80105b7c:	75 25                	jne    80105ba3 <sys_unlink+0x118>
80105b7e:	83 ec 0c             	sub    $0xc,%esp
80105b81:	ff 75 f0             	pushl  -0x10(%ebp)
80105b84:	e8 9f fe ff ff       	call   80105a28 <isdirempty>
80105b89:	83 c4 10             	add    $0x10,%esp
80105b8c:	85 c0                	test   %eax,%eax
80105b8e:	75 13                	jne    80105ba3 <sys_unlink+0x118>
    iunlockput(ip);
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	ff 75 f0             	pushl  -0x10(%ebp)
80105b96:	e8 f8 bf ff ff       	call   80101b93 <iunlockput>
80105b9b:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b9e:	e9 b1 00 00 00       	jmp    80105c54 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105ba3:	83 ec 04             	sub    $0x4,%esp
80105ba6:	6a 10                	push   $0x10
80105ba8:	6a 00                	push   $0x0
80105baa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bad:	50                   	push   %eax
80105bae:	e8 97 f5 ff ff       	call   8010514a <memset>
80105bb3:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105bb6:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105bb9:	6a 10                	push   $0x10
80105bbb:	50                   	push   %eax
80105bbc:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bbf:	50                   	push   %eax
80105bc0:	ff 75 f4             	pushl  -0xc(%ebp)
80105bc3:	e8 d0 c3 ff ff       	call   80101f98 <writei>
80105bc8:	83 c4 10             	add    $0x10,%esp
80105bcb:	83 f8 10             	cmp    $0x10,%eax
80105bce:	74 0d                	je     80105bdd <sys_unlink+0x152>
    panic("unlink: writei");
80105bd0:	83 ec 0c             	sub    $0xc,%esp
80105bd3:	68 fd 88 10 80       	push   $0x801088fd
80105bd8:	e8 7f a9 ff ff       	call   8010055c <panic>
  if(ip->type == T_DIR){
80105bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105be4:	66 83 f8 01          	cmp    $0x1,%ax
80105be8:	75 21                	jne    80105c0b <sys_unlink+0x180>
    dp->nlink--;
80105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bed:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bf1:	83 e8 01             	sub    $0x1,%eax
80105bf4:	89 c2                	mov    %eax,%edx
80105bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf9:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105bfd:	83 ec 0c             	sub    $0xc,%esp
80105c00:	ff 75 f4             	pushl  -0xc(%ebp)
80105c03:	e8 01 bb ff ff       	call   80101709 <iupdate>
80105c08:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105c0b:	83 ec 0c             	sub    $0xc,%esp
80105c0e:	ff 75 f4             	pushl  -0xc(%ebp)
80105c11:	e8 7d bf ff ff       	call   80101b93 <iunlockput>
80105c16:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c20:	83 e8 01             	sub    $0x1,%eax
80105c23:	89 c2                	mov    %eax,%edx
80105c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c28:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c2c:	83 ec 0c             	sub    $0xc,%esp
80105c2f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c32:	e8 d2 ba ff ff       	call   80101709 <iupdate>
80105c37:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c3a:	83 ec 0c             	sub    $0xc,%esp
80105c3d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c40:	e8 4e bf ff ff       	call   80101b93 <iunlockput>
80105c45:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c48:	e8 a7 d8 ff ff       	call   801034f4 <end_op>

  return 0;
80105c4d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c52:	eb 18                	jmp    80105c6c <sys_unlink+0x1e1>

bad:
  iunlockput(dp);
80105c54:	83 ec 0c             	sub    $0xc,%esp
80105c57:	ff 75 f4             	pushl  -0xc(%ebp)
80105c5a:	e8 34 bf ff ff       	call   80101b93 <iunlockput>
80105c5f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c62:	e8 8d d8 ff ff       	call   801034f4 <end_op>
  return -1;
80105c67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c6c:	c9                   	leave  
80105c6d:	c3                   	ret    

80105c6e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c6e:	55                   	push   %ebp
80105c6f:	89 e5                	mov    %esp,%ebp
80105c71:	83 ec 38             	sub    $0x38,%esp
80105c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c77:	8b 55 10             	mov    0x10(%ebp),%edx
80105c7a:	8b 45 14             	mov    0x14(%ebp),%eax
80105c7d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c81:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c85:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c89:	83 ec 08             	sub    $0x8,%esp
80105c8c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c8f:	50                   	push   %eax
80105c90:	ff 75 08             	pushl  0x8(%ebp)
80105c93:	e8 15 c8 ff ff       	call   801024ad <nameiparent>
80105c98:	83 c4 10             	add    $0x10,%esp
80105c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ca2:	75 0a                	jne    80105cae <create+0x40>
    return 0;
80105ca4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ca9:	e9 90 01 00 00       	jmp    80105e3e <create+0x1d0>
  ilock(dp);
80105cae:	83 ec 0c             	sub    $0xc,%esp
80105cb1:	ff 75 f4             	pushl  -0xc(%ebp)
80105cb4:	e8 23 bc ff ff       	call   801018dc <ilock>
80105cb9:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105cbc:	83 ec 04             	sub    $0x4,%esp
80105cbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cc2:	50                   	push   %eax
80105cc3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cc6:	50                   	push   %eax
80105cc7:	ff 75 f4             	pushl  -0xc(%ebp)
80105cca:	e8 6f c4 ff ff       	call   8010213e <dirlookup>
80105ccf:	83 c4 10             	add    $0x10,%esp
80105cd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cd9:	74 50                	je     80105d2b <create+0xbd>
    iunlockput(dp);
80105cdb:	83 ec 0c             	sub    $0xc,%esp
80105cde:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce1:	e8 ad be ff ff       	call   80101b93 <iunlockput>
80105ce6:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105ce9:	83 ec 0c             	sub    $0xc,%esp
80105cec:	ff 75 f0             	pushl  -0x10(%ebp)
80105cef:	e8 e8 bb ff ff       	call   801018dc <ilock>
80105cf4:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105cf7:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105cfc:	75 15                	jne    80105d13 <create+0xa5>
80105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d01:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d05:	66 83 f8 02          	cmp    $0x2,%ax
80105d09:	75 08                	jne    80105d13 <create+0xa5>
      return ip;
80105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0e:	e9 2b 01 00 00       	jmp    80105e3e <create+0x1d0>
    iunlockput(ip);
80105d13:	83 ec 0c             	sub    $0xc,%esp
80105d16:	ff 75 f0             	pushl  -0x10(%ebp)
80105d19:	e8 75 be ff ff       	call   80101b93 <iunlockput>
80105d1e:	83 c4 10             	add    $0x10,%esp
    return 0;
80105d21:	b8 00 00 00 00       	mov    $0x0,%eax
80105d26:	e9 13 01 00 00       	jmp    80105e3e <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105d2b:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d32:	8b 00                	mov    (%eax),%eax
80105d34:	83 ec 08             	sub    $0x8,%esp
80105d37:	52                   	push   %edx
80105d38:	50                   	push   %eax
80105d39:	e8 ea b8 ff ff       	call   80101628 <ialloc>
80105d3e:	83 c4 10             	add    $0x10,%esp
80105d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d48:	75 0d                	jne    80105d57 <create+0xe9>
    panic("create: ialloc");
80105d4a:	83 ec 0c             	sub    $0xc,%esp
80105d4d:	68 0c 89 10 80       	push   $0x8010890c
80105d52:	e8 05 a8 ff ff       	call   8010055c <panic>

  ilock(ip);
80105d57:	83 ec 0c             	sub    $0xc,%esp
80105d5a:	ff 75 f0             	pushl  -0x10(%ebp)
80105d5d:	e8 7a bb ff ff       	call   801018dc <ilock>
80105d62:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d68:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105d6c:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d73:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105d77:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7e:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105d84:	83 ec 0c             	sub    $0xc,%esp
80105d87:	ff 75 f0             	pushl  -0x10(%ebp)
80105d8a:	e8 7a b9 ff ff       	call   80101709 <iupdate>
80105d8f:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105d92:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d97:	75 6a                	jne    80105e03 <create+0x195>
    dp->nlink++;  // for ".."
80105d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105da0:	83 c0 01             	add    $0x1,%eax
80105da3:	89 c2                	mov    %eax,%edx
80105da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105dac:	83 ec 0c             	sub    $0xc,%esp
80105daf:	ff 75 f4             	pushl  -0xc(%ebp)
80105db2:	e8 52 b9 ff ff       	call   80101709 <iupdate>
80105db7:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbd:	8b 40 04             	mov    0x4(%eax),%eax
80105dc0:	83 ec 04             	sub    $0x4,%esp
80105dc3:	50                   	push   %eax
80105dc4:	68 e6 88 10 80       	push   $0x801088e6
80105dc9:	ff 75 f0             	pushl  -0x10(%ebp)
80105dcc:	e8 28 c4 ff ff       	call   801021f9 <dirlink>
80105dd1:	83 c4 10             	add    $0x10,%esp
80105dd4:	85 c0                	test   %eax,%eax
80105dd6:	78 1e                	js     80105df6 <create+0x188>
80105dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddb:	8b 40 04             	mov    0x4(%eax),%eax
80105dde:	83 ec 04             	sub    $0x4,%esp
80105de1:	50                   	push   %eax
80105de2:	68 e8 88 10 80       	push   $0x801088e8
80105de7:	ff 75 f0             	pushl  -0x10(%ebp)
80105dea:	e8 0a c4 ff ff       	call   801021f9 <dirlink>
80105def:	83 c4 10             	add    $0x10,%esp
80105df2:	85 c0                	test   %eax,%eax
80105df4:	79 0d                	jns    80105e03 <create+0x195>
      panic("create dots");
80105df6:	83 ec 0c             	sub    $0xc,%esp
80105df9:	68 1b 89 10 80       	push   $0x8010891b
80105dfe:	e8 59 a7 ff ff       	call   8010055c <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e06:	8b 40 04             	mov    0x4(%eax),%eax
80105e09:	83 ec 04             	sub    $0x4,%esp
80105e0c:	50                   	push   %eax
80105e0d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e10:	50                   	push   %eax
80105e11:	ff 75 f4             	pushl  -0xc(%ebp)
80105e14:	e8 e0 c3 ff ff       	call   801021f9 <dirlink>
80105e19:	83 c4 10             	add    $0x10,%esp
80105e1c:	85 c0                	test   %eax,%eax
80105e1e:	79 0d                	jns    80105e2d <create+0x1bf>
    panic("create: dirlink");
80105e20:	83 ec 0c             	sub    $0xc,%esp
80105e23:	68 27 89 10 80       	push   $0x80108927
80105e28:	e8 2f a7 ff ff       	call   8010055c <panic>

  iunlockput(dp);
80105e2d:	83 ec 0c             	sub    $0xc,%esp
80105e30:	ff 75 f4             	pushl  -0xc(%ebp)
80105e33:	e8 5b bd ff ff       	call   80101b93 <iunlockput>
80105e38:	83 c4 10             	add    $0x10,%esp

  return ip;
80105e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e3e:	c9                   	leave  
80105e3f:	c3                   	ret    

80105e40 <sys_open>:

int
sys_open(void)
{
80105e40:	55                   	push   %ebp
80105e41:	89 e5                	mov    %esp,%ebp
80105e43:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e46:	83 ec 08             	sub    $0x8,%esp
80105e49:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e4c:	50                   	push   %eax
80105e4d:	6a 00                	push   $0x0
80105e4f:	e8 a4 f6 ff ff       	call   801054f8 <argstr>
80105e54:	83 c4 10             	add    $0x10,%esp
80105e57:	85 c0                	test   %eax,%eax
80105e59:	78 15                	js     80105e70 <sys_open+0x30>
80105e5b:	83 ec 08             	sub    $0x8,%esp
80105e5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e61:	50                   	push   %eax
80105e62:	6a 01                	push   $0x1
80105e64:	e8 08 f6 ff ff       	call   80105471 <argint>
80105e69:	83 c4 10             	add    $0x10,%esp
80105e6c:	85 c0                	test   %eax,%eax
80105e6e:	79 0a                	jns    80105e7a <sys_open+0x3a>
    return -1;
80105e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e75:	e9 61 01 00 00       	jmp    80105fdb <sys_open+0x19b>

  begin_op();
80105e7a:	e8 e7 d5 ff ff       	call   80103466 <begin_op>

  if(omode & O_CREATE){
80105e7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e82:	25 00 02 00 00       	and    $0x200,%eax
80105e87:	85 c0                	test   %eax,%eax
80105e89:	74 2a                	je     80105eb5 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105e8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e8e:	6a 00                	push   $0x0
80105e90:	6a 00                	push   $0x0
80105e92:	6a 02                	push   $0x2
80105e94:	50                   	push   %eax
80105e95:	e8 d4 fd ff ff       	call   80105c6e <create>
80105e9a:	83 c4 10             	add    $0x10,%esp
80105e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ea0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea4:	75 75                	jne    80105f1b <sys_open+0xdb>
      end_op();
80105ea6:	e8 49 d6 ff ff       	call   801034f4 <end_op>
      return -1;
80105eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb0:	e9 26 01 00 00       	jmp    80105fdb <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105eb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105eb8:	83 ec 0c             	sub    $0xc,%esp
80105ebb:	50                   	push   %eax
80105ebc:	e8 d0 c5 ff ff       	call   80102491 <namei>
80105ec1:	83 c4 10             	add    $0x10,%esp
80105ec4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ec7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ecb:	75 0f                	jne    80105edc <sys_open+0x9c>
      end_op();
80105ecd:	e8 22 d6 ff ff       	call   801034f4 <end_op>
      return -1;
80105ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed7:	e9 ff 00 00 00       	jmp    80105fdb <sys_open+0x19b>
    }
    ilock(ip);
80105edc:	83 ec 0c             	sub    $0xc,%esp
80105edf:	ff 75 f4             	pushl  -0xc(%ebp)
80105ee2:	e8 f5 b9 ff ff       	call   801018dc <ilock>
80105ee7:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eed:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ef1:	66 83 f8 01          	cmp    $0x1,%ax
80105ef5:	75 24                	jne    80105f1b <sys_open+0xdb>
80105ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105efa:	85 c0                	test   %eax,%eax
80105efc:	74 1d                	je     80105f1b <sys_open+0xdb>
      iunlockput(ip);
80105efe:	83 ec 0c             	sub    $0xc,%esp
80105f01:	ff 75 f4             	pushl  -0xc(%ebp)
80105f04:	e8 8a bc ff ff       	call   80101b93 <iunlockput>
80105f09:	83 c4 10             	add    $0x10,%esp
      end_op();
80105f0c:	e8 e3 d5 ff ff       	call   801034f4 <end_op>
      return -1;
80105f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f16:	e9 c0 00 00 00       	jmp    80105fdb <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105f1b:	e8 30 b0 ff ff       	call   80100f50 <filealloc>
80105f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f27:	74 17                	je     80105f40 <sys_open+0x100>
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	ff 75 f0             	pushl  -0x10(%ebp)
80105f2f:	e8 36 f7 ff ff       	call   8010566a <fdalloc>
80105f34:	83 c4 10             	add    $0x10,%esp
80105f37:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f3e:	79 2e                	jns    80105f6e <sys_open+0x12e>
    if(f)
80105f40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f44:	74 0e                	je     80105f54 <sys_open+0x114>
      fileclose(f);
80105f46:	83 ec 0c             	sub    $0xc,%esp
80105f49:	ff 75 f0             	pushl  -0x10(%ebp)
80105f4c:	e8 bc b0 ff ff       	call   8010100d <fileclose>
80105f51:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105f54:	83 ec 0c             	sub    $0xc,%esp
80105f57:	ff 75 f4             	pushl  -0xc(%ebp)
80105f5a:	e8 34 bc ff ff       	call   80101b93 <iunlockput>
80105f5f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f62:	e8 8d d5 ff ff       	call   801034f4 <end_op>
    return -1;
80105f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6c:	eb 6d                	jmp    80105fdb <sys_open+0x19b>
  }
  iunlock(ip);
80105f6e:	83 ec 0c             	sub    $0xc,%esp
80105f71:	ff 75 f4             	pushl  -0xc(%ebp)
80105f74:	e8 ba ba ff ff       	call   80101a33 <iunlock>
80105f79:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f7c:	e8 73 d5 ff ff       	call   801034f4 <end_op>

  f->type = FD_INODE;
80105f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f84:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f90:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f96:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa0:	83 e0 01             	and    $0x1,%eax
80105fa3:	85 c0                	test   %eax,%eax
80105fa5:	0f 94 c0             	sete   %al
80105fa8:	89 c2                	mov    %eax,%edx
80105faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fad:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fb3:	83 e0 01             	and    $0x1,%eax
80105fb6:	85 c0                	test   %eax,%eax
80105fb8:	75 0a                	jne    80105fc4 <sys_open+0x184>
80105fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fbd:	83 e0 02             	and    $0x2,%eax
80105fc0:	85 c0                	test   %eax,%eax
80105fc2:	74 07                	je     80105fcb <sys_open+0x18b>
80105fc4:	b8 01 00 00 00       	mov    $0x1,%eax
80105fc9:	eb 05                	jmp    80105fd0 <sys_open+0x190>
80105fcb:	b8 00 00 00 00       	mov    $0x0,%eax
80105fd0:	89 c2                	mov    %eax,%edx
80105fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105fd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105fdb:	c9                   	leave  
80105fdc:	c3                   	ret    

80105fdd <sys_mkdir>:

int
sys_mkdir(void)
{
80105fdd:	55                   	push   %ebp
80105fde:	89 e5                	mov    %esp,%ebp
80105fe0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105fe3:	e8 7e d4 ff ff       	call   80103466 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105fe8:	83 ec 08             	sub    $0x8,%esp
80105feb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fee:	50                   	push   %eax
80105fef:	6a 00                	push   $0x0
80105ff1:	e8 02 f5 ff ff       	call   801054f8 <argstr>
80105ff6:	83 c4 10             	add    $0x10,%esp
80105ff9:	85 c0                	test   %eax,%eax
80105ffb:	78 1b                	js     80106018 <sys_mkdir+0x3b>
80105ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106000:	6a 00                	push   $0x0
80106002:	6a 00                	push   $0x0
80106004:	6a 01                	push   $0x1
80106006:	50                   	push   %eax
80106007:	e8 62 fc ff ff       	call   80105c6e <create>
8010600c:	83 c4 10             	add    $0x10,%esp
8010600f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106012:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106016:	75 0c                	jne    80106024 <sys_mkdir+0x47>
    end_op();
80106018:	e8 d7 d4 ff ff       	call   801034f4 <end_op>
    return -1;
8010601d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106022:	eb 18                	jmp    8010603c <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106024:	83 ec 0c             	sub    $0xc,%esp
80106027:	ff 75 f4             	pushl  -0xc(%ebp)
8010602a:	e8 64 bb ff ff       	call   80101b93 <iunlockput>
8010602f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106032:	e8 bd d4 ff ff       	call   801034f4 <end_op>
  return 0;
80106037:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010603c:	c9                   	leave  
8010603d:	c3                   	ret    

8010603e <sys_mknod>:

int
sys_mknod(void)
{
8010603e:	55                   	push   %ebp
8010603f:	89 e5                	mov    %esp,%ebp
80106041:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106044:	e8 1d d4 ff ff       	call   80103466 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106049:	83 ec 08             	sub    $0x8,%esp
8010604c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010604f:	50                   	push   %eax
80106050:	6a 00                	push   $0x0
80106052:	e8 a1 f4 ff ff       	call   801054f8 <argstr>
80106057:	83 c4 10             	add    $0x10,%esp
8010605a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010605d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106061:	78 4f                	js     801060b2 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106063:	83 ec 08             	sub    $0x8,%esp
80106066:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106069:	50                   	push   %eax
8010606a:	6a 01                	push   $0x1
8010606c:	e8 00 f4 ff ff       	call   80105471 <argint>
80106071:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106074:	85 c0                	test   %eax,%eax
80106076:	78 3a                	js     801060b2 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106078:	83 ec 08             	sub    $0x8,%esp
8010607b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010607e:	50                   	push   %eax
8010607f:	6a 02                	push   $0x2
80106081:	e8 eb f3 ff ff       	call   80105471 <argint>
80106086:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106089:	85 c0                	test   %eax,%eax
8010608b:	78 25                	js     801060b2 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010608d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106090:	0f bf c8             	movswl %ax,%ecx
80106093:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106096:	0f bf d0             	movswl %ax,%edx
80106099:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010609c:	51                   	push   %ecx
8010609d:	52                   	push   %edx
8010609e:	6a 03                	push   $0x3
801060a0:	50                   	push   %eax
801060a1:	e8 c8 fb ff ff       	call   80105c6e <create>
801060a6:	83 c4 10             	add    $0x10,%esp
801060a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060b0:	75 0c                	jne    801060be <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801060b2:	e8 3d d4 ff ff       	call   801034f4 <end_op>
    return -1;
801060b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060bc:	eb 18                	jmp    801060d6 <sys_mknod+0x98>
  }
  iunlockput(ip);
801060be:	83 ec 0c             	sub    $0xc,%esp
801060c1:	ff 75 f0             	pushl  -0x10(%ebp)
801060c4:	e8 ca ba ff ff       	call   80101b93 <iunlockput>
801060c9:	83 c4 10             	add    $0x10,%esp
  end_op();
801060cc:	e8 23 d4 ff ff       	call   801034f4 <end_op>
  return 0;
801060d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060d6:	c9                   	leave  
801060d7:	c3                   	ret    

801060d8 <sys_chdir>:

int
sys_chdir(void)
{
801060d8:	55                   	push   %ebp
801060d9:	89 e5                	mov    %esp,%ebp
801060db:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060de:	e8 83 d3 ff ff       	call   80103466 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801060e3:	83 ec 08             	sub    $0x8,%esp
801060e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e9:	50                   	push   %eax
801060ea:	6a 00                	push   $0x0
801060ec:	e8 07 f4 ff ff       	call   801054f8 <argstr>
801060f1:	83 c4 10             	add    $0x10,%esp
801060f4:	85 c0                	test   %eax,%eax
801060f6:	78 18                	js     80106110 <sys_chdir+0x38>
801060f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fb:	83 ec 0c             	sub    $0xc,%esp
801060fe:	50                   	push   %eax
801060ff:	e8 8d c3 ff ff       	call   80102491 <namei>
80106104:	83 c4 10             	add    $0x10,%esp
80106107:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010610a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010610e:	75 0c                	jne    8010611c <sys_chdir+0x44>
    end_op();
80106110:	e8 df d3 ff ff       	call   801034f4 <end_op>
    return -1;
80106115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611a:	eb 6e                	jmp    8010618a <sys_chdir+0xb2>
  }
  ilock(ip);
8010611c:	83 ec 0c             	sub    $0xc,%esp
8010611f:	ff 75 f4             	pushl  -0xc(%ebp)
80106122:	e8 b5 b7 ff ff       	call   801018dc <ilock>
80106127:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010612a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106131:	66 83 f8 01          	cmp    $0x1,%ax
80106135:	74 1a                	je     80106151 <sys_chdir+0x79>
    iunlockput(ip);
80106137:	83 ec 0c             	sub    $0xc,%esp
8010613a:	ff 75 f4             	pushl  -0xc(%ebp)
8010613d:	e8 51 ba ff ff       	call   80101b93 <iunlockput>
80106142:	83 c4 10             	add    $0x10,%esp
    end_op();
80106145:	e8 aa d3 ff ff       	call   801034f4 <end_op>
    return -1;
8010614a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614f:	eb 39                	jmp    8010618a <sys_chdir+0xb2>
  }
  iunlock(ip);
80106151:	83 ec 0c             	sub    $0xc,%esp
80106154:	ff 75 f4             	pushl  -0xc(%ebp)
80106157:	e8 d7 b8 ff ff       	call   80101a33 <iunlock>
8010615c:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010615f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106165:	8b 40 68             	mov    0x68(%eax),%eax
80106168:	83 ec 0c             	sub    $0xc,%esp
8010616b:	50                   	push   %eax
8010616c:	e8 33 b9 ff ff       	call   80101aa4 <iput>
80106171:	83 c4 10             	add    $0x10,%esp
  end_op();
80106174:	e8 7b d3 ff ff       	call   801034f4 <end_op>
  proc->cwd = ip;
80106179:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010617f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106182:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106185:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618a:	c9                   	leave  
8010618b:	c3                   	ret    

8010618c <sys_exec>:

int
sys_exec(void)
{
8010618c:	55                   	push   %ebp
8010618d:	89 e5                	mov    %esp,%ebp
8010618f:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106195:	83 ec 08             	sub    $0x8,%esp
80106198:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010619b:	50                   	push   %eax
8010619c:	6a 00                	push   $0x0
8010619e:	e8 55 f3 ff ff       	call   801054f8 <argstr>
801061a3:	83 c4 10             	add    $0x10,%esp
801061a6:	85 c0                	test   %eax,%eax
801061a8:	78 18                	js     801061c2 <sys_exec+0x36>
801061aa:	83 ec 08             	sub    $0x8,%esp
801061ad:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801061b3:	50                   	push   %eax
801061b4:	6a 01                	push   $0x1
801061b6:	e8 b6 f2 ff ff       	call   80105471 <argint>
801061bb:	83 c4 10             	add    $0x10,%esp
801061be:	85 c0                	test   %eax,%eax
801061c0:	79 0a                	jns    801061cc <sys_exec+0x40>
    return -1;
801061c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c7:	e9 c6 00 00 00       	jmp    80106292 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801061cc:	83 ec 04             	sub    $0x4,%esp
801061cf:	68 80 00 00 00       	push   $0x80
801061d4:	6a 00                	push   $0x0
801061d6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061dc:	50                   	push   %eax
801061dd:	e8 68 ef ff ff       	call   8010514a <memset>
801061e2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801061e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801061ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ef:	83 f8 1f             	cmp    $0x1f,%eax
801061f2:	76 0a                	jbe    801061fe <sys_exec+0x72>
      return -1;
801061f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f9:	e9 94 00 00 00       	jmp    80106292 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106201:	c1 e0 02             	shl    $0x2,%eax
80106204:	89 c2                	mov    %eax,%edx
80106206:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010620c:	01 c2                	add    %eax,%edx
8010620e:	83 ec 08             	sub    $0x8,%esp
80106211:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106217:	50                   	push   %eax
80106218:	52                   	push   %edx
80106219:	e8 b7 f1 ff ff       	call   801053d5 <fetchint>
8010621e:	83 c4 10             	add    $0x10,%esp
80106221:	85 c0                	test   %eax,%eax
80106223:	79 07                	jns    8010622c <sys_exec+0xa0>
      return -1;
80106225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622a:	eb 66                	jmp    80106292 <sys_exec+0x106>
    if(uarg == 0){
8010622c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106232:	85 c0                	test   %eax,%eax
80106234:	75 27                	jne    8010625d <sys_exec+0xd1>
      argv[i] = 0;
80106236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106239:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106240:	00 00 00 00 
      break;
80106244:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106245:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106248:	83 ec 08             	sub    $0x8,%esp
8010624b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106251:	52                   	push   %edx
80106252:	50                   	push   %eax
80106253:	e8 ec a8 ff ff       	call   80100b44 <exec>
80106258:	83 c4 10             	add    $0x10,%esp
8010625b:	eb 35                	jmp    80106292 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010625d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106263:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106266:	c1 e2 02             	shl    $0x2,%edx
80106269:	01 c2                	add    %eax,%edx
8010626b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106271:	83 ec 08             	sub    $0x8,%esp
80106274:	52                   	push   %edx
80106275:	50                   	push   %eax
80106276:	e8 94 f1 ff ff       	call   8010540f <fetchstr>
8010627b:	83 c4 10             	add    $0x10,%esp
8010627e:	85 c0                	test   %eax,%eax
80106280:	79 07                	jns    80106289 <sys_exec+0xfd>
      return -1;
80106282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106287:	eb 09                	jmp    80106292 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106289:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010628d:	e9 5a ff ff ff       	jmp    801061ec <sys_exec+0x60>
  return exec(path, argv);
}
80106292:	c9                   	leave  
80106293:	c3                   	ret    

80106294 <sys_pipe>:

int
sys_pipe(void)
{
80106294:	55                   	push   %ebp
80106295:	89 e5                	mov    %esp,%ebp
80106297:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010629a:	83 ec 04             	sub    $0x4,%esp
8010629d:	6a 08                	push   $0x8
8010629f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062a2:	50                   	push   %eax
801062a3:	6a 00                	push   $0x0
801062a5:	e8 ef f1 ff ff       	call   80105499 <argptr>
801062aa:	83 c4 10             	add    $0x10,%esp
801062ad:	85 c0                	test   %eax,%eax
801062af:	79 0a                	jns    801062bb <sys_pipe+0x27>
    return -1;
801062b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b6:	e9 af 00 00 00       	jmp    8010636a <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801062bb:	83 ec 08             	sub    $0x8,%esp
801062be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062c1:	50                   	push   %eax
801062c2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062c5:	50                   	push   %eax
801062c6:	e8 68 dc ff ff       	call   80103f33 <pipealloc>
801062cb:	83 c4 10             	add    $0x10,%esp
801062ce:	85 c0                	test   %eax,%eax
801062d0:	79 0a                	jns    801062dc <sys_pipe+0x48>
    return -1;
801062d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d7:	e9 8e 00 00 00       	jmp    8010636a <sys_pipe+0xd6>
  fd0 = -1;
801062dc:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801062e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	50                   	push   %eax
801062ea:	e8 7b f3 ff ff       	call   8010566a <fdalloc>
801062ef:	83 c4 10             	add    $0x10,%esp
801062f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f9:	78 18                	js     80106313 <sys_pipe+0x7f>
801062fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062fe:	83 ec 0c             	sub    $0xc,%esp
80106301:	50                   	push   %eax
80106302:	e8 63 f3 ff ff       	call   8010566a <fdalloc>
80106307:	83 c4 10             	add    $0x10,%esp
8010630a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010630d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106311:	79 3f                	jns    80106352 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106313:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106317:	78 14                	js     8010632d <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106319:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010631f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106322:	83 c2 08             	add    $0x8,%edx
80106325:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010632c:	00 
    fileclose(rf);
8010632d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106330:	83 ec 0c             	sub    $0xc,%esp
80106333:	50                   	push   %eax
80106334:	e8 d4 ac ff ff       	call   8010100d <fileclose>
80106339:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010633c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010633f:	83 ec 0c             	sub    $0xc,%esp
80106342:	50                   	push   %eax
80106343:	e8 c5 ac ff ff       	call   8010100d <fileclose>
80106348:	83 c4 10             	add    $0x10,%esp
    return -1;
8010634b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106350:	eb 18                	jmp    8010636a <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106352:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106355:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106358:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010635a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010635d:	8d 50 04             	lea    0x4(%eax),%edx
80106360:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106363:	89 02                	mov    %eax,(%edx)
  return 0;
80106365:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010636a:	c9                   	leave  
8010636b:	c3                   	ret    

8010636c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010636c:	55                   	push   %ebp
8010636d:	89 e5                	mov    %esp,%ebp
8010636f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106372:	e8 bf e2 ff ff       	call   80104636 <fork>
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <sys_exit>:

int
sys_exit(void)
{
80106379:	55                   	push   %ebp
8010637a:	89 e5                	mov    %esp,%ebp
8010637c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010637f:	e8 43 e4 ff ff       	call   801047c7 <exit>
  return 0;  // not reached
80106384:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106389:	c9                   	leave  
8010638a:	c3                   	ret    

8010638b <sys_wait>:

int
sys_wait(void)
{
8010638b:	55                   	push   %ebp
8010638c:	89 e5                	mov    %esp,%ebp
8010638e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106391:	e8 6c e5 ff ff       	call   80104902 <wait>
}
80106396:	c9                   	leave  
80106397:	c3                   	ret    

80106398 <sys_kill>:

int
sys_kill(void)
{
80106398:	55                   	push   %ebp
80106399:	89 e5                	mov    %esp,%ebp
8010639b:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010639e:	83 ec 08             	sub    $0x8,%esp
801063a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063a4:	50                   	push   %eax
801063a5:	6a 00                	push   $0x0
801063a7:	e8 c5 f0 ff ff       	call   80105471 <argint>
801063ac:	83 c4 10             	add    $0x10,%esp
801063af:	85 c0                	test   %eax,%eax
801063b1:	79 07                	jns    801063ba <sys_kill+0x22>
    return -1;
801063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b8:	eb 0f                	jmp    801063c9 <sys_kill+0x31>
  return kill(pid);
801063ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bd:	83 ec 0c             	sub    $0xc,%esp
801063c0:	50                   	push   %eax
801063c1:	e8 51 e9 ff ff       	call   80104d17 <kill>
801063c6:	83 c4 10             	add    $0x10,%esp
}
801063c9:	c9                   	leave  
801063ca:	c3                   	ret    

801063cb <sys_getpid>:

int
sys_getpid(void)
{
801063cb:	55                   	push   %ebp
801063cc:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801063ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063d4:	8b 40 10             	mov    0x10(%eax),%eax
}
801063d7:	5d                   	pop    %ebp
801063d8:	c3                   	ret    

801063d9 <sys_sbrk>:

int
sys_sbrk(void)
{
801063d9:	55                   	push   %ebp
801063da:	89 e5                	mov    %esp,%ebp
801063dc:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801063df:	83 ec 08             	sub    $0x8,%esp
801063e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e5:	50                   	push   %eax
801063e6:	6a 00                	push   $0x0
801063e8:	e8 84 f0 ff ff       	call   80105471 <argint>
801063ed:	83 c4 10             	add    $0x10,%esp
801063f0:	85 c0                	test   %eax,%eax
801063f2:	79 07                	jns    801063fb <sys_sbrk+0x22>
    return -1;
801063f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f9:	eb 28                	jmp    80106423 <sys_sbrk+0x4a>
  addr = proc->sz;
801063fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106401:	8b 00                	mov    (%eax),%eax
80106403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106409:	83 ec 0c             	sub    $0xc,%esp
8010640c:	50                   	push   %eax
8010640d:	e8 81 e1 ff ff       	call   80104593 <growproc>
80106412:	83 c4 10             	add    $0x10,%esp
80106415:	85 c0                	test   %eax,%eax
80106417:	79 07                	jns    80106420 <sys_sbrk+0x47>
    return -1;
80106419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641e:	eb 03                	jmp    80106423 <sys_sbrk+0x4a>
  return addr;
80106420:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106423:	c9                   	leave  
80106424:	c3                   	ret    

80106425 <sys_sleep>:

int
sys_sleep(void)
{
80106425:	55                   	push   %ebp
80106426:	89 e5                	mov    %esp,%ebp
80106428:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010642b:	83 ec 08             	sub    $0x8,%esp
8010642e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106431:	50                   	push   %eax
80106432:	6a 00                	push   $0x0
80106434:	e8 38 f0 ff ff       	call   80105471 <argint>
80106439:	83 c4 10             	add    $0x10,%esp
8010643c:	85 c0                	test   %eax,%eax
8010643e:	79 07                	jns    80106447 <sys_sleep+0x22>
    return -1;
80106440:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106445:	eb 77                	jmp    801064be <sys_sleep+0x99>
  acquire(&tickslock);
80106447:	83 ec 0c             	sub    $0xc,%esp
8010644a:	68 80 4b 11 80       	push   $0x80114b80
8010644f:	e8 9a ea ff ff       	call   80104eee <acquire>
80106454:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106457:	a1 c0 53 11 80       	mov    0x801153c0,%eax
8010645c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010645f:	eb 39                	jmp    8010649a <sys_sleep+0x75>
    if(proc->killed){
80106461:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106467:	8b 40 24             	mov    0x24(%eax),%eax
8010646a:	85 c0                	test   %eax,%eax
8010646c:	74 17                	je     80106485 <sys_sleep+0x60>
      release(&tickslock);
8010646e:	83 ec 0c             	sub    $0xc,%esp
80106471:	68 80 4b 11 80       	push   $0x80114b80
80106476:	e8 d9 ea ff ff       	call   80104f54 <release>
8010647b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010647e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106483:	eb 39                	jmp    801064be <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106485:	83 ec 08             	sub    $0x8,%esp
80106488:	68 80 4b 11 80       	push   $0x80114b80
8010648d:	68 c0 53 11 80       	push   $0x801153c0
80106492:	e8 5e e7 ff ff       	call   80104bf5 <sleep>
80106497:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010649a:	a1 c0 53 11 80       	mov    0x801153c0,%eax
8010649f:	2b 45 f4             	sub    -0xc(%ebp),%eax
801064a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064a5:	39 d0                	cmp    %edx,%eax
801064a7:	72 b8                	jb     80106461 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801064a9:	83 ec 0c             	sub    $0xc,%esp
801064ac:	68 80 4b 11 80       	push   $0x80114b80
801064b1:	e8 9e ea ff ff       	call   80104f54 <release>
801064b6:	83 c4 10             	add    $0x10,%esp
  return 0;
801064b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064be:	c9                   	leave  
801064bf:	c3                   	ret    

801064c0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801064c0:	55                   	push   %ebp
801064c1:	89 e5                	mov    %esp,%ebp
801064c3:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801064c6:	83 ec 0c             	sub    $0xc,%esp
801064c9:	68 80 4b 11 80       	push   $0x80114b80
801064ce:	e8 1b ea ff ff       	call   80104eee <acquire>
801064d3:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801064d6:	a1 c0 53 11 80       	mov    0x801153c0,%eax
801064db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801064de:	83 ec 0c             	sub    $0xc,%esp
801064e1:	68 80 4b 11 80       	push   $0x80114b80
801064e6:	e8 69 ea ff ff       	call   80104f54 <release>
801064eb:	83 c4 10             	add    $0x10,%esp
  return xticks;
801064ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064f1:	c9                   	leave  
801064f2:	c3                   	ret    

801064f3 <sys_trace>:

int sys_trace(int x){
801064f3:	55                   	push   %ebp
801064f4:	89 e5                	mov    %esp,%ebp
801064f6:	83 ec 18             	sub    $0x18,%esp
	cprintf("\ncalling trace\n");
801064f9:	83 ec 0c             	sub    $0xc,%esp
801064fc:	68 37 89 10 80       	push   $0x80108937
80106501:	e8 b9 9e ff ff       	call   801003bf <cprintf>
80106506:	83 c4 10             	add    $0x10,%esp
	cprintf("caller pid is %d", proc->pid);
80106509:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010650f:	8b 40 10             	mov    0x10(%eax),%eax
80106512:	83 ec 08             	sub    $0x8,%esp
80106515:	50                   	push   %eax
80106516:	68 47 89 10 80       	push   $0x80108947
8010651b:	e8 9f 9e ff ff       	call   801003bf <cprintf>
80106520:	83 c4 10             	add    $0x10,%esp

	if(x != 0){
80106523:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80106527:	74 1b                	je     80106544 <sys_trace+0x51>
		   proc->traceFlag = true;
80106529:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652f:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
		int temp = proc->totalSysCall;
		proc->totalSysCall = 0;
		return temp;
	}
	
	return proc->totalSysCall;
80106536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010653c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106542:	eb 2f                	jmp    80106573 <sys_trace+0x80>
	cprintf("caller pid is %d", proc->pid);

	if(x != 0){
		   proc->traceFlag = true;
	}else{
		proc->traceFlag = false;
80106544:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010654a:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
		int temp = proc->totalSysCall;
80106551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106557:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010655d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		proc->totalSysCall = 0;
80106560:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106566:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010656d:	00 00 00 
		return temp;
80106570:	8b 45 f4             	mov    -0xc(%ebp),%eax
	}
	
	return proc->totalSysCall;
}
80106573:	c9                   	leave  
80106574:	c3                   	ret    

80106575 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106575:	55                   	push   %ebp
80106576:	89 e5                	mov    %esp,%ebp
80106578:	83 ec 08             	sub    $0x8,%esp
8010657b:	8b 55 08             	mov    0x8(%ebp),%edx
8010657e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106581:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106585:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106588:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010658c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106590:	ee                   	out    %al,(%dx)
}
80106591:	c9                   	leave  
80106592:	c3                   	ret    

80106593 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106593:	55                   	push   %ebp
80106594:	89 e5                	mov    %esp,%ebp
80106596:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106599:	6a 34                	push   $0x34
8010659b:	6a 43                	push   $0x43
8010659d:	e8 d3 ff ff ff       	call   80106575 <outb>
801065a2:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801065a5:	68 9c 00 00 00       	push   $0x9c
801065aa:	6a 40                	push   $0x40
801065ac:	e8 c4 ff ff ff       	call   80106575 <outb>
801065b1:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801065b4:	6a 2e                	push   $0x2e
801065b6:	6a 40                	push   $0x40
801065b8:	e8 b8 ff ff ff       	call   80106575 <outb>
801065bd:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801065c0:	83 ec 0c             	sub    $0xc,%esp
801065c3:	6a 00                	push   $0x0
801065c5:	e8 55 d8 ff ff       	call   80103e1f <picenable>
801065ca:	83 c4 10             	add    $0x10,%esp
}
801065cd:	c9                   	leave  
801065ce:	c3                   	ret    

801065cf <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801065cf:	1e                   	push   %ds
  pushl %es
801065d0:	06                   	push   %es
  pushl %fs
801065d1:	0f a0                	push   %fs
  pushl %gs
801065d3:	0f a8                	push   %gs
  pushal
801065d5:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801065d6:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801065da:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801065dc:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801065de:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801065e2:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801065e4:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801065e6:	54                   	push   %esp
  call trap
801065e7:	e8 d4 01 00 00       	call   801067c0 <trap>
  addl $4, %esp
801065ec:	83 c4 04             	add    $0x4,%esp

801065ef <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801065ef:	61                   	popa   
  popl %gs
801065f0:	0f a9                	pop    %gs
  popl %fs
801065f2:	0f a1                	pop    %fs
  popl %es
801065f4:	07                   	pop    %es
  popl %ds
801065f5:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801065f6:	83 c4 08             	add    $0x8,%esp
  iret
801065f9:	cf                   	iret   

801065fa <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801065fa:	55                   	push   %ebp
801065fb:	89 e5                	mov    %esp,%ebp
801065fd:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106600:	8b 45 0c             	mov    0xc(%ebp),%eax
80106603:	83 e8 01             	sub    $0x1,%eax
80106606:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010660a:	8b 45 08             	mov    0x8(%ebp),%eax
8010660d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106611:	8b 45 08             	mov    0x8(%ebp),%eax
80106614:	c1 e8 10             	shr    $0x10,%eax
80106617:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010661b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010661e:	0f 01 18             	lidtl  (%eax)
}
80106621:	c9                   	leave  
80106622:	c3                   	ret    

80106623 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106623:	55                   	push   %ebp
80106624:	89 e5                	mov    %esp,%ebp
80106626:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106629:	0f 20 d0             	mov    %cr2,%eax
8010662c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010662f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106632:	c9                   	leave  
80106633:	c3                   	ret    

80106634 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106634:	55                   	push   %ebp
80106635:	89 e5                	mov    %esp,%ebp
80106637:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010663a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106641:	e9 c3 00 00 00       	jmp    80106709 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106649:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106650:	89 c2                	mov    %eax,%edx
80106652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106655:	66 89 14 c5 c0 4b 11 	mov    %dx,-0x7feeb440(,%eax,8)
8010665c:	80 
8010665d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106660:	66 c7 04 c5 c2 4b 11 	movw   $0x8,-0x7feeb43e(,%eax,8)
80106667:	80 08 00 
8010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666d:	0f b6 14 c5 c4 4b 11 	movzbl -0x7feeb43c(,%eax,8),%edx
80106674:	80 
80106675:	83 e2 e0             	and    $0xffffffe0,%edx
80106678:	88 14 c5 c4 4b 11 80 	mov    %dl,-0x7feeb43c(,%eax,8)
8010667f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106682:	0f b6 14 c5 c4 4b 11 	movzbl -0x7feeb43c(,%eax,8),%edx
80106689:	80 
8010668a:	83 e2 1f             	and    $0x1f,%edx
8010668d:	88 14 c5 c4 4b 11 80 	mov    %dl,-0x7feeb43c(,%eax,8)
80106694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106697:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
8010669e:	80 
8010669f:	83 e2 f0             	and    $0xfffffff0,%edx
801066a2:	83 ca 0e             	or     $0xe,%edx
801066a5:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
801066ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066af:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
801066b6:	80 
801066b7:	83 e2 ef             	and    $0xffffffef,%edx
801066ba:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
801066c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c4:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
801066cb:	80 
801066cc:	83 e2 9f             	and    $0xffffff9f,%edx
801066cf:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
801066d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d9:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
801066e0:	80 
801066e1:	83 ca 80             	or     $0xffffff80,%edx
801066e4:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
801066eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ee:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801066f5:	c1 e8 10             	shr    $0x10,%eax
801066f8:	89 c2                	mov    %eax,%edx
801066fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fd:	66 89 14 c5 c6 4b 11 	mov    %dx,-0x7feeb43a(,%eax,8)
80106704:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106705:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106709:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106710:	0f 8e 30 ff ff ff    	jle    80106646 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106716:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
8010671b:	66 a3 c0 4d 11 80    	mov    %ax,0x80114dc0
80106721:	66 c7 05 c2 4d 11 80 	movw   $0x8,0x80114dc2
80106728:	08 00 
8010672a:	0f b6 05 c4 4d 11 80 	movzbl 0x80114dc4,%eax
80106731:	83 e0 e0             	and    $0xffffffe0,%eax
80106734:	a2 c4 4d 11 80       	mov    %al,0x80114dc4
80106739:	0f b6 05 c4 4d 11 80 	movzbl 0x80114dc4,%eax
80106740:	83 e0 1f             	and    $0x1f,%eax
80106743:	a2 c4 4d 11 80       	mov    %al,0x80114dc4
80106748:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
8010674f:	83 c8 0f             	or     $0xf,%eax
80106752:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106757:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
8010675e:	83 e0 ef             	and    $0xffffffef,%eax
80106761:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106766:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
8010676d:	83 c8 60             	or     $0x60,%eax
80106770:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106775:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
8010677c:	83 c8 80             	or     $0xffffff80,%eax
8010677f:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106784:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106789:	c1 e8 10             	shr    $0x10,%eax
8010678c:	66 a3 c6 4d 11 80    	mov    %ax,0x80114dc6
  
  initlock(&tickslock, "time");
80106792:	83 ec 08             	sub    $0x8,%esp
80106795:	68 58 89 10 80       	push   $0x80108958
8010679a:	68 80 4b 11 80       	push   $0x80114b80
8010679f:	e8 29 e7 ff ff       	call   80104ecd <initlock>
801067a4:	83 c4 10             	add    $0x10,%esp
}
801067a7:	c9                   	leave  
801067a8:	c3                   	ret    

801067a9 <idtinit>:

void
idtinit(void)
{
801067a9:	55                   	push   %ebp
801067aa:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801067ac:	68 00 08 00 00       	push   $0x800
801067b1:	68 c0 4b 11 80       	push   $0x80114bc0
801067b6:	e8 3f fe ff ff       	call   801065fa <lidt>
801067bb:	83 c4 08             	add    $0x8,%esp
}
801067be:	c9                   	leave  
801067bf:	c3                   	ret    

801067c0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801067c0:	55                   	push   %ebp
801067c1:	89 e5                	mov    %esp,%ebp
801067c3:	57                   	push   %edi
801067c4:	56                   	push   %esi
801067c5:	53                   	push   %ebx
801067c6:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801067c9:	8b 45 08             	mov    0x8(%ebp),%eax
801067cc:	8b 40 30             	mov    0x30(%eax),%eax
801067cf:	83 f8 40             	cmp    $0x40,%eax
801067d2:	75 3f                	jne    80106813 <trap+0x53>
    if(proc->killed)
801067d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067da:	8b 40 24             	mov    0x24(%eax),%eax
801067dd:	85 c0                	test   %eax,%eax
801067df:	74 05                	je     801067e6 <trap+0x26>
      exit();
801067e1:	e8 e1 df ff ff       	call   801047c7 <exit>
    proc->tf = tf;
801067e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067ec:	8b 55 08             	mov    0x8(%ebp),%edx
801067ef:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801067f2:	e8 32 ed ff ff       	call   80105529 <syscall>
    if(proc->killed)
801067f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067fd:	8b 40 24             	mov    0x24(%eax),%eax
80106800:	85 c0                	test   %eax,%eax
80106802:	74 0a                	je     8010680e <trap+0x4e>
      exit();
80106804:	e8 be df ff ff       	call   801047c7 <exit>
    return;
80106809:	e9 14 02 00 00       	jmp    80106a22 <trap+0x262>
8010680e:	e9 0f 02 00 00       	jmp    80106a22 <trap+0x262>
  }

  switch(tf->trapno){
80106813:	8b 45 08             	mov    0x8(%ebp),%eax
80106816:	8b 40 30             	mov    0x30(%eax),%eax
80106819:	83 e8 20             	sub    $0x20,%eax
8010681c:	83 f8 1f             	cmp    $0x1f,%eax
8010681f:	0f 87 c0 00 00 00    	ja     801068e5 <trap+0x125>
80106825:	8b 04 85 00 8a 10 80 	mov    -0x7fef7600(,%eax,4),%eax
8010682c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010682e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106834:	0f b6 00             	movzbl (%eax),%eax
80106837:	84 c0                	test   %al,%al
80106839:	75 3d                	jne    80106878 <trap+0xb8>
      acquire(&tickslock);
8010683b:	83 ec 0c             	sub    $0xc,%esp
8010683e:	68 80 4b 11 80       	push   $0x80114b80
80106843:	e8 a6 e6 ff ff       	call   80104eee <acquire>
80106848:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010684b:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80106850:	83 c0 01             	add    $0x1,%eax
80106853:	a3 c0 53 11 80       	mov    %eax,0x801153c0
      wakeup(&ticks);
80106858:	83 ec 0c             	sub    $0xc,%esp
8010685b:	68 c0 53 11 80       	push   $0x801153c0
80106860:	e8 7c e4 ff ff       	call   80104ce1 <wakeup>
80106865:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106868:	83 ec 0c             	sub    $0xc,%esp
8010686b:	68 80 4b 11 80       	push   $0x80114b80
80106870:	e8 df e6 ff ff       	call   80104f54 <release>
80106875:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106878:	e8 c2 c6 ff ff       	call   80102f3f <lapiceoi>
    break;
8010687d:	e9 1c 01 00 00       	jmp    8010699e <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106882:	e8 d9 be ff ff       	call   80102760 <ideintr>
    lapiceoi();
80106887:	e8 b3 c6 ff ff       	call   80102f3f <lapiceoi>
    break;
8010688c:	e9 0d 01 00 00       	jmp    8010699e <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106891:	e8 b0 c4 ff ff       	call   80102d46 <kbdintr>
    lapiceoi();
80106896:	e8 a4 c6 ff ff       	call   80102f3f <lapiceoi>
    break;
8010689b:	e9 fe 00 00 00       	jmp    8010699e <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801068a0:	e8 5a 03 00 00       	call   80106bff <uartintr>
    lapiceoi();
801068a5:	e8 95 c6 ff ff       	call   80102f3f <lapiceoi>
    break;
801068aa:	e9 ef 00 00 00       	jmp    8010699e <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068af:	8b 45 08             	mov    0x8(%ebp),%eax
801068b2:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801068b5:	8b 45 08             	mov    0x8(%ebp),%eax
801068b8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068bc:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801068bf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068c5:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801068c8:	0f b6 c0             	movzbl %al,%eax
801068cb:	51                   	push   %ecx
801068cc:	52                   	push   %edx
801068cd:	50                   	push   %eax
801068ce:	68 60 89 10 80       	push   $0x80108960
801068d3:	e8 e7 9a ff ff       	call   801003bf <cprintf>
801068d8:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801068db:	e8 5f c6 ff ff       	call   80102f3f <lapiceoi>
    break;
801068e0:	e9 b9 00 00 00       	jmp    8010699e <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801068e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068eb:	85 c0                	test   %eax,%eax
801068ed:	74 11                	je     80106900 <trap+0x140>
801068ef:	8b 45 08             	mov    0x8(%ebp),%eax
801068f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068f6:	0f b7 c0             	movzwl %ax,%eax
801068f9:	83 e0 03             	and    $0x3,%eax
801068fc:	85 c0                	test   %eax,%eax
801068fe:	75 40                	jne    80106940 <trap+0x180>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106900:	e8 1e fd ff ff       	call   80106623 <rcr2>
80106905:	89 c3                	mov    %eax,%ebx
80106907:	8b 45 08             	mov    0x8(%ebp),%eax
8010690a:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010690d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106913:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106916:	0f b6 d0             	movzbl %al,%edx
80106919:	8b 45 08             	mov    0x8(%ebp),%eax
8010691c:	8b 40 30             	mov    0x30(%eax),%eax
8010691f:	83 ec 0c             	sub    $0xc,%esp
80106922:	53                   	push   %ebx
80106923:	51                   	push   %ecx
80106924:	52                   	push   %edx
80106925:	50                   	push   %eax
80106926:	68 84 89 10 80       	push   $0x80108984
8010692b:	e8 8f 9a ff ff       	call   801003bf <cprintf>
80106930:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106933:	83 ec 0c             	sub    $0xc,%esp
80106936:	68 b6 89 10 80       	push   $0x801089b6
8010693b:	e8 1c 9c ff ff       	call   8010055c <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106940:	e8 de fc ff ff       	call   80106623 <rcr2>
80106945:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106948:	8b 45 08             	mov    0x8(%ebp),%eax
8010694b:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010694e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106954:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106957:	0f b6 d8             	movzbl %al,%ebx
8010695a:	8b 45 08             	mov    0x8(%ebp),%eax
8010695d:	8b 48 34             	mov    0x34(%eax),%ecx
80106960:	8b 45 08             	mov    0x8(%ebp),%eax
80106963:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106966:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696c:	8d 78 6c             	lea    0x6c(%eax),%edi
8010696f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106975:	8b 40 10             	mov    0x10(%eax),%eax
80106978:	ff 75 e4             	pushl  -0x1c(%ebp)
8010697b:	56                   	push   %esi
8010697c:	53                   	push   %ebx
8010697d:	51                   	push   %ecx
8010697e:	52                   	push   %edx
8010697f:	57                   	push   %edi
80106980:	50                   	push   %eax
80106981:	68 bc 89 10 80       	push   $0x801089bc
80106986:	e8 34 9a ff ff       	call   801003bf <cprintf>
8010698b:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010698e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106994:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010699b:	eb 01                	jmp    8010699e <trap+0x1de>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010699d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010699e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a4:	85 c0                	test   %eax,%eax
801069a6:	74 24                	je     801069cc <trap+0x20c>
801069a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069ae:	8b 40 24             	mov    0x24(%eax),%eax
801069b1:	85 c0                	test   %eax,%eax
801069b3:	74 17                	je     801069cc <trap+0x20c>
801069b5:	8b 45 08             	mov    0x8(%ebp),%eax
801069b8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069bc:	0f b7 c0             	movzwl %ax,%eax
801069bf:	83 e0 03             	and    $0x3,%eax
801069c2:	83 f8 03             	cmp    $0x3,%eax
801069c5:	75 05                	jne    801069cc <trap+0x20c>
    exit();
801069c7:	e8 fb dd ff ff       	call   801047c7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801069cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069d2:	85 c0                	test   %eax,%eax
801069d4:	74 1e                	je     801069f4 <trap+0x234>
801069d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069dc:	8b 40 0c             	mov    0xc(%eax),%eax
801069df:	83 f8 04             	cmp    $0x4,%eax
801069e2:	75 10                	jne    801069f4 <trap+0x234>
801069e4:	8b 45 08             	mov    0x8(%ebp),%eax
801069e7:	8b 40 30             	mov    0x30(%eax),%eax
801069ea:	83 f8 20             	cmp    $0x20,%eax
801069ed:	75 05                	jne    801069f4 <trap+0x234>
    yield();
801069ef:	e8 97 e1 ff ff       	call   80104b8b <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801069f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069fa:	85 c0                	test   %eax,%eax
801069fc:	74 24                	je     80106a22 <trap+0x262>
801069fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a04:	8b 40 24             	mov    0x24(%eax),%eax
80106a07:	85 c0                	test   %eax,%eax
80106a09:	74 17                	je     80106a22 <trap+0x262>
80106a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a0e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a12:	0f b7 c0             	movzwl %ax,%eax
80106a15:	83 e0 03             	and    $0x3,%eax
80106a18:	83 f8 03             	cmp    $0x3,%eax
80106a1b:	75 05                	jne    80106a22 <trap+0x262>
    exit();
80106a1d:	e8 a5 dd ff ff       	call   801047c7 <exit>
}
80106a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a25:	5b                   	pop    %ebx
80106a26:	5e                   	pop    %esi
80106a27:	5f                   	pop    %edi
80106a28:	5d                   	pop    %ebp
80106a29:	c3                   	ret    

80106a2a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106a2a:	55                   	push   %ebp
80106a2b:	89 e5                	mov    %esp,%ebp
80106a2d:	83 ec 14             	sub    $0x14,%esp
80106a30:	8b 45 08             	mov    0x8(%ebp),%eax
80106a33:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a37:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106a3b:	89 c2                	mov    %eax,%edx
80106a3d:	ec                   	in     (%dx),%al
80106a3e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106a41:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106a45:	c9                   	leave  
80106a46:	c3                   	ret    

80106a47 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106a47:	55                   	push   %ebp
80106a48:	89 e5                	mov    %esp,%ebp
80106a4a:	83 ec 08             	sub    $0x8,%esp
80106a4d:	8b 55 08             	mov    0x8(%ebp),%edx
80106a50:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a53:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106a57:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a5a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106a5e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106a62:	ee                   	out    %al,(%dx)
}
80106a63:	c9                   	leave  
80106a64:	c3                   	ret    

80106a65 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106a65:	55                   	push   %ebp
80106a66:	89 e5                	mov    %esp,%ebp
80106a68:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106a6b:	6a 00                	push   $0x0
80106a6d:	68 fa 03 00 00       	push   $0x3fa
80106a72:	e8 d0 ff ff ff       	call   80106a47 <outb>
80106a77:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106a7a:	68 80 00 00 00       	push   $0x80
80106a7f:	68 fb 03 00 00       	push   $0x3fb
80106a84:	e8 be ff ff ff       	call   80106a47 <outb>
80106a89:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106a8c:	6a 0c                	push   $0xc
80106a8e:	68 f8 03 00 00       	push   $0x3f8
80106a93:	e8 af ff ff ff       	call   80106a47 <outb>
80106a98:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106a9b:	6a 00                	push   $0x0
80106a9d:	68 f9 03 00 00       	push   $0x3f9
80106aa2:	e8 a0 ff ff ff       	call   80106a47 <outb>
80106aa7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106aaa:	6a 03                	push   $0x3
80106aac:	68 fb 03 00 00       	push   $0x3fb
80106ab1:	e8 91 ff ff ff       	call   80106a47 <outb>
80106ab6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106ab9:	6a 00                	push   $0x0
80106abb:	68 fc 03 00 00       	push   $0x3fc
80106ac0:	e8 82 ff ff ff       	call   80106a47 <outb>
80106ac5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ac8:	6a 01                	push   $0x1
80106aca:	68 f9 03 00 00       	push   $0x3f9
80106acf:	e8 73 ff ff ff       	call   80106a47 <outb>
80106ad4:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ad7:	68 fd 03 00 00       	push   $0x3fd
80106adc:	e8 49 ff ff ff       	call   80106a2a <inb>
80106ae1:	83 c4 04             	add    $0x4,%esp
80106ae4:	3c ff                	cmp    $0xff,%al
80106ae6:	75 02                	jne    80106aea <uartinit+0x85>
    return;
80106ae8:	eb 6c                	jmp    80106b56 <uartinit+0xf1>
  uart = 1;
80106aea:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106af1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106af4:	68 fa 03 00 00       	push   $0x3fa
80106af9:	e8 2c ff ff ff       	call   80106a2a <inb>
80106afe:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b01:	68 f8 03 00 00       	push   $0x3f8
80106b06:	e8 1f ff ff ff       	call   80106a2a <inb>
80106b0b:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106b0e:	83 ec 0c             	sub    $0xc,%esp
80106b11:	6a 04                	push   $0x4
80106b13:	e8 07 d3 ff ff       	call   80103e1f <picenable>
80106b18:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106b1b:	83 ec 08             	sub    $0x8,%esp
80106b1e:	6a 00                	push   $0x0
80106b20:	6a 04                	push   $0x4
80106b22:	e8 d7 be ff ff       	call   801029fe <ioapicenable>
80106b27:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b2a:	c7 45 f4 80 8a 10 80 	movl   $0x80108a80,-0xc(%ebp)
80106b31:	eb 19                	jmp    80106b4c <uartinit+0xe7>
    uartputc(*p);
80106b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b36:	0f b6 00             	movzbl (%eax),%eax
80106b39:	0f be c0             	movsbl %al,%eax
80106b3c:	83 ec 0c             	sub    $0xc,%esp
80106b3f:	50                   	push   %eax
80106b40:	e8 13 00 00 00       	call   80106b58 <uartputc>
80106b45:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4f:	0f b6 00             	movzbl (%eax),%eax
80106b52:	84 c0                	test   %al,%al
80106b54:	75 dd                	jne    80106b33 <uartinit+0xce>
    uartputc(*p);
}
80106b56:	c9                   	leave  
80106b57:	c3                   	ret    

80106b58 <uartputc>:

void
uartputc(int c)
{
80106b58:	55                   	push   %ebp
80106b59:	89 e5                	mov    %esp,%ebp
80106b5b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106b5e:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106b63:	85 c0                	test   %eax,%eax
80106b65:	75 02                	jne    80106b69 <uartputc+0x11>
    return;
80106b67:	eb 51                	jmp    80106bba <uartputc+0x62>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b70:	eb 11                	jmp    80106b83 <uartputc+0x2b>
    microdelay(10);
80106b72:	83 ec 0c             	sub    $0xc,%esp
80106b75:	6a 0a                	push   $0xa
80106b77:	e8 dd c3 ff ff       	call   80102f59 <microdelay>
80106b7c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b83:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106b87:	7f 1a                	jg     80106ba3 <uartputc+0x4b>
80106b89:	83 ec 0c             	sub    $0xc,%esp
80106b8c:	68 fd 03 00 00       	push   $0x3fd
80106b91:	e8 94 fe ff ff       	call   80106a2a <inb>
80106b96:	83 c4 10             	add    $0x10,%esp
80106b99:	0f b6 c0             	movzbl %al,%eax
80106b9c:	83 e0 20             	and    $0x20,%eax
80106b9f:	85 c0                	test   %eax,%eax
80106ba1:	74 cf                	je     80106b72 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba6:	0f b6 c0             	movzbl %al,%eax
80106ba9:	83 ec 08             	sub    $0x8,%esp
80106bac:	50                   	push   %eax
80106bad:	68 f8 03 00 00       	push   $0x3f8
80106bb2:	e8 90 fe ff ff       	call   80106a47 <outb>
80106bb7:	83 c4 10             	add    $0x10,%esp
}
80106bba:	c9                   	leave  
80106bbb:	c3                   	ret    

80106bbc <uartgetc>:

static int
uartgetc(void)
{
80106bbc:	55                   	push   %ebp
80106bbd:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106bbf:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106bc4:	85 c0                	test   %eax,%eax
80106bc6:	75 07                	jne    80106bcf <uartgetc+0x13>
    return -1;
80106bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bcd:	eb 2e                	jmp    80106bfd <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106bcf:	68 fd 03 00 00       	push   $0x3fd
80106bd4:	e8 51 fe ff ff       	call   80106a2a <inb>
80106bd9:	83 c4 04             	add    $0x4,%esp
80106bdc:	0f b6 c0             	movzbl %al,%eax
80106bdf:	83 e0 01             	and    $0x1,%eax
80106be2:	85 c0                	test   %eax,%eax
80106be4:	75 07                	jne    80106bed <uartgetc+0x31>
    return -1;
80106be6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106beb:	eb 10                	jmp    80106bfd <uartgetc+0x41>
  return inb(COM1+0);
80106bed:	68 f8 03 00 00       	push   $0x3f8
80106bf2:	e8 33 fe ff ff       	call   80106a2a <inb>
80106bf7:	83 c4 04             	add    $0x4,%esp
80106bfa:	0f b6 c0             	movzbl %al,%eax
}
80106bfd:	c9                   	leave  
80106bfe:	c3                   	ret    

80106bff <uartintr>:

void
uartintr(void)
{
80106bff:	55                   	push   %ebp
80106c00:	89 e5                	mov    %esp,%ebp
80106c02:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c05:	83 ec 0c             	sub    $0xc,%esp
80106c08:	68 bc 6b 10 80       	push   $0x80106bbc
80106c0d:	e8 bf 9b ff ff       	call   801007d1 <consoleintr>
80106c12:	83 c4 10             	add    $0x10,%esp
}
80106c15:	c9                   	leave  
80106c16:	c3                   	ret    

80106c17 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $0
80106c19:	6a 00                	push   $0x0
  jmp alltraps
80106c1b:	e9 af f9 ff ff       	jmp    801065cf <alltraps>

80106c20 <vector1>:
.globl vector1
vector1:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $1
80106c22:	6a 01                	push   $0x1
  jmp alltraps
80106c24:	e9 a6 f9 ff ff       	jmp    801065cf <alltraps>

80106c29 <vector2>:
.globl vector2
vector2:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $2
80106c2b:	6a 02                	push   $0x2
  jmp alltraps
80106c2d:	e9 9d f9 ff ff       	jmp    801065cf <alltraps>

80106c32 <vector3>:
.globl vector3
vector3:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $3
80106c34:	6a 03                	push   $0x3
  jmp alltraps
80106c36:	e9 94 f9 ff ff       	jmp    801065cf <alltraps>

80106c3b <vector4>:
.globl vector4
vector4:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $4
80106c3d:	6a 04                	push   $0x4
  jmp alltraps
80106c3f:	e9 8b f9 ff ff       	jmp    801065cf <alltraps>

80106c44 <vector5>:
.globl vector5
vector5:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $5
80106c46:	6a 05                	push   $0x5
  jmp alltraps
80106c48:	e9 82 f9 ff ff       	jmp    801065cf <alltraps>

80106c4d <vector6>:
.globl vector6
vector6:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $6
80106c4f:	6a 06                	push   $0x6
  jmp alltraps
80106c51:	e9 79 f9 ff ff       	jmp    801065cf <alltraps>

80106c56 <vector7>:
.globl vector7
vector7:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $7
80106c58:	6a 07                	push   $0x7
  jmp alltraps
80106c5a:	e9 70 f9 ff ff       	jmp    801065cf <alltraps>

80106c5f <vector8>:
.globl vector8
vector8:
  pushl $8
80106c5f:	6a 08                	push   $0x8
  jmp alltraps
80106c61:	e9 69 f9 ff ff       	jmp    801065cf <alltraps>

80106c66 <vector9>:
.globl vector9
vector9:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $9
80106c68:	6a 09                	push   $0x9
  jmp alltraps
80106c6a:	e9 60 f9 ff ff       	jmp    801065cf <alltraps>

80106c6f <vector10>:
.globl vector10
vector10:
  pushl $10
80106c6f:	6a 0a                	push   $0xa
  jmp alltraps
80106c71:	e9 59 f9 ff ff       	jmp    801065cf <alltraps>

80106c76 <vector11>:
.globl vector11
vector11:
  pushl $11
80106c76:	6a 0b                	push   $0xb
  jmp alltraps
80106c78:	e9 52 f9 ff ff       	jmp    801065cf <alltraps>

80106c7d <vector12>:
.globl vector12
vector12:
  pushl $12
80106c7d:	6a 0c                	push   $0xc
  jmp alltraps
80106c7f:	e9 4b f9 ff ff       	jmp    801065cf <alltraps>

80106c84 <vector13>:
.globl vector13
vector13:
  pushl $13
80106c84:	6a 0d                	push   $0xd
  jmp alltraps
80106c86:	e9 44 f9 ff ff       	jmp    801065cf <alltraps>

80106c8b <vector14>:
.globl vector14
vector14:
  pushl $14
80106c8b:	6a 0e                	push   $0xe
  jmp alltraps
80106c8d:	e9 3d f9 ff ff       	jmp    801065cf <alltraps>

80106c92 <vector15>:
.globl vector15
vector15:
  pushl $0
80106c92:	6a 00                	push   $0x0
  pushl $15
80106c94:	6a 0f                	push   $0xf
  jmp alltraps
80106c96:	e9 34 f9 ff ff       	jmp    801065cf <alltraps>

80106c9b <vector16>:
.globl vector16
vector16:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $16
80106c9d:	6a 10                	push   $0x10
  jmp alltraps
80106c9f:	e9 2b f9 ff ff       	jmp    801065cf <alltraps>

80106ca4 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ca4:	6a 11                	push   $0x11
  jmp alltraps
80106ca6:	e9 24 f9 ff ff       	jmp    801065cf <alltraps>

80106cab <vector18>:
.globl vector18
vector18:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $18
80106cad:	6a 12                	push   $0x12
  jmp alltraps
80106caf:	e9 1b f9 ff ff       	jmp    801065cf <alltraps>

80106cb4 <vector19>:
.globl vector19
vector19:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $19
80106cb6:	6a 13                	push   $0x13
  jmp alltraps
80106cb8:	e9 12 f9 ff ff       	jmp    801065cf <alltraps>

80106cbd <vector20>:
.globl vector20
vector20:
  pushl $0
80106cbd:	6a 00                	push   $0x0
  pushl $20
80106cbf:	6a 14                	push   $0x14
  jmp alltraps
80106cc1:	e9 09 f9 ff ff       	jmp    801065cf <alltraps>

80106cc6 <vector21>:
.globl vector21
vector21:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $21
80106cc8:	6a 15                	push   $0x15
  jmp alltraps
80106cca:	e9 00 f9 ff ff       	jmp    801065cf <alltraps>

80106ccf <vector22>:
.globl vector22
vector22:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $22
80106cd1:	6a 16                	push   $0x16
  jmp alltraps
80106cd3:	e9 f7 f8 ff ff       	jmp    801065cf <alltraps>

80106cd8 <vector23>:
.globl vector23
vector23:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $23
80106cda:	6a 17                	push   $0x17
  jmp alltraps
80106cdc:	e9 ee f8 ff ff       	jmp    801065cf <alltraps>

80106ce1 <vector24>:
.globl vector24
vector24:
  pushl $0
80106ce1:	6a 00                	push   $0x0
  pushl $24
80106ce3:	6a 18                	push   $0x18
  jmp alltraps
80106ce5:	e9 e5 f8 ff ff       	jmp    801065cf <alltraps>

80106cea <vector25>:
.globl vector25
vector25:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $25
80106cec:	6a 19                	push   $0x19
  jmp alltraps
80106cee:	e9 dc f8 ff ff       	jmp    801065cf <alltraps>

80106cf3 <vector26>:
.globl vector26
vector26:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $26
80106cf5:	6a 1a                	push   $0x1a
  jmp alltraps
80106cf7:	e9 d3 f8 ff ff       	jmp    801065cf <alltraps>

80106cfc <vector27>:
.globl vector27
vector27:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $27
80106cfe:	6a 1b                	push   $0x1b
  jmp alltraps
80106d00:	e9 ca f8 ff ff       	jmp    801065cf <alltraps>

80106d05 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $28
80106d07:	6a 1c                	push   $0x1c
  jmp alltraps
80106d09:	e9 c1 f8 ff ff       	jmp    801065cf <alltraps>

80106d0e <vector29>:
.globl vector29
vector29:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $29
80106d10:	6a 1d                	push   $0x1d
  jmp alltraps
80106d12:	e9 b8 f8 ff ff       	jmp    801065cf <alltraps>

80106d17 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $30
80106d19:	6a 1e                	push   $0x1e
  jmp alltraps
80106d1b:	e9 af f8 ff ff       	jmp    801065cf <alltraps>

80106d20 <vector31>:
.globl vector31
vector31:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $31
80106d22:	6a 1f                	push   $0x1f
  jmp alltraps
80106d24:	e9 a6 f8 ff ff       	jmp    801065cf <alltraps>

80106d29 <vector32>:
.globl vector32
vector32:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $32
80106d2b:	6a 20                	push   $0x20
  jmp alltraps
80106d2d:	e9 9d f8 ff ff       	jmp    801065cf <alltraps>

80106d32 <vector33>:
.globl vector33
vector33:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $33
80106d34:	6a 21                	push   $0x21
  jmp alltraps
80106d36:	e9 94 f8 ff ff       	jmp    801065cf <alltraps>

80106d3b <vector34>:
.globl vector34
vector34:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $34
80106d3d:	6a 22                	push   $0x22
  jmp alltraps
80106d3f:	e9 8b f8 ff ff       	jmp    801065cf <alltraps>

80106d44 <vector35>:
.globl vector35
vector35:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $35
80106d46:	6a 23                	push   $0x23
  jmp alltraps
80106d48:	e9 82 f8 ff ff       	jmp    801065cf <alltraps>

80106d4d <vector36>:
.globl vector36
vector36:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $36
80106d4f:	6a 24                	push   $0x24
  jmp alltraps
80106d51:	e9 79 f8 ff ff       	jmp    801065cf <alltraps>

80106d56 <vector37>:
.globl vector37
vector37:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $37
80106d58:	6a 25                	push   $0x25
  jmp alltraps
80106d5a:	e9 70 f8 ff ff       	jmp    801065cf <alltraps>

80106d5f <vector38>:
.globl vector38
vector38:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $38
80106d61:	6a 26                	push   $0x26
  jmp alltraps
80106d63:	e9 67 f8 ff ff       	jmp    801065cf <alltraps>

80106d68 <vector39>:
.globl vector39
vector39:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $39
80106d6a:	6a 27                	push   $0x27
  jmp alltraps
80106d6c:	e9 5e f8 ff ff       	jmp    801065cf <alltraps>

80106d71 <vector40>:
.globl vector40
vector40:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $40
80106d73:	6a 28                	push   $0x28
  jmp alltraps
80106d75:	e9 55 f8 ff ff       	jmp    801065cf <alltraps>

80106d7a <vector41>:
.globl vector41
vector41:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $41
80106d7c:	6a 29                	push   $0x29
  jmp alltraps
80106d7e:	e9 4c f8 ff ff       	jmp    801065cf <alltraps>

80106d83 <vector42>:
.globl vector42
vector42:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $42
80106d85:	6a 2a                	push   $0x2a
  jmp alltraps
80106d87:	e9 43 f8 ff ff       	jmp    801065cf <alltraps>

80106d8c <vector43>:
.globl vector43
vector43:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $43
80106d8e:	6a 2b                	push   $0x2b
  jmp alltraps
80106d90:	e9 3a f8 ff ff       	jmp    801065cf <alltraps>

80106d95 <vector44>:
.globl vector44
vector44:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $44
80106d97:	6a 2c                	push   $0x2c
  jmp alltraps
80106d99:	e9 31 f8 ff ff       	jmp    801065cf <alltraps>

80106d9e <vector45>:
.globl vector45
vector45:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $45
80106da0:	6a 2d                	push   $0x2d
  jmp alltraps
80106da2:	e9 28 f8 ff ff       	jmp    801065cf <alltraps>

80106da7 <vector46>:
.globl vector46
vector46:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $46
80106da9:	6a 2e                	push   $0x2e
  jmp alltraps
80106dab:	e9 1f f8 ff ff       	jmp    801065cf <alltraps>

80106db0 <vector47>:
.globl vector47
vector47:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $47
80106db2:	6a 2f                	push   $0x2f
  jmp alltraps
80106db4:	e9 16 f8 ff ff       	jmp    801065cf <alltraps>

80106db9 <vector48>:
.globl vector48
vector48:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $48
80106dbb:	6a 30                	push   $0x30
  jmp alltraps
80106dbd:	e9 0d f8 ff ff       	jmp    801065cf <alltraps>

80106dc2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $49
80106dc4:	6a 31                	push   $0x31
  jmp alltraps
80106dc6:	e9 04 f8 ff ff       	jmp    801065cf <alltraps>

80106dcb <vector50>:
.globl vector50
vector50:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $50
80106dcd:	6a 32                	push   $0x32
  jmp alltraps
80106dcf:	e9 fb f7 ff ff       	jmp    801065cf <alltraps>

80106dd4 <vector51>:
.globl vector51
vector51:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $51
80106dd6:	6a 33                	push   $0x33
  jmp alltraps
80106dd8:	e9 f2 f7 ff ff       	jmp    801065cf <alltraps>

80106ddd <vector52>:
.globl vector52
vector52:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $52
80106ddf:	6a 34                	push   $0x34
  jmp alltraps
80106de1:	e9 e9 f7 ff ff       	jmp    801065cf <alltraps>

80106de6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $53
80106de8:	6a 35                	push   $0x35
  jmp alltraps
80106dea:	e9 e0 f7 ff ff       	jmp    801065cf <alltraps>

80106def <vector54>:
.globl vector54
vector54:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $54
80106df1:	6a 36                	push   $0x36
  jmp alltraps
80106df3:	e9 d7 f7 ff ff       	jmp    801065cf <alltraps>

80106df8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $55
80106dfa:	6a 37                	push   $0x37
  jmp alltraps
80106dfc:	e9 ce f7 ff ff       	jmp    801065cf <alltraps>

80106e01 <vector56>:
.globl vector56
vector56:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $56
80106e03:	6a 38                	push   $0x38
  jmp alltraps
80106e05:	e9 c5 f7 ff ff       	jmp    801065cf <alltraps>

80106e0a <vector57>:
.globl vector57
vector57:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $57
80106e0c:	6a 39                	push   $0x39
  jmp alltraps
80106e0e:	e9 bc f7 ff ff       	jmp    801065cf <alltraps>

80106e13 <vector58>:
.globl vector58
vector58:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $58
80106e15:	6a 3a                	push   $0x3a
  jmp alltraps
80106e17:	e9 b3 f7 ff ff       	jmp    801065cf <alltraps>

80106e1c <vector59>:
.globl vector59
vector59:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $59
80106e1e:	6a 3b                	push   $0x3b
  jmp alltraps
80106e20:	e9 aa f7 ff ff       	jmp    801065cf <alltraps>

80106e25 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $60
80106e27:	6a 3c                	push   $0x3c
  jmp alltraps
80106e29:	e9 a1 f7 ff ff       	jmp    801065cf <alltraps>

80106e2e <vector61>:
.globl vector61
vector61:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $61
80106e30:	6a 3d                	push   $0x3d
  jmp alltraps
80106e32:	e9 98 f7 ff ff       	jmp    801065cf <alltraps>

80106e37 <vector62>:
.globl vector62
vector62:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $62
80106e39:	6a 3e                	push   $0x3e
  jmp alltraps
80106e3b:	e9 8f f7 ff ff       	jmp    801065cf <alltraps>

80106e40 <vector63>:
.globl vector63
vector63:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $63
80106e42:	6a 3f                	push   $0x3f
  jmp alltraps
80106e44:	e9 86 f7 ff ff       	jmp    801065cf <alltraps>

80106e49 <vector64>:
.globl vector64
vector64:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $64
80106e4b:	6a 40                	push   $0x40
  jmp alltraps
80106e4d:	e9 7d f7 ff ff       	jmp    801065cf <alltraps>

80106e52 <vector65>:
.globl vector65
vector65:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $65
80106e54:	6a 41                	push   $0x41
  jmp alltraps
80106e56:	e9 74 f7 ff ff       	jmp    801065cf <alltraps>

80106e5b <vector66>:
.globl vector66
vector66:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $66
80106e5d:	6a 42                	push   $0x42
  jmp alltraps
80106e5f:	e9 6b f7 ff ff       	jmp    801065cf <alltraps>

80106e64 <vector67>:
.globl vector67
vector67:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $67
80106e66:	6a 43                	push   $0x43
  jmp alltraps
80106e68:	e9 62 f7 ff ff       	jmp    801065cf <alltraps>

80106e6d <vector68>:
.globl vector68
vector68:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $68
80106e6f:	6a 44                	push   $0x44
  jmp alltraps
80106e71:	e9 59 f7 ff ff       	jmp    801065cf <alltraps>

80106e76 <vector69>:
.globl vector69
vector69:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $69
80106e78:	6a 45                	push   $0x45
  jmp alltraps
80106e7a:	e9 50 f7 ff ff       	jmp    801065cf <alltraps>

80106e7f <vector70>:
.globl vector70
vector70:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $70
80106e81:	6a 46                	push   $0x46
  jmp alltraps
80106e83:	e9 47 f7 ff ff       	jmp    801065cf <alltraps>

80106e88 <vector71>:
.globl vector71
vector71:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $71
80106e8a:	6a 47                	push   $0x47
  jmp alltraps
80106e8c:	e9 3e f7 ff ff       	jmp    801065cf <alltraps>

80106e91 <vector72>:
.globl vector72
vector72:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $72
80106e93:	6a 48                	push   $0x48
  jmp alltraps
80106e95:	e9 35 f7 ff ff       	jmp    801065cf <alltraps>

80106e9a <vector73>:
.globl vector73
vector73:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $73
80106e9c:	6a 49                	push   $0x49
  jmp alltraps
80106e9e:	e9 2c f7 ff ff       	jmp    801065cf <alltraps>

80106ea3 <vector74>:
.globl vector74
vector74:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $74
80106ea5:	6a 4a                	push   $0x4a
  jmp alltraps
80106ea7:	e9 23 f7 ff ff       	jmp    801065cf <alltraps>

80106eac <vector75>:
.globl vector75
vector75:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $75
80106eae:	6a 4b                	push   $0x4b
  jmp alltraps
80106eb0:	e9 1a f7 ff ff       	jmp    801065cf <alltraps>

80106eb5 <vector76>:
.globl vector76
vector76:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $76
80106eb7:	6a 4c                	push   $0x4c
  jmp alltraps
80106eb9:	e9 11 f7 ff ff       	jmp    801065cf <alltraps>

80106ebe <vector77>:
.globl vector77
vector77:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $77
80106ec0:	6a 4d                	push   $0x4d
  jmp alltraps
80106ec2:	e9 08 f7 ff ff       	jmp    801065cf <alltraps>

80106ec7 <vector78>:
.globl vector78
vector78:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $78
80106ec9:	6a 4e                	push   $0x4e
  jmp alltraps
80106ecb:	e9 ff f6 ff ff       	jmp    801065cf <alltraps>

80106ed0 <vector79>:
.globl vector79
vector79:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $79
80106ed2:	6a 4f                	push   $0x4f
  jmp alltraps
80106ed4:	e9 f6 f6 ff ff       	jmp    801065cf <alltraps>

80106ed9 <vector80>:
.globl vector80
vector80:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $80
80106edb:	6a 50                	push   $0x50
  jmp alltraps
80106edd:	e9 ed f6 ff ff       	jmp    801065cf <alltraps>

80106ee2 <vector81>:
.globl vector81
vector81:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $81
80106ee4:	6a 51                	push   $0x51
  jmp alltraps
80106ee6:	e9 e4 f6 ff ff       	jmp    801065cf <alltraps>

80106eeb <vector82>:
.globl vector82
vector82:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $82
80106eed:	6a 52                	push   $0x52
  jmp alltraps
80106eef:	e9 db f6 ff ff       	jmp    801065cf <alltraps>

80106ef4 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $83
80106ef6:	6a 53                	push   $0x53
  jmp alltraps
80106ef8:	e9 d2 f6 ff ff       	jmp    801065cf <alltraps>

80106efd <vector84>:
.globl vector84
vector84:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $84
80106eff:	6a 54                	push   $0x54
  jmp alltraps
80106f01:	e9 c9 f6 ff ff       	jmp    801065cf <alltraps>

80106f06 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $85
80106f08:	6a 55                	push   $0x55
  jmp alltraps
80106f0a:	e9 c0 f6 ff ff       	jmp    801065cf <alltraps>

80106f0f <vector86>:
.globl vector86
vector86:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $86
80106f11:	6a 56                	push   $0x56
  jmp alltraps
80106f13:	e9 b7 f6 ff ff       	jmp    801065cf <alltraps>

80106f18 <vector87>:
.globl vector87
vector87:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $87
80106f1a:	6a 57                	push   $0x57
  jmp alltraps
80106f1c:	e9 ae f6 ff ff       	jmp    801065cf <alltraps>

80106f21 <vector88>:
.globl vector88
vector88:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $88
80106f23:	6a 58                	push   $0x58
  jmp alltraps
80106f25:	e9 a5 f6 ff ff       	jmp    801065cf <alltraps>

80106f2a <vector89>:
.globl vector89
vector89:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $89
80106f2c:	6a 59                	push   $0x59
  jmp alltraps
80106f2e:	e9 9c f6 ff ff       	jmp    801065cf <alltraps>

80106f33 <vector90>:
.globl vector90
vector90:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $90
80106f35:	6a 5a                	push   $0x5a
  jmp alltraps
80106f37:	e9 93 f6 ff ff       	jmp    801065cf <alltraps>

80106f3c <vector91>:
.globl vector91
vector91:
  pushl $0
80106f3c:	6a 00                	push   $0x0
  pushl $91
80106f3e:	6a 5b                	push   $0x5b
  jmp alltraps
80106f40:	e9 8a f6 ff ff       	jmp    801065cf <alltraps>

80106f45 <vector92>:
.globl vector92
vector92:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $92
80106f47:	6a 5c                	push   $0x5c
  jmp alltraps
80106f49:	e9 81 f6 ff ff       	jmp    801065cf <alltraps>

80106f4e <vector93>:
.globl vector93
vector93:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $93
80106f50:	6a 5d                	push   $0x5d
  jmp alltraps
80106f52:	e9 78 f6 ff ff       	jmp    801065cf <alltraps>

80106f57 <vector94>:
.globl vector94
vector94:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $94
80106f59:	6a 5e                	push   $0x5e
  jmp alltraps
80106f5b:	e9 6f f6 ff ff       	jmp    801065cf <alltraps>

80106f60 <vector95>:
.globl vector95
vector95:
  pushl $0
80106f60:	6a 00                	push   $0x0
  pushl $95
80106f62:	6a 5f                	push   $0x5f
  jmp alltraps
80106f64:	e9 66 f6 ff ff       	jmp    801065cf <alltraps>

80106f69 <vector96>:
.globl vector96
vector96:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $96
80106f6b:	6a 60                	push   $0x60
  jmp alltraps
80106f6d:	e9 5d f6 ff ff       	jmp    801065cf <alltraps>

80106f72 <vector97>:
.globl vector97
vector97:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $97
80106f74:	6a 61                	push   $0x61
  jmp alltraps
80106f76:	e9 54 f6 ff ff       	jmp    801065cf <alltraps>

80106f7b <vector98>:
.globl vector98
vector98:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $98
80106f7d:	6a 62                	push   $0x62
  jmp alltraps
80106f7f:	e9 4b f6 ff ff       	jmp    801065cf <alltraps>

80106f84 <vector99>:
.globl vector99
vector99:
  pushl $0
80106f84:	6a 00                	push   $0x0
  pushl $99
80106f86:	6a 63                	push   $0x63
  jmp alltraps
80106f88:	e9 42 f6 ff ff       	jmp    801065cf <alltraps>

80106f8d <vector100>:
.globl vector100
vector100:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $100
80106f8f:	6a 64                	push   $0x64
  jmp alltraps
80106f91:	e9 39 f6 ff ff       	jmp    801065cf <alltraps>

80106f96 <vector101>:
.globl vector101
vector101:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $101
80106f98:	6a 65                	push   $0x65
  jmp alltraps
80106f9a:	e9 30 f6 ff ff       	jmp    801065cf <alltraps>

80106f9f <vector102>:
.globl vector102
vector102:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $102
80106fa1:	6a 66                	push   $0x66
  jmp alltraps
80106fa3:	e9 27 f6 ff ff       	jmp    801065cf <alltraps>

80106fa8 <vector103>:
.globl vector103
vector103:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $103
80106faa:	6a 67                	push   $0x67
  jmp alltraps
80106fac:	e9 1e f6 ff ff       	jmp    801065cf <alltraps>

80106fb1 <vector104>:
.globl vector104
vector104:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $104
80106fb3:	6a 68                	push   $0x68
  jmp alltraps
80106fb5:	e9 15 f6 ff ff       	jmp    801065cf <alltraps>

80106fba <vector105>:
.globl vector105
vector105:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $105
80106fbc:	6a 69                	push   $0x69
  jmp alltraps
80106fbe:	e9 0c f6 ff ff       	jmp    801065cf <alltraps>

80106fc3 <vector106>:
.globl vector106
vector106:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $106
80106fc5:	6a 6a                	push   $0x6a
  jmp alltraps
80106fc7:	e9 03 f6 ff ff       	jmp    801065cf <alltraps>

80106fcc <vector107>:
.globl vector107
vector107:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $107
80106fce:	6a 6b                	push   $0x6b
  jmp alltraps
80106fd0:	e9 fa f5 ff ff       	jmp    801065cf <alltraps>

80106fd5 <vector108>:
.globl vector108
vector108:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $108
80106fd7:	6a 6c                	push   $0x6c
  jmp alltraps
80106fd9:	e9 f1 f5 ff ff       	jmp    801065cf <alltraps>

80106fde <vector109>:
.globl vector109
vector109:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $109
80106fe0:	6a 6d                	push   $0x6d
  jmp alltraps
80106fe2:	e9 e8 f5 ff ff       	jmp    801065cf <alltraps>

80106fe7 <vector110>:
.globl vector110
vector110:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $110
80106fe9:	6a 6e                	push   $0x6e
  jmp alltraps
80106feb:	e9 df f5 ff ff       	jmp    801065cf <alltraps>

80106ff0 <vector111>:
.globl vector111
vector111:
  pushl $0
80106ff0:	6a 00                	push   $0x0
  pushl $111
80106ff2:	6a 6f                	push   $0x6f
  jmp alltraps
80106ff4:	e9 d6 f5 ff ff       	jmp    801065cf <alltraps>

80106ff9 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $112
80106ffb:	6a 70                	push   $0x70
  jmp alltraps
80106ffd:	e9 cd f5 ff ff       	jmp    801065cf <alltraps>

80107002 <vector113>:
.globl vector113
vector113:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $113
80107004:	6a 71                	push   $0x71
  jmp alltraps
80107006:	e9 c4 f5 ff ff       	jmp    801065cf <alltraps>

8010700b <vector114>:
.globl vector114
vector114:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $114
8010700d:	6a 72                	push   $0x72
  jmp alltraps
8010700f:	e9 bb f5 ff ff       	jmp    801065cf <alltraps>

80107014 <vector115>:
.globl vector115
vector115:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $115
80107016:	6a 73                	push   $0x73
  jmp alltraps
80107018:	e9 b2 f5 ff ff       	jmp    801065cf <alltraps>

8010701d <vector116>:
.globl vector116
vector116:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $116
8010701f:	6a 74                	push   $0x74
  jmp alltraps
80107021:	e9 a9 f5 ff ff       	jmp    801065cf <alltraps>

80107026 <vector117>:
.globl vector117
vector117:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $117
80107028:	6a 75                	push   $0x75
  jmp alltraps
8010702a:	e9 a0 f5 ff ff       	jmp    801065cf <alltraps>

8010702f <vector118>:
.globl vector118
vector118:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $118
80107031:	6a 76                	push   $0x76
  jmp alltraps
80107033:	e9 97 f5 ff ff       	jmp    801065cf <alltraps>

80107038 <vector119>:
.globl vector119
vector119:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $119
8010703a:	6a 77                	push   $0x77
  jmp alltraps
8010703c:	e9 8e f5 ff ff       	jmp    801065cf <alltraps>

80107041 <vector120>:
.globl vector120
vector120:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $120
80107043:	6a 78                	push   $0x78
  jmp alltraps
80107045:	e9 85 f5 ff ff       	jmp    801065cf <alltraps>

8010704a <vector121>:
.globl vector121
vector121:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $121
8010704c:	6a 79                	push   $0x79
  jmp alltraps
8010704e:	e9 7c f5 ff ff       	jmp    801065cf <alltraps>

80107053 <vector122>:
.globl vector122
vector122:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $122
80107055:	6a 7a                	push   $0x7a
  jmp alltraps
80107057:	e9 73 f5 ff ff       	jmp    801065cf <alltraps>

8010705c <vector123>:
.globl vector123
vector123:
  pushl $0
8010705c:	6a 00                	push   $0x0
  pushl $123
8010705e:	6a 7b                	push   $0x7b
  jmp alltraps
80107060:	e9 6a f5 ff ff       	jmp    801065cf <alltraps>

80107065 <vector124>:
.globl vector124
vector124:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $124
80107067:	6a 7c                	push   $0x7c
  jmp alltraps
80107069:	e9 61 f5 ff ff       	jmp    801065cf <alltraps>

8010706e <vector125>:
.globl vector125
vector125:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $125
80107070:	6a 7d                	push   $0x7d
  jmp alltraps
80107072:	e9 58 f5 ff ff       	jmp    801065cf <alltraps>

80107077 <vector126>:
.globl vector126
vector126:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $126
80107079:	6a 7e                	push   $0x7e
  jmp alltraps
8010707b:	e9 4f f5 ff ff       	jmp    801065cf <alltraps>

80107080 <vector127>:
.globl vector127
vector127:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $127
80107082:	6a 7f                	push   $0x7f
  jmp alltraps
80107084:	e9 46 f5 ff ff       	jmp    801065cf <alltraps>

80107089 <vector128>:
.globl vector128
vector128:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $128
8010708b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107090:	e9 3a f5 ff ff       	jmp    801065cf <alltraps>

80107095 <vector129>:
.globl vector129
vector129:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $129
80107097:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010709c:	e9 2e f5 ff ff       	jmp    801065cf <alltraps>

801070a1 <vector130>:
.globl vector130
vector130:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $130
801070a3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801070a8:	e9 22 f5 ff ff       	jmp    801065cf <alltraps>

801070ad <vector131>:
.globl vector131
vector131:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $131
801070af:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801070b4:	e9 16 f5 ff ff       	jmp    801065cf <alltraps>

801070b9 <vector132>:
.globl vector132
vector132:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $132
801070bb:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801070c0:	e9 0a f5 ff ff       	jmp    801065cf <alltraps>

801070c5 <vector133>:
.globl vector133
vector133:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $133
801070c7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801070cc:	e9 fe f4 ff ff       	jmp    801065cf <alltraps>

801070d1 <vector134>:
.globl vector134
vector134:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $134
801070d3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801070d8:	e9 f2 f4 ff ff       	jmp    801065cf <alltraps>

801070dd <vector135>:
.globl vector135
vector135:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $135
801070df:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801070e4:	e9 e6 f4 ff ff       	jmp    801065cf <alltraps>

801070e9 <vector136>:
.globl vector136
vector136:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $136
801070eb:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801070f0:	e9 da f4 ff ff       	jmp    801065cf <alltraps>

801070f5 <vector137>:
.globl vector137
vector137:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $137
801070f7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801070fc:	e9 ce f4 ff ff       	jmp    801065cf <alltraps>

80107101 <vector138>:
.globl vector138
vector138:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $138
80107103:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107108:	e9 c2 f4 ff ff       	jmp    801065cf <alltraps>

8010710d <vector139>:
.globl vector139
vector139:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $139
8010710f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107114:	e9 b6 f4 ff ff       	jmp    801065cf <alltraps>

80107119 <vector140>:
.globl vector140
vector140:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $140
8010711b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107120:	e9 aa f4 ff ff       	jmp    801065cf <alltraps>

80107125 <vector141>:
.globl vector141
vector141:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $141
80107127:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010712c:	e9 9e f4 ff ff       	jmp    801065cf <alltraps>

80107131 <vector142>:
.globl vector142
vector142:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $142
80107133:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107138:	e9 92 f4 ff ff       	jmp    801065cf <alltraps>

8010713d <vector143>:
.globl vector143
vector143:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $143
8010713f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107144:	e9 86 f4 ff ff       	jmp    801065cf <alltraps>

80107149 <vector144>:
.globl vector144
vector144:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $144
8010714b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107150:	e9 7a f4 ff ff       	jmp    801065cf <alltraps>

80107155 <vector145>:
.globl vector145
vector145:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $145
80107157:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010715c:	e9 6e f4 ff ff       	jmp    801065cf <alltraps>

80107161 <vector146>:
.globl vector146
vector146:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $146
80107163:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107168:	e9 62 f4 ff ff       	jmp    801065cf <alltraps>

8010716d <vector147>:
.globl vector147
vector147:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $147
8010716f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107174:	e9 56 f4 ff ff       	jmp    801065cf <alltraps>

80107179 <vector148>:
.globl vector148
vector148:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $148
8010717b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107180:	e9 4a f4 ff ff       	jmp    801065cf <alltraps>

80107185 <vector149>:
.globl vector149
vector149:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $149
80107187:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010718c:	e9 3e f4 ff ff       	jmp    801065cf <alltraps>

80107191 <vector150>:
.globl vector150
vector150:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $150
80107193:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107198:	e9 32 f4 ff ff       	jmp    801065cf <alltraps>

8010719d <vector151>:
.globl vector151
vector151:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $151
8010719f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801071a4:	e9 26 f4 ff ff       	jmp    801065cf <alltraps>

801071a9 <vector152>:
.globl vector152
vector152:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $152
801071ab:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801071b0:	e9 1a f4 ff ff       	jmp    801065cf <alltraps>

801071b5 <vector153>:
.globl vector153
vector153:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $153
801071b7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801071bc:	e9 0e f4 ff ff       	jmp    801065cf <alltraps>

801071c1 <vector154>:
.globl vector154
vector154:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $154
801071c3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801071c8:	e9 02 f4 ff ff       	jmp    801065cf <alltraps>

801071cd <vector155>:
.globl vector155
vector155:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $155
801071cf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801071d4:	e9 f6 f3 ff ff       	jmp    801065cf <alltraps>

801071d9 <vector156>:
.globl vector156
vector156:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $156
801071db:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801071e0:	e9 ea f3 ff ff       	jmp    801065cf <alltraps>

801071e5 <vector157>:
.globl vector157
vector157:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $157
801071e7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801071ec:	e9 de f3 ff ff       	jmp    801065cf <alltraps>

801071f1 <vector158>:
.globl vector158
vector158:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $158
801071f3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801071f8:	e9 d2 f3 ff ff       	jmp    801065cf <alltraps>

801071fd <vector159>:
.globl vector159
vector159:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $159
801071ff:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107204:	e9 c6 f3 ff ff       	jmp    801065cf <alltraps>

80107209 <vector160>:
.globl vector160
vector160:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $160
8010720b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107210:	e9 ba f3 ff ff       	jmp    801065cf <alltraps>

80107215 <vector161>:
.globl vector161
vector161:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $161
80107217:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010721c:	e9 ae f3 ff ff       	jmp    801065cf <alltraps>

80107221 <vector162>:
.globl vector162
vector162:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $162
80107223:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107228:	e9 a2 f3 ff ff       	jmp    801065cf <alltraps>

8010722d <vector163>:
.globl vector163
vector163:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $163
8010722f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107234:	e9 96 f3 ff ff       	jmp    801065cf <alltraps>

80107239 <vector164>:
.globl vector164
vector164:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $164
8010723b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107240:	e9 8a f3 ff ff       	jmp    801065cf <alltraps>

80107245 <vector165>:
.globl vector165
vector165:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $165
80107247:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010724c:	e9 7e f3 ff ff       	jmp    801065cf <alltraps>

80107251 <vector166>:
.globl vector166
vector166:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $166
80107253:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107258:	e9 72 f3 ff ff       	jmp    801065cf <alltraps>

8010725d <vector167>:
.globl vector167
vector167:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $167
8010725f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107264:	e9 66 f3 ff ff       	jmp    801065cf <alltraps>

80107269 <vector168>:
.globl vector168
vector168:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $168
8010726b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107270:	e9 5a f3 ff ff       	jmp    801065cf <alltraps>

80107275 <vector169>:
.globl vector169
vector169:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $169
80107277:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010727c:	e9 4e f3 ff ff       	jmp    801065cf <alltraps>

80107281 <vector170>:
.globl vector170
vector170:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $170
80107283:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107288:	e9 42 f3 ff ff       	jmp    801065cf <alltraps>

8010728d <vector171>:
.globl vector171
vector171:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $171
8010728f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107294:	e9 36 f3 ff ff       	jmp    801065cf <alltraps>

80107299 <vector172>:
.globl vector172
vector172:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $172
8010729b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801072a0:	e9 2a f3 ff ff       	jmp    801065cf <alltraps>

801072a5 <vector173>:
.globl vector173
vector173:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $173
801072a7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801072ac:	e9 1e f3 ff ff       	jmp    801065cf <alltraps>

801072b1 <vector174>:
.globl vector174
vector174:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $174
801072b3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801072b8:	e9 12 f3 ff ff       	jmp    801065cf <alltraps>

801072bd <vector175>:
.globl vector175
vector175:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $175
801072bf:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801072c4:	e9 06 f3 ff ff       	jmp    801065cf <alltraps>

801072c9 <vector176>:
.globl vector176
vector176:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $176
801072cb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801072d0:	e9 fa f2 ff ff       	jmp    801065cf <alltraps>

801072d5 <vector177>:
.globl vector177
vector177:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $177
801072d7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801072dc:	e9 ee f2 ff ff       	jmp    801065cf <alltraps>

801072e1 <vector178>:
.globl vector178
vector178:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $178
801072e3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801072e8:	e9 e2 f2 ff ff       	jmp    801065cf <alltraps>

801072ed <vector179>:
.globl vector179
vector179:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $179
801072ef:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801072f4:	e9 d6 f2 ff ff       	jmp    801065cf <alltraps>

801072f9 <vector180>:
.globl vector180
vector180:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $180
801072fb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107300:	e9 ca f2 ff ff       	jmp    801065cf <alltraps>

80107305 <vector181>:
.globl vector181
vector181:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $181
80107307:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010730c:	e9 be f2 ff ff       	jmp    801065cf <alltraps>

80107311 <vector182>:
.globl vector182
vector182:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $182
80107313:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107318:	e9 b2 f2 ff ff       	jmp    801065cf <alltraps>

8010731d <vector183>:
.globl vector183
vector183:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $183
8010731f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107324:	e9 a6 f2 ff ff       	jmp    801065cf <alltraps>

80107329 <vector184>:
.globl vector184
vector184:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $184
8010732b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107330:	e9 9a f2 ff ff       	jmp    801065cf <alltraps>

80107335 <vector185>:
.globl vector185
vector185:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $185
80107337:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010733c:	e9 8e f2 ff ff       	jmp    801065cf <alltraps>

80107341 <vector186>:
.globl vector186
vector186:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $186
80107343:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107348:	e9 82 f2 ff ff       	jmp    801065cf <alltraps>

8010734d <vector187>:
.globl vector187
vector187:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $187
8010734f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107354:	e9 76 f2 ff ff       	jmp    801065cf <alltraps>

80107359 <vector188>:
.globl vector188
vector188:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $188
8010735b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107360:	e9 6a f2 ff ff       	jmp    801065cf <alltraps>

80107365 <vector189>:
.globl vector189
vector189:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $189
80107367:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010736c:	e9 5e f2 ff ff       	jmp    801065cf <alltraps>

80107371 <vector190>:
.globl vector190
vector190:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $190
80107373:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107378:	e9 52 f2 ff ff       	jmp    801065cf <alltraps>

8010737d <vector191>:
.globl vector191
vector191:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $191
8010737f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107384:	e9 46 f2 ff ff       	jmp    801065cf <alltraps>

80107389 <vector192>:
.globl vector192
vector192:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $192
8010738b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107390:	e9 3a f2 ff ff       	jmp    801065cf <alltraps>

80107395 <vector193>:
.globl vector193
vector193:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $193
80107397:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010739c:	e9 2e f2 ff ff       	jmp    801065cf <alltraps>

801073a1 <vector194>:
.globl vector194
vector194:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $194
801073a3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801073a8:	e9 22 f2 ff ff       	jmp    801065cf <alltraps>

801073ad <vector195>:
.globl vector195
vector195:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $195
801073af:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801073b4:	e9 16 f2 ff ff       	jmp    801065cf <alltraps>

801073b9 <vector196>:
.globl vector196
vector196:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $196
801073bb:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801073c0:	e9 0a f2 ff ff       	jmp    801065cf <alltraps>

801073c5 <vector197>:
.globl vector197
vector197:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $197
801073c7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801073cc:	e9 fe f1 ff ff       	jmp    801065cf <alltraps>

801073d1 <vector198>:
.globl vector198
vector198:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $198
801073d3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801073d8:	e9 f2 f1 ff ff       	jmp    801065cf <alltraps>

801073dd <vector199>:
.globl vector199
vector199:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $199
801073df:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801073e4:	e9 e6 f1 ff ff       	jmp    801065cf <alltraps>

801073e9 <vector200>:
.globl vector200
vector200:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $200
801073eb:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801073f0:	e9 da f1 ff ff       	jmp    801065cf <alltraps>

801073f5 <vector201>:
.globl vector201
vector201:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $201
801073f7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801073fc:	e9 ce f1 ff ff       	jmp    801065cf <alltraps>

80107401 <vector202>:
.globl vector202
vector202:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $202
80107403:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107408:	e9 c2 f1 ff ff       	jmp    801065cf <alltraps>

8010740d <vector203>:
.globl vector203
vector203:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $203
8010740f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107414:	e9 b6 f1 ff ff       	jmp    801065cf <alltraps>

80107419 <vector204>:
.globl vector204
vector204:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $204
8010741b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107420:	e9 aa f1 ff ff       	jmp    801065cf <alltraps>

80107425 <vector205>:
.globl vector205
vector205:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $205
80107427:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010742c:	e9 9e f1 ff ff       	jmp    801065cf <alltraps>

80107431 <vector206>:
.globl vector206
vector206:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $206
80107433:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107438:	e9 92 f1 ff ff       	jmp    801065cf <alltraps>

8010743d <vector207>:
.globl vector207
vector207:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $207
8010743f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107444:	e9 86 f1 ff ff       	jmp    801065cf <alltraps>

80107449 <vector208>:
.globl vector208
vector208:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $208
8010744b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107450:	e9 7a f1 ff ff       	jmp    801065cf <alltraps>

80107455 <vector209>:
.globl vector209
vector209:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $209
80107457:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010745c:	e9 6e f1 ff ff       	jmp    801065cf <alltraps>

80107461 <vector210>:
.globl vector210
vector210:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $210
80107463:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107468:	e9 62 f1 ff ff       	jmp    801065cf <alltraps>

8010746d <vector211>:
.globl vector211
vector211:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $211
8010746f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107474:	e9 56 f1 ff ff       	jmp    801065cf <alltraps>

80107479 <vector212>:
.globl vector212
vector212:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $212
8010747b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107480:	e9 4a f1 ff ff       	jmp    801065cf <alltraps>

80107485 <vector213>:
.globl vector213
vector213:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $213
80107487:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010748c:	e9 3e f1 ff ff       	jmp    801065cf <alltraps>

80107491 <vector214>:
.globl vector214
vector214:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $214
80107493:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107498:	e9 32 f1 ff ff       	jmp    801065cf <alltraps>

8010749d <vector215>:
.globl vector215
vector215:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $215
8010749f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801074a4:	e9 26 f1 ff ff       	jmp    801065cf <alltraps>

801074a9 <vector216>:
.globl vector216
vector216:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $216
801074ab:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801074b0:	e9 1a f1 ff ff       	jmp    801065cf <alltraps>

801074b5 <vector217>:
.globl vector217
vector217:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $217
801074b7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801074bc:	e9 0e f1 ff ff       	jmp    801065cf <alltraps>

801074c1 <vector218>:
.globl vector218
vector218:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $218
801074c3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801074c8:	e9 02 f1 ff ff       	jmp    801065cf <alltraps>

801074cd <vector219>:
.globl vector219
vector219:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $219
801074cf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801074d4:	e9 f6 f0 ff ff       	jmp    801065cf <alltraps>

801074d9 <vector220>:
.globl vector220
vector220:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $220
801074db:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801074e0:	e9 ea f0 ff ff       	jmp    801065cf <alltraps>

801074e5 <vector221>:
.globl vector221
vector221:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $221
801074e7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801074ec:	e9 de f0 ff ff       	jmp    801065cf <alltraps>

801074f1 <vector222>:
.globl vector222
vector222:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $222
801074f3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801074f8:	e9 d2 f0 ff ff       	jmp    801065cf <alltraps>

801074fd <vector223>:
.globl vector223
vector223:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $223
801074ff:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107504:	e9 c6 f0 ff ff       	jmp    801065cf <alltraps>

80107509 <vector224>:
.globl vector224
vector224:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $224
8010750b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107510:	e9 ba f0 ff ff       	jmp    801065cf <alltraps>

80107515 <vector225>:
.globl vector225
vector225:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $225
80107517:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010751c:	e9 ae f0 ff ff       	jmp    801065cf <alltraps>

80107521 <vector226>:
.globl vector226
vector226:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $226
80107523:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107528:	e9 a2 f0 ff ff       	jmp    801065cf <alltraps>

8010752d <vector227>:
.globl vector227
vector227:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $227
8010752f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107534:	e9 96 f0 ff ff       	jmp    801065cf <alltraps>

80107539 <vector228>:
.globl vector228
vector228:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $228
8010753b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107540:	e9 8a f0 ff ff       	jmp    801065cf <alltraps>

80107545 <vector229>:
.globl vector229
vector229:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $229
80107547:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010754c:	e9 7e f0 ff ff       	jmp    801065cf <alltraps>

80107551 <vector230>:
.globl vector230
vector230:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $230
80107553:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107558:	e9 72 f0 ff ff       	jmp    801065cf <alltraps>

8010755d <vector231>:
.globl vector231
vector231:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $231
8010755f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107564:	e9 66 f0 ff ff       	jmp    801065cf <alltraps>

80107569 <vector232>:
.globl vector232
vector232:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $232
8010756b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107570:	e9 5a f0 ff ff       	jmp    801065cf <alltraps>

80107575 <vector233>:
.globl vector233
vector233:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $233
80107577:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010757c:	e9 4e f0 ff ff       	jmp    801065cf <alltraps>

80107581 <vector234>:
.globl vector234
vector234:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $234
80107583:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107588:	e9 42 f0 ff ff       	jmp    801065cf <alltraps>

8010758d <vector235>:
.globl vector235
vector235:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $235
8010758f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107594:	e9 36 f0 ff ff       	jmp    801065cf <alltraps>

80107599 <vector236>:
.globl vector236
vector236:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $236
8010759b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801075a0:	e9 2a f0 ff ff       	jmp    801065cf <alltraps>

801075a5 <vector237>:
.globl vector237
vector237:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $237
801075a7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801075ac:	e9 1e f0 ff ff       	jmp    801065cf <alltraps>

801075b1 <vector238>:
.globl vector238
vector238:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $238
801075b3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801075b8:	e9 12 f0 ff ff       	jmp    801065cf <alltraps>

801075bd <vector239>:
.globl vector239
vector239:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $239
801075bf:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801075c4:	e9 06 f0 ff ff       	jmp    801065cf <alltraps>

801075c9 <vector240>:
.globl vector240
vector240:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $240
801075cb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801075d0:	e9 fa ef ff ff       	jmp    801065cf <alltraps>

801075d5 <vector241>:
.globl vector241
vector241:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $241
801075d7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801075dc:	e9 ee ef ff ff       	jmp    801065cf <alltraps>

801075e1 <vector242>:
.globl vector242
vector242:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $242
801075e3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801075e8:	e9 e2 ef ff ff       	jmp    801065cf <alltraps>

801075ed <vector243>:
.globl vector243
vector243:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $243
801075ef:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801075f4:	e9 d6 ef ff ff       	jmp    801065cf <alltraps>

801075f9 <vector244>:
.globl vector244
vector244:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $244
801075fb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107600:	e9 ca ef ff ff       	jmp    801065cf <alltraps>

80107605 <vector245>:
.globl vector245
vector245:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $245
80107607:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010760c:	e9 be ef ff ff       	jmp    801065cf <alltraps>

80107611 <vector246>:
.globl vector246
vector246:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $246
80107613:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107618:	e9 b2 ef ff ff       	jmp    801065cf <alltraps>

8010761d <vector247>:
.globl vector247
vector247:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $247
8010761f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107624:	e9 a6 ef ff ff       	jmp    801065cf <alltraps>

80107629 <vector248>:
.globl vector248
vector248:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $248
8010762b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107630:	e9 9a ef ff ff       	jmp    801065cf <alltraps>

80107635 <vector249>:
.globl vector249
vector249:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $249
80107637:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010763c:	e9 8e ef ff ff       	jmp    801065cf <alltraps>

80107641 <vector250>:
.globl vector250
vector250:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $250
80107643:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107648:	e9 82 ef ff ff       	jmp    801065cf <alltraps>

8010764d <vector251>:
.globl vector251
vector251:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $251
8010764f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107654:	e9 76 ef ff ff       	jmp    801065cf <alltraps>

80107659 <vector252>:
.globl vector252
vector252:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $252
8010765b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107660:	e9 6a ef ff ff       	jmp    801065cf <alltraps>

80107665 <vector253>:
.globl vector253
vector253:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $253
80107667:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010766c:	e9 5e ef ff ff       	jmp    801065cf <alltraps>

80107671 <vector254>:
.globl vector254
vector254:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $254
80107673:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107678:	e9 52 ef ff ff       	jmp    801065cf <alltraps>

8010767d <vector255>:
.globl vector255
vector255:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $255
8010767f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107684:	e9 46 ef ff ff       	jmp    801065cf <alltraps>

80107689 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107689:	55                   	push   %ebp
8010768a:	89 e5                	mov    %esp,%ebp
8010768c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010768f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107692:	83 e8 01             	sub    $0x1,%eax
80107695:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107699:	8b 45 08             	mov    0x8(%ebp),%eax
8010769c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801076a0:	8b 45 08             	mov    0x8(%ebp),%eax
801076a3:	c1 e8 10             	shr    $0x10,%eax
801076a6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801076aa:	8d 45 fa             	lea    -0x6(%ebp),%eax
801076ad:	0f 01 10             	lgdtl  (%eax)
}
801076b0:	c9                   	leave  
801076b1:	c3                   	ret    

801076b2 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801076b2:	55                   	push   %ebp
801076b3:	89 e5                	mov    %esp,%ebp
801076b5:	83 ec 04             	sub    $0x4,%esp
801076b8:	8b 45 08             	mov    0x8(%ebp),%eax
801076bb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801076bf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801076c3:	0f 00 d8             	ltr    %ax
}
801076c6:	c9                   	leave  
801076c7:	c3                   	ret    

801076c8 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801076c8:	55                   	push   %ebp
801076c9:	89 e5                	mov    %esp,%ebp
801076cb:	83 ec 04             	sub    $0x4,%esp
801076ce:	8b 45 08             	mov    0x8(%ebp),%eax
801076d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801076d5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801076d9:	8e e8                	mov    %eax,%gs
}
801076db:	c9                   	leave  
801076dc:	c3                   	ret    

801076dd <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801076dd:	55                   	push   %ebp
801076de:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801076e0:	8b 45 08             	mov    0x8(%ebp),%eax
801076e3:	0f 22 d8             	mov    %eax,%cr3
}
801076e6:	5d                   	pop    %ebp
801076e7:	c3                   	ret    

801076e8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801076e8:	55                   	push   %ebp
801076e9:	89 e5                	mov    %esp,%ebp
801076eb:	8b 45 08             	mov    0x8(%ebp),%eax
801076ee:	05 00 00 00 80       	add    $0x80000000,%eax
801076f3:	5d                   	pop    %ebp
801076f4:	c3                   	ret    

801076f5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801076f5:	55                   	push   %ebp
801076f6:	89 e5                	mov    %esp,%ebp
801076f8:	8b 45 08             	mov    0x8(%ebp),%eax
801076fb:	05 00 00 00 80       	add    $0x80000000,%eax
80107700:	5d                   	pop    %ebp
80107701:	c3                   	ret    

80107702 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107702:	55                   	push   %ebp
80107703:	89 e5                	mov    %esp,%ebp
80107705:	53                   	push   %ebx
80107706:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107709:	e8 d8 b7 ff ff       	call   80102ee6 <cpunum>
8010770e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107714:	05 40 24 11 80       	add    $0x80112440,%eax
80107719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107728:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010772e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107731:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107738:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010773c:	83 e2 f0             	and    $0xfffffff0,%edx
8010773f:	83 ca 0a             	or     $0xa,%edx
80107742:	88 50 7d             	mov    %dl,0x7d(%eax)
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010774c:	83 ca 10             	or     $0x10,%edx
8010774f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107755:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107759:	83 e2 9f             	and    $0xffffff9f,%edx
8010775c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010775f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107762:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107766:	83 ca 80             	or     $0xffffff80,%edx
80107769:	88 50 7d             	mov    %dl,0x7d(%eax)
8010776c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107773:	83 ca 0f             	or     $0xf,%edx
80107776:	88 50 7e             	mov    %dl,0x7e(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107780:	83 e2 ef             	and    $0xffffffef,%edx
80107783:	88 50 7e             	mov    %dl,0x7e(%eax)
80107786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107789:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010778d:	83 e2 df             	and    $0xffffffdf,%edx
80107790:	88 50 7e             	mov    %dl,0x7e(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010779a:	83 ca 40             	or     $0x40,%edx
8010779d:	88 50 7e             	mov    %dl,0x7e(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077a7:	83 ca 80             	or     $0xffffff80,%edx
801077aa:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b7:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801077be:	ff ff 
801077c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c3:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801077ca:	00 00 
801077cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cf:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801077d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077e0:	83 e2 f0             	and    $0xfffffff0,%edx
801077e3:	83 ca 02             	or     $0x2,%edx
801077e6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077f6:	83 ca 10             	or     $0x10,%edx
801077f9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107802:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107809:	83 e2 9f             	and    $0xffffff9f,%edx
8010780c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010781c:	83 ca 80             	or     $0xffffff80,%edx
8010781f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107828:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010782f:	83 ca 0f             	or     $0xf,%edx
80107832:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107842:	83 e2 ef             	and    $0xffffffef,%edx
80107845:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107855:	83 e2 df             	and    $0xffffffdf,%edx
80107858:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107868:	83 ca 40             	or     $0x40,%edx
8010786b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010787b:	83 ca 80             	or     $0xffffff80,%edx
8010787e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010788e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107891:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107898:	ff ff 
8010789a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801078a4:	00 00 
801078a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a9:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078ba:	83 e2 f0             	and    $0xfffffff0,%edx
801078bd:	83 ca 0a             	or     $0xa,%edx
801078c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078d0:	83 ca 10             	or     $0x10,%edx
801078d3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078e3:	83 ca 60             	or     $0x60,%edx
801078e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ef:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078f6:	83 ca 80             	or     $0xffffff80,%edx
801078f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107902:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107909:	83 ca 0f             	or     $0xf,%edx
8010790c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107915:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010791c:	83 e2 ef             	and    $0xffffffef,%edx
8010791f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010792f:	83 e2 df             	and    $0xffffffdf,%edx
80107932:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107942:	83 ca 40             	or     $0x40,%edx
80107945:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010794b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107955:	83 ca 80             	or     $0xffffff80,%edx
80107958:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010795e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107961:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796b:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107972:	ff ff 
80107974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107977:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010797e:	00 00 
80107980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107983:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010798a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107994:	83 e2 f0             	and    $0xfffffff0,%edx
80107997:	83 ca 02             	or     $0x2,%edx
8010799a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a3:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079aa:	83 ca 10             	or     $0x10,%edx
801079ad:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079bd:	83 ca 60             	or     $0x60,%edx
801079c0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801079d0:	83 ca 80             	or     $0xffffff80,%edx
801079d3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801079d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079e3:	83 ca 0f             	or     $0xf,%edx
801079e6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ef:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079f6:	83 e2 ef             	and    $0xffffffef,%edx
801079f9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a09:	83 e2 df             	and    $0xffffffdf,%edx
80107a0c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a1c:	83 ca 40             	or     $0x40,%edx
80107a1f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a28:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a2f:	83 ca 80             	or     $0xffffff80,%edx
80107a32:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3b:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a45:	05 b4 00 00 00       	add    $0xb4,%eax
80107a4a:	89 c3                	mov    %eax,%ebx
80107a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4f:	05 b4 00 00 00       	add    $0xb4,%eax
80107a54:	c1 e8 10             	shr    $0x10,%eax
80107a57:	89 c2                	mov    %eax,%edx
80107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5c:	05 b4 00 00 00       	add    $0xb4,%eax
80107a61:	c1 e8 18             	shr    $0x18,%eax
80107a64:	89 c1                	mov    %eax,%ecx
80107a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a69:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107a70:	00 00 
80107a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a75:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107a8f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a92:	83 ca 02             	or     $0x2,%edx
80107a95:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107aa5:	83 ca 10             	or     $0x10,%edx
80107aa8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ab8:	83 e2 9f             	and    $0xffffff9f,%edx
80107abb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107acb:	83 ca 80             	or     $0xffffff80,%edx
80107ace:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ade:	83 e2 f0             	and    $0xfffffff0,%edx
80107ae1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107af1:	83 e2 ef             	and    $0xffffffef,%edx
80107af4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afd:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b04:	83 e2 df             	and    $0xffffffdf,%edx
80107b07:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b10:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b17:	83 ca 40             	or     $0x40,%edx
80107b1a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b2a:	83 ca 80             	or     $0xffffff80,%edx
80107b2d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b36:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3f:	83 c0 70             	add    $0x70,%eax
80107b42:	83 ec 08             	sub    $0x8,%esp
80107b45:	6a 38                	push   $0x38
80107b47:	50                   	push   %eax
80107b48:	e8 3c fb ff ff       	call   80107689 <lgdt>
80107b4d:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107b50:	83 ec 0c             	sub    $0xc,%esp
80107b53:	6a 18                	push   $0x18
80107b55:	e8 6e fb ff ff       	call   801076c8 <loadgs>
80107b5a:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b60:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107b66:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107b6d:	00 00 00 00 
}
80107b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b74:	c9                   	leave  
80107b75:	c3                   	ret    

80107b76 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b76:	55                   	push   %ebp
80107b77:	89 e5                	mov    %esp,%ebp
80107b79:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b7f:	c1 e8 16             	shr    $0x16,%eax
80107b82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b89:	8b 45 08             	mov    0x8(%ebp),%eax
80107b8c:	01 d0                	add    %edx,%eax
80107b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b94:	8b 00                	mov    (%eax),%eax
80107b96:	83 e0 01             	and    $0x1,%eax
80107b99:	85 c0                	test   %eax,%eax
80107b9b:	74 18                	je     80107bb5 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ba0:	8b 00                	mov    (%eax),%eax
80107ba2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ba7:	50                   	push   %eax
80107ba8:	e8 48 fb ff ff       	call   801076f5 <p2v>
80107bad:	83 c4 04             	add    $0x4,%esp
80107bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bb3:	eb 48                	jmp    80107bfd <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107bb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107bb9:	74 0e                	je     80107bc9 <walkpgdir+0x53>
80107bbb:	e8 c5 af ff ff       	call   80102b85 <kalloc>
80107bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107bc7:	75 07                	jne    80107bd0 <walkpgdir+0x5a>
      return 0;
80107bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80107bce:	eb 44                	jmp    80107c14 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107bd0:	83 ec 04             	sub    $0x4,%esp
80107bd3:	68 00 10 00 00       	push   $0x1000
80107bd8:	6a 00                	push   $0x0
80107bda:	ff 75 f4             	pushl  -0xc(%ebp)
80107bdd:	e8 68 d5 ff ff       	call   8010514a <memset>
80107be2:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107be5:	83 ec 0c             	sub    $0xc,%esp
80107be8:	ff 75 f4             	pushl  -0xc(%ebp)
80107beb:	e8 f8 fa ff ff       	call   801076e8 <v2p>
80107bf0:	83 c4 10             	add    $0x10,%esp
80107bf3:	83 c8 07             	or     $0x7,%eax
80107bf6:	89 c2                	mov    %eax,%edx
80107bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bfb:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c00:	c1 e8 0c             	shr    $0xc,%eax
80107c03:	25 ff 03 00 00       	and    $0x3ff,%eax
80107c08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c12:	01 d0                	add    %edx,%eax
}
80107c14:	c9                   	leave  
80107c15:	c3                   	ret    

80107c16 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107c16:	55                   	push   %ebp
80107c17:	89 e5                	mov    %esp,%ebp
80107c19:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107c27:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c2a:	8b 45 10             	mov    0x10(%ebp),%eax
80107c2d:	01 d0                	add    %edx,%eax
80107c2f:	83 e8 01             	sub    $0x1,%eax
80107c32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c3a:	83 ec 04             	sub    $0x4,%esp
80107c3d:	6a 01                	push   $0x1
80107c3f:	ff 75 f4             	pushl  -0xc(%ebp)
80107c42:	ff 75 08             	pushl  0x8(%ebp)
80107c45:	e8 2c ff ff ff       	call   80107b76 <walkpgdir>
80107c4a:	83 c4 10             	add    $0x10,%esp
80107c4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c54:	75 07                	jne    80107c5d <mappages+0x47>
      return -1;
80107c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c5b:	eb 49                	jmp    80107ca6 <mappages+0x90>
    if(*pte & PTE_P)
80107c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c60:	8b 00                	mov    (%eax),%eax
80107c62:	83 e0 01             	and    $0x1,%eax
80107c65:	85 c0                	test   %eax,%eax
80107c67:	74 0d                	je     80107c76 <mappages+0x60>
      panic("remap");
80107c69:	83 ec 0c             	sub    $0xc,%esp
80107c6c:	68 88 8a 10 80       	push   $0x80108a88
80107c71:	e8 e6 88 ff ff       	call   8010055c <panic>
    *pte = pa | perm | PTE_P;
80107c76:	8b 45 18             	mov    0x18(%ebp),%eax
80107c79:	0b 45 14             	or     0x14(%ebp),%eax
80107c7c:	83 c8 01             	or     $0x1,%eax
80107c7f:	89 c2                	mov    %eax,%edx
80107c81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c84:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c8c:	75 08                	jne    80107c96 <mappages+0x80>
      break;
80107c8e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c8f:	b8 00 00 00 00       	mov    $0x0,%eax
80107c94:	eb 10                	jmp    80107ca6 <mappages+0x90>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107c96:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c9d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ca4:	eb 94                	jmp    80107c3a <mappages+0x24>
  return 0;
}
80107ca6:	c9                   	leave  
80107ca7:	c3                   	ret    

80107ca8 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ca8:	55                   	push   %ebp
80107ca9:	89 e5                	mov    %esp,%ebp
80107cab:	53                   	push   %ebx
80107cac:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107caf:	e8 d1 ae ff ff       	call   80102b85 <kalloc>
80107cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cbb:	75 0a                	jne    80107cc7 <setupkvm+0x1f>
    return 0;
80107cbd:	b8 00 00 00 00       	mov    $0x0,%eax
80107cc2:	e9 8e 00 00 00       	jmp    80107d55 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107cc7:	83 ec 04             	sub    $0x4,%esp
80107cca:	68 00 10 00 00       	push   $0x1000
80107ccf:	6a 00                	push   $0x0
80107cd1:	ff 75 f0             	pushl  -0x10(%ebp)
80107cd4:	e8 71 d4 ff ff       	call   8010514a <memset>
80107cd9:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107cdc:	83 ec 0c             	sub    $0xc,%esp
80107cdf:	68 00 00 00 0e       	push   $0xe000000
80107ce4:	e8 0c fa ff ff       	call   801076f5 <p2v>
80107ce9:	83 c4 10             	add    $0x10,%esp
80107cec:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107cf1:	76 0d                	jbe    80107d00 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107cf3:	83 ec 0c             	sub    $0xc,%esp
80107cf6:	68 8e 8a 10 80       	push   $0x80108a8e
80107cfb:	e8 5c 88 ff ff       	call   8010055c <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d00:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107d07:	eb 40                	jmp    80107d49 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0c:	8b 48 0c             	mov    0xc(%eax),%ecx
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	8b 50 04             	mov    0x4(%eax),%edx
80107d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d18:	8b 58 08             	mov    0x8(%eax),%ebx
80107d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1e:	8b 40 04             	mov    0x4(%eax),%eax
80107d21:	29 c3                	sub    %eax,%ebx
80107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d26:	8b 00                	mov    (%eax),%eax
80107d28:	83 ec 0c             	sub    $0xc,%esp
80107d2b:	51                   	push   %ecx
80107d2c:	52                   	push   %edx
80107d2d:	53                   	push   %ebx
80107d2e:	50                   	push   %eax
80107d2f:	ff 75 f0             	pushl  -0x10(%ebp)
80107d32:	e8 df fe ff ff       	call   80107c16 <mappages>
80107d37:	83 c4 20             	add    $0x20,%esp
80107d3a:	85 c0                	test   %eax,%eax
80107d3c:	79 07                	jns    80107d45 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107d3e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d43:	eb 10                	jmp    80107d55 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d45:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d49:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107d50:	72 b7                	jb     80107d09 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d58:	c9                   	leave  
80107d59:	c3                   	ret    

80107d5a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d5a:	55                   	push   %ebp
80107d5b:	89 e5                	mov    %esp,%ebp
80107d5d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d60:	e8 43 ff ff ff       	call   80107ca8 <setupkvm>
80107d65:	a3 18 54 11 80       	mov    %eax,0x80115418
  switchkvm();
80107d6a:	e8 02 00 00 00       	call   80107d71 <switchkvm>
}
80107d6f:	c9                   	leave  
80107d70:	c3                   	ret    

80107d71 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d71:	55                   	push   %ebp
80107d72:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107d74:	a1 18 54 11 80       	mov    0x80115418,%eax
80107d79:	50                   	push   %eax
80107d7a:	e8 69 f9 ff ff       	call   801076e8 <v2p>
80107d7f:	83 c4 04             	add    $0x4,%esp
80107d82:	50                   	push   %eax
80107d83:	e8 55 f9 ff ff       	call   801076dd <lcr3>
80107d88:	83 c4 04             	add    $0x4,%esp
}
80107d8b:	c9                   	leave  
80107d8c:	c3                   	ret    

80107d8d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d8d:	55                   	push   %ebp
80107d8e:	89 e5                	mov    %esp,%ebp
80107d90:	56                   	push   %esi
80107d91:	53                   	push   %ebx
  pushcli();
80107d92:	e8 b1 d2 ff ff       	call   80105048 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107d97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d9d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107da4:	83 c2 08             	add    $0x8,%edx
80107da7:	89 d6                	mov    %edx,%esi
80107da9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107db0:	83 c2 08             	add    $0x8,%edx
80107db3:	c1 ea 10             	shr    $0x10,%edx
80107db6:	89 d3                	mov    %edx,%ebx
80107db8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107dbf:	83 c2 08             	add    $0x8,%edx
80107dc2:	c1 ea 18             	shr    $0x18,%edx
80107dc5:	89 d1                	mov    %edx,%ecx
80107dc7:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107dce:	67 00 
80107dd0:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107dd7:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107ddd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107de4:	83 e2 f0             	and    $0xfffffff0,%edx
80107de7:	83 ca 09             	or     $0x9,%edx
80107dea:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107df0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107df7:	83 ca 10             	or     $0x10,%edx
80107dfa:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e00:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e07:	83 e2 9f             	and    $0xffffff9f,%edx
80107e0a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e10:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e17:	83 ca 80             	or     $0xffffff80,%edx
80107e1a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e20:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e27:	83 e2 f0             	and    $0xfffffff0,%edx
80107e2a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e30:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e37:	83 e2 ef             	and    $0xffffffef,%edx
80107e3a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e40:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e47:	83 e2 df             	and    $0xffffffdf,%edx
80107e4a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e50:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e57:	83 ca 40             	or     $0x40,%edx
80107e5a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e60:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107e67:	83 e2 7f             	and    $0x7f,%edx
80107e6a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107e70:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107e76:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e7c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e83:	83 e2 ef             	and    $0xffffffef,%edx
80107e86:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107e8c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e92:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107e98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e9e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107ea5:	8b 52 08             	mov    0x8(%edx),%edx
80107ea8:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107eae:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107eb1:	83 ec 0c             	sub    $0xc,%esp
80107eb4:	6a 30                	push   $0x30
80107eb6:	e8 f7 f7 ff ff       	call   801076b2 <ltr>
80107ebb:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec1:	8b 40 04             	mov    0x4(%eax),%eax
80107ec4:	85 c0                	test   %eax,%eax
80107ec6:	75 0d                	jne    80107ed5 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107ec8:	83 ec 0c             	sub    $0xc,%esp
80107ecb:	68 9f 8a 10 80       	push   $0x80108a9f
80107ed0:	e8 87 86 ff ff       	call   8010055c <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed8:	8b 40 04             	mov    0x4(%eax),%eax
80107edb:	83 ec 0c             	sub    $0xc,%esp
80107ede:	50                   	push   %eax
80107edf:	e8 04 f8 ff ff       	call   801076e8 <v2p>
80107ee4:	83 c4 10             	add    $0x10,%esp
80107ee7:	83 ec 0c             	sub    $0xc,%esp
80107eea:	50                   	push   %eax
80107eeb:	e8 ed f7 ff ff       	call   801076dd <lcr3>
80107ef0:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ef3:	e8 94 d1 ff ff       	call   8010508c <popcli>
}
80107ef8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107efb:	5b                   	pop    %ebx
80107efc:	5e                   	pop    %esi
80107efd:	5d                   	pop    %ebp
80107efe:	c3                   	ret    

80107eff <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107eff:	55                   	push   %ebp
80107f00:	89 e5                	mov    %esp,%ebp
80107f02:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107f05:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107f0c:	76 0d                	jbe    80107f1b <inituvm+0x1c>
    panic("inituvm: more than a page");
80107f0e:	83 ec 0c             	sub    $0xc,%esp
80107f11:	68 b3 8a 10 80       	push   $0x80108ab3
80107f16:	e8 41 86 ff ff       	call   8010055c <panic>
  mem = kalloc();
80107f1b:	e8 65 ac ff ff       	call   80102b85 <kalloc>
80107f20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f23:	83 ec 04             	sub    $0x4,%esp
80107f26:	68 00 10 00 00       	push   $0x1000
80107f2b:	6a 00                	push   $0x0
80107f2d:	ff 75 f4             	pushl  -0xc(%ebp)
80107f30:	e8 15 d2 ff ff       	call   8010514a <memset>
80107f35:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107f38:	83 ec 0c             	sub    $0xc,%esp
80107f3b:	ff 75 f4             	pushl  -0xc(%ebp)
80107f3e:	e8 a5 f7 ff ff       	call   801076e8 <v2p>
80107f43:	83 c4 10             	add    $0x10,%esp
80107f46:	83 ec 0c             	sub    $0xc,%esp
80107f49:	6a 06                	push   $0x6
80107f4b:	50                   	push   %eax
80107f4c:	68 00 10 00 00       	push   $0x1000
80107f51:	6a 00                	push   $0x0
80107f53:	ff 75 08             	pushl  0x8(%ebp)
80107f56:	e8 bb fc ff ff       	call   80107c16 <mappages>
80107f5b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f5e:	83 ec 04             	sub    $0x4,%esp
80107f61:	ff 75 10             	pushl  0x10(%ebp)
80107f64:	ff 75 0c             	pushl  0xc(%ebp)
80107f67:	ff 75 f4             	pushl  -0xc(%ebp)
80107f6a:	e8 9a d2 ff ff       	call   80105209 <memmove>
80107f6f:	83 c4 10             	add    $0x10,%esp
}
80107f72:	c9                   	leave  
80107f73:	c3                   	ret    

80107f74 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f74:	55                   	push   %ebp
80107f75:	89 e5                	mov    %esp,%ebp
80107f77:	53                   	push   %ebx
80107f78:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f7e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f83:	85 c0                	test   %eax,%eax
80107f85:	74 0d                	je     80107f94 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80107f87:	83 ec 0c             	sub    $0xc,%esp
80107f8a:	68 d0 8a 10 80       	push   $0x80108ad0
80107f8f:	e8 c8 85 ff ff       	call   8010055c <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f9b:	e9 95 00 00 00       	jmp    80108035 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa6:	01 d0                	add    %edx,%eax
80107fa8:	83 ec 04             	sub    $0x4,%esp
80107fab:	6a 00                	push   $0x0
80107fad:	50                   	push   %eax
80107fae:	ff 75 08             	pushl  0x8(%ebp)
80107fb1:	e8 c0 fb ff ff       	call   80107b76 <walkpgdir>
80107fb6:	83 c4 10             	add    $0x10,%esp
80107fb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fbc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fc0:	75 0d                	jne    80107fcf <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80107fc2:	83 ec 0c             	sub    $0xc,%esp
80107fc5:	68 f3 8a 10 80       	push   $0x80108af3
80107fca:	e8 8d 85 ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
80107fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fd2:	8b 00                	mov    (%eax),%eax
80107fd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107fdc:	8b 45 18             	mov    0x18(%ebp),%eax
80107fdf:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fe2:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fe7:	77 0b                	ja     80107ff4 <loaduvm+0x80>
      n = sz - i;
80107fe9:	8b 45 18             	mov    0x18(%ebp),%eax
80107fec:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fef:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ff2:	eb 07                	jmp    80107ffb <loaduvm+0x87>
    else
      n = PGSIZE;
80107ff4:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107ffb:	8b 55 14             	mov    0x14(%ebp),%edx
80107ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108001:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	ff 75 e8             	pushl  -0x18(%ebp)
8010800a:	e8 e6 f6 ff ff       	call   801076f5 <p2v>
8010800f:	83 c4 10             	add    $0x10,%esp
80108012:	ff 75 f0             	pushl  -0x10(%ebp)
80108015:	53                   	push   %ebx
80108016:	50                   	push   %eax
80108017:	ff 75 10             	pushl  0x10(%ebp)
8010801a:	e8 1f 9e ff ff       	call   80101e3e <readi>
8010801f:	83 c4 10             	add    $0x10,%esp
80108022:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108025:	74 07                	je     8010802e <loaduvm+0xba>
      return -1;
80108027:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010802c:	eb 18                	jmp    80108046 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010802e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108038:	3b 45 18             	cmp    0x18(%ebp),%eax
8010803b:	0f 82 5f ff ff ff    	jb     80107fa0 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108041:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108049:	c9                   	leave  
8010804a:	c3                   	ret    

8010804b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010804b:	55                   	push   %ebp
8010804c:	89 e5                	mov    %esp,%ebp
8010804e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108051:	8b 45 10             	mov    0x10(%ebp),%eax
80108054:	85 c0                	test   %eax,%eax
80108056:	79 0a                	jns    80108062 <allocuvm+0x17>
    return 0;
80108058:	b8 00 00 00 00       	mov    $0x0,%eax
8010805d:	e9 b0 00 00 00       	jmp    80108112 <allocuvm+0xc7>
  if(newsz < oldsz)
80108062:	8b 45 10             	mov    0x10(%ebp),%eax
80108065:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108068:	73 08                	jae    80108072 <allocuvm+0x27>
    return oldsz;
8010806a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806d:	e9 a0 00 00 00       	jmp    80108112 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108072:	8b 45 0c             	mov    0xc(%ebp),%eax
80108075:	05 ff 0f 00 00       	add    $0xfff,%eax
8010807a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010807f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108082:	eb 7f                	jmp    80108103 <allocuvm+0xb8>
    mem = kalloc();
80108084:	e8 fc aa ff ff       	call   80102b85 <kalloc>
80108089:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010808c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108090:	75 2b                	jne    801080bd <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108092:	83 ec 0c             	sub    $0xc,%esp
80108095:	68 11 8b 10 80       	push   $0x80108b11
8010809a:	e8 20 83 ff ff       	call   801003bf <cprintf>
8010809f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080a2:	83 ec 04             	sub    $0x4,%esp
801080a5:	ff 75 0c             	pushl  0xc(%ebp)
801080a8:	ff 75 10             	pushl  0x10(%ebp)
801080ab:	ff 75 08             	pushl  0x8(%ebp)
801080ae:	e8 61 00 00 00       	call   80108114 <deallocuvm>
801080b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801080b6:	b8 00 00 00 00       	mov    $0x0,%eax
801080bb:	eb 55                	jmp    80108112 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801080bd:	83 ec 04             	sub    $0x4,%esp
801080c0:	68 00 10 00 00       	push   $0x1000
801080c5:	6a 00                	push   $0x0
801080c7:	ff 75 f0             	pushl  -0x10(%ebp)
801080ca:	e8 7b d0 ff ff       	call   8010514a <memset>
801080cf:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801080d2:	83 ec 0c             	sub    $0xc,%esp
801080d5:	ff 75 f0             	pushl  -0x10(%ebp)
801080d8:	e8 0b f6 ff ff       	call   801076e8 <v2p>
801080dd:	83 c4 10             	add    $0x10,%esp
801080e0:	89 c2                	mov    %eax,%edx
801080e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e5:	83 ec 0c             	sub    $0xc,%esp
801080e8:	6a 06                	push   $0x6
801080ea:	52                   	push   %edx
801080eb:	68 00 10 00 00       	push   $0x1000
801080f0:	50                   	push   %eax
801080f1:	ff 75 08             	pushl  0x8(%ebp)
801080f4:	e8 1d fb ff ff       	call   80107c16 <mappages>
801080f9:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801080fc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108106:	3b 45 10             	cmp    0x10(%ebp),%eax
80108109:	0f 82 75 ff ff ff    	jb     80108084 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010810f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108112:	c9                   	leave  
80108113:	c3                   	ret    

80108114 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108114:	55                   	push   %ebp
80108115:	89 e5                	mov    %esp,%ebp
80108117:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010811a:	8b 45 10             	mov    0x10(%ebp),%eax
8010811d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108120:	72 08                	jb     8010812a <deallocuvm+0x16>
    return oldsz;
80108122:	8b 45 0c             	mov    0xc(%ebp),%eax
80108125:	e9 a5 00 00 00       	jmp    801081cf <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
8010812a:	8b 45 10             	mov    0x10(%ebp),%eax
8010812d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108132:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108137:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010813a:	e9 81 00 00 00       	jmp    801081c0 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	83 ec 04             	sub    $0x4,%esp
80108145:	6a 00                	push   $0x0
80108147:	50                   	push   %eax
80108148:	ff 75 08             	pushl  0x8(%ebp)
8010814b:	e8 26 fa ff ff       	call   80107b76 <walkpgdir>
80108150:	83 c4 10             	add    $0x10,%esp
80108153:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108156:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010815a:	75 09                	jne    80108165 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010815c:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108163:	eb 54                	jmp    801081b9 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108165:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108168:	8b 00                	mov    (%eax),%eax
8010816a:	83 e0 01             	and    $0x1,%eax
8010816d:	85 c0                	test   %eax,%eax
8010816f:	74 48                	je     801081b9 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108174:	8b 00                	mov    (%eax),%eax
80108176:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010817e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108182:	75 0d                	jne    80108191 <deallocuvm+0x7d>
        panic("kfree");
80108184:	83 ec 0c             	sub    $0xc,%esp
80108187:	68 29 8b 10 80       	push   $0x80108b29
8010818c:	e8 cb 83 ff ff       	call   8010055c <panic>
      char *v = p2v(pa);
80108191:	83 ec 0c             	sub    $0xc,%esp
80108194:	ff 75 ec             	pushl  -0x14(%ebp)
80108197:	e8 59 f5 ff ff       	call   801076f5 <p2v>
8010819c:	83 c4 10             	add    $0x10,%esp
8010819f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	ff 75 e8             	pushl  -0x18(%ebp)
801081a8:	e8 3c a9 ff ff       	call   80102ae9 <kfree>
801081ad:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801081b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801081b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081c6:	0f 82 73 ff ff ff    	jb     8010813f <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801081cc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081cf:	c9                   	leave  
801081d0:	c3                   	ret    

801081d1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081d1:	55                   	push   %ebp
801081d2:	89 e5                	mov    %esp,%ebp
801081d4:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801081d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081db:	75 0d                	jne    801081ea <freevm+0x19>
    panic("freevm: no pgdir");
801081dd:	83 ec 0c             	sub    $0xc,%esp
801081e0:	68 2f 8b 10 80       	push   $0x80108b2f
801081e5:	e8 72 83 ff ff       	call   8010055c <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801081ea:	83 ec 04             	sub    $0x4,%esp
801081ed:	6a 00                	push   $0x0
801081ef:	68 00 00 00 80       	push   $0x80000000
801081f4:	ff 75 08             	pushl  0x8(%ebp)
801081f7:	e8 18 ff ff ff       	call   80108114 <deallocuvm>
801081fc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801081ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108206:	eb 4f                	jmp    80108257 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108212:	8b 45 08             	mov    0x8(%ebp),%eax
80108215:	01 d0                	add    %edx,%eax
80108217:	8b 00                	mov    (%eax),%eax
80108219:	83 e0 01             	and    $0x1,%eax
8010821c:	85 c0                	test   %eax,%eax
8010821e:	74 33                	je     80108253 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108223:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010822a:	8b 45 08             	mov    0x8(%ebp),%eax
8010822d:	01 d0                	add    %edx,%eax
8010822f:	8b 00                	mov    (%eax),%eax
80108231:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108236:	83 ec 0c             	sub    $0xc,%esp
80108239:	50                   	push   %eax
8010823a:	e8 b6 f4 ff ff       	call   801076f5 <p2v>
8010823f:	83 c4 10             	add    $0x10,%esp
80108242:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108245:	83 ec 0c             	sub    $0xc,%esp
80108248:	ff 75 f0             	pushl  -0x10(%ebp)
8010824b:	e8 99 a8 ff ff       	call   80102ae9 <kfree>
80108250:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108253:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108257:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010825e:	76 a8                	jbe    80108208 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108260:	83 ec 0c             	sub    $0xc,%esp
80108263:	ff 75 08             	pushl  0x8(%ebp)
80108266:	e8 7e a8 ff ff       	call   80102ae9 <kfree>
8010826b:	83 c4 10             	add    $0x10,%esp
}
8010826e:	c9                   	leave  
8010826f:	c3                   	ret    

80108270 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108270:	55                   	push   %ebp
80108271:	89 e5                	mov    %esp,%ebp
80108273:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108276:	83 ec 04             	sub    $0x4,%esp
80108279:	6a 00                	push   $0x0
8010827b:	ff 75 0c             	pushl  0xc(%ebp)
8010827e:	ff 75 08             	pushl  0x8(%ebp)
80108281:	e8 f0 f8 ff ff       	call   80107b76 <walkpgdir>
80108286:	83 c4 10             	add    $0x10,%esp
80108289:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010828c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108290:	75 0d                	jne    8010829f <clearpteu+0x2f>
    panic("clearpteu");
80108292:	83 ec 0c             	sub    $0xc,%esp
80108295:	68 40 8b 10 80       	push   $0x80108b40
8010829a:	e8 bd 82 ff ff       	call   8010055c <panic>
  *pte &= ~PTE_U;
8010829f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a2:	8b 00                	mov    (%eax),%eax
801082a4:	83 e0 fb             	and    $0xfffffffb,%eax
801082a7:	89 c2                	mov    %eax,%edx
801082a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ac:	89 10                	mov    %edx,(%eax)
}
801082ae:	c9                   	leave  
801082af:	c3                   	ret    

801082b0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801082b0:	55                   	push   %ebp
801082b1:	89 e5                	mov    %esp,%ebp
801082b3:	53                   	push   %ebx
801082b4:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801082b7:	e8 ec f9 ff ff       	call   80107ca8 <setupkvm>
801082bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082c3:	75 0a                	jne    801082cf <copyuvm+0x1f>
    return 0;
801082c5:	b8 00 00 00 00       	mov    $0x0,%eax
801082ca:	e9 f8 00 00 00       	jmp    801083c7 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801082cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082d6:	e9 c8 00 00 00       	jmp    801083a3 <copyuvm+0xf3>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082de:	83 ec 04             	sub    $0x4,%esp
801082e1:	6a 00                	push   $0x0
801082e3:	50                   	push   %eax
801082e4:	ff 75 08             	pushl  0x8(%ebp)
801082e7:	e8 8a f8 ff ff       	call   80107b76 <walkpgdir>
801082ec:	83 c4 10             	add    $0x10,%esp
801082ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082f6:	75 0d                	jne    80108305 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801082f8:	83 ec 0c             	sub    $0xc,%esp
801082fb:	68 4a 8b 10 80       	push   $0x80108b4a
80108300:	e8 57 82 ff ff       	call   8010055c <panic>
    if(!(*pte & PTE_P))
80108305:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108308:	8b 00                	mov    (%eax),%eax
8010830a:	83 e0 01             	and    $0x1,%eax
8010830d:	85 c0                	test   %eax,%eax
8010830f:	75 0d                	jne    8010831e <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108311:	83 ec 0c             	sub    $0xc,%esp
80108314:	68 64 8b 10 80       	push   $0x80108b64
80108319:	e8 3e 82 ff ff       	call   8010055c <panic>
    pa = PTE_ADDR(*pte);
8010831e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108321:	8b 00                	mov    (%eax),%eax
80108323:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108328:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010832b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010832e:	8b 00                	mov    (%eax),%eax
80108330:	25 ff 0f 00 00       	and    $0xfff,%eax
80108335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108338:	e8 48 a8 ff ff       	call   80102b85 <kalloc>
8010833d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108340:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108344:	75 02                	jne    80108348 <copyuvm+0x98>
      goto bad;
80108346:	eb 6c                	jmp    801083b4 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108348:	83 ec 0c             	sub    $0xc,%esp
8010834b:	ff 75 e8             	pushl  -0x18(%ebp)
8010834e:	e8 a2 f3 ff ff       	call   801076f5 <p2v>
80108353:	83 c4 10             	add    $0x10,%esp
80108356:	83 ec 04             	sub    $0x4,%esp
80108359:	68 00 10 00 00       	push   $0x1000
8010835e:	50                   	push   %eax
8010835f:	ff 75 e0             	pushl  -0x20(%ebp)
80108362:	e8 a2 ce ff ff       	call   80105209 <memmove>
80108367:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010836a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010836d:	83 ec 0c             	sub    $0xc,%esp
80108370:	ff 75 e0             	pushl  -0x20(%ebp)
80108373:	e8 70 f3 ff ff       	call   801076e8 <v2p>
80108378:	83 c4 10             	add    $0x10,%esp
8010837b:	89 c2                	mov    %eax,%edx
8010837d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108380:	83 ec 0c             	sub    $0xc,%esp
80108383:	53                   	push   %ebx
80108384:	52                   	push   %edx
80108385:	68 00 10 00 00       	push   $0x1000
8010838a:	50                   	push   %eax
8010838b:	ff 75 f0             	pushl  -0x10(%ebp)
8010838e:	e8 83 f8 ff ff       	call   80107c16 <mappages>
80108393:	83 c4 20             	add    $0x20,%esp
80108396:	85 c0                	test   %eax,%eax
80108398:	79 02                	jns    8010839c <copyuvm+0xec>
      goto bad;
8010839a:	eb 18                	jmp    801083b4 <copyuvm+0x104>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010839c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083a9:	0f 82 2c ff ff ff    	jb     801082db <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801083af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b2:	eb 13                	jmp    801083c7 <copyuvm+0x117>

bad:
  freevm(d);
801083b4:	83 ec 0c             	sub    $0xc,%esp
801083b7:	ff 75 f0             	pushl  -0x10(%ebp)
801083ba:	e8 12 fe ff ff       	call   801081d1 <freevm>
801083bf:	83 c4 10             	add    $0x10,%esp
  return 0;
801083c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083ca:	c9                   	leave  
801083cb:	c3                   	ret    

801083cc <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083cc:	55                   	push   %ebp
801083cd:	89 e5                	mov    %esp,%ebp
801083cf:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083d2:	83 ec 04             	sub    $0x4,%esp
801083d5:	6a 00                	push   $0x0
801083d7:	ff 75 0c             	pushl  0xc(%ebp)
801083da:	ff 75 08             	pushl  0x8(%ebp)
801083dd:	e8 94 f7 ff ff       	call   80107b76 <walkpgdir>
801083e2:	83 c4 10             	add    $0x10,%esp
801083e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083eb:	8b 00                	mov    (%eax),%eax
801083ed:	83 e0 01             	and    $0x1,%eax
801083f0:	85 c0                	test   %eax,%eax
801083f2:	75 07                	jne    801083fb <uva2ka+0x2f>
    return 0;
801083f4:	b8 00 00 00 00       	mov    $0x0,%eax
801083f9:	eb 29                	jmp    80108424 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801083fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fe:	8b 00                	mov    (%eax),%eax
80108400:	83 e0 04             	and    $0x4,%eax
80108403:	85 c0                	test   %eax,%eax
80108405:	75 07                	jne    8010840e <uva2ka+0x42>
    return 0;
80108407:	b8 00 00 00 00       	mov    $0x0,%eax
8010840c:	eb 16                	jmp    80108424 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010840e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108411:	8b 00                	mov    (%eax),%eax
80108413:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108418:	83 ec 0c             	sub    $0xc,%esp
8010841b:	50                   	push   %eax
8010841c:	e8 d4 f2 ff ff       	call   801076f5 <p2v>
80108421:	83 c4 10             	add    $0x10,%esp
}
80108424:	c9                   	leave  
80108425:	c3                   	ret    

80108426 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108426:	55                   	push   %ebp
80108427:	89 e5                	mov    %esp,%ebp
80108429:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010842c:	8b 45 10             	mov    0x10(%ebp),%eax
8010842f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108432:	eb 7f                	jmp    801084b3 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108434:	8b 45 0c             	mov    0xc(%ebp),%eax
80108437:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010843c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010843f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108442:	83 ec 08             	sub    $0x8,%esp
80108445:	50                   	push   %eax
80108446:	ff 75 08             	pushl  0x8(%ebp)
80108449:	e8 7e ff ff ff       	call   801083cc <uva2ka>
8010844e:	83 c4 10             	add    $0x10,%esp
80108451:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108454:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108458:	75 07                	jne    80108461 <copyout+0x3b>
      return -1;
8010845a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010845f:	eb 61                	jmp    801084c2 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108461:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108464:	2b 45 0c             	sub    0xc(%ebp),%eax
80108467:	05 00 10 00 00       	add    $0x1000,%eax
8010846c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010846f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108472:	3b 45 14             	cmp    0x14(%ebp),%eax
80108475:	76 06                	jbe    8010847d <copyout+0x57>
      n = len;
80108477:	8b 45 14             	mov    0x14(%ebp),%eax
8010847a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010847d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108480:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108483:	89 c2                	mov    %eax,%edx
80108485:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108488:	01 d0                	add    %edx,%eax
8010848a:	83 ec 04             	sub    $0x4,%esp
8010848d:	ff 75 f0             	pushl  -0x10(%ebp)
80108490:	ff 75 f4             	pushl  -0xc(%ebp)
80108493:	50                   	push   %eax
80108494:	e8 70 cd ff ff       	call   80105209 <memmove>
80108499:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010849c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801084a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a5:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ab:	05 00 10 00 00       	add    $0x1000,%eax
801084b0:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801084b3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084b7:	0f 85 77 ff ff ff    	jne    80108434 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801084bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084c2:	c9                   	leave  
801084c3:	c3                   	ret    
