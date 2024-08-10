.export __STARTUP__:absolute=1
.exportzp _ctrl1, _ctrl2, spr_count, ftmp1, ftmp2, ftmp3, fptr1, ftmp4, f16tmp1
.import _init,_update,_draw
.importzp sp

; Linker generated symbols
.import initlib,push0,popa,popax,_main,zerobss,copydata

; Linker generated symbols
.import __RAM_START__   ,__RAM_SIZE__
.import __ROM0_START__  ,__ROM0_SIZE__
.import __STARTUP_LOAD__,__STARTUP_RUN__,__STARTUP_SIZE__
.import	__CODE_LOAD__   ,__CODE_RUN__   ,__CODE_SIZE__
.import	__RODATA_LOAD__ ,__RODATA_RUN__ ,__RODATA_SIZE__
.import NES_MAPPER,NES_PRG_BANKS,NES_CHR_BANKS,NES_MIRRORING
PPUCTRL		=$2000
PPUMASK		=$2001
PPUSTATUS	=$2002
OAMADDR		=$2003
OAMDATA		=$2004
PPUSCROLL	=$2005
PPUADDR		=$2006
PPUDATA		=$2007
OAMDMA		=$4014
CTRL1PORT	=$4016
CTRL2PORT	=$4017

.segment "HEADER"
.byte "NES"
.byte $1A
.byte $02 ; 2 * 16KB PRG ROM
.byte $01 ; 1 * 8KB CHR ROM
.byte %00000001 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes
.segment "ZEROPAGE"
ftmp1: .res 1
ftmp2: .res 1
ftmp3: .res 1
ftmp4: .res 1
f16tmp1: .res 2
fptr1: .res 2 ; lo then hi
fptr2: .res 2 ; lo then hi
_ctrl1: .res 1
_ctrl2: .res 1
spr_count: .res 1
.segment "STARTUP"
Reset: 
	sei ; Disable interrupts
	cld ; Diable decimal Mode

	; Disable sound IRQ
	ldx #$40
	stx $4017

	; Initialize the stack register
	ldx #$FF
	txs
	inx ; FF + 1 = 0

	; Zero out the PPU registers
	stx PPUCTRL
	stx PPUMASK

	stx $4010

: ; wait for vblank
	bit PPUSTATUS 
	bpl :-

	txa
clear_mem:
	sta $0000, X ; 0000 => 01FF
	sta $0100, X
	sta $0300, X
	sta $0400, X
	sta $0500, X
	sta $0600, X
	sta $0700, X
	lda #$FF
	sta $0200, X
	lda #$00
	inx
	bne clear_mem

	lda #<(__RAM_START__+__RAM_SIZE__)
	sta	sp
	lda	#>(__RAM_START__+__RAM_SIZE__)
	sta	sp+1

: ; wait for vblank
	bit PPUSTATUS 
	bpl :-
	lda #$02
	sta OAMDMA
	nop


	lda #$3F ; REPLACE WITH C LATER
	sta PPUADDR
	lda #$00
	sta PPUADDR

	ldx #$00

load_palettes:
	lda palette_data, X
	sta PPUDATA
	inx
	cpx #$20
	bne load_palettes

	ldx #$00
; Enable Interrupts
	cli
	lda #%10010000 ; enable nmi change background to use second chr set of tiles
	sta PPUCTRL
	; enabling sprites and background for left-most 8-pixels
	lda #%00011110
	sta PPUMASK
	jsr _init
init_apu:
	lda #$0F
	sta $4015

Loop:
	jmp Loop

NMI:
	;temp
	;temp end
	lda #$02
	sta OAMDMA
	jsr _draw
	jsr read_controller
	jsr _update
	rti

read_controller:
	lda #1
	sta _ctrl1
	sta CTRL1PORT
	lda #$0
	sta CTRL1PORT
read_loop:
	lda CTRL1PORT
	lsr a
	rol _ctrl1
	bcc read_loop
read_controller2:
	lda #1
	sta _ctrl2
	sta CTRL2PORT
	lda #$0
	sta CTRL2PORT
read_loop2:
	lda CTRL2PORT
	lsr a
	rol _ctrl2
	bcc read_loop2
	rts

.segment "RODATA"
	palette_data:
	  .byte $0D,$2D,$10,$30,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$22  ;background palette data
	  .byte $0D,$2D,$10,$30,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

.segment "VECTORS"
	.word NMI
	.word Reset
	; 
.segment "CHARS"
	.incbin "Alpha.chr"
; basic setup from this video: https://www.youtube.com/watch?v=LeCGYp0JWok (ASM SETUP)
