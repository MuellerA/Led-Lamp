;;; ========================================================================
;;; led-lamp.asm
;;; (c) Andreas Müller
;;;     see LICENSE.md
;;; ========================================================================

	.include "settings.inc"

;;; ========================================================================
;;; Register
;;; ========================================================================

	_Zero      =  1
	_FnUpdate  =  2		; LedMatrix::Update()
	_FnDisplay =  4		; LedMatrix::Display()
	_FnConfig  =  6		; LedMatrix::Configure(Config c)
	_Cmd       =  8		; IR command
	_LedMatrixAddrLo = 16	; &ledMatrix
	_LedMatrixAddrHi = 17

;;; ========================================================================
;;; Constants
;;; ========================================================================

	Cmd0 = 0
	Cmd1 = 1
	Cmd2 = 2
	Cmd3 = 3
	Cmd4 = 4
	Cmd5 = 5
	Cmd6 = 6
	Cmd7 = 7
	Cmd8 = 8
	Cmd9 = 9
	CmdProgUp     = 10
	CmdProgDown   = 11
	CmdSpeedUp    = 12
	CmdSpeedDown  = 13
	CmdBrightUp   = 14
	CmdBrightDown = 15
	CmdSave       = 16
	CmdLoad       = 17
	CmdEnd        = 18

	IRprotocolSamsung = 1
	IRprotocolNEC     = 2
	IRprotocol = IRprotocolNEC

	ConfigBrightness = 1
	ConfigForceRedraw = 2

;;; ========================================================================
;;; ISR INT0
;;; ========================================================================
;;; State  0: nothing
;;; State  1: start falling edge
;;; State  2: rising edge header after 4.5ms (Samsung)
;;; State  3: falling edge header after 4.5ms
;;; State  4: rising edge bit 0 after 0.56ms
;;; State  5: falling edge bit 0 after 0.56 or 1.69ms
;;; State  6: rising edge bit 1 after 0.56ms
;;; ...
;;; State 68: falling edge bit 31 after 0.56 or 1.69ms

.if IRprotocol == IRprotocolSamsung

	IrHdrMark   = 4500
	IrHdrSpace  = 4500
	IrBitMark   =  500
	IrBit1Space = 1700
	IrBit0Space =  600
	IrByte2     = 0x1f
	IrByte3     = 0xe0

ISR_INT0_CodeToCmd:
	;       00    01    02    03    04    05    06    07      08    09    0a    0b    0c    0d    0e    0f
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   14, 0xff,     11, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 00
	.byte    4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 10
	.byte    1, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 20
	.byte    7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 30
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,     10, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 40
	.byte    6, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 50
	.byte    3, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 60
	.byte    9, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 70

	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   15, 0xff,      0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 80
	.byte    5, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 90
	.byte    2, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; a0
	.byte    8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; b0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; c0
	.byte   13, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; d0
	.byte   12, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; e0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; f0

.elseif IRprotocol == IRprotocolNEC

	IrHdrMark   = 9000
	IrHdrSpace  = 4500
	IrBitMark   =  560
	IrBit1Space = 1650
	IrBit0Space =  560
	IrByte2     = 0xff
	IrByte3     = 0x00

ISR_INT0_CodeToCmd:
	;       00    01    02    03    04    05    06    07      08    09    0a    0b    0c    0d    0e    0f
	.byte 0xff, 0xff,   14, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 00
	.byte    4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,      2, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 10
	.byte 0xff, 0xff,   15, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 20
	.byte    1, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,      5, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 30
	.byte 0xff, 0xff,    7, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff,    8, 0xff, 0xff, 0xff, 0xff, 0xff ; 40
	.byte 0xff, 0xff,    9, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff,    6, 0xff, 0xff, 0xff, 0xff, 0xff ; 50
	.byte 0xff, 0xff,   17, 0xff, 0xff, 0xff, 0xff, 0xff,      0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 60
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff,    3, 0xff, 0xff, 0xff, 0xff, 0xff ; 70

	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 80
	.byte   16, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 90
	.byte 0xff, 0xff,   11, 0xff, 0xff, 0xff, 0xff, 0xff,     12, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; a0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; b0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; c0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; d0
	.byte   13, 0xff,   10, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; e0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; f0

.endif

	.global ISR_INT0
	_SREG  =  9
	_TickL = 10
	_TickH = 11
	_INT0  = 16
	_State = 17
	_DelayMinL = 18
	_DelayMinH = 19
	_DelayMaxL = 20
	_DelayMaxH = 21
