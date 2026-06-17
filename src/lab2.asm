BITS 16
ORG 0000H

PORTA   EQU 08H
PORTB   EQU 0AH
PORTC   EQU 0CH
CTRL    EQU 0EH

start:
    ; 初始化8255
    ; PA输入，PB输出，PC输出，方式0
    mov dx, CTRL
    mov al, 90h
    out dx, al

main:
    mov dx, PORTA
    in  al, dx

    mov dx, PORTB
    out dx, al

    jmp main