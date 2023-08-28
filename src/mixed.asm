.nolist
#include "/includes/ti84pce.inc"
.list
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp

init:
 call _ClrScrnFull
 call _HomeUp
 call _RunIndicOff
 call _RandInit
 ld a,mb
 ;save flags
     push af
     push iy

main:
 di
 stmix
 ld a,$d1
 ld mb,a

 call _Random
 ld hl,OP1
 call dispFloat

 rsmix

exit:
 ;restore flags
     pop iy
     pop af
 ld mb,a
 ei
 call _GetKey
 call _ClrScrnFull
 call _HomeUp
 res donePrgm,(iy+doneFlags)
 ret

float:
 .db $00, $80, $27, $18, $28, $18, $28, $45, $94

.assume ADL=1
;ez80 mode
;gets random number
;b <= a <= c
;corrupts ...
getRandom:
 push.lil bc
 ld a,c
 ld hl,OP1
 call intToFloat
 pop.lil bc
 push.lil bc
 ld a,b
 ld hl,OP2
 call intToFloat
 call _FPSub
 ld a,1
 ld hl,OP2
 call intToFloat
 call _FPAdd
 ld hl,OP1
 ld de,OP2
 call ldFloat
 call _Random
 call _FPMult
 pop.lil bc
 ld a,b
 ld hl,OP2
 call intToFloat
 call _FPAdd
 call _Intgr

 ld hl,OP1
 call floatToInt


 ret

.assume ADL=1
;ez80 mode
;displays a float
;hl = OP(x)
;corrupts hl,bc,de,a
dispFloat:
 inc hl
 ld bc,0
 ld a,(hl)
 ld c,$80
 cp a,c
 jp c,negDecimalPt
 sub a,c
 ld c,a
 inc hl
 ld de,dispFloatVar
 ex de,hl
 add hl,bc
 inc hl
 ld (hl),$2e
 ex de,hl
 ld de,dispFloatVar
 jp dispFloatLoopBegin
negDecimalPt:
 push.lil de
 ld d,a
 ld a,c
 ld c,d
 pop.lil de
 sub a,c
 ld c,a
 inc hl
 ld de,dispFloatVar
 ex de,hl
 or a
 sbc hl,bc
 inc hl
 ld (hl),$2e
 ex de,hl
 ld de,dispFloatVar
 
dispFloatLoopBegin:
 ld b,7
 ld a,(de)
 ld c,$2e
 cp a,c
 jp nz,$+5
 inc de
dispFloatLoop:

 ld a,(hl)
;a >> 4
 srl a
 srl a
 srl a
 srl a
;
 ld c,$30
 add a,c
 ld (de), a
 inc de
 ld a,(de)
 ld c,$2e
 cp a,c
 jp nz,$+5
 inc de

 ld a,(hl)
;res upper 4 bits of a
 res 7,a
 res 6,a
 res 5,a
 res 4,a
;
 ld c,$30
 add a,c
 ld (de),a
 inc hl
 inc de
 ld a,(de)
 ld c,$2e
 cp a,c
 jp nz,$+5
 inc de

 djnz dispFloatLoop

 ld hl,dispFloatVar
 call _PutS

 ;reset float var
 ld hl,dispFloatVar
 ld (hl),$30
 ld de,dispFloatVar
 inc de
 ld bc,14
 ldir

 ret

dispFloatVar:
 .db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30 ;float digits (one extra for decimal point)
 .db 0

.assume ADL=1
;ez80 mode
;converts int to float
;a = int
;hl = OP(x)
;corrupts hl,bc,de,a
intToFloat:
 ld (hl),0 ;positive real number

 ;zero out entire float
 push.lil hl
 pop.lil de
 inc hl
 push.lil hl
 ex de,hl
 ld bc,9
 ldir
 pop.lil hl
 
 ld d,a
 ld b,0
 ld e,10
divBy10Loop:
 push.lil bc
 call div_d_e
 pop.lil bc
 inc b
 push.lil af

 ld a,d
 or a
 jp nz,divBy10Loop

 dec b
 ld a,$80
 add a,b
 ld (hl),a
 
 inc hl 
 ld c,b ;track b for even odd cmp
 
 xor a
 cp a,b ;check for zero skip
 jp z,oddDigits

insertNumberLoop:
 pop.lil af
;a << 4
 add a,a
 add a,a
 add a,a
 add a,a
;
 ld d,a
 pop.lil af
 add a,d
 ld (hl),a
 inc hl

 dec b
 ld a,1
 cp a,b
 dec b
 jp c,insertNumberLoop

 bit 0,c
 jp nz,evenDigits

oddDigits:
 pop.lil af
;a << 4
 add a,a
 add a,a
 add a,a
 add a,a
;
 ld (hl),a
evenDigits:
 
 ret
 

.assume ADL=1
;ez80 mode
;load float into int
;a = float
;hl = OP(x)
;corrupts ...
FloatToInt:
 inc hl
 ld b,(hl)
 inc hl
 xor a
floatToIntLoop:
 ld 
 mult

.assume ADL=1
;source: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Division
;ez80 mode
;8 bit division
;d = divisor
;e = dividend
;d = quotient
;a = remainder
;corrupts b
div_d_e:
   xor	a
   ld	b, 8

_loop:
   sla	d
   rla
   cp	e
   jr	c, $+4
   sub	e
   inc	d
   
   djnz	_loop
   
   ret