ISR_INT0:
	push _SREG
	push _TickL
	push _TickH
	push _INT0
	push _State
	push _DelayMinL
	push _DelayMinH
	push _DelayMaxL
	push _DelayMaxH
	push 22
	push 23
	push 24
	push 25
	push YL
	push YH
	push ZL
	push ZH
	in _SREG, SREG

	ldiw YL, maInt0
	ldd _State, Y + moInt0State

ISR_INT0_0:
	cpi _State, 0x00
	brne ISR_INT0_1

	sbic INT0Pin, INT0Idx	; check INT0 is low (active)
	rjmp ISR_INT0_Error

	rcall StartTimer

	rjmp ISR_INT0_Success

ISR_INT0_1:
	cpi _State, 0x01
	brne ISR_INT0_2

	ldiw _DelayMinL, IrHdrMark *  7 / 10 / 20
	ldiw _DelayMaxL, IrHdrMark * 13 / 10 / 20
	rjmp ISR_INT0_Check

ISR_INT0_2:
	cpi _State, 0x02
	brne ISR_INT0_3

	ldiw _DelayMinL, IrHdrSpace *  7 / 10 / 20
	ldiw _DelayMaxL, IrHdrSpace * 13 / 10 / 20
	rjmp ISR_INT0_Check

ISR_INT0_3:
	sbrs _State, 0
	rjmp ISR_INT0_GetBit

	ldiw _DelayMinL, IrBitMark *  7 / 10 / 20
	ldiw _DelayMaxL, IrBitMark * 13 / 10 / 20

ISR_INT0_Check:
	rcall GetTickCnt	; r24:25 now, r22:23 prev
	sub 24, 22
	sbc 25, 23
	movw _TickL, 24		; ticks since last irq

	cp  _TickL, _DelayMinL
	cpc _TickH, _DelayMinH
	brcs ISR_INT0_Error	; ticks < minDelay

	cp  _DelayMaxL, _TickL
	cpc _DelayMaxH, _TickH
	brcs ISR_INT0_Error	; ticks > maxDelay

	rjmp ISR_INT0_Success

ISR_INT0_GetBit:
	rcall GetTickCnt	; r24:25 now, r22:23 prev
	sub 24, 22
	sbc 25, 23
	movw _TickL, 24		; ticks since last irq

	ldiw _DelayMinL, IrBit0Space *  7 / 10 / 20
	cp  _TickL, _DelayMinL
	cpc _TickH, _DelayMinH
	brcs ISR_INT0_GetBit1

	ldiw _DelayMaxL, IrBit0Space * 13 / 10 / 20
	cp  _DelayMaxL, _TickL
	cpc _DelayMaxH, _TickH
	brcs ISR_INT0_GetBit1

	clc
	rjmp ISR_INT0_ShiftBit

ISR_INT0_GetBit1:
	ldiw _DelayMinL, IrBit1Space *  7 / 10 / 20
	cp  _TickL, _DelayMinL
	cpc _TickH, _DelayMinH
	brcs ISR_INT0_Error

	ldiw _DelayMaxL, IrBit1Space * 13 / 10 / 20
	cp  _DelayMaxL, _TickL
	cpc _DelayMaxH, _TickH
	brcs ISR_INT0_Error

	sec
	rjmp ISR_INT0_ShiftBit

ISR_INT0_Error:
	rcall StopTimer

	ser _State
	rjmp ISR_INT0_Success

ISR_INT0_ShiftBit:
	ldd 24, Y + moInt0B0
	rol 24
	std Y + moInt0B0, 24
	ldd 24, Y + moInt0B1
	rol 24
	std Y + moInt0B1, 24
	ldd 24, Y + moInt0B2
	rol 24
	std Y + moInt0B2, 24
	ldd 24, Y + moInt0B3
	rol 24
	std Y + moInt0B3, 24

ISR_INT0_Success:
	inc _State

	cpi _State, 68
	brne ISR_INT0_Success1

	ldd 24, Y + moInt0B3
	cpi 24, IrByte3
	brne ISR_INT0_Error	; unknown command

	ldd 24, Y + moInt0B2
	cpi 24, IrByte2
	brne ISR_INT0_Error	; unknown command

	ldd 24, Y + moInt0B1
	ldd 25, Y + moInt0B0
	eor 25, 24
	cpi 25, 0xff
	brne ISR_INT0_Error	; unknown command

	ldiw ZL, ISR_INT0_CodeToCmd
	add ZL, 24
	clr 24
	adc ZH, 24
	lpm 24, Z
	cpi 24, 0xff
	breq ISR_INT0_Error
	mov _Cmd, 24

	ldi   17, lo8(RAMEND)
	out   SPL, 17	; Stack Pointer Low [0x3d]
	ldi   17, hi8(RAMEND)
	out   SPH, 17	; Stack Pointer High [0x3e]
	ldi   17, 0
	out   SREG, r17	; Status Register [0x3f]

	rjmp MainInt0

