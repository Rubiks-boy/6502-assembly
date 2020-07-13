; Outputs a message to the LCD using the LCD's 4 bit mode
; On the W65C22, assumes E, RW, and RS are on port b alongside the 4 data pins
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

LCD_DATA = %11110000
E =  %00001000
RW = %00000100
RS = %00000010

    .org $8000

reset:

lcd_setup:
; sets up the lcd (sets correct mode, turns on display, etc)
    ; set pins on portb as outputs
    lda #$ff
    sta DDRB

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

print_message:
; print message to the lcd
    ldy #0
print_iter:
    lda message,y
    beq loop
    sec
    jsr send_lcd_byte_cmd
    iny
    jmp print_iter

loop:
; do nothing
    jmp loop

message: .asciiz "ya YEET!"

lcd_instruction:
    clc
    jsr send_lcd_byte_cmd
    rts

send_lcd_byte_cmd:
; sends the byte in reg A to the lcd
; uses carry bit to determine whether to set RS
    ; wait for lcd to be ready
    pha
    jsr lcd_wait
    pla

    ; save other half of cmd & carry bit for later
    php ; (gets overriden by asl)
    pha ; (gets overridden when extracting first half)

    ; send first half of instruction
    and #LCD_DATA

    jsr send_lcd_cmd

    ; send second half of instruction
    pla ; get second half back
    asl ; move into 4 highest bits
    asl
    asl
    asl
    plp ; get carry bit again
    jsr send_lcd_cmd
    rts

send_lcd_cmd:
; sends whatever's in the top 4 bits of the A reg to the lcd
; if carry bit set, also sends RS
    bcc skip_rs
    ora #(RS)
skip_rs:
    jsr pulse_e
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

    ; reset things back to output before leaving subroutine
    lda #$ff
    sta DDRB
    rts

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

    .org $fffc
    .word reset
    .word $0000