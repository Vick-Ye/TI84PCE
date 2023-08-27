.nolist
#include "../includes/ti84pce.inc"
.list
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp

init:
 di
 call _HomeUp
 call _ClrScrnFull
 call _RunIndicOff
    ;save flags
     push af
     push iy

main:
 ld hl,mpKeyMode
 ld (hl),2

 ld a,0
wait:
 cp a,(hl)
 jp nz,wait

 ld hl,mpKeyData+$e
 ld a,(hl)
 bit 0,a
 call nz,down
 bit 1,a
 call nz,left
 bit 2,a
 call nz,right
 bit 3,a
 call nz,up

 ld hl,mpKeyData+$c
 ld a,(hl)
 bit 0,a
 jp nz,exit
 bit 6,a
 jp nz,exit

 jp main

exit:
 pop iy
 pop af
 ei
 call restoreKeyBoard
 call _ClrScrnFull
 call _HomeUp
 res donePrgm, (iy+doneFlags)
 ret

up:
 ld hl,U
 call _PutS
 call _NewLine
 ret
U:
 .db "up",0
down:
 ld hl,Do
 call _PutS
 call _NewLine
 ret
Do:
 .db "down",0
left:
 ld hl,Lef
 call _PutS
 call _NewLine
 ret
Lef:
 .db "left",0
right:
 ld hl,Ri
 call _PutS
 call _NewLine
 ret
Ri:
 .db "right",0

;source: https://wikiti.brandonw.net/index.php?title=84PCE:Ports:A000
;ez80 mode
;resets keyboard
RestoreKeyboard:
 ld hl,mpKeyRange
 xor a		; Mode 0
 ld (hl),a
 inc l		; 0F50001h
 ld (hl),15	; Wait 15*256 APB cycles before scanning each row
 inc l		; 0F50002h
 xor a
 ld (hl),a
 inc l		; 0F50003h
 ld (hl),15	; Wait 15 APB cycles before each scan
 inc l		; 0F50004h
 ld a,8		; Number of rows to scan
 ld (hl),a
 inc l		; 0F50005h
 ld (hl),a	; Number of columns to scan
 ret