ISR_INT0_Success1:
	std Y + moInt0State, _State

	out SREG, _SREG
	pop ZH
	pop ZL
	pop YH
	pop YL
	pop 25
	pop 24
	pop 23
	pop 22
	pop _DelayMaxH
	pop _DelayMaxL
	pop _DelayMinH
	pop _DelayMinL
	pop _State
	pop _INT0
	pop _TickH
	pop _TickL
	pop _SREG
	reti

;;; ========================================================================
;;; ISR TIMER0
;;; ========================================================================
;;; called at 50kHz / every 20us
	.global ISR_TIMER0
	_SREG = 17
ISR_TIMER0:
	push _SREG
	push 22
	push 23
	push 24
	push 25
	push ZL
	push ZH
	in _SREG, SREG

	ldiw ZL, maTickCnt
	ldd 24, Z+0		; cnt now
	ldd 25, Z+1
	ldd 22, Z+2		; cnt prev
	ldd 23, Z+3
	inc 24
	std Z+0, 24
	brne ISR_TIMER0_1
	inc 25
	std Z+1, 25

ISR_TIMER0_1:
	sub 24, 22
	sbc 25, 23
	cpi 25, 2		; timeout ~10ms
	brcs ISR_TIMER0_2

	out SREG, _SREG
	pop ZH
	pop ZL
	pop 25
	pop 24
	pop 23
	pop 22
	pop _SREG
	rjmp ISR_INT0

ISR_TIMER0_2:
	out SREG, _SREG
	pop ZH
	pop ZL
	pop 25
	pop 24
	pop 23
	pop 22
	pop _SREG
	reti

;;; ========================================================================
;;; unsigned short GetTickCnt()
;;; ========================================================================
	_SREG = 18
GetTickCnt:
	push _SREG
	in _SREG, SREG

	cli

	ldiw ZL, maTickCnt
	ldd 24, Z+0		; now
	ldd 25, Z+1
	ldd 22, Z+2		; prev
	ldd 23, Z+3
	std Z+2, 24
	std Z+3, 25

	out SREG, _SREG
	pop _SREG
	ret

;;; ========================================================================
;;; StartTimer
;;; ========================================================================
StartTimer:
	clr 24
	ldiw ZL, maTickCnt
	st Z+, 24		; now
	st Z+, 24
	st Z+, 24		; prev
	st Z+, 24

	out TCNT0, 24

	ldi 24, 0x10
	out TIFR, 24
	out TIMSK, 24

	ret

;;; ========================================================================
;;; StopTimer
;;; ========================================================================
StopTimer:
	ldi 24, 0x00
	out TIMSK, 24
	ldi 24, 0x10
	out TIFR, 24

	ret

;;; ========================================================================
;;; void main()
;;; ========================================================================
	.global Main
Main:
	sbi LedDdr, LedIdx
 sbi DbgDdr, DbgIdx
 cbi DbgPrt, DbgIdx

	clr _Zero
	ldiw YL, maMain

	movw 24, YL
	rcall ParamLoad
	movw 24, YL
	rcall ParamFix

	ldd 24, Y + moMainFuncSelNo
	mov _Cmd, 24
	com 24
	std Y + moMainFuncSelNoPrev, 24

MainInt0:
	ldiw YL, maMain
	ldiw _LedMatrixAddrLo, maLedMatrixAddr ; LedMatrix RAM address

	clr 24			; reset Int0 States
	ldiw ZL, maInt0
	st Z+, 24
	st Z+, 24
	st Z+, 24
	st Z+, 24
	st Z+, 24

	rcall StopTimer

	mov 24, _Cmd
	cpi 24, CmdEnd
	brcs MainInt01

	ldi 24, 0x00		; red
	ldi 22, 0x04		; square
	rcall _ZN9LedMatrix5BlinkEhh ; LedMatrix::Blink(col, mode)
	ldiw 24, 0x0100
	rcall Delay
	rjmp MainCmdEnd
MainInt01:
	ldip ZL, MainCmdJmpTab
	add ZL, 24
	adc ZH, _Zero
	ijmp

