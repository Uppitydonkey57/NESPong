.importzp spr_count, tmp1, tmp2, ftmp1, sp, ftmp2, ftmp3, fptr1, ftmp4
.export _draw_meta_sprite, _clear_oam, _draw_sprite
.import decsp3, popa, incsp5, pushax, incsp4, incsp3

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
