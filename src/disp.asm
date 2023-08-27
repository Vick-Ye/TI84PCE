#include "/includes/ti84pce.inc"
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp
 call _homeup
 call _ClrScrnFull
 jp start
start:
	ld de,vRam
	ld hl,imageData ;need to scale by 4x4

	;repeat 120x to load all rows
	ld b,120
loop1:
	push bc

	push hl ;pixel data
	push de ;first pixel of the row

	;repeat 160x to load entire row
	ld b,160
loop2:
	push bc

	push hl ;pixel data
	push de ;first of four pixel

	;load first pixel
	ld bc,2*1
	ldir

	;load pixel 1x more
	pop hl ;go to first of the four pixels
	ld bc,2*1
	ldir

	;increment to next pixel in data
	pop hl ;go back to pixel data
	ld bc,2*1
	add hl,bc

	pop bc
	djnz loop2

	;load row 1x more
	pop hl ;go to first pixel of the row
	ld bc,640*1
	ldir

	;increment to next row in data
	pop hl ;go back to pixel data
	ld bc,2*160
	add hl,bc

	pop bc
	djnz loop1


	call _GetKey
	call _ClrScrnFull
	res donePrgm,(iy+doneFlags)
	ret

test:
	.db "testing",0
imageData:
	#import "../assets/images/Image.txt"