MainCmdJmpTab:
	rjmp MainCmdN		; 0
	rjmp MainCmdN		; 1
	rjmp MainCmdN 		; 2
	rjmp MainCmdN		; 3
	rjmp MainCmdN		; 4
	rjmp MainCmdN		; 5
	rjmp MainCmdN		; 6
	rjmp MainCmdN		; 7
	rjmp MainCmdN		; 8
	rjmp MainCmdN		; 9
	rjmp MainCmdProgUp	; CH+ 10
	rjmp MainCmdProgDown	; CH- 11
	rjmp MainCmdSpeedUp	; +   12
	rjmp MainCmdSpeedDown	; -   13
	rjmp MainCmdBrightUp	; >>| 14
	rjmp MainCmdBrightDown	; |<< 15
	rjmp MainCmdSave	; EQ  16
	rjmp MainCmdLoad	; CH  17

MainCmdN:
	std Y + moMainFuncSelNo, _Cmd

MainCmdNewFunc:
	ldiw ZL, MainFuncTable
	ldd 24, Y + moMainFuncSelNo
	ldd 25, Y + moMainFuncSelNoPrev
	cp 24, 25
	brne MainCmdNewFunc1
	ldi 24, 0x01		; green
	ldi 22, 0x04		; square
	rjmp MainCmdBlink
MainCmdNewFunc1:
	std Y + moMainFuncSelNoPrev, 24
	lsl 24			; 24 = 2*Idx
	lsl 24			; 24 = 4*Idx
	lsl 24			; 24 = 8*Idx = MainFuncTableEntrySize*Idx

	add ZL, 24
	adc ZH, _Zero

	lpm 24, Z+		; get constructor
	lpm 25, Z+
	lpm _FnUpdate, Z+	; Update()
	lpm _FnUpdate+1, Z+
	lpm _FnDisplay, Z+	; Display()
	lpm _FnDisplay+1, Z+
	lpm _FnConfig, Z+
	lpm _FnConfig+1, Z+	; Config(int type, int value)

	movw ZL, 24
	movw 24, _LedMatrixAddrLo
	icall			; call constructor (with parameters)

	movw 24, _LedMatrixAddrLo
	ldi 22, ConfigBrightness
	ldd 20, Y + moMainBrightness
	movw ZL, _FnConfig
	icall			; call <class>::Config(ConfigBrightness, brightness)

	rjmp MainCmdEnd

MainCmdProgUp:
	ldd 24, Y + moMainFuncSelNo
	cpi 24, MainFuncTableSize - 1
	brne MainCmdProgUp1

	ldi 24, 0x00
	std Y + moMainFuncSelNo, 24
	rjmp MainCmdNewFunc
MainCmdProgUp1:
	inc 24
	std Y + moMainFuncSelNo, 24
	rjmp MainCmdNewFunc

MainCmdProgDown:
	ldd 24, Y + moMainFuncSelNo
	cpi 24, 0x00
	brne MainCmdProgDown1

	ldi 24, MainFuncTableSize - 1
	std Y + moMainFuncSelNo, 24
	rjmp MainCmdNewFunc
MainCmdProgDown1:
	dec 24
	std Y + moMainFuncSelNo, 24
	rjmp MainCmdNewFunc

MainCmdSpeedUp:
	ldd 24, Y + moMainDelayLo
	ldd 25, Y + moMainDelayHi

	cpi 24, 0x40		; min == 0x0040
	brne MainCmdSpeedUp1
	ldi 24, 0x00 		; red
	ldi 22, 0x01 		; right
	rjmp MainCmdBlink
MainCmdSpeedUp1:
	lsr 25
	ror 24

	std Y + moMainDelayLo, 24
	std Y + moMainDelayHi, 25

	ldi 24, 0x01 		; green
	ldi 22, 0x01 		; right
	rjmp MainCmdBlink

MainCmdSpeedDown:
	ldd 24, Y + moMainDelayLo
	ldd 25, Y + moMainDelayHi

	cpi 25, 0x80		; max = 0x8000
	brne MainCmdSpeedDown1
	ldi 24, 0x00		; red
	ldi 22, 0x00		; left
	rjmp MainCmdBlink
MainCmdSpeedDown1:
	lsl 24
	rol 25

	std Y + moMainDelayLo, 24
	std Y + moMainDelayHi, 25

	ldi 24, 0x01		; green
	ldi 22, 0x00		; left
	rjmp MainCmdBlink

MainCmdBrightUp:
	ldd 24, Y + moMainBrightness

	cpi 24, 0xff		; max = 0xff
	brne MainCmdBrightUp1
	ldi 24, 0x00		; red
	ldi 22, 0x02		; top
	rjmp MainCmdBlink
