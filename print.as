; print Module

; zone 1: constants

IO		EQU	fffeh ; fimereco para colocar o output
NL		EQU	000ah ; codigo ascii do caracter newline
filtro		EQU	0007h  
sp_inicial	EQU	fdffh

; zone 2: variables

		ORIG	8000h

Result		WORD	0201h
Guess		WORD	0000011010110001b
Code		WORD	0000011010110001b


; zone 3: code

		ORIG	0000h
                JMP	inicio

;;print_char: imprime um caracter na JV;;
print_char:	PUSH	R1  ;preserva o R1

		MOV	R1, M[SP + 3]  ;coloca o caracter em R1
		MOV	M[IO], R1  ;imprime
                POP	R1  ;restora o R1
                RETN	1  

;;print_digit: imprime um digito na JV;;
print_digit:	PUSH	R1  ;preserva o R1

		MOV	R1, M[SP + 3]  ;coloca o caracter em R1
		ADD	R1, '0'  ;converte para ascii
                MOV	M[IO], R1  ;imprime
                POP	R1  ;restora o R1
                RETN	1

;;print_guess: imprime um numero com 4 digitos em 3 bits, a começar no 12;;
print_guess:	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2
		PUSH	R3 ; preserva o R3
              
		MOV	R1, M[SP + 5] ; coloca o parametro em R1
                ROL	R1, 4 ; "encosta" o numero à esquerda
                MOV	R2, 4  ; contador

guess_ciclo:	ROL	R1, 3 ;coloca o digito mais significativo na posição menos significativa
		MOV	R3, R1 ;preserva o R1
                AND	R3, filtro ;coloca em R3 o digito menos significativo
                PUSH	R3
                CALL	print_digit ;imprime R3

                DEC	R2
                BR.NZ	guess_ciclo

		POP	R3 ;restora o R3
		POP	R2 ;restora o R2
		POP	R1 ;restora o R1
                RETN	1

;;print_count: imprime o contador, em decimal, com 2 digitos
print_count:	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2

		MOV	R1, M[SP + 4] ; coloca o parametro em R1
                MOV	R2, 10d 
                DIV	R1, R2 ; em R1 está o algarismo das dezenas e em R2 as unidades

		BR.Z	unidades ; verifica se o algarismo das dezenas e zero
                PUSH	R1
                CALL	print_digit ; imprime algarismo das dezenas

unidades:	PUSH	R2
                CALL	print_digit ; imprime algarismo das unidades

		POP	R2 ; restora o R2
                POP	R1 ; restora o R1
                RETN	1

;;print_result: imprime o resultado da jogada
print_result:	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2
		PUSH	R3 ; preserva o R3

		MOV	R1, M[SP + 6] ; R1 <- #Xes 
		MOV	R2, M[SP + 5] ; R2 <- #Oes 
                MOV	R3, 4 ; numero de tracos a colocar
                SUB	R3, R1 ; subtrai o numero de X's                          
                SUB	R3, R2 ; subtrai o numero de O's

print_xes:	CMP	R1, R0
		BR.Z	print_oes ; verifica se o contador esta em 0

                PUSH	'X'
                CALL	print_char ; imprime 'X'
                DEC	R1
                BR	print_xes

print_oes:	CMP	R2, R0
		BR.Z	print_dash  ; verifica se o contador esta em 0

                PUSH	'O'
                CALL	print_char  ; imprime 'O'
                DEC	R2
                BR	print_oes

print_dash:	CMP	R3, R0  
		BR.Z	ret_result  ; verifica se o contador esta em 0

                PUSH	'-'
                CALL	print_char ; imprime '-'
                DEC	R3
                BR	print_dash

ret_result:	PUSH	NL
                CALL	print_char ; imprime um <newline>

                POP	R3 ; restora o R3
                POP	R2 ; restora o R2
                POP	R1 ; restora o R1
                RETN	2

;;print_line: imprime uma linha, ou seja, o resultado de uma ronda do programa;;
print_line:	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2

		MOV	R1, M[SP + 4] ; contador de jogada
		PUSH 	R1
                CALL	print_count ; imprime o contador

                PUSH	':'
                CALL	print_char

                PUSH	' '
                CALL	print_char

		MOV	R1, M[SP + 5] ; guess
                PUSH	R1
                CALL	print_guess ; imprime a jogada , o guess

                PUSH	':'
                CALL	print_char

                PUSH	' '
                CALL	print_char

                MOV	R1, M[SP + 6] ; R1 <- #Xes
                MOV	R2, M[SP + 7] ; R2 <- #Oes
                PUSH	R1
                PUSH	R2
                CALL	print_result ; imprime resultado

		POP	R2 ; restora o R2
		POP	R1 ; restora o R1
                RETN 4


;;;;;;;;;;;;;;;main;;;;;;;;;;;;;;;;;;
inicio:		MOV	R1, sp_inicial
		MOV	SP, R1

		MOV	R1, 1

ciclo:		MOV	R2, R0 ; limpa o R2
		MVBH	R2, M[Result] ; Oes
		ROR	R2, 8 ; coloca o octeto na posicao correta
		MVBL	R3, M[Result] ; Xes
                PUSH	R2
                PUSH	R3
                PUSH	M[Guess]
		PUSH	R1 ; coloca o contador para impressao
                CALL	print_line

		INC	R1
                CMP	R1, 13 ; o contador comeca a 1
                BR.NZ	ciclo

fim:		BR	fim
