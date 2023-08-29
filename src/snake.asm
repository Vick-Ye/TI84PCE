.nolist
#include "/includes/ti84pce.inc"
queueTail equ 0
queueHead equ 2
queueCount equ 4
queueSize equ 6
queueArr equ 8

.list
 .assume ADL=1
 .org userMem-2
 .db tExtTok,tAsm84CeCmp

init:
 call _ClrScrnFull
 call _HomeUp
 call _RunIndicOff
 ld a,mb
 ;save flags
     push af
     push iy
 ld a,(mpRtcRange)
 ld (time),a
 ld ix,snake
 ld bc,1538
 ld de,pixelShadow

 di
 stmix
 ld a,$d1
 ld mb,a

 call.il initQueue
 ld a,(pos)
 call.il enqueue
 ld a,(pos+1)
 call.il enqueue

 call.il draw
 call.il loop
 rsmix

 jp exit


loop:
 ;keyboard
 ld hl,mpKeyRange
 ld (hl),2

 xor a
wait:
 cp a,(hl)
 jp nz,wait

 ld a,(mpKeyData+$e)
 bit 0,a ;down
 ld d,0
 ld e,1
 call.il nz,setDir
 bit 1,a ;left
 ld d,-1
 ld e,0
 call.il nz,setDir
 bit 2,a ;right
 ld d,1
 ld e,0
 call.il nz,setDir
 bit 3,a ;up
 ld d,0
 ld e,-1
 call.il nz,setDir

 ;timer
 ld a,(mpRtcRange)
 ld b,a
 ld a,(time)
 cp a,b
 ld a,b
 ld (time),a
 jp nz,update
 jp loop

update:
 ;pos.x += dir.x
 ld a,(dir)
 ld b,a
 ld a,(pos)
 add a,b
 ld (pos),a

 ;pos.y += dir.y
 ld a,(dir+1)
 ld b,a
 ld a,(pos+1)
 add a,b
 ld (pos+1),a

 ;if pos.x > 31 or pos.x < 0 then exit
 ld a,(pos)
 cp a,32
 jp nc,dead
 ld a,(pos)
 or a
 jp c,dead

 ;if pos.y > 23 or pos.y < 0 then exit
 ld a,(pos+1)
 cp a,24
 jp nc,dead
 or a
 jp c,dead

 call.il dequeue
 call.il dequeue

 ld a,(pos)
 call.il enqueue
 ld a,(pos+1)
 call.il enqueue

 call.il draw

 jp loop

dead:
 ret.l

exit:
 ;restore flags
     pop iy
     pop af
 ld mb,a
 ei
 call RestoreKeyboard
 call _GetKey
 call _ClrScrnFull
 call _HomeUp
 res donePrgm,(iy+doneFlags)
 ret
 
time:
 .db 0

pos: ;(0,0) -> (31,23)
 .db 16,12

dir: ;(+-1,+-1)
 .db 0,-1

apple:
 .db 0,0

snake: ;queue
.dw 0 ;tail
.dw 0 ;head
.dw 0 ;count
.dw 0 ;size
.db 0,0,0 ;arr

.assume ADL=1
;ez80 mode
;initiates the size and arr of a queue
;ix = queue
;bc = size
;de = arr
initQueue:
 ld (ix+queueSize),bc
 ld (ix+queueArr),de

 ret.l
 
.assume ADL=1
;ez80 mode
;adds an element to the front
;ix = queue
;a = element
;corrupts hl,bc
enqueue:
 ld.sis bc,(ix+queueHead)
 ld hl,(ix+queueArr)
 add hl,bc
 ld (hl),a

 ;queueHead = (queueHead + 1) % queueSize
 ld.sis hl,(ix+queueHead)
 inc.sis hl
 ld.sis bc,(ix+queueSize)
 or a
 sbc.sis hl,bc
 jp nc,$+6
 add.sis hl,bc
 ld.sis (ix+queueHead),hl

 ld.sis hl,(ix+queueCount)
 inc.sis hl
 ld.sis (ix+queueCount),hl

 ret.l

