/*****************************************************************************
checks for ext2 format disk, prints info
compiles with Turbo C, 16-bit Watcom C, or DJGPP
*****************************************************************************/
#include <stdlib.h> /* atoi() */
#include <stdio.h> /* printf(), sscanf() */
#include <bios.h> /* _DISK_nnn, struct diskinfo_t, _bios_disk() */

/* these assume little-endian CPU like x86 */
#define	read_le16(X)	*(u16 *)(X)
#define	read_le32(X)	*(u32 *)(X)

/* these assume sizeof(short)==2 and sizeof(long)==4 */
typedef unsigned short	u16;
typedef unsigned long	u32;
/*****************************************************************************
*****************************************************************************/
#if defined(__TURBOC__)
#if __TURBOC__<0x0300

#define _DISK_RESET     0
#define _DISK_READ      2

struct diskinfo_t
{
	unsigned drive, head, track, sector, nsectors;
	void far *buffer;
};

int _bios_disk(int cmd, struct diskinfo_t *i)
{
	return biosdisk(cmd, i->drive, i->head, i->track, i->sector,
		i->nsectors, (void *)i->buffer);
}

#endif
#endif
/*****************************************************************************
*****************************************************************************/
static int read_sector(unsigned drive, unsigned cyl, unsigned head,
		unsigned sect, unsigned char *buf)
{
	struct diskinfo_t cmd;
	unsigned tries, err;

	cmd.drive = drive;
	cmd.head = head;
	cmd.track = cyl;
	cmd.sector = sect;
	cmd.nsectors = 1;
	cmd.buffer = buf;
	for(tries = 3; tries != 0; tries--)
	{
		err = _bios_disk(_DISK_READ, &cmd);
		err >>= 8;
		if(err == 0)
			return 0;
		_bios_disk(_DISK_RESET, &cmd);
	}
	printf("error 0x%02X reading drive\n", err);
	return -1;
}
/*****************************************************************************
*****************************************************************************/
static int check_if_ext2_superblock(unsigned char *buf)
{
	int bad = 0;

	if(read_le16(buf + 56) != 0xEF53)
		bad = 1;
	return bad;
}
/*****************************************************************************
*****************************************************************************/
int main(int arg_c, char *arg_v[])
{
	unsigned bs, super_blk, gd_blk, bb_blk, ib_blk, it_blk;
	unsigned cyl = 0, head = 0, sect = 1;
	unsigned drive, part = 0;
	unsigned char buf[512];

	if(arg_c < 2)
		drive = 0;
	else
	{
		sscanf(arg_v[1], "%X", &drive);
		if(drive != 0 && drive != 1 && drive != 0x80 && drive != 0x81)
		{
			printf("Bad INT 13h drive number 0x%X "
				"(must be 0, 1, 0x80, or 0x81)\n", drive);
			return 1;
		}
		if(arg_c < 3)
			part = 0;
		else
		{
			part = atoi(arg_v[2]);
			if(part > 3)
			{
				printf("Bad primary partition number %u "
					"(must be < 4)\n", part);
				return 1;
			}
		}
	}
	if(drive >= 0x80)
		printf("partition %u on ", part);
	printf("drive 0x%02X:\n\n", drive);
/* if hard disk, find partition via MBR */
	if(drive >= 0x80)
	{
		unsigned char *ptab_rec;

		if(read_sector(drive, 0, 0, 1, buf) != 0)
			return 1;
/* point to partition table entry */
		ptab_rec = buf + 446 + 16 * part;
/* make sure it's ext2 */
		if(ptab_rec[4] != 0x83)
			goto NOT;
/* get starting CHS of partition */
		cyl = ptab_rec[3];
		head = ptab_rec[1];
		sect = ptab_rec[2] & 0x3F;
		if(ptab_rec[2] & 0x40)
			cyl |= 0x100;
		if(ptab_rec[2] & 0x80)
			cyl |= 0x200;
	}
/* the first superblock is ALWAYS 1024 bytes into the disk or partition,
regardless of block size */
	if(read_sector(drive, cyl, head, sect + 2, buf) != 0)
		return 1;
	if(check_if_ext2_superblock(buf))
NOT:	{
		printf("not an ext2 volume\n");
		return 1;
	}
	bs = read_le32(buf + 24);
	bs = 1024 << bs;
	printf("Block size: %u bytes (%u sectors)\n", bs, bs / 512);
	bs /= 512;
	super_blk = read_le32(buf + 20);
	if(super_blk > 0)
		printf("block #0 (sector #0): unused\n");
	printf("block #%u (sector #%u): 1st superblock\n", super_blk, super_blk * bs);
/* find and read group descriptor */
	gd_blk = 1 + super_blk;
	printf("block #%u (sector #%u): 1st set of group descriptors\n",
		gd_blk, gd_blk * bs);
	if(read_sector(drive, cyl, head, sect + gd_blk * bs, buf) != 0)
		return 1;
	bb_blk = read_le32(buf + 0);
	ib_blk = read_le32(buf + 4);
	it_blk = read_le32(buf + 8);
	printf("block #%u (sector #%u): 1st block bitmap\n",
		bb_blk, bb_blk * bs);
	printf("block #%u (sector #%u): 1st inode bitmap\n",
		ib_blk, ib_blk * bs);
	printf("block #%u (sector #%u): 1st inode table\n",
		it_blk, it_blk * bs);
	return 0;
}
