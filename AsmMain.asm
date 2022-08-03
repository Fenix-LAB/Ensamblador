;********TAREA 2*******************
#include "p16f877a.inc"
;DECLARACION DE "VARIABLES"
#define B1 PORTE,0
#define B2 PORTE,2  
#define SPR PORTB,0 
#define SPA PORTB,1
#define SPV PORTB,2
#define SAR PORTB,7
#define SAA PORTC,0
#define SAV PORTC,1    
; CONFIG
; __config 0xFF39
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
 ORG 0x00
 GOTO START
START
 ;**********VARIABLES DE RETARDOS***************
DCounter1 EQU 0X0C
DCounter2 EQU 0X0D
DCounter3 EQU 0X0E
;*****CONFIGURACION*******
 BCF STATUS,RP1 ;banco de memoria1
 BSF STATUS,RP0 ;cambiamos a banco 1 de mem
 
 MOVLW b'10000101'   ;COnfiguracion de TMR0
 MOVWF OPTION_REG    ;DIerccion del registro option reg para configurar el TMR0
 CLRF PORTB    ;todo puerto B salida
 CLRF PORTC    ;todo el puerto C salida
 CLRF PORTD    ;todo el puerto D salida
 BSF B1         ;Pin 0 del puerto E como entrada
 BSF B2         ;Pin 2 del puerto E como entrada
 MOVLW b'10001110' ;Configuracion para el registro ADCON!
 MOVWF ADCON1      ;COnfiguracion para el ADC en A0
 
 BCF STATUS, RP1 ;BAnco de momoria1
 BCF STATUS,RP0 ;cambiamos a banco 0 de mem
 ;************************* 
 ;********MAIN*************
 MOVLW b'11000001'  ;Literal de la configurcion del registro adcon
 MOVWF ADCON0       ;Reh¿gistro ADCON del banco de memoria 0
 CLRF PORTB         ;MAndamos ceros a los puerto B;C y D
 CLRF PORTC 
 CLRF PORTD
 ;*******CODIGO PARA LOS BOTONES**************
 BTFSC B1
 GOTO UNO
 GOTO CERO
 
UNO
 BTFSC B2
 GOTO FUNCION4
 GOTO FUNCION3
 
CERO
 BTFSC B2
 GOTO FUNCION2
 GOTO FUNCION1
;****************FUNCIONES*******************
;****************BLINK***********************
FUNCION1
ST
 BSF PORTB,0         ;Apagamos es pin 0 del Puerto B
 CALL RETARDO        ;Llamamos al retardo
 BCF PORTB,0         ;APagamos el pin 0
 CALL RETARDO        ;VOlvemos a llamar el Retardo
 GOTO ST             ;Por medio de este GOTO creamos un buble para que se este ejecuntando indefinidamente
 ;***************RUTINA DE RETARDO***************
RETARDO                  ;DEfinicion de nustro retardo
 BSF ADCON0,GO_DONE      ;MAndamos un 1 al bit GO_DONE del registro ADCON0 Para iniciar  la conversion del ADC
REGRESO1 
 BTFSC ADCON0,GO_DONE    ;Preguntamos para saber cuando se ha terminado la conversion
 GOTO REGRESO1           
 BSF STATUS,RP0          
    MOVF 0x9E,0          ;Nos dirigimos al registro ADRESL ahi se encuantran los 8 bits del ADC que se encuantra en el bamco de memoria 1 y tomamos los bits y paamos al registro de trabajo
 BCF STATUS,RP0
 ;MULLW
 MOVWF TMR0              ;Ahora los bits del registro de trabajo que son los valores del ADC, se los psamos a TMR0 para que haga un conteo en base al ADC
 BCF INTCON,T0IF         ;Mansamos un 0 al bit T0IF para iniciar el conteo
DESBORDE
 BTFSS INTCON,T0IF       ;Pereguntamos para saber cuando a terminado el conteo
 GOTO DESBORDE
 RETURN
 ;************SEMAFORO***************************
FUNCION2 
INICIO
 BTFSC B1         ;Verificamos el estado del boton 1 para desidir a cual rutina nos vamos a dirigir
 GOTO BOTONP      ;Si esta en 1 nos vamos a la rutina del semaforo peatonal
 CALL NORMALF     ;si no esta presionado entonces se hace la funcion normal del semaforo de los autos
 GOTO INICIO      ;Este GOTO nos permite tener un bucle indefinido
 
