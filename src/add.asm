#include "includes/ti84pce.inc"
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp
 call _homeup
 call _ClrScrnFull

 jp start
start:
	ld a,0
	adc a,a ;reset carry flag
	ld a,(in)
	ld b,a
	ld a,(in+1)
	adc a,b
	ld (out),a
	jr NC,$+10
	ld hl,message
	call _PutS
	ld hl,out
	call _PutS
	call _GetKey
	call _ClrScrnFull
	res donePrgm,(iy+doneFlags)
	ret
in:
	.db $00,$48
out:
	.db $00,"elloWorld",0
message:
	.db "carried",0
error:
	.db "ERROR",0