.nolist
#include "../includes/ti84pce.inc"
.list
 .assume ADL=1
 .org userMem-2
 .db tExtTok, tAsm84CeCmp

;init
 di
 call _HomeUp
 call _ClrScrnFull
 call _RunIndicOff
    ;save flags
     push af
     push iy

main:
 ;ld a,(mpRtcRange)
 in a,(pRtcRange)
 ld hl,0
 ld l,a
 push af
 call _DispHL
 call _NewLine
 pop af
 cp a,40
 jp z,exit
 jp main

exit:
 pop iy
 pop af
 call _GetKey
 call _ClrScrnFull
 call _HomeUp
 res donePrgm, (iy+doneFlags)
 ret
