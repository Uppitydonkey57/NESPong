;
; File generated by cc65 v 2.18 - Debian 2.19-1
;
	.fopt		compiler,"cc65 v 2.18 - Debian 2.19-1"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.export		_sprite_counter

.segment	"DATA"

_sprite_counter:
	.byte	$00

