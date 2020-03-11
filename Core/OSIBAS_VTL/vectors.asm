.import Reset

.segment "VECTS"
	.word	Reset		; NMI 
	.word	Reset		; RESET 
	.word	Reset		; IRQ 