MainCmdBrightUp1:
	subi 24, 0xf0		; addi 24, 0x10

	std Y + moMainBrightness, 24

	movw 24, _LedMatrixAddrLo
	ldi 22, ConfigBrightness
	ldd 20, Y + moMainBrightness
	movw ZL, _FnConfig
	icall			; call <class>::Config(ConfigBrightness, brightness)

	ldi 24, 0x01		; green
	ldi 22, 0x02		; top
	rjmp MainCmdBlink

MainCmdBrightDown:
	ldd 24, Y + moMainBrightness

	cpi 24, 0x1f		; min = 0x1f
	brne MainCmdBrightDown1
	ldi 24, 0x00		; red
	ldi 22, 0x03		; bottom
	rjmp MainCmdBlink
MainCmdBrightDown1:
	subi 24, 0x10

	std Y + moMainBrightness, 24

	movw 24, _LedMatrixAddrLo
	ldi 22, ConfigBrightness
	ldd 20, Y + moMainBrightness
	movw ZL, _FnConfig
	icall			; call <class>::Config(ConfigBrightness, brightness)

	ldi 24, 0x01		; green
	ldi 22, 0x03		; bottom
	rjmp MainCmdBlink

MainCmdSave:
	ldi 24, 0x02		; blue
	ldi 22, 0x04		; square
	rcall _ZN9LedMatrix5BlinkEhh ; LedMatrix::Blink(col, mode)

	movw 24, YL
	rcall ParamSave

	ldi 24, 0x02		; blue
	ldi 22, 0x04		; square
	rjmp MainCmdBlink

MainCmdLoad:
	movw 24, YL
	rcall ParamLoad
	movw 24, YL
	rcall ParamFix

	rjmp MainCmdNewFunc

MainCmdBlink:			; 24: col, 22: mode
	rcall _ZN9LedMatrix5BlinkEhh ; LedMatrix::Blink(col, mode)

	ldiw 24, 0x0800
	rcall Delay

	movw 24, _LedMatrixAddrLo
	ldi  22, ConfigForceRedraw
	ldi  20, 0x00
	movw ZL, _FnConfig
	icall			; call <class>::Config(ConfigForceRedraw, dummy)

MainCmdEnd:

	sei

MainLoop:
	lds 24, maInt0 + moInt0State
	tst 24
	brne MainLoopDelay

	movw r24, _LedMatrixAddrLo
	movw ZL, _FnUpdate	; Update()
	icall

	movw r24, _LedMatrixAddrLo
	movw ZL, _FnDisplay	; Display()
	icall

MainLoopDelay:
; rcall DbgLed
	ldd 24, Y + moMainDelayLo
	ldd 25, Y + moMainDelayHi
	rcall Delay
	rjmp MainLoop

	MainFuncTableSize      = (MainFuncTableEnd - MainFuncTable) / MainFuncTableEntrySize
	MainFuncTableEntrySize = 0x08
MainFuncTable:
	.word pm(ConstColOff)
	.word pm(_ZN8ConstCol6UpdateEv)
	.word pm(_ZN8ConstCol7DisplayEv)
	.word pm(_ZN8ConstCol6ConfigEhh)

	.word pm(_ZN13LedMatrixBallC1Ev)
	.word pm(_ZN13LedMatrixBall6UpdateEv)
	.word pm(_ZN13LedMatrixBall7DisplayEv)
	.word pm(_ZN13LedMatrixBall6ConfigEhh)

	.word pm(_ZN4RainC1Ev)
	.word pm(_ZN4Rain6UpdateEv)
	.word pm(_ZN4Rain7DisplayEv)
	.word pm(_ZN4Rain6ConfigEhh)

	.word pm(Flow)
	.word pm(_ZN4Flow6UpdateEv)
	.word pm(_ZN4Flow7DisplayEv)
	.word pm(_ZN4Flow6ConfigEhh)

	.word pm(MultiCol2)
	.word pm(_ZN8MultiCol6UpdateEv)
	.word pm(_ZN8MultiCol7DisplayEv)
	.word pm(_ZN8MultiCol6ConfigEhh)

	.word pm(MultiCol1)
	.word pm(_ZN8MultiCol6UpdateEv)
	.word pm(_ZN8MultiCol7DisplayEv)
	.word pm(_ZN8MultiCol6ConfigEhh)

	.word pm(Pump1)
	.word pm(_ZN4Pump6UpdateEv)
	.word pm(_ZN4Pump7DisplayEv)
	.word pm(_ZN4Pump6ConfigEhh)

	.word pm(ConstColRed)
	.word pm(_ZN8ConstCol6UpdateEv)
	.word pm(_ZN8ConstCol7DisplayEv)
	.word pm(_ZN8ConstCol6ConfigEhh)

	.word pm(ConstColGreen)
	.word pm(_ZN8ConstCol6UpdateEv)
	.word pm(_ZN8ConstCol7DisplayEv)
	.word pm(_ZN8ConstCol6ConfigEhh)

	.word pm(ConstColBlue)
	.word pm(_ZN8ConstCol6UpdateEv)
	.word pm(_ZN8ConstCol7DisplayEv)
	.word pm(_ZN8ConstCol6ConfigEhh)

	.word pm(ConstColWhite1)
	.word pm(_ZN8ConstCol6UpdateEv)
	.word pm(_ZN8ConstCol7DisplayEv)
	.word pm(_ZN8ConstCol6ConfigEhh)

	.word pm(Pump0)
	.word pm(_ZN4Pump6UpdateEv)
	.word pm(_ZN4Pump7DisplayEv)
	.word pm(_ZN4Pump6ConfigEhh)