NORMALF           ;Esta es la secuancia de encendidos y apagados que nossotros quisimos usar
 BCF SAR
 BSF SAV
 CALL DELAY1     ;Aqui llamamos el delay que esta configurado a 1s, lo llamamos 3 veces para tener 3s
 CALL DELAY1
 CALL DELAY1
 BCF SAV
 CALL DELAY1
 BSF SAV
 CALL DELAY1
 BCF SAV
 CALL DELAY1
 BSF SAV
 CALL DELAY1
 BCF SAV
 BSF SAA
 CALL DELAY1
 CALL DELAY1
 BCF SAA
 BSF SAR
 CALL DELAY1
 CALL DELAY1
 CALL DELAY1
 RETURN
 ;*****nUMEROS ALREVES**************
BOTONP                      ;Esta es la secuencia del semaforo para los peatones, en esta ya se usa el display para hacer un contador descendente
 BCF SPR
 BSF SPV
 BSF SAR
 MOVLW b'01101111' ;9
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01111111' ;8
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'00000111' ;7
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01111101' ;6
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01101101' ;5
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01100110' ;4
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01001111' ;3
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'01011011' ;2
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'00000110' ;1
 MOVWF PORTD
 CALL DELAY1
 MOVLW b'00111111' ;0
 MOVWF PORTD
 CALL DELAY1
 CLRF PORTB
 CLRF PORTC
 CLRF PORTD
 RETURN
 
DELAY1                    ;Este es el codigo del delay tomado de "DELAY CODE GENERATOR"
 MOVLW 0Xac
 MOVWF DCounter1
 MOVLW 0X13
 MOVWF DCounter2
 MOVLW 0X06
 MOVWF DCounter3
LOOP
 DECFSZ DCounter1, 1
 GOTO LOOP
 DECFSZ DCounter2, 1
 GOTO LOOP
 DECFSZ DCounter3, 1
 GOTO LOOP
 NOP
 RETURN
  
 ;***********VALORES DEL ADC*********************
FUNCION3
START2 
 BSF ADCON0,GO_DONE     ;MAndamos un 1 al bit GO_DONE del registro ADCON0 Para iniciar  la conversion del ADC
REGRES 
 BTFSC ADCON0,GO_DONE   ;Preguntamos para saber cuando se ha terminado la conversion
 GOTO REGRES
 GOTO IR
IR
 MOVF ADRESH,0          ;Cuando la conversion termine nos dirigimos al registro ADRESH para tomar los 2 bits de la conversion, los movemos al registro de trabajo
 MOVWF PORTC            ;Los dos bits los mostramos en el puerto C
 BSF STATUS,RP0
    MOVF ADRESL,0       ;Nos dirigimos al registro ADRESL ahi se encuantran los 8 bits del ADC que se encuantra en el bamco de memoria 1 y tomamos los bits y paamos al registro de trabajo
 BCF STATUS,RP0
 MOVWF PORTB            ;Ahora los 8 bits los pasamos al Puerto B
 CALL DELAY2             ;Llamamos al delay qeu es de 10ms
 GOTO START2            ; COn este GOTO creamos un bucle infinito
 
DELAY2                   ;DELAY de 10ms
 MOVLW 0Xfa
 MOVWF DCounter1
 MOVLW 0X0d
 MOVWF DCounter2
LOOP5
 DECFSZ DCounter1, 1
 GOTO LOOP5
 DECFSZ DCounter2, 1
 GOTO LOOP5
 NOP
 RETURN
 
 ;**************CONTADOR******************+
FUNCION4
 MOVLW 0X00 ; INICAMOS EL REGISTRO W EN 0
 MOVWF 0x20 ; GUARDAMOS EL 0 EN EL BANCO DE MEMORIA 1
START1
 CALL MOSTRAR; LLAMAMOS A LA FUNCION PARA QUE SE EJECUTE
 
BOTONES
 CALL DELAY3
 MOVLW 0X00 ; RESETEAMOS EL VALOR DE W A 0
 IORWF 0X20,0 
 BTFSC B1; VALOR DE B1 EN 0?
 GOTO F1; FALSO
 GOTO F2; VERDADERO
 GOTO START1; VOLVEMOS AL INICIO DEL PROGRAMA
F1
 BTFSC B2 ; B2 EN 0?
 GOTO MOSTRAR; FALSO
 GOTO SUMAR; VERDADERO
 
F2
 BTFSC B2
 GOTO RESTAR
 GOTO START1
 
SUMAR
 XORLW 0X0F ;COMPARAR EL VALOR DE W CON 16 YA QUE SI ES 16 NO DEBE PASAR
 BTFSC STATUS,Z;; Z=0?
 GOTO BOTONES;FALSO
 INCF 0X20,0 ; SUMAMOS UN 1 HEX AL VALOR DE W QUE SE TENIA
 MOVWF 0X20 ; GUARDAMOS EL VALOR DE W EN RP1
 GOTO START1
 
