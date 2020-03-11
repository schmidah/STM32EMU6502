; STARTUP AND SERIAL I/O ROUTINES ===========================================================
; BY G. SEARLE 2013 =========================================================================
; Modified by schmidah 2020
ACIA 			:= $A000
ACIAControl 	:= ACIA+0
ACIAStatus 		:= ACIA+0
ACIAData 		:= ACIA+1

.import vtl_reset
.import vtl_start
.import RESTART
.import COLD_START

.export Reset
.export MONCOUT
.export MONRDKEY
.export MONISCNTC
.export LOAD
.export SAVE

.segment "IOHANDLER"
Reset:
	LDX     #$FF		; Set up the stack
	TXS

	LDA 	#$95		; Set ACIA baud rate, word size and Rx interrupt (to control RTS)
	STA	ACIAControl

; Display startup message
	LDY #0
ShowStartMsg:
	LDA	StartupMessage,Y
	BEQ	WaitForKpMode
	JSR	MONCOUT
	INY
	BNE	ShowStartMsg
	
; Wait for a cold/warm start selection
WaitForKpMode:
	JSR	MONRDKEY
	BCC	WaitForKpMode
	
	AND	#$DF			; Make upper case
	CMP	#'M'			; compare with [M] MBasic State
	BEQ	MBasicSelect

	CMP	#'V'			; compare with [V] VTL State
	BNE	Reset

VTLSelect:
	CLC					; Clear the Carry
	PHP					; Push the status word
	BCC RAMSelect		; Always taken

MBasicSelect:
	SEC					; Set the Carry
	PHP					; Push the status word

RAMSelect:
	LDY #0
RAMSelect_01:
	LDA	RAMTypeMessage,Y
	BEQ	RAMSelect_02
	JSR	MONCOUT
	INY
	BNE	RAMSelect_01
RAMSelect_02:

SelectKWait:
	JSR	MONRDKEY
	BCC	SelectKWait
	
	AND	#$DF			; Make upper case
	CMP	#'W'			; compare with [W]arm start
	BEQ	WarmStart

	CMP	#'C'			; compare with [C]old start
	BNE	Reset

ColdStart:
	PLP					; Restore the Carry
	BCC	ColdStartVTL
ColdStartMBasic:
	JMP	COLD_START		; VTL cold start
ColdStartVTL:
	JMP vtl_reset

WarmStart:
	PLP					; Restore the Carry
	BCC	WarmStartVTL
WarmStartMBasic:
	JMP RESTART
WarmStartVTL:
	JMP	vtl_start		; VTL02 warm start

MONCOUT:
	PHA
SerialOutWait:
	LDA	ACIAStatus
	AND	#2
	CMP	#2
	BNE	SerialOutWait
	PLA
	STA	ACIAData
	RTS

MONRDKEY:
	LDA	ACIAStatus
	AND	#1
	CMP	#1
	BNE	NoDataIn
	LDA	ACIAData
	SEC		; Carry set if key available
	RTS
NoDataIn:
	CLC		; Carry clear if no key pressed
	RTS

MONISCNTC:
	JSR	MONRDKEY
	BCC	NotCTRLC ; If no key pressed then exit
	CMP	#3
	BNE	NotCTRLC ; if CTRL-C not pressed then exit
	SEC		; Carry set if control C pressed
	RTS
NotCTRLC:
	CLC		; Carry clear if control C not pressed
	RTS

StartupMessage:
	.byte	$0C,"MBasic [M] or VTL02 [V] start?",$0D,$0A,$00

RAMTypeMessage:
	.byte	"Cold [C] or warm [W] start?",$0D,$0A,$00

LOAD:
	RTS

SAVE:
	RTS