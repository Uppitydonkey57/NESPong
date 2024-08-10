.importzp spr_count, tmp1, tmp2, ftmp1, sp, ftmp2, ftmp3, fptr1, ftmp4, f16tmp1
.export _draw_meta_sprite, _clear_oam, _draw_sprite, _clear_nametable, _ppu_on, _ppu_off, _set_nametable_address, _set_scroll, _set_ppu_addr, _write_ppu_data, _draw_nametable_string, _set_palettes
.import decsp3, popa, incsp5, pushax, incsp4, incsp3, incsp2, incsp1, popax

; draw_meta_sprite(u8 x_pos, u8 y_pos, u8 attribute, u8 sprite_num)
_draw_sprite:
	sta ftmp1
	ldx spr_count
	ldy #1
	lda (sp), y
	sta $0200, x
	inx
	lda ftmp1
	sta $0200, x
	inx
	ldy #0
	lda (sp), y
	sta $0200, x
	inx
	ldy #2
	lda (sp), y
	sta $0200, x
	inx
	stx spr_count
	jsr incsp3
	rts

 _draw_meta_sprite: ; params: x_pos, y_pos, hi_ptr, lo_ptr, size
 	; fmtp1 acts as pointer incrementer for looking at non moved data
	sta ftmp2
 	ldx spr_count
	ldy #0
	lda (sp), y
	sta $33
	sta <fptr1
	ldy #3
	lda (sp), y
	sta ftmp1
	ldy #2
	lda (sp), y
	sta ftmp4
	ldy #1
	lda (sp), y
	sta <fptr1+1
	sta $34
	;lda (sp), y ; use < and > to offset to lo and hi bytes
	ldy #0
	jmp @sprite_loop
	@reset_loop:
	ldx ftmp3
	@sprite_loop: ; maybe add support for size being able to not be a multiple of 4
	; start drawing sprites
	; y
	lda (fptr1), y
	adc ftmp4
	sta $0200, x
	inx
	iny
	; spr_num
	lda (fptr1), y
	sta $0200, x
	inx
	iny
	; attrib
	lda (fptr1), y
	sta $0200, x
	inx
	iny
	; x
	lda (fptr1), y
	adc ftmp1
	sta $0200, x
	inx
	iny
	; check
	stx ftmp3
	txa
	sec
	sbc spr_count
	cmp ftmp2
	bne @reset_loop
	adc spr_count
	sta spr_count
	dec spr_count
	jsr incsp4
 	rts

_clear_oam:
	lda #$FF
@clear_loop:
	sta $0200, x
	dex
	cpx #0
	bne @clear_loop
	lda #$00
	sta spr_count
	rts

_clear_nametable:
	ldx #0
	ldy #0
	lda #0
	;sta $2002
	lda #$20
	sta $2006
	lda #00
	sta $2006
@clear_nametable_loop:
	sta $2007
	inx
	cpx #32
	bne @clear_nametable_loop
	ldx #0
	iny
	cpy #30
	bne @clear_nametable_loop
	rts

_ppu_off:
	lda #%00000110
	sta $2001
	rts

_ppu_on:
	lda #%00011110
	sta $2001
	rts

_set_nametable_address: ; make real function ! 
	sta ftmp1
	lda #$20
	sta	<f16tmp1+1
	ldy #0
	lda (sp), y
	tax
	lda #0
	cpx #0
	beq @nametable_place_x
@nametable_place_y:
	adc #$1F
	bcc @dont_increment_hibyte_y
	inc <f16tmp1+1
@dont_increment_hibyte_y:
	dex
	cpx #0
	bne @nametable_place_y
@nametable_place_x:
	sta <f16tmp1
	ldy #1
	lda (sp), y
	tay
	lda <f16tmp1 ; these 3 are wrong relook later
	sty ftmp2
	clc
	adc ftmp2
	bcc @dont_increment_hibyte_x
	inc <f16tmp1+1
@dont_increment_hibyte_x:
	ldx <f16tmp1+1
	stx $2006
	sta $2006
	lda ftmp1
	sta $2007
	jsr incsp2
	rts

_draw_nametable_string:
	sta ftmp1
	lda #$20
	sta	<f16tmp1+1
	ldy #2
	lda (sp), y
	tax
	lda #0
	cpx #0
	beq @str_nametable_place_x
@str_nametable_place_y:
	adc #$1F
	bcc @str_dont_increment_hibyte_y
	inc <f16tmp1+1
@str_dont_increment_hibyte_y:
	dex
	cpx #0
	bne @str_nametable_place_y
@str_nametable_place_x:
	sta <f16tmp1
	ldy #3
	lda (sp), y
	tay
	lda <f16tmp1 ; these 3 are wrong relook later
	sty ftmp2
	clc
	adc ftmp2
	bcc @str_dont_increment_hibyte_x
	inc <f16tmp1+1
@str_dont_increment_hibyte_x:
	ldx <f16tmp1+1
	stx $2006
	sta $2006
	ldy #0
	lda (sp), y
	sta <fptr1
	ldy #1
	lda (sp), y
	sta <fptr1+1
	ldy #0
	ldx ftmp1
@str_write_char:
	lda (fptr1), y
	sta $2007
	iny
	dex
	cpx #0
	bne @str_write_char
	jsr incsp4
	rts

_set_palettes:
	sta <fptr1
	stx <fptr1+1
	lda #$3F
	sta $2006
	lda #$00
	sta $2006
	ldy #0
@load_color_bg:
	lda (fptr1), y
	sta $2007
	iny
	cpy #$F
	bne @load_color_bg

	tya
	tax
	ldy #0
	lda (sp), y
	sta <fptr1
	ldy #1
	lda (sp), y
	sta <fptr1+1
	txa
	tay
@load_color_fg:
	lda #$33
	lda (fptr1), y
	sta $2007
	iny
	cpy #$20
	bne @load_color_fg
	jsr popax
	rts

_set_scroll: 
	bit $2002
	sta ftmp1
	ldy #$0
	lda (sp), y
	sta $2005
	lda ftmp1
	sta $2005
	jsr incsp1
	rts

_write_ppu_data:
	sta $2007
	rts

_set_ppu_addr:
	stx $2006
	sta $2006
	jsr incsp1
	rts

_square_sfx:
	ldy #3
	lda (sp), y
	;and 0b00001111
	sta ftmp1
	eor	ftmp1
	jsr incsp3
	rts
