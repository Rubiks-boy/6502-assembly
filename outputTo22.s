    .org $8000
    lda #$ff
    sta $6002

    lda #$69
    sta $6000

loop:
    jmp loop

    .org $fffc
    .word $8000
    .word $0000