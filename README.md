# Project Report of CS202 Spring 2026

## 1. 团队成员

| 学号     | 姓名   | 负责工作 | 贡献比 |
| -------- | ------ | -------- | ------ |
|          |        |          |        |
| 12412639 | 王思宇 |          |        |
|          |        |          |        |



## 2. 开发环境

开发计划日程安排和实施情况



## 3. Github相关

| github classroom团队名称                                     | 这玩意随便吧                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 仓库地址                                                     | https://github.com/CS202ComputerOrganization/cpu-project-team |
|                                                              | 朱晓涛                                                       |
| [Siyu Wang (feitianduowen)](https://github.com/feitianduowen) | 王思宇                                                       |
| [这是人机在玩 (Shay-xyh)](https://github.com/Shay-xyh)       | 谢祎恒                                                       |

## 4. CPU架构设计

### 4.1 CPU特性

**ISA**

参考RISC-V基本指令集以及一些拓展

| 指令                    | 指令类型 | 执行操作                                  |
| ----------------------- | -------- | ----------------------------------------- |
| `add rd, rs1, rs2`      | R        | rd = rs1 + rs2                            |
| `sub rd, rs1, rs2`      | R        | rd = rs1 - rs2                            |
| `xor rd, rs1, rs2`      | R        | rd = rs1 ^ rs2                            |
| `or rd, rs1, rs2`       | R        | rd = rs1 \| rs2                           |
| `and rd, rs1, rs2`      | R        | rd = rs1 & rs2                            |
| `sll rd, rs1, rs2`      | R        | rd = rs1 << rs2                           |
| `srl rd, rs1, rs2`      | R        | rd = rs1 >> rs2                           |
| `sra rd, rs1, rs2`      | R        | rd = rs1 >> rs2 (sign-extend)             |
| `slt rd, rs1, rs2`      | R        | rd = ( rs1 < rs2 ) ? 1 : 0                |
| `sltu rd, rs1, rs2`     | R        | rd = ( (u)rs1 < (u)rs2 ) ? 1 : 0          |
| `addi rd, rs1, rs2`     | I        | rd = rs1 + imm                            |
| `xori rd, rs1, rs2`     | I        | rd = rs1 ^ imm                            |
| `ori rd, rs1, rs2`      | I        | rd = rs1 \| imm                           |
| `andi rd, rs1, rs2`     | I        | rd = rs1 & imm                            |
| `slli rd, rs1, rs2`     | I        | rd = rs1 << imm[4:0]                      |
| `srli rd, rs1, rs2`     | I        | rd = rs1 >> imm[4:0]                      |
| `srai rd, rs1, rs2`     | I        | rd = rs1 >> imm[4:0] (sign-extend)        |
| `slti rd, rs1, rs2`     | I        | rd = (rs1 < imm) ? 1 : 0                  |
| `sltiu rd, rs1, rs2`    | I        | rd = ( (u)rs1 < (u)imm ) ? 1 : 0          |
| `lb rd, imm(rs1)`       | I        | 读取 1 byte 并做符号位扩展                |
| `lh rd, imm(rs1)`       | I        | 读取 1 half-word (2 bytes) 并做符号位扩展 |
| `lw rd, imm(rs1)`       | I        | 读取 1 word (4 bytes)                     |
| `lbu rd, imm(rs1)`      | I        | 读取 1 byte 并做 0 扩展                   |
| `lhu rd, imm(rs1)`      | I        | 读取 2 byte 并做 0 扩展                   |
| `sb rd, imm(rs1)`       | S        | 存入 1 byte                               |
| `sh rd, imm(rs1)`       | S        | 存入 1 half-word (2 bytes)                |
| `sw rd, imm(rs1)`       | S        | 存入 1 word (4 bytes)                     |
| `beq rs1, rs2, label`   | B        | if (rs1 == rs2)  pc += (imm << 1)         |
| `bne rs1, rs2, label`   | B        | if (rs1 != rs2)  pc += (imm << 1)         |
| `blt rs1, rs2, label`   | B        | if (rs1 < rs2)  pc += (imm << 1)          |
| `bge rs1, rs2, label`   | B        | if (rs1 >= rs2)  pc += (imm << 1)         |
| `bltu rs1, rs2, label`  | B        | if ( (u)rs1 < (u)rs2 )  pc += (imm << 1)  |
| `bgeu rs1, rs2, label`  | B        | if ( (u)rs1 >= (u)rs2 )  pc += (imm << 1) |
| `jal rd, label`         | J        | rd = pc + 4; pc += (imm << 1)             |
| `jalr rd, rs1, imm`     | I        | rd = pc + 4; pc = rs1 + imm               |
| `lui rd, imm`           | U        | rd = imm << 12                            |
| `auipc rd, imm`         | U        | rd = pc + (imm << 12)                     |
| `ecall`                 | I        | 控制权交给固件 (采用输入设备模拟)         |
| `sret` *                | I        | 控制权交还给程序                          |
| `mul rd, rs1, rs2` *    | R        | rd = (rs1 * rs2)[31:0]                    |
| `mulh rd, rs1, rs2` *   | R        | rd = (rs1 * rs2)[63:32]                   |
| `mulhsu rd, rs1, rs2` * | R        | rd = (rs1 * (u)rs2)[63:32]                |
| `mulhu rd, rs1, rs2` *  | R        | rd = ( (u)rs1 * (u)rs2 )[63:32]           |
| `div rd, rs1, rs2` *    | R        | rd = rs1 / rs2                            |
| `rem rd, rs1, rs2` *    | R        | rd = rs1 % rs2                            |

### 4.2 CPU 信息表

| CPU时钟      | CPI          | CPU周期            | Pipeline        | 寻址空间        | 寻址单位 |
| ------------ | ------------ | ------------------ | --------------- | --------------- | -------- |
| 23MHz        | 1            | 单周期             |                 |                 |          |
| **指令空间** | **数据空间** | **栈空间的基地址** | **外设I/O支持** | **I/O访问方式** |          |
|              |              |                    |                 |                 |          |

### 4.3 CPU接口

| cpu_top ports     | 位宽 | 类型   | 说明                 |
| ----------------- | ---- | ------ | -------------------- |
| clk_100           | 1    | input  | 100Mhz时钟           |
| rst_n             | 1    | input  | 复位信号             |
| finish            | 1    | input  | 确定按键             |
| switch            | 8    | input  | 8个拨码开关          |
| small_switch      | 8    | input  | 8个小拨码开关        |
| tube_scan         | 8    | output | 数码管扫描信号       |
| tube_signal_left  | 8    | output | 左数码管信号         |
| tube_signal_right | 8    | output | 右数码管信号         |
| led               | 8    | output | led灯                |
| small_led         | 8    | output | 小led灯              |
| tx                | 1    | output | send data by UART    |
| rx                | 1    | input  | receive data by UART |
| start_pg          | 1    | input  | Active High          |
|                   |      |        |                      |

### 4.6 系统上板使用说明

### 4.7 自测试说明

测试用例：

| 测试内容 | 测试方法 | 测试类型 | 测试用例 | 测试结果 |
| -------- | -------- | -------- | -------- | -------- |
| add      | 仿真     | 集成     |          | 通过     |
| sub      | 仿真     | 集成     |          | 通过     |
| xor      | 仿真     | 集成     |          | 通过     |
| or       | 仿真     | 集成     |          | 通过     |
| and      | 仿真     | 集成     |          | 通过     |
| sll      | 仿真     | 集成     |          | 通过     |
| srl      | 仿真     | 集成     |          | 通过     |
| sra      | 仿真     | 集成     |          | 通过     |
| slt      | 仿真     | 集成     |          | 通过     |
| sltu     | 仿真     | 集成     |          | 通过     |
| addi     | 仿真     | 集成     |          | 通过     |
| xori     | 仿真     | 集成     |          | 通过     |
| ori      | 仿真     | 集成     |          | 通过     |
| andi     | 仿真     | 集成     |          | 通过     |
| slli     | 仿真     | 集成     |          | 通过     |
| srli     | 仿真     | 集成     |          | 通过     |
| srai     | 仿真     | 集成     |          | 通过     |
| slti     | 仿真     | 集成     |          | 通过     |
| sltiu    | 仿真     | 集成     |          | 通过     |
| lb       | 仿真     | 集成     |          | 通过     |
| lh       | 仿真     | 集成     |          | 通过     |
| lw       | 仿真     | 集成     |          | 通过     |
| lbu      | 仿真     | 集成     |          | 通过     |
| lhu      | 仿真     | 集成     |          | 通过     |
| sb       | 仿真     | 集成     |          | 通过     |
| sh       | 仿真     | 集成     |          | 通过     |
| sw       | 仿真     | 集成     |          | 通过     |
| beq      | 仿真     | 单元     |          | 通过     |
| bne      | 仿真     | 单元     |          | 通过     |
| blt      | 仿真     | 单元     |          | 通过     |
| bltu     | 仿真     | 单元     |          | 通过     |
| bgeu     | 仿真     | 单元     |          | 通过     |
| jal      | 仿真     | 单元     |          | 通过     |
| jalr     | 仿真     | 单元     |          | 通过     |
| lui      | 仿真     | 单元     |          | 通过     |
| auipc    | 仿真     | 单元     |          | 通过     |
| ecall    | 上板     | 单元     |          | 通过     |

## 5. bonus

## 6. 问题及总结
