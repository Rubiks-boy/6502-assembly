PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
; E =  %10000000
; RW = %01000000
; RS = %00100000
LCD_DATA = %11110000
E =  %00001000
RW = %00000100
RS = %00000010

    .org $8000

reset:
    jsr lcd_setup

; print message to the lcd
    ldy #0
print:
    lda message,y
    beq loop
    jsr print_char
    iny
    jmp print

loop:
; do nothing
    jmp loop

message: .asciiz "ya YEET!"

set_output:
; Sets pins corresponding to LCD to output
    lda #$ff
    sta DDRB
    rts

lcd_setup:
; sets up the lcd (sets correct mode, turns on display, etc)
    jsr set_output

    ; Set to 4 bit mode
    ; In the event the cpu was reset, set to 8 bit
    ; and then back to 4 bit so that we aren't
    ; off by half instructions
    lda #%00110000 ; Set 8-bit
    jsr lcd_instruction
    lda #%00100000 ; Set 4-bit
    jsr pulse_e

    lda #%00101000 ; Set 4-bit, 2 line, 5x8
    jsr lcd_instruction
    lda #%00001100 ; Disp on with cursor, doesn't blink
    jsr lcd_instruction
    lda #%00000110 ; Write left to right, don't shift
    jsr lcd_instruction
    lda #%00000001 ; Clear display
    jsr lcd_instruction

pulse_e:
; maintains values of RS, RW, and 4 data pins passed 
; in from reg A and pulses the enable signal
; will also try reading in port b to reg x
    sta PORTB
    ora #E
    sta PORTB
    ldx PORTB
    and #(RW|RS|LCD_DATA)
    sta PORTB
    rts

lcd_wait:
; loops until the lcd is ready for another command
    ; set lcd data pins as input
    lda #$0f
    sta DDRB
lcd_busy:
    ; read busy flag & store the first half of the input
    ; (the part that contains the flag) onto the stack
    lda #RW
    jsr pulse_e
    phx
    jsr pulse_e

    ; see if lcd is busy or not; jump accordingly
    pla
    and #%10000000
    bne lcd_busy

    ; reset things back to output before leaving loop
    jsr set_output
    rts

lcd_instruction:
    ; wait for lcd to be ready
    pha
    jsr lcd_wait
    pla

    ; save other half for later
    pha

    ; send first half of instruction
    and #LCD_DATA
    jsr pulse_e

    ; send second half of instruction
    pla
    asl
    asl
    asl
    asl
    jsr pulse_e
    rts

print_char:
    ; wait for lcd to be ready
    pha
    jsr lcd_wait
    pla

    ; save other half for later
    pha

    ; send first half of instruction
    and #LCD_DATA
    ora #(RS)
    jsr pulse_e

    ; send second half of instruction
    pla
    asl
    asl
    asl
    asl
    ora #RS
    jsr pulse_e
    rts

send_lcd_byte:
; sends the byte in reg A to the lcd
; if the carry bit is set, will also send RS
    ; wait for lcd to be ready
    pha
    jsr lcd_wait
    pla

    ; save other half for later
    pha

    ; send first half of instruction
    and #LCD_DATA

    bcc skip_rs
    ora #(RS)
skip_rs:
    jsr pulse_e

    ; send second half of instruction
    pla
    asl
    asl
    asl
    asl
    bcc skip_rs2
    ora #(RS)
skip_rs2:
    jsr pulse_e
    rts

    .org $fffc
    .word reset
    .word $0000