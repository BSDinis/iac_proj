; timer module
;
; Implementa a função start_timer em que é inicializado um temporizador que atualiza
; de n em n milissegundos, dependendo do parâmetro de entrada.
;
; Output fica em memória

;TODO
;separar isto em funções
;integrar


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
INT_MASK	EQU	8000h 



                              
		ORIG	FE0Fh
INTF		WORD	INTFF

		ORIG	8000h
timer		TAB	1
time_remaining	WORD	ffffh


		ORIG	0000h
		JMP	inicio

INTFF:	       	PUSH	R1 ; preserva o R1
		INC	M[timer]          ;incrementa o timer de 1 em 1 segundo
		;reinicia o temporizador
		MOV 	R1, 1 ; podemos alterar com um valor em memoria
		MOV	M[TEMP_VALUE], R1
		MOV	R1, 1
		MOV	M[TEMP], R1
		POP 	R1
		RTI


;; diplay_time: int -> void
;;
;; mostra o tempo que falta nos LEDS
;;
;; input: o tempo que falta, endereçado em time_remaining
display_time:	PUSH	R1 ; preserva o R1
		MOV	R1, M[time_remaining]
                MOV	M[IO_LEDS], R1
                POP	R1
                RET
        	
start_timer:	PUSH	R1 ; preserva o R1
		MOV	R1, 1
		MOV     M[TEMP_VALUE], R1
		MOV	R1, 1
		MOV	M[TEMP], R1
                POP	R1
                RET

reset_timer:	MOV	M[timer], R0
		MOV	M[TEMP], R0 ; disable o temporizador
                RET



inicio:		MOV	R1, SP_INICIAL
		MOV	SP, R1
		MOV	R1, INT_MASK
		MOV	M[INT_MASK_ADDR], R1
                CALL	display_time

		ENI

                MOV 	R1, M[time_remaining]

led_cycle:    	CALL	reset_timer
                CALL	start_timer
timer_cycle:    MOV	R2, 5
                CMP	M[timer], R2
                BR.NZ	timer_cycle
                SHR	R1, 1
	        MOV	M[time_remaining], R1 
                CALL	display_time
                BR.NZ	led_cycle


                DSI
                   
end:		BR	end	
