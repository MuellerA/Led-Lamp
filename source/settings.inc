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

	MemTickCnt = RAMSTART	;
	MemTickCntNow  = 0	; current GetTickCnt call
	memTickCntPrev = 2	; previous GetTickCnt call

	MemInt0 = MemTickCnt + 4
	MemInt0State = 0	; state
	MemInt0B0    = 1	; IR read bytes 0..3
	MemInt0B1    = 2
	MemInt0B2    = 3
	MemInt0B3    = 4

	MemMain = MemInt0 + 5
	MemMainRndVal = 0
	MemMainFuncSelLo = 4
	MemMainFuncSelHi = 5
	MemMainFuncSelNo = 6
	MemMainFuncSelNoPrev = 7
	MemMainDelayLo = 8
	MemMainDelayHi = 9
	MemMainBrightness = 10

	MemLedMatrixAddr = MemMain + 11 ; C++ object address -- LAST ENTRY!!!

;;; ========================================================================
;;; EEPROM
;;; ========================================================================

	EepromCmd        = 0
	EepromDelayLo    = 1
	EepromDelayHi    = 2
	EepromBrightness = 3
	
;;; ========================================================================
;;; EOF
;;; ========================================================================
