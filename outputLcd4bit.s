PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E =  %10000000
RW = %01000000
RS = %00100000
; LCD_DATA = %11110000
; E =  %00001000
; RW = %00000100
; RS = %00000010

    .org $8000

reset:
    ; Sets pins corresponding to LCD to output
    lda #$ff
    sta DDRB
    lda #%11100000
    sta DDRA

    ; for setting 4 bit mode, the very first instruction
    ; is read as an 8 bit instruction & must be repeated
    lda #%00100000 ; Set 4-bit
    sta PORTB
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
    ; pulse enable signal
    ldx #0
    stx PORTA
    ldx #E
    stx PORTA
    ldx #0
    stx PORTA
    rts

pulse_rs_e:
    ; pulse enable signal
    ldx #RS
    stx PORTA
    ldx #(RS|E)
    stx PORTA
    ldx #RS
    stx PORTA
    rts

lcd_wait:
    pha
    ; port b input
    lda #$00
    sta DDRB
lcd_busy:
    ; read busy flag
    ldx #RW
    stx PORTA
    ldx #(RW|E)
    stx PORTA
    lda PORTB

    ldx #RW
    stx PORTA
    ldx #(RW|E)
    stx PORTA

    and #%10000000
    bne lcd_busy

    ; port b output
    lda #RW
    sta PORTA
    lda #$ff
    sta DDRB
    pla
    rts

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    jsr pulse_e
    asl
    asl
    asl
    asl
    sta PORTB
    jsr pulse_e
    rts

print_char:
    jsr lcd_wait
    sta PORTB
    jsr pulse_rs_e
    asl
    asl
    asl
    asl
    sta PORTB
    jsr pulse_rs_e
    rts

    .org $fffc
    .word reset
    .word $0000


; given something in a register:
; copy left half into x register
; write that
; and with enable pin
; write that
; go back to without enable pin
; write that
; shift left x4
; repeat write/enable stuff