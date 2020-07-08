# Manual hex values that correspond to latching a single output number
code = bytearray([
    # all pins on register b are output
    0xa9, 0xff,
    0x8d, 0x02, 0x60,

    # latch output
    0xa9, 0x69,
    0x8d, 0x00, 0x60
])
rom = code + bytearray([0xea]*(32768 - len(code)))

# First instruction location
rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom.bin", "wb") as f:
    f.write(rom)