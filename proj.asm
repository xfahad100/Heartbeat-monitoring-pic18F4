LIST P=PIC18F452, F=INHX32, N=0, ST=OFF, R=HEX    ; INCLUDE CONTROLLER TYPE
#include P18F452.INC            ; INCLUDE CONTROLLER FILE
; FUSE BIT SETTINGS
CONFIG OSC = HS, OSCS = OFF            ; HS=HIGH OSCILATOR
CONFIG WDT = OFF             ; WATCH DOG TIMER OFF
CONFIG PWRT = ON, BOR = OFF         ; POWER UP TIMER ON
; BROWN OUT RESET VOLTAGE OFF
CONFIG DEBUG = OFF, LVP = OFF, STVR = OFF       ; DEBUG OFF
; LOW VOLTAGEPROGRAMMING OFF

ORG  0X00 
GOTO MAIN         ; bypass interrupt vector table 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ORG  0008H            ; interrupt vector table
BTFSS INTCON, TMR0IF  ; Timer0 interrupt scan
RETFIE                ; No, return to initialize
GOTO ISR              ; Yes, go to Timer0 ISR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ----------------------------------- Initialize Timer0 and keeping CPU busy------------------------------------------------
ORG  100H  
MAIN

CLRF TRISB             ; making bit0 of PORTB an output
BSF TRISC,2
BCF TRISC,5
BCF PORTC,2       ; making bit0 of PORTC an output
CLRF TRISD
CLRF TRISA
YES
BTFSS PORTC,2
BRA YES

MOVLW B'00001000'      ; Timer0, 8-bit, No prescaler, EXT CLK
MOVWF T0CON            ; load T0CON register
MOVLW   0x67           ; FFH to high byte
MOVWF   TMR0H          ; load Timer0 high byte
MOVLW   0x69           ; FFH to high byte
MOVWF   TMR0L          ; load Timer0 high byte
BCF INTCON, TMR0IF     ; clear Timer interrupt flag bit
BSF INTCON, TMR0IE     ; enable Timer0 interrupt
BSF INTCON, GIE        ; enable interrupt globally

;TMR1 SETTINGS
BSF TRISC,0
MOVLW B'00000110'
MOVWF T1CON
MOVLW 00H
MOVWF TMR1L

BSF T0CON,TMR0ON
BSF T1CON,TMR1ON
HERE
BTG PORTA,2            ; keeping CPU busy, when there is no interrupt 
CALL DELAY_100MS
BRA HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ----------------------------------- ISR(Interrupt Service Routine)------------------------------------------------
ISR
ORG  200H
G1 EQU 0x61
G2 EQU 0x62
R1 EQU 0x11
D1 EQU 0x12
R3 EQU 0x13
TEMP1 EQU 0x14
TEMP2 EQU 0x15
TEMP3 EQU 0x16
MOVLW 05H
MOVWF TEMP2
LOL
MOVLW B'00000000'
MOVWF TEMP1
MOVWF R1
BCF T0CON, TMR0ON     
BCF INTCON, TMR0IF

MOVLW B'00000111'    
MOVWF T0CON      

MOVLW   0x1B           ; FFH to high byte
MOVWF   TMR0H          ; load Timer0 high byte
MOVLW   0x1E           ; 00H to low byte
MOVWF TMR0L            ; load Timer0 low byte

BSF T0CON,TMR0ON

BACK BTFSC INTCON, TMR0IF         ; toggle the bit 0 of PORTC
COMF TEMP1,F
MOVLW B'00000000'
CPFSGT TEMP1
BRA BACK
BTG PORTA,3
DECF TEMP2,F
MOVLW 00H
CPFSEQ TEMP2
GOTO LOL

BCF T0CON,TMR0ON
BCF T1CON,TMR1ON

MOVLW D'4'
MULWF TMR1L
MOVFF PRODL,TMR1L
 ;BCD CONVERT
BCD0        EQU 0x35       ; holder for lowest BCD pair
BIN0        EQU 0x36       ; holder for binary number to convert, lowest byte
BitCtr		EQU	0x37       ; counter of number of bits to convert
bcount      EQU 0x38
 MOVLW   0x08
 MOVWF  bcount  

  CLRF    BCD0
  MOVLW   0x08
  MOVWF   BitCtr
  MOVFF TMR1L,BIN0

ConvertBit
    RLCF    BIN0, f     ; for first byte to convert
    movf    BCD0, w     ; move first BCD pair into Wreg
    addwfc  BCD0, w     ; add it to itself (double) and add carry from 
                        ; rotate of binary 
    daw                 ; Decimal adjust BCD word
    movwf   BCD0        ; Save result back to BCDx register
    decfsz  BitCtr      ; decrement Bit Counter
    bra     ConvertBit  ; keep going until last bit rotated out of binary source

;seperate high and low byte
B1 equ 0x20
B2 equ 0x21

MOVF BCD0,W
ANDLW 0x0F
MOVWF B2
MOVF BCD0,W
ANDLW 0xF0
MOVWF B1
SWAPF B1
;B1
MOVLW 0x00
CPFSEQ  B1
GOTO SEG1
MOVLW 0x3F
MOVWF G1
GOTO FIG2

SEG1
CLRF R3
CLRF D1
INCF R3
YUP
MOVLW 0x00
CPFSEQ D1
RLNCF R3
INCF D1
MOVF D1,W
CPFSEQ B1
BRA YUP

MOVLW 0x09
CPFSEQ D1
GOTO SEG2
MOVLW 0x67
MOVWF G1
GOTO FIG2
SEG2
BTFSC R3,0
MOVLW 0x06
BTFSC R3,1
MOVLW 0x5B
BTFSC R3,2
MOVLW 0x4F
BTFSC R3,3
MOVLW 0x66
BTFSC R3,4
MOVLW 0x6D
BTFSC R3,5
MOVLW 0x7D
BTFSC R3,6
MOVLW 0x07
BTFSC R3,7
MOVLW 0x7F
MOVWF G1
GOTO FIG2

;B2
FIG2
MOVLW 0x00
CPFSEQ  B2
GOTO SEG01
MOVLW 0x3F
MOVWF G2
GOTO FINAL

SEG01
CLRF R3
CLRF D1
INCF R3
YUP0
MOVLW 0x00
CPFSEQ D1
RLNCF R3
INCF D1
MOVF D1,W
CPFSEQ B2
BRA YUP0

MOVLW 0x09
CPFSEQ D1
GOTO SEG02
MOVLW 0x67
MOVWF G2
GOTO FINAL
SEG02
BTFSC R3,0
MOVLW 0x06
BTFSC R3,1
MOVLW 0x5B
BTFSC R3,2
MOVLW 0x4F
BTFSC R3,3
MOVLW 0x66
BTFSC R3,4
MOVLW 0x6D
BTFSC R3,5
MOVLW 0x7D
BTFSC R3,6
MOVLW 0x07
BTFSC R3,7
MOVLW 0x7F
MOVWF G2
GOTO FINAL

FINAL
DISP
BSF PORTA,1
BCF PORTA,0

MOVFF G1,PORTD
CALL DELAY_1MS
BSF PORTA,0
BCF PORTA,1

MOVFF G2,PORTD
CALL DELAY_1MS

BTFSS PORTC,3
BRA DISP

CLRF PORTC
CLRF PORTD
CLRF TMR1L
BCF INTCON, TMR0IF

 GOTO MAIN                ; return from interrupt

#INCLUDE<NUMS.asm>
#INCLUDE<DELAY_20MHZ.ASM>
END               ; end program