MainFuncTableEnd:

Pump0:
	ldi r22, 0x00
	rjmp _ZN4PumpC1Eh			; Pump::Pump(0)

Pump1:
	ldi r22, 0x01
	rjmp _ZN4PumpC1Eh			; Pump::Pump(1)

Flow:
	ldi r22, 0x01
	rjmp _ZN4FlowC1Eh			; Flow::Flow()

ConstColRed:
	ldi r22, 0xff
	ldi r20, 0x00
	ldi r18, 0x00
	rjmp 	_ZN8ConstColC1Ehhh 		; ConstCol::CosntCol(0xff, 0x00, 0x00)

ConstColGreen:
	ldi r22, 0x00
	ldi r20, 0xff
	ldi r18, 0x00
	rjmp 	_ZN8ConstColC1Ehhh		; ConstCol::CosntCol(0x00, 0xff, 0x00)

ConstColBlue:
	ldi r22, 0x00
	ldi r20, 0x00
	ldi r18, 0xff
	rjmp 	_ZN8ConstColC1Ehhh		; ConstCol::CosntCol(0x00, 0x00, 0xff)

ConstColWhite1:
	ldi r22, 0x5f
	ldi r20, 0x5f
	ldi r18, 0x5f
	rjmp 	_ZN8ConstColC1Ehhh 		; ConstCol::CosntCol(0x5f, 0x5f, 0x5f)

ConstColOff:
	ldi r22, 0x00
	ldi r20, 0x00
	ldi r18, 0x00
	rjmp 	_ZN8ConstColC1Ehhh 		; ConstCol::CosntCol(0x00, 0x00, 0x00)

MultiCol1:
	ldi r22, 0x00
	rjmp 	_ZN8MultiColC1Eh 		; ConstCol::CosntCol(0x00, 0x00, 0x00)

MultiCol2:
	ldi r22, 0x01
	rjmp 	_ZN8MultiColC1Eh 		; ConstCol::CosntCol(0x00, 0x00, 0x00)

;;; ========================================================================
;;; ParamLoad(MemMain*)
;;; ========================================================================
	_MemMainLo = 12
	_MemMainHi = 13
	_EepromLo = 14
	_EepromHi = 15
ParamLoad:
	push _MemMainLo
	push _MemMainHi
	push _EepromLo
	push _EepromHi
	movw _MemMainLo, 24

	clr _EepromHi

	clr _EepromLo
	movw 24, _EepromLo
	rcall EepromRead
	movw ZL, _MemMainLo
	std Z + moMainFuncSelNo, 24

	inc _EepromLo
	movw 24, _EepromLo
	rcall EepromRead
	movw ZL, _MemMainLo
	std Z + moMainDelayLo, 24

	inc _EepromLo
	movw 24, _EepromLo
	rcall EepromRead
	movw ZL, _MemMainLo
	std Z + moMainDelayHi, 24

	inc _EepromLo
	movw 24, _EepromLo
	rcall EepromRead
	movw ZL, _MemMainLo
	std Z + moMainBrightness, 24

	pop _EepromHi
	pop _EepromLo
	pop _MemMainHi
	pop _MemMainLo
	ret

;;; ========================================================================
;;; ParamSave(MemMain*)
;;; ========================================================================
ParamSave:
	push _MemMainLo
	push _MemMainHi
	push _EepromLo
	push _EepromHi
	movw _MemMainLo, 24

	clr _EepromHi

	clr _EepromLo
	movw 24, _EepromLo
	movw ZL, _MemMainLo
	ldd 22, Z + moMainFuncSelNo
	rcall EepromWrite

	inc _EepromLo
	movw 24, _EepromLo
	movw ZL, _MemMainLo
	ldd 22, Z + moMainDelayLo
	rcall EepromWrite

	inc _EepromLo
	movw 24, _EepromLo
	movw ZL, _MemMainLo
	ldd 22, Z + moMainDelayHi
	rcall EepromWrite

	inc _EepromLo
	movw 24, _EepromLo
	movw ZL, _MemMainLo
	ldd 22, Z + moMainBrightness
	rcall EepromWrite

	pop _EepromHi
	pop _EepromLo
	pop _MemMainHi
	pop _MemMainLo
	ret

