    .org $8000
    lda #$ff
    sta $6002
    lda #$03

loop:
    sta $6000
    rol
    jmp loop

    .org $fffc
    .word $8000
    .word $0000