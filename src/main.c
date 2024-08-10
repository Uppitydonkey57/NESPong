#include "main.h"
#include "nesmacros.h"

#define PADDLE_SPEED 2
#define BALL_SPEED 2
#define PLAY_BUTTON_TEXT_OFFSET 8
#define PALETTE_COUNT 4

enum BallDirections {
	UP_LEFT,
	DOWN_LEFT,
	UP_RIGHT,
	DOWN_RIGHT
};

#pragma bss-name(push, "BSS")


const struct Palette standard = {
	{0x36,0x03,0x10,0x30,0x22,1,2,3,0,1,2,3,0,1,2,3},
	{0x0D,0x2D,0x10,0x30,0x22,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22}
};
const struct Palette purple = {
	{0x36,0x03,0x3B,0x22,0,1,2,3,0,1,2,3,0,1,2,3},
	{0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22}
};
const struct Palette red = {
	{0x04,0x26,0x05,0x36,0,1,2,3,0,1,2,3,0,1,2,3},
	{0x04,0x26,0x05,0x36,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22}
};
const struct Palette blue = {
	{0x21,0x05,0x06,0x16,0,1,2,3,0,1,2,3,0,1,2,3},
	{0x21,0x05,0x06,0x16,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22,0x36,0x03,0x3B,0x22}
};
const char palette_names[4][8] = {"standard", "pastel", "purple", "blue"};
const u8 palette_name_lengths[4] = {8, 6, 6, 4};

const u8 paddle[32] = {0,2,128,0,8,3,0,0,16,3,0,0,24,2,0,0};
#pragma bss-name(pop)

#pragma data-name (push, "ZEROPAGE")
u8 paddle1y;
u8 paddle2y;
u8 ballx;
u8 bally;
u8 ball_direction = 0;
u8 score1;
u8 score2;
u8 scroll_y;
u8 for_iter;
u8 game_over;
u8 in_game;
u8 selected_button;
u8 up_button_held_title;
u8 down_button_held_title;
u8 left_button_held_title;
u8 right_button_held_title;
u8 current_palette;
#pragma data-name (pop)

void init(void) {
	paddle1y = 104;
	paddle2y = 104;
	ballx = 124;
	bally = 104;
	ball_direction = DOWN_RIGHT;
	score1 = 0x30;
	score2 = 0x30;
	set_palettes(standard.foreground, standard.background);
	draw_title_screen();
	asm("rts");
}

void draw(void) {
	// remove later
}

void draw_title_screen() {
	ppu_off();
	clear_nametable();
	draw_nametable_string(14,8,"pong",4);
	draw_nametable_string(12, 20, "start", 5);
	draw_nametable_string(12, 22, "palette: ", 9);
	draw_nametable_string(12, 24, "song: ", 6);
	draw_nametable_string(21, 22, palette_names[current_palette], palette_name_lengths[current_palette]);

	//draw_nametable_string(20, 10, hello_title, 12);
	set_scroll(0,0);
	ppu_on();
}

void draw_background_line() {
	ppu_off();
	//set_nametable_address(20,20,3);
	clear_nametable();
	for (for_iter = 0; for_iter < 30; for_iter++) {
		set_nametable_address(16, for_iter, 1);
	}
	set_scroll(0, 0);
	ppu_on();
}

void refresh_palettes() {
	switch(current_palette) {
	case 0:
		set_palettes(standard.foreground, standard.background);
		break;
	case 1:
		set_palettes(purple.foreground, purple.background);
		break;
	case 2:
		set_palettes(red.foreground, red.background);
		break;
	case 3:
		set_palettes(blue.foreground, blue.background);
		break;
	}
	ppu_off();
	draw_nametable_string(21, 22, palette_names[current_palette], sizeof(palette_names[current_palette]));
	
	set_scroll(0,0);
	ppu_on();
}