;;; ========================================================================
;;; ParamInit(MemMain*)
;;; ========================================================================
ParamInit:
	movw ZL, 24
	ldi 24, 0x04
	std Z + moMainFuncSelNo, 24
	ldi 24, 0x00
	std Z + moMainDelayLo, 24
	ldi 24, 0x02
	std Z + moMainDelayHi, 24
	ldi 24, 0x7f
	std Z + moMainBrightness, 24
	ret

;;; ========================================================================
;;; ParamFix(MemMain*)
;;; ========================================================================
ParamFix:
	movw ZL, 24
	ldd 24, Z + moMainFuncSelNo
	cpi 24, MainFuncTableSize
	brcc ParamFixErr

	ldd 24, Z + moMainDelayLo
	ldd 25, Z + moMainDelayHi

	clr 22
	ldi 23, 8
ParamFix1b:
	lsl 24
	brcc ParamFix1a
	inc 22
ParamFix1a:
	dec 23
	brne ParamFix1b
	ldi 23, 8
ParamFix2b:
	lsl 25
	brcc ParamFix2a
	inc 22
ParamFix2a:
	dec 23
	brne ParamFix2b

	cpi 22, 0x01
	brne ParamFixErr

	ldd 24, Z + moMainBrightness
	mov 23, 24
	andi 23, 0x0f
	cpi 23, 0x0f
	brne ParamFixErr
	cpi 24, 0x1f
	brcs ParamFixErr

	ret

ParamFixErr:
	push _MemMainLo
	push _MemMainHi
	movw _MemMainLo, ZL
	movw 24, _MemMainLo
	rcall ParamInit
	movw 24, _MemMainLo
	rcall ParamSave
	pop _MemMainHi
	pop _MemMainLo
	ret

;;; ========================================================================
;;; void SendDataRGB(unsigned char r, unsigned char g, unsigned char b)
;;; ========================================================================
	.global SendDataRGB
SendDataRGB:
	push 16
	push 20
	push 24
	in 16, SREG

	cli

	mov 24, 22
	rcall SendDataByte
	pop 24
	rcall SendDataByte
	pop 24
	rcall SendDataByte

	out SREG, 16
	pop 16
	ret

;;; ========================================================================
;;; void SendDataByte(unsigned char byte)
;;; ========================================================================
	.macro nops cnt=2
	nop
	.if \cnt-1
	nops \cnt-1
	.endif
	.endm

	.global SendDataByte
	_BitCnt = 22
	_Byte = 24
SendDataByte:
	ldi _BitCnt, 8
BitLoop:
	lsl _Byte		; 1
	brcs B1			; 1 / 2

;;; ========================================================================
;;; WS2812
;;; ========================================================================
.if 1
;;; Bit	HIGH	LOW	16MHz		20MHz
;;;  0 	350ns	800ns	5.6/12.8	7/16
;;;  1	700ns	600ns	11.2/9.6	14/12

B0:
	sbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:4
	nops 4
.elseif MCUclock == 20000000 ; 20MHz:5
	nops 5
.else
	.error
.endif

	cbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:4
	nops 4
.elseif MCUclock == 20000000 ; 20MHZ:7
	nops 7
.endif

	rjmp BitDec		; 2

B1:
	sbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:9
	nops 9
.elseif MCUclock == 20000000 ; 20MHz:12
	nops 12
.endif

	cbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:2
	nops 2
.elseif MCUclock == 20000000 ; 20MHZ:5
	nops 5
.endif

.endif
;;; WS2812
;;; ========================================================================

;;; ========================================================================
;;; WS2812B
;;; ========================================================================
.if 0
;;; Bit	HIGH	LOW	16MHz		20MHz
;;;  0 	400ns	850ns	6.4/13.6	8/17
;;;  1	800ns	450ns	12.8/7.2	16/9

B0:
	sbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:4
	nops 4
.elseif MCUclock == 20000000 ; 20MHz:6
	nops 6
.endif

	cbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:5
	nops 5
.elseif MCUclock == 20000000 ; 20MHZ:8
	nops 8
.endif

	rjmp BitDec		; 2

B1:
	sbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:11
	nops 11
