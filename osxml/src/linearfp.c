/* segment:offset pair */
typedef uint32_t FARPTR;

/* Make a FARPTR from a segment and an offset */
#define MK_FP(seg, off)    ((FARPTR) (((uint32_t) (seg) &lt;&lt; 16) | (uint16_t) (off)))

/* Extract the segment part of a FARPTR */
#define FP_SEG(fp)        (((FARPTR) fp) &gt;&gt; 16)

/* Extract the offset part of a FARPTR */
#define FP_OFF(fp)        (((FARPTR) fp) &amp; 0xffff)

/* Convert a segment:offset pair to a linear address */
#define FP_TO_LINEAR(seg, off) ((void*) ((((uint16_t) (seg)) &lt;&lt; 4) + ((uint16_t) (off))))

FARPTR i386LinearToFp(void *ptr)
{
    unsigned seg, off;
    off = (addr_t) ptr &amp; 0xf;
    seg = ((addr_t) ptr - ((addr_t) ptr &amp; 0xf)) / 16;
    return MK_FP(seg, off);
}
