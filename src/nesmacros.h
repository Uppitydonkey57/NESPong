#ifndef NESMACROS
#define NESMACROS
typedef unsigned char	u8;
typedef unsigned int	u16;

struct OAMSprite {
	u8 y;
	u8 index;
	u8 attributes;
	u8 x;
};

extern u8 ctrl2;
#pragma zpsym("ctrl2");
extern u8 ctrl1;
#pragma zpsym("ctrl1");

#define PPUCTRL		*(u8*)2000
#define PPUMASK		*(u8*)2001
#define PPUSTATUS	*(u8*)2002
#define OAMADDR		*(u8*)2003
#define OAMDATA		*(u8*)2004
#define PPUSCROLL	*(u8*)2005
#define PPUADDR		*(u8*)2006
#define PPUDATA		*(u8*)2007
#define OAMDMA		*(u8*)4014

#define SPRDATA		((struct OAMSprite*)0x0200)

#define A_BTN		0b10000000
#define B_BTN		0b01000000
#define SELECT_BTN	0b00100000
#define START_BTN	0b00010000
#define UP_BTN		0b00001000
#define DOWN_BTN	0b00000100
#define LEFT_BTN	0b00000010
#define RIGHT_BTN	0b00000001

void draw_meta_sprite(u8 x_pos, u8 y_pos, const u8 *sprite_ptr, u8 sprite_size);
void draw_sprite(u8 x_pos, u8 y_pos, u8 attribute, u8 sprite_num);
void clear_oam(void);

extern char iter;
#endif
