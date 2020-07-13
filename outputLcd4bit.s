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
    ; Sets pins corresponding to LCD to output
    lda #$ff
    sta DDRB

    ; for setting 4 bit mode, the very first instruction
    ; is read as an 8 bit instruction & must be repeated
    lda #%00100000 ; Set 4-bit
    jsr pulse_e

    lda #%00101000 ; Set 4-bit, 2 line, 5x8
    jsr lcd_instruction
    lda #%00001110 ; Disp on with cursor, doesn't blink
    jsr lcd_instruction
    lda #%00000110 ; Write left to right, don't shift
    jsr lcd_instruction
    lda #%00000001 ; Clear display
    jsr lcd_instruction

    ldy #0
print:
    lda message,y
    beq loop
    jsr print_char
    iny
    jmp print

loop:
    jmp loop

message: .asciiz "ya YEET!"

pulse_e:
    ; takes values of RS, RW, and 4 data pins from reg A
    ; and pulses the enable signal
    sta PORTB
    ora #E
    sta PORTB
    and #(RW|RS|LCD_DATA)
    sta PORTB
    rts

lcd_wait:
    ; set lcd data pins as input
    lda #$0f
    sta DDRB
lcd_busy:
    ; read first half of busy flag
    ldx #RW
    stx PORTB
    ldx #(RW|E)
    stx PORTB
    lda PORTB

    ; tell lcd to output second half of busy flag
    ; disregard this output, since it's address
    ; lines we don't care about
    ldx #RW
    stx PORTB
    ldx #(RW|E)
    stx PORTB

    ; see if lcd is busy or not; jump accordingly
    and #%10000000
    bne lcd_busy

    ; if lcd is not busy, reset things back
    ; port b output
    lda #RW
    sta PORTB
    lda #$ff
    sta DDRB
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

    .org $fffc
    .word reset
    .word $0000