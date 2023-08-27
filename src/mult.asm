.nolist
#include "../includes/ti84pce.inc"
.list
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp
 
;init
 call _HomeUp
 call _ClrScrnFull
 call _RunIndicOff
 ld a,mb
    ;save flags
     push af
     push iy
     
main:
 di
 stmix
 ld a,$d1 ;load to of address for z80
 ld mb,a
 ld hl,0
 ld bc,32767
 ld de,16

 call.is multiply & $ffff

 rsmix

 push hl
 push de
 call _DispHL
 pop hl
 pop de
 push hl
 push de
 call _DispHL
 pop hl
 pop de
 call _DispHL

exit:
 pop iy
 pop af
 ld mb,a
 call _GetKey
 call _ClrScrnFull
 call _HomeUp
 res donePrgm, (iy+doneFlags)
 ret

;source: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Multiplication
;z80 mode
;16 bit signed multiply
;call with bc, de = 16 bit signed numbers to multiply
;returns   de:hl = 32 bit signed product
;corrupts  a

; de:hl = bc*de
.assume ADL=0
multiply:
  xor a
  ld h,a
  ld l,a

  bit 7,d
  jp z,muldpos & $ffff
  sbc hl,bc
muldpos:

  or b
  jp p,mulbpos & $ffff
  sbc hl,de
mulbpos:

  ld a,16
mulloop:
  add hl,hl
  rl e
  rl d
  jp nc,mul0bit & $ffff
  add hl,bc
  jp nc,mul0bit & $ffff
  inc de
mul0bit:
  dec a
  jp nz,mulloop & $ffff

  ret.l
