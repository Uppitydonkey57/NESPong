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

struct Palette {
	u8 foreground[16];
	u8 background[16];
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
void clear_nametable();
void set_nametable_address(u8 x, u8 y, u8 sprite);
void ppu_off();
void ppu_on();
void set_scroll(u8 x, u8 y);
void set_ppu_addr(u16 address);
void write_ppu_data(u8 sprite);
void draw_nametable_string(u8 x, u8 y, const char *string, u8 length);
void set_palettes(const u8 *foreground, const u8 *background);
void square_sfx(u8 pitch, u8 volume, u8 duty_cycle, u8 sfx_length);

extern char iter;
#endif
