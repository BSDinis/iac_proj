; interface module
; 


SP_INICIAL	EQU	FDFFh ; stack pointer
IO_READ		EQU	FFFFh ; input janela de texto
IO_WRITE	EQU	FFFEh ; output janela de texto
IO_STATUS	EQU	FFFDh ; testa se foi premida tecla na janela de texto
IO_CONTROL	EQU	FFFCh ; posiciona o cursor na janela de texto
IO_SW  		EQU	FFF9h ; 8 interruptores (alavancas)
IO_LEDS		EQU	FFF8h ; 16 leds (1 por bit)
LCD_WRITE	EQU	FFF5h ; escreve caracter no display
LCD_CONTROL	EQU	FFF4h ; colocar o cursor no display
IO_DISPLAY	EQU	FFF0h ; display de 7 leds
TEMP		EQU	FFF7h ; start/stop temporizador
TEMP_VALUE	EQU	FFF6h ; valor para gerar interrupção
INT_MASK_ADDR	EQU	FFFAh
INT_MASK	EQU	8001h 
NL		EQU	000ah ; codigo ascii do caracter newline
ZERO		EQU	'0' ; codigo ascii do zero


		ORIG	8000h
best_score	TAB	1 
current_score	TAB	1 ; numero de jogadas ate ao momento
time_remaining	TAB	1 ; tempo para acabar a jogada


init_game	STR	'Carregue no botao IA para iniciar@'


		ORIG	0000h
                JMP	start

;;print_digit: imprime um digito na JV;;
print_digit:	PUSH	R1  ;preserva o R1

		MOV	R1, M[SP + 3]  ;coloca o caracter em R1
		ADD	R1, '0'  ;converte para ascii
                MOV	M[IO_WRITE], R1  ;imprime
                POP	R1  ;restora o R1
                RETN	1
 




                           
start:		MOV	R1, SP_INICIAL
		MOV	SP, R1
                MOV	R1, 1010
		MOV	M[time_remaining], R1
                CALL	display_time


end:		BR	end
		
