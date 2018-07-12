; check Module

;zone 1: constants

filtro		EQU	000fh; f000h
sp_inicial     	EQU	fdffh

;zone 2: variables

		ORIG	8000h

Xes		WORD	0h
Oes		WORD	0h
Guess		WORD	1234h
Code		WORD	1422h



;zone 3: code

		ORIG	0000h
		JMP	start


;; check: verifica o resultado da jogada, comparando-a com o codigo ;;
check_direct:  	MOV	R1, 4 
		ADD	M[SP + 6], R1 ; <8 bits a 0> + <'X's>
                BR	check_ret


check:		PUSH	R1 ; preserva R1
		PUSH	R2 ; preserva R2
		MOV	R1, M[SP + 5] ; R1 <- Guess

		CMP	R1,  M[SP + 4] ; compara a jogada com o codigo
		BR.Z	check_direct

                MOV	R2, M[SP + 4] ; R2 <- Code
                PUSH	R0 ; Resposta
                PUSH	R1 ; Guess
                PUSH	R2 ; Code
		CALL	check_xes
                POP	R1
		MOV	M[SP + 6], R1 ; X's
		MOV	R1, M[SP + 5] ; R1 <- Guess

		PUSH	R0 ; Resposta
                PUSH	R1 ; Guess
                PUSH	R2 ; Code
		CALL	check_oes
		POP	R1
                SUB	R1, M[SP + 6] ; retira os valores que foram contados em check_xes
                ROR	R1, 8 ; coloca a resposta no octeto mais significativo de R1
		MVBH	M[SP + 6], R1 ; O's

check_ret:	POP	R2 ; recupera R2
		POP	R1 ; recupera R1
		RETN	2

;check_xes: calcula quanto digitos na posicao certa estao na jogada ;
check_xes:      PUSH	R1 ; preserva R1 
		PUSH	R2 ; preserva R2
		PUSH	R3 ; preserva R3
		PUSH	R4 ; preserva R4
		PUSH	R5 ; preserva R5

		MOV	R1, 4 ; contador ciclo
		MOV	R2, R0 ; contador X's 
                MOV	R3, filtro ; filtro

ciclo_xes:   	MOV	R4, M[SP + 8] ; recupera a jogada
		MOV	R5, M[SP + 7] ; impede R2 de ser destuido / recupera o codigo

                AND	R4, R3 ; aplica o filtro
                AND	R5, R3 ; aplica o filtro
                CMP	R4, R5
                BR.NZ	salto_xes

                INC 	R2 ; incrementa o contador

salto_xes:      ROR	R3, 4 ; muda o filtro de posicao
		DEC	R1
                BR.NZ	ciclo_xes

                MOV	M[SP + 9], R2 ; retorna a resposta

                POP	R5 ; recupera R5
                POP	R4 ; recupera R4
                POP	R3 ; recupera R3
                POP	R2 ; recupera R2
                POP	R1 ; recupera R1
                RETN	2


;;check_oes: calcula o numero de digitos corretos que estao na jogada,
            ;independentemente se estao na posicao correta ou nao
check_oes:	PUSH	R1 ; preserva o R1
		PUSH	R2 ; preserva o R2
		PUSH	R3 ; preserva o R3
                PUSH	R4 ; preserva o R4
                PUSH	R5 ; preserva o R5

		MOV	R1, 4; contador do ciclo
                MOV	R2, M[SP + 7] ; R4 <- Code
                MOV	R3, filtro
		MOV	R4, R0 ; contador dos O's

ciclo_oes:	MOV	R5, M[SP + 8] ; R5 <- Guess

		AND	R5, R3 ; isola um digito
                PUSH	R0 
                PUSH	R2 ; R2 vai ser alterado, propositadamente, para evitar repeticao de contagem
                PUSH	R5 ; R5 passou a ser livre
                PUSH	R3 ; filtro
                CALL	check_digit 
                POP	R5
                ADD	R4, R5 ; atualiza o resultado

                ROR	R3, 4 ; altera a posicao do filtro
                DEC	R1
                BR.NZ	ciclo_oes

                MOV	M[SP + 9], R4 ; escreve o valor de retorno
                POP	R5 ; recupera R5
                POP	R4 ; recupera R4
                POP	R3 ; recupera R3
                POP	R2 ; recupera R3
                POP	R1 ; recupera R1
                RETN	2

;;check_digit: verifica se o parametro e um digito do codigo que nao foi encontrado antes 
              ;retorna 1 se a verificacao for verdadeira, senao retorna 0
check_digit:    PUSH	R1 ; preserva R1 ; nao preserva o de R2, para saber quais digitos ja foram retirados
		PUSH	R3 ; preserva R3

                MOV	R1, 4 ; contador
                MOV	R2, M[SP + 6] ; R2 <- Code - valores previamente encontrados na funcao
                
ciclo_digit:	MOV	R3, R2
		AND	R3, M[SP + 4] ; aplica filtro

                CMP	R3, M[SP + 5] ; verifica se o digito e igual
                BR.NZ	salto_digit
                INC	M[SP + 7] ; incrementa o valor de retorno, passa a 1
                OR	R2, M[SP + 4] ; coloca-se o digito a f_h
                BR	ret_digit

salto_digit:	ROR	M[SP + 4], 4 ; atualiza a posicao do filtro
		ROR	M[SP + 5], 4 ; atualiza a posicao do digito
		DEC	R1
		BR.NZ	ciclo_digit

ret_digit:	POP	R3 ; recupera R3
		POP	R1 ; recupera R1
                RETN	3

		
		
;;;;;;;;;;;;;


start:		MOV	R1, sp_inicial
		MOV	SP, R1

		MOV	R1, M[Guess]
		MOV	R2, M[Code]

		PUSH	R0
		PUSH	R1
		PUSH	R2
		CALL	check
		POP	R1

end:		BR	end
