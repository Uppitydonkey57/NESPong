#include "nesmacros.h"

#pragma bss-name(push, "BSS")
const u8 foreground_palette[16] = {0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3};
const u8 background_palette[16] = {5,6,7,8,5,6,7,8,5,6,7,8,5,6,7,8};

const u8 paddle[32] = {0,2,128,0,8,3,0,0,16,3,0,0,24,2,0,0};
#pragma bss-name(pop)

#pragma data-name (push, "ZEROPAGE")
u8 game_state = 0b00000000;
u8 x_pos = 30;
u8 y_pos = 30;
u8 sprite = 10;
u8 meta_x = 0;
#pragma data-name (pop)

void init(void) {
	asm("rts");
}

void draw(void) {
	draw_sprite(x_pos, y_pos, 0, 1);
	draw_sprite(70, 50, 0xA9, 3);
	draw_meta_sprite(meta_x,20,paddle,32);
}

void update(void) {
	meta_x++;
	if (ctrl1 & DOWN_BTN) {
		y_pos++;
	}
	if (ctrl1 & UP_BTN) {
		y_pos--;
	}
	if (ctrl1 & RIGHT_BTN) {
		x_pos++;
	}
	if (ctrl1 & LEFT_BTN) {
		x_pos--;
	}

	if (ctrl1 & A_BTN) {
		sprite--;
	}
	asm("rts");
}
