				PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
__Vectors
				DCD  0x20001000     ; stack pointer value when stack is empty
				DCD  Reset_Handler  ; reset vector

				AREA	myCode, CODE, READONLY
;**********************************************************************************
GPIOC_CRL   	EQU     0x40011000
GPIOC_CRH   	EQU     0x40011004
GPIOC_IDR   	EQU     0x40011008
GPIOC_ODR   	EQU     0x4001100C
GPIOC_BSRR  	EQU     0x40011010
GPIOC_BRR   	EQU     0x40011014
GPIOC_LCKR  	EQU     0x40011018
RCC_AHB1ENR		EQU		0x40023830
GPIOA_MODER		EQU		0x40020000
GPIOB_MODER		EQU		0x40020400
GPIOA_OSPEEDR	EQU		0x40020008
GPIOB_OSPEEDR	EQU		0x40020408
GPIOA_PUPDR 	EQU		0x4002000C
GPIOB_PUPDR		EQU		0x4002040C
GPIOB_OTYPER	EQU		0x40020404

;**********************************************************************************

				
				ENTRY
Reset_Handler

;**********************************************************************************
; You'd want code here to enable GPIOC clock in AHB

			MOV32 R0, #RCC_AHB1ENR
			LDR   R1, [R0]
			ORR   R1, R1, #3
			STR   R1, [R0]
			
			MOV32 R0, #GPIOA_MODER
			LDR   R1, [R0]
			AND   R1, R1, #0xFFFFFFFC
			STR   R1, [R0]
			
			MOV32 R0, #GPIOB_MODER
			LDR   R1, [R0]
			ORR   R1, R1, #4
			STR   R1, [R0]
			
			
			

			MOV  R8, #15				; register used for counting in rows
			MOV  R9, #15				; register used for counting in clomns
			MOV32 R10, ROW		; R0, R1, R2 points to the first array of first three rows
			LDR  R0, [R10]
			ADD  R10, R10, #4
			LDR  R1, [R10]
			ADD  R10, R10, #4
			LDR  R2, [R10]
			LDRB R3, [R0]
			LDRB R4, [R1]
			LDRB R5, [R2]

			
			LDR R11, =0x40010000 		; addres memory which we want to store the risults
			
LOOP1	
			MOV  R6, #0					; R6 holds the sum of each kernel which is apllied
			LDRB R3, [R0], #1
			ADD  R6, R6, R3 			; start of applying [1 2 1] to the three arrays in row1 and so on
			LDRB R3, [R0], #1
			ADD  R6, R6, R3, LSL #1
			LDRB R3, [R0], #-1
			ADD  R6, R6, R3
			LDRB R4, [R1], #1
			ADD  R6, R6, R4, LSL #1		; start of applying [2 4 2] to the three arrays in row2 and so on	
			LDRB R4, [R1], #1
			ADD  R6, R6, R4, LSL #2		
			LDRB R4, [R1], #-1
			ADD  R6, R6, R4, LSL #1
			LDRB R5, [R2], #1
			ADD  R6, R6, R5				; start of applying [1 2 1] to the three arrays in row3 and so on
			LDRB R5, [R2], #1
			ADD  R6, R6, R5, LSL #1
			LDRB R5, [R2], #-1
			ADD  R6, R6, R5
			MOV  R6, R6, LSR #4
			STR  R6, [R11], #1
			SUBS R8, R8, #1 			; check if we finish one 3*1 rows or not (15 times)
			BNE  LOOP1					; if not start applying kernel on next arrays of same rows
			MOV  R8, #15
			ADD  R0, R0, #2				; if it is finished so each row should be added 2 to skip the padding and edge 
			ADD  R1, R1, #2
			ADD  R2, R2, #2
			SUBS R9, R9, #1				; check if we,re not run out of number (15*15 times from the beginning)
			BNE  LOOP1					; if we,re not start over
			
			
	
	; KERNEL LABE
	
							
	
			MOV  R8, #15				; register used for counting in rows
			MOV  R9, #15				; register used for counting in clomns
			MOV  R12, #0			
			MOV32 R10,RROW 
			LDR  R0, [R10], #4				; R0, R1, R2 points to the first array of first three rows
			ADD  R0, R0, #1
			LDR  R1, [R10], #4
			LDR  R2, [R10]
			ADD  R2, R2, #1
			
