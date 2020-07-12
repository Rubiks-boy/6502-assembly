PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

    ; Sets pins corresponding to LCD to output
    lda #$ff
    sta DDRB
    lda #%11100000
    sta DDRA

    lda #%00101000 ; Set 4-bit, 2 lint, 5x8
    jsr lcd_instruction
    lda #%00001110 ; Disp on with cursor, doesn't blink
    jsr lcd_instruction
    lda #%00000110 ; Write left to right, don't shift
    jsr lcd_instruction
    lda #%00000001 ; Clear display
    jsr lcd_instruction

    ; Write letter
    lda #"y"
    jsr print_char
    lda #"a"
    jsr print_char
    lda #" "
    jsr print_char
    lda #"Y"
    jsr print_char
    lda #"E"
    jsr print_char
    lda #"E"
    jsr print_char
    lda #"T"
    jsr print_char

loop:
    sta $6000
    rol
    jmp loop

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

lcd_instruction:
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
    .word $8000
    .word $0000