.assume ADL=1
;ez80 mode
;removes and returns an element at the back
;ix = queue
;a = element
;corrupts hl, bc
dequeue:
 ld.sis bc,(ix+queueTail)
 ld hl,(ix+queueArr)
 add hl,bc
 ld a,(hl)

 ;queueTail = (queueTail + 1) % queueSize
 ld.sis hl, (ix+queueTail)
 inc.sis hl
 ld.sis bc, (ix+queueSize)
 or a
 sbc.sis hl, bc
 jp nc, $+6
 add.sis hl,bc
 ld.sis (ix+queueTail),hl

 ld.sis hl,(ix+queueCount)
 dec.sis hl
 ld.sis (ix+queueCount),hl

 ret.l

.assume ADL=1
;ez80 mode
;sets dir
;de = new dir
;corrupts a
setDir:
 ld a,d
 ld (dir),a
 ld a,e
 ld (dir+1),a

 ret.l

.assume ADL=1
;ez80 mode
;set background of screen
;hl = background color
;corrupts hl,de,bc
background:
 ld de,vRam+2
 ld (vRam),hl
 ld hl,vRam
 ld bc,320*240*2-2
 ldir

 ret.l

.assume ADL=1
;ez80 mode
;draws background, snake, and food
;ix = queue
;corrupts a,hl,de
draw:
 ld hl,0
 call.il background
 ;ld a,(pos)
 ;ld d,a
 ;ld a,(pos+1)
 ;ld e,a
 ;ld hl,$ffffff
 ;call.il square

 ;for(i = queueTail; i != queueHead; i = (i + 2) % queueSize)
 ld hl,0
 ld.sis hl,(ix+queueTail)

drawLoop:
 push.lil hl
 ld de,(ix+queueArr)
 add hl,de
 ld d,(hl)
 inc hl
 ld e,(hl)
 ld hl,$ffffff
 call.il square
 pop.lil hl

 ;hl = (hl + 2) % queueSize
 inc.sis hl
 inc.sis hl
 ld.sis bc,(ix+queueSize)
 or a
 sbc.sis hl,bc
 jp nc,$+6
 add.sis hl,bc
 
 ld.sis bc,(ix+queueHead)
 or a
 sbc.sis hl,bc
 add.sis hl,bc

 jp nz,drawLoop

 ret.l
 
.assume ADL=1
;ez80 mode
;draws a 10x10 square at (d*10,e*10)
;hl = color
;corrupts hl,de,bc,a
square:
 push.lil hl
 push.lil de

 ;d*10*2
 ld a,d
 ld bc,0
 ld c,a
 ld de,10*2
 call.is multiply & $ffff

 pop.lil de
 push.lil hl ;hl = d*10*2
 ld a,e
 ld bc,0
 ld c,a
 ld de,10*320*2
 call.is multiply & $ffff
 ex de,hl ;hl = e*10*320*2 upper bits, de = lower 16 bits
; hl<<16
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl

;
 add hl,de
 ex de,hl
 pop.lil hl
 ex de,hl
 add hl,de
 ld de,vram
 add hl,de

 ;hl = vram + d*10*2 + e*10*320*2
 ;de = color
 pop.lil de

 ;draw 10 lines
 ld b,10
lineLoop:
 push.lil bc

 push.lil hl
 push.lil de
 ld (hl),de
 push.lil hl
 pop.lil de
 inc de
 inc de
 ld bc,2*10-2
 ldir
 pop.lil de
 pop.lil hl
 ld bc,2*320
 add hl,bc

 pop.lil bc
 djnz lineLoop
 
 ret.l

.assume ADL=1
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

.assume ADL=0
;source: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Multiplication
;z80 mode
;16 bit signed multiply
;bc, de = operands
;de:hl = product
;corrupts  a
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