RESTAR 
 DECFSZ 0X20,0 ; DECREMENTAMOS EL VALOR GUARDADO EN RP1 EN 1 Y SE GUARDA EN W
 MOVWF 0X20; GUARDAMOS ESE VALOR EN RP1
 GOTO START1
 ;********** Funcion que revisa en que valor se encuentra W para imprimir en los 7 segmentos*******
MOSTRAR
 XORLW 0X00 ; HACEMOS UNA XOR A W CON EL VALOR 0
 BTFSC STATUS,Z; SI FLAG SALTA SIGNIFICA QUE W Y 0 ERAN IGUALES
 CALL LABEL0 ; VAMOS A LA FUNCION QUE MANDA A LOS 7 SEGMENTOS
 XORLW 0X00^0X01 ; HACEMOS UNA XOR A W CON EL RESULTADO DE 0 XOR 1 y el ciclo continua asi hasta el 15
  BTFSC STATUS,Z
 CALL LABEL1
 XORLW 0X01^0X02
  BTFSC STATUS,Z
 CALL LABEL2
 XORLW 0X02^0X03
  BTFSC STATUS,Z
 CALL LABEL3
 XORLW 0X03^0X04
  BTFSC STATUS,Z
 CALL LABEL4
 XORLW 0X04^0X05
  BTFSC STATUS,Z
 CALL LABEL5
 XORLW 0X05^0X06
  BTFSC STATUS,Z
 CALL LABEL6
 XORLW 0X06^0X07
  BTFSC STATUS,Z
 CALL LABEL7
 XORLW 0X07^0X08
  BTFSC STATUS,Z
 CALL LABEL8
 XORLW 0X08^0X09
  BTFSC STATUS,Z
 CALL LABEL9
 XORLW 0X09^0X0A
  BTFSC STATUS,Z
 CALL LABEL10
 XORLW 0X0A^0X0B
  BTFSC STATUS,Z
 CALL LABEL11
 XORLW 0X0B^0X0C
  BTFSC STATUS,Z
 CALL LABEL12
 XORLW 0X0C^0X0D
 BTFSC STATUS,Z
 CALL LABEL13
 XORLW 0X0D^0X0E
  BTFSC STATUS,Z
 CALL LABEL14
 XORLW 0X0E^0X0F
 BTFSC STATUS,Z
 CALL LABEL15
 GOTO BOTONES
 
LABEL0; Imprime 0
 MOVLW b'00111111' ;0
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL1; Imprime 1
 MOVLW b'00000110' ;1
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL2; Imprime 2
 MOVLW b'01011011' ;2
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL3; Imprime 3
 MOVLW b'01001111' ;3
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL4; Imprime 4
 MOVLW b'01100110'  ;4
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL5; Imprime 5
 MOVLW b'01101101'  ;5
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL6; Imprime 6
 MOVLW b'01111101' ;6
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL7; Imprime 7
 MOVLW b'00000111' ;7
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL8; Imprime 8
 MOVLW b'01111111'  ;8
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL9; Imprime 9
 MOVLW b'01101111' ;9
 MOVWF PORTD
 MOVLW b'00111111'
 MOVWF PORTC
 GOTO BOTONES
LABEL10; Imprime 10
 MOVLW b'00111111' ;0
 MOVWF PORTD
 MOVLW b'00000110';1
 MOVWF PORTC
 GOTO BOTONES
LABEL11; Imprime 11
 MOVLW b'00000110' ;1
 MOVWF PORTD
 MOVLW b'00000110'
 MOVWF PORTC
 GOTO BOTONES
LABEL12; Imprime 12
 MOVLW b'01011011';2
 MOVWF PORTD
 MOVLW b'00000110'
 MOVWF PORTC
 GOTO BOTONES
LABEL13; Imprime 13
 MOVLW b'01001111' ;3
 MOVWF PORTD
 MOVLW b'00000110'
 MOVWF PORTC
 GOTO BOTONES
LABEL14; Imprime 14
 MOVLW b'01100110'  ;4
 MOVWF PORTD
 MOVLW b'00000110'
 MOVWF PORTC
 GOTO BOTONES
LABEL15; Imprime 15
 MOVLW b'01101101'  ;5
 MOVWF PORTD
 MOVLW b'00000110'
 MOVWF PORTC
 GOTO BOTONES
 ;****** DELAYS PARA LA FUNCION 4******
DELAY3
 MOVLW 0Xac
 MOVWF DCounter1
 MOVLW 0X13
 MOVWF DCounter2
 MOVLW 0X06
 MOVWF DCounter3
LOOP2
 DECFSZ DCounter1, 1
 GOTO LOOP2
 DECFSZ DCounter2, 1
 GOTO LOOP2
 DECFSZ DCounter3, 1
 GOTO LOOP2
 NOP
 RETURN
 
 END