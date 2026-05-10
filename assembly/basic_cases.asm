# MMIO base address = 0xFFFF0000, +0(switch), +8(led)
.text
main:
    li x31, 0xFFFF0000
    lw x1, 0(x31) // read switch
    sw x1, 8(x31) // clear switch
    j main