void update(void) {

	if (!in_game) {
		if (ctrl1 & A_BTN && selected_button == 0) {
			in_game = 1;
			draw_background_line();
		}
		if (ctrl1 & DOWN_BTN && !up_button_held_title) {
			up_button_held_title = 1;
			++selected_button;
			if (selected_button > 2) {
				selected_button = 0;
			}
		} else if (!(ctrl1 & DOWN_BTN)) {
			up_button_held_title = 0;
		}
		if (ctrl1 & UP_BTN && !down_button_held_title) {
			down_button_held_title = 1;
			--selected_button;
			if (selected_button == 255) {
				selected_button = 2;
			}
		} else if (!(ctrl1 & UP_BTN)) {
			down_button_held_title = 0;
		}

		if (ctrl1 & LEFT_BTN && !left_button_held_title) {
			if (selected_button == 1) {
				--current_palette;
				if (current_palette == 255) current_palette = PALETTE_COUNT-1;
				refresh_palettes();
			}
			left_button_held_title = 1;
		} else if (!(ctrl1 & LEFT_BTN)) {
			left_button_held_title = 0;
		}
		if (ctrl1 & RIGHT_BTN && !right_button_held_title) {
			if (selected_button == 1) {
				++current_palette;
				if (current_palette == PALETTE_COUNT) current_palette = 0;
				refresh_palettes();
			}
			right_button_held_title = 1;
		} else if (!(ctrl1 & RIGHT_BTN)) {
			right_button_held_title = 0;
		}
		clear_oam();
		draw_sprite(80, 160 + (selected_button * 16), 0, 1);
		return;
	}
	/**((u8*)0x4000) = 80;
	*((u8*)0x4001) = 80;
	*((u8*)0x4002) = 80;
	*((u8*)0x4003) = 80;*/
	scroll_y -= 1;
	if (score1 > 0x39 && game_over == 0) {
		game_over = 1;
		ppu_off();
		draw_nametable_string(10,16, "player 1 won", 12);
		set_scroll(0, 0);
		ppu_on();
	}
	if (score2 > 0x39 && game_over == 0) {
		game_over = 1;
		ppu_off();
		draw_nametable_string(10,16, "player 2 won", 12);
		set_scroll(0, 0);
		ppu_on();
	}
	clear_oam();
	draw_sprite(ballx, bally, 0, 1);
	draw_meta_sprite(20,paddle1y,paddle,32);
	draw_meta_sprite(228,paddle2y,paddle,32);
	if (score1 < 0x39) { 
		draw_sprite(64,20,0,score1);
	} else {
		draw_sprite(64,20,0,0x39);
	}
	if (score2 < 0x39) { 
		draw_sprite(192,20,0,score2);
	} else {
		draw_sprite(192,20,0,0x39);
	}
	if (game_over) {
		if (ctrl1 & B_BTN) {
			score1 = 0x30;
			score2 = 0x30;
			paddle1y = 104;
			paddle2y = 104;
			game_over = 0;
			in_game = 0;
			draw_title_screen();
		}
		return;
	}
	if (ctrl1 & DOWN_BTN && paddle1y < 216) {
		paddle1y += PADDLE_SPEED;
	}
	if (ctrl1 & UP_BTN && paddle1y > 0) {
		paddle1y -= PADDLE_SPEED;
	}
	if (ctrl2 & DOWN_BTN && paddle2y < 216) {
		paddle2y += PADDLE_SPEED;
	}
	if (ctrl2 & UP_BTN && paddle2y > 0) {
		paddle2y -= PADDLE_SPEED;
	}

	if (ballx >= 250) { // change 250 to exact screen boundry
		score1++;
		ballx = 124;
		bally = 104;
	}
	else if (ballx <= 4) { // change 4 to exact screen boundry
		score2++;
		ballx = 124;
		bally = 104;
	}

	if (bally >= 240) {
		switch (ball_direction) {
			case DOWN_LEFT:
				ball_direction = UP_LEFT;
				break;
			case DOWN_RIGHT:
				ball_direction = UP_RIGHT;
				break;
		}
	}

	if (bally <= 6) {
		switch (ball_direction) {
			case UP_LEFT:
				ball_direction = DOWN_LEFT;
				break;
			case UP_RIGHT:
				ball_direction = DOWN_RIGHT;
				break;
		}
	}

	switch (ball_direction) {
		case (u8)UP_LEFT:
			ballx -= BALL_SPEED;
			bally -= BALL_SPEED;
			break;
		case (u8)DOWN_LEFT:
			ballx -= BALL_SPEED;
			bally += BALL_SPEED;
			break;
		case (u8)UP_RIGHT:
			ballx += BALL_SPEED;
			bally -= BALL_SPEED;
			break;
		case (u8)DOWN_RIGHT:
			ballx += BALL_SPEED;
			bally += BALL_SPEED;
			break;
	}

	if (ballx <= 26 && bally > paddle1y-4 && bally < paddle1y+36) {
		if (bally < paddle1y + 16) {
			ball_direction = UP_RIGHT;
		} else {
			ball_direction = DOWN_RIGHT;
		}
	}
	if (ballx >= 220 && bally > paddle2y-4 && bally < paddle2y+36) {
		if (bally < paddle2y + 16) {
			ball_direction = UP_LEFT;
		} else {
			ball_direction = DOWN_LEFT;
		}
	}

	asm("rts");
}
