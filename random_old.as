; random Module


; zone1: constants

inicial		EQU	3004d ; semente para o gerador, tem de ser alterada
Mask   		EQU	1000000000010110b
sp_inicial	EQU	fdffh

; zone2: variables

; zone3: code

	        ORIG	0000h
                JMP	start

;;random: gera um numero pseudoaleatorio, sendo a semente a constante inicial
random:   	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2
		PUSH	R3 ; preserva o R3
		PUSH	R4 ; preserva o R4
		PUSH	R5 ; preserva o R5

		MOV	R1, 4 ; contador
		MOV	R2, inicial ;
                MOV	R3, R0 ; numero gerado
		MOV	R4, Mask

rand_cycle:	ROL	R3, 4 ; gera espaco para o proximo digito
                MOV	R5, 6 

                TEST	R2, 1
                BR.Z	jump
	        XOR	R2, R4 

jump:		ROR	R2, 1
                MOV	R6, R2 ; preserva o R2
		DIV	R6, R5 ; garante que o valor esta entre 0 e 5
                INC	R5 ; garante que o resultado esta entre 1 e 6
		ADD	R3, R5 ;Devolve o resultado para o numero de 4 algarismos

                DEC	R1
                BR.NZ	rand_cycle

                MOV	M[SP + 7], R3
                POP	R1 ; preserva o R1
                POP	R2 ; preserva o R2
                POP	R3 ; preserva o R3
                POP	R4 ; preserva o R4
                POP	R5 ; preserva o R5
                RET                       

;;;;;;;;;;;;;;;;start;;;;;;;;;;;;;;;;
start:	        MOV	R1, sp_inicial
		MOV	SP, R1

		PUSH 	R0
		CALL	random
                POP	R1

end:            BR end

