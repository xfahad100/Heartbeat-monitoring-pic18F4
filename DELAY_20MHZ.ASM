; DELAY_1S
; DELAY_100MS
; DELAY_1MS
; DELAY_10US
DELAY1 EQU 0X7F
DELAY2 EQU 0X7E
DELAY3 EQU 0X7D

DELAY_1MS
MOVLW d'7'
MOVWF DELAY2
DELAY_2
MOVLW d'238'
MOVWF DELAY1
DELAY_1
DECFSZ DELAY1
GOTO DELAY_1
DECFSZ DELAY2
goto DELAY_2
RETURN

DELAY_100MS
MOVLW d'100'
MOVWF DELAY3
DELAY_4
MOVLW d'7'
MOVWF DELAY2
DELAY_5
MOVLW d'238'
MOVWF DELAY1
DELAY_6
DECFSZ DELAY1
GOTO DELAY_6
DECFSZ DELAY2
goto DELAY_5
DECFSZ DELAY3
goto DELAY_4
RETURN

DELAY_10US
MOVLW d'11'
MOVWF DELAY1
DELAY_7
NOP
DECFSZ DELAY1
GOTO DELAY_7
RETURN

DELAY_1S
MOVLW d'19'
MOVWF DELAY3
DELAY_8
MOVLW d'255'
MOVWF DELAY2
DELAY_9
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
MOVLW d'255'
MOVWF DELAY1
DELAY_10
NOP
DECFSZ DELAY1
GOTO DELAY_10
DECFSZ DELAY2
goto DELAY_9
DECFSZ DELAY3
goto DELAY_8
RETURN