.elseif MCUclock == 20000000 ; 20MHz:14
	nops 14
.endif

	cbi LedPrt, LedIdx	; 2
.if MCUclock == 16000000 ; 16MHz:0
	;nops 2
.elseif MCUclock == 20000000 ; 20MHZ:2
	nops 2
.endif

.endif
;;; WS2812B
;;; ========================================================================

BitDec:	dec _BitCnt		; 1
	brne BitLoop		; 2|1

	ret

;;; ========================================================================
;;; unsigned char EepromRead(addr*)
;;; ========================================================================
	.global EepromRead
EepromRead:
	sbic EECR, EECR_EEPE
	rjmp EepromRead

	out EEARH, 25
	out EEARL, 24
	sbi EECR, EECR_EERE
	in 24, EEDR

	ret

;;; ========================================================================
;;; void EepromWrite(addr*, byte)
;;; ========================================================================
	.global EepromWrite
EepromWrite:
	sbic EECR, EECR_EEPE
	rjmp EepromWrite

	out EEARH, 25
	out EEARL, 24
	out EEDR, 22
	sbi EECR, EECR_EEMPE
	sbi EECR, EECR_EEPE

	ret

;;; ========================================================================
;;; unsigned char Rnd()
;;; ========================================================================
	.global Rnd
	LL = 24
	LH = 25
	HL = 26
	HH = 27
	FB = 22			; feed back
	Tmp = 23
	Cnt = 20
Rnd:				; LFSR 32bit
	ldiw ZL, maMain + moMainRndVal
	ldd LL, Z+0
	ldd LH, Z+1
	ldd HL, Z+2
	ldd HH, Z+3

	ldi Cnt, 8
Rnd1:
	mov FB, LL		; tap 32

	bst LL, 2		; tap 30
	bld Tmp, 0
	eor FB, Tmp

	bst LL, 6		; tap 26
	bld Tmp, 0
	eor FB, Tmp

	bst LL, 7		; tap 25
	bld Tmp, 0
	eor FB, Tmp

	ror FB
	ror HH
	ror HL
	ror LH
	ror LL

	dec Cnt
	brne Rnd1

	std Z+0, LL
	std Z+1, LH
	std Z+2, HL
	std Z+3, HH

	;; 24 == LL
	ret

;;; ========================================================================
;;; void Delay()
;;; 24:25 delay
;;; ========================================================================
Delay:
	clr 22
DelayLoop:
	dec 22
	brne DelayLoop
	sbiw 24, 0x01
	brne DelayLoop

	ret

;;; ========================================================================
;;; DbgLed
;;; ========================================================================
.if 0
DbgLed:
	push 16
	push 17

	ldiw 24, 0x0040
	rcall Delay

	in 16, SPH
	rcall DbgLedByte

	in 16, SPL
	rcall DbgLedByte

	mov 16, YH
	rcall DbgLedByte

	mov 16, YL
	rcall DbgLedByte

	ldd 16, Y + moMainFuncSelNo
	rcall DbgLedByte

	ldiw 24, 0x0000
	rcall EepromRead
	mov 16, 24
	rcall DbgLedByte

	ldd 16, Y + moMainBrightness
	rcall DbgLedByte

	ldiw 24, 0x0003
	rcall EepromRead
	mov 16, 24
	rcall DbgLedByte

	pop 17
	pop 16
	ret

DbgLedByte:
	ldi 17, 0x08
DbgLedByte1:
	rcall DbgLedBit
	dec 17
	brne DbgLedByte1

	ret

DbgLedBit:
	lsl 16
	brcc DbgLedBit0
DbgLedBit1:
	ldi 24, 0x0f
	ldi 22, 0x00
	ldi 20, 0x00
	rjmp SendDataRGB
DbgLedBit0:
	ldi 24, 0x00
	ldi 22, 0x00
	ldi 20, 0x0f
	rjmp SendDataRGB
.endif

;;; ========================================================================
;;; DbgWord, DbgByte
;;; ========================================================================
.if 0
	.global DbgWord
DbgWord:
	push 25
	push 24

	push 24
	mov 24, 25
	rcall DbgByte
	pop 24
	rcall DbgByte

	pop 24
	pop 25
	ret

	.global DbgByte
DbgByte:
	push 24

	sbi DbgPin, DbgIdx
	sbi DbgPin, DbgIdx
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit
	rcall DbgBit

	pop 24
	ret

DbgBit:
	lsl 24
	brcc DbgBit1
	dbg 2
	ret
DbgBit1:
	dbg
	nop
	nop
	ret
.endif

;;; ========================================================================
;;; EOF
;;; ========================================================================
