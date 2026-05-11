# MMIO base address = 0xFFFF0000, +0(switch), +8(led)
.text
main:
    li x31, 0xFFFF0000
    lw x1, 0(x31) # read switch
    sw x1, 8(x31) # clear switch
    j main

    # ffff0fb7
    # 000f8f93
    # 000fa083
    # 001fa423
    # ff1ff06f
    # 会一直循环，而且led灯会显示大拨码开关的状态。
    # 但是测试过发现只有单步测试时LED有效。
    # smallsw7=1时LED没有跟随switch的状态变化.