LOOP2 		MOV  R6, #0
			LDRB R3, [R0], #1			; after we load r1, r0 increases by one
			ADD  R6, R6, R3
			LDRB R4, [R1], #1
			ADD  R6, R6, R4
			LDRB R4, [R1], #1
			MOV  R4, R4, LSL #2
			SUBS R4, R12, R4
			ADD  R6, R6, R4
			LDRB R4, [R1], #-1
			ADD  R6, R6, R4
			LDRB R5, [R2], #1
			ADD  R6, R6, R5
			MOV  R6, R6, LSR #2
			ADD  R6, R6, #64
			STR  R6, [R11], #1			; this kernel stores after the first one
			SUBS R8, R8, #1
			BNE  LOOP2
			MOV  R8, #15
			ADD  R0, R0, #2				; if it is finished so each row should be added 2 to skip the padding and edge 
			ADD  R1, R1, #2
			ADD  R2, R2, #2
			SUBS R9, R9, #1				; check if we,re not run out of number (15*15 times from the beginning)
			BNE  LOOP2
			
loop	 B       loop
			

			
		; noisy

		
ROW   DCD ROW1,ROW2,ROW3,ROW4,ROW5,ROW6,ROW7,ROW8,ROW9,ROW10,ROW11,ROW12,ROW13,ROW14,ROW15,ROW16,ROW17	
ROW1  DCB 129,129,109,153,143,118,158,144,42,102,175,157,133,114,177,72,72 
ROW2  DCB 129,129,109,153,143,118,158,144,42,102,175,157,133,114,177,72,72 
ROW3  DCB 102,102,110,157,109,97,111,114,6,102,99,86,122,122,183,151,151	
ROW4  DCB 83,83,107,103,133,137,39,130,2,103,110,75,93,94,135,121,121
ROW5  DCB 105,105,99,144,81,116,80,125,48,102,107,108,77,95,100,108,108	
ROW6  DCB 95,95,100,66,85,108,66,126,22,71,53,98,88,147,137,100,100
ROW7  DCB 192,192,73,79,119,119,136,113,7,112,85,80,141,132,36,87,87
ROW8  DCB 144,144,144,135,122,172,122,118,0,137,101,140,85,102,127,118,118
ROW9  DCB 32,32,28,27,0,25,0,29,42,38,14,0,34,0,0,59,59
ROW10 DCB 114,114,130,100,184,113,124,97,8,104,151,58,62,65,120,140,140
ROW11 DCB 122,122,44,116,78,82,141,93,0,111,57,63,99,61,110,139,139
ROW12 DCB 116,116,107,169,45,159,106,123,0,112,121,97,116,133,101,102,102
ROW13 DCB 68,68,40,158,88,100,143,115,57,141,153,114,48,62,117,81,81
ROW14 DCB 137,137,69,78,117,106,85,126,19,91,87,82,100,82,83,112,112
ROW15 DCB 145,145,144,132,95,121,148,85,67,72,166,153,87,80,77,127,127
ROW16 DCB 131,131,141,166,134,171,129,128,9,112,116,74,113,73,64,122,122
ROW17 DCB 131,131,141,166,134,171,129,128,9,112,116,74,113,73,64,122,122

		



		
RROW   DCD RROW1,RROW2,RROW3,RROW4,RROW5,RROW6,RROW7,RROW8,RROW9,RROW10,RROW11,RROW12,RROW13,RROW14,RROW15,RROW16,RROW17
RROW1  DCB 129,129,124,130,126,127,122,129,14,128,118,125,128,130,138,125,125
RROW2  DCB 129,129,124,130,126,127,122,129,14,128,118,125,128,130,138,125,125
RROW3  DCB 112,112,99,145,131,99,117,128,29,118,93,111,119,133,158,145,145
RROW4  DCB 105,105,97,104,111,134,96,127,11,125,114,98,109,129,114,129,129
RROW5  DCB 107,107,109,117,92,81,105,129,6,126,111,93,78,121,105,118,118
RROW6  DCB 101,101,99,75,101,100,108,122,0,125,76,79,90,94,122,118,118
RROW7  DCB 120,120,71,68,112,116,125,114,1,125,90,75,115,103,79,99,99
RROW8  DCB 129,129,126,127,126,130,128,118,2,115,115,111,119,129,127,128,128
RROW9  DCB 16,16,25,15,18,4,1,4,35,6,7,7,18,20,14,21,21
RROW10 DCB 128,128,126,128,128,127,115,118,8,125,120,87,90,108,96,122,122
RROW11 DCB 129,129,93,91,104,76,97,129,6,121,96,80,89,109,116,113,113
RROW12 DCB 129,129,117,102,91,108,90,128,14,115,108,111,105,90,109,100,100
RROW13 DCB 125,125,94,117,78,124,124,124,29,113,117,115,106,80,100,100,100
RROW14 DCB 120,120,95,81,119,87,103,127,31,109,111,111,87,86,86,114,114
RROW15 DCB 120,120,103,113,125,109,124,121,9,101,86,118,104,100,78,117,117
RROW16 DCB 128,128,128,130,145,127,123,123,0,114,95,93,112,84,105,122,122
RROW17 DCB 128,128,128,130,145,127,123,123,0,114,95,93,112,84,105,122,122






		

;**********************************************************************************
			END
				