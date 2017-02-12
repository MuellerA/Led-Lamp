;;; ========================================================================
;;; settings.inc
;;; (c) Andreas Müller
;;;    see LICENSE.md
;;; ========================================================================

.if __MCU__ == 45
	.include "ports.attiny45.inc"
	TICK_PER_US = 1
.elseif __MCU__ == 85
	.include "ports.attiny85.inc"
	TICK_PER_US = 1
.elseif __MCU__ == 328
	.include "ports.atmega328p.inc"
	TICK_PER_US = 2
.endif

;;; ========================================================================
;;; Macros
;;; ========================================================================

	.macro ldiw reg val
	ldi \reg, lo8(\val)
	ldi \reg+1, hi8(\val)
	.endm

	.macro ldip reg val
	ldi \reg, pm_lo8(\val)
	ldi \reg+1, pm_hi8(\val)
	.endm

	.macro dbg pulse=1
	sbi DbgPin, DbgIdx
	sbi DbgPin, DbgIdx
	.if \pulse-1
	dbg \pulse-1
	.endif
	.endm

;;; ========================================================================
;;; Registers
;;; ========================================================================

	;; setup GCC registers
	;; clr _Zero
	;; R0, T scratch
	;; R18-27,30-31 call-clobbered
	;; r2-17,28,29 call-saved

;;; ========================================================================
;;; SRAM
;;; ========================================================================

	maTickCnt = RAMSTART	;
	maTickCntNow  = 0	; current GetTickCnt call
	maTickCntPrev = 2	; previous GetTickCnt call

	maInt0 = maTickCnt + 4
	moInt0State = 0	; state
	moInt0B0    = 1	; IR read bytes 0..3
	moInt0B1    = 2
	moInt0B2    = 3
	moInt0B3    = 4

	maMain = maInt0 + 5
	moMainRndVal = 0
	moMainFuncSelNo = 4	; [0..MainFuncTableSize-1]
	moMainFuncSelNoPrev = 5
	moMainDelayLo = 6	; [0x0040..0x8000, */ 2]
	moMainDelayHi = 7
	moMainBrightness = 8	; [0x1f..0xff, +- 0x10]

	maLedMatrixAddr = maMain + 9 ; C++ object address -- LAST ENTRY!!!

;;; ========================================================================
;;; EEPROM
;;; ========================================================================

	eaSelNo      = 0	; [0..MainFuncTableSize-1]
	eaDelayLo    = 1	; [0x0040..0x8000, */ 2]
	eaDelayHi    = 2
	eaBrightness = 3	; [0x1f..0xff, += 0x10]

;;; ========================================================================
;;; EOF
;;; ========================================================================
