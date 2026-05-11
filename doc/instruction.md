1. ```verilog
   case (small_switch[3:0])
              4'd0: display_data = pc_dbg;//current PC
              4'd1: display_data = imem_rdata;//current instruction
              4'd2: display_data = wb_dbg;//current write-back data
              4'd3: display_data = reg_dbg;//current register data
              4'd4: display_data = dmem_addr;//current data memory address
              4'd5: display_data = dmem_wdata;//current data memory write data
              4'd6: display_data = dmem_rdata;//current data memory read data
              4'd7: display_data = dmem_dbg_rdata;//current data memory debug read data
              4'd8: display_data = {28'b0, dmem_wstrb};//current data memory write strobe
              4'd9: display_data = {30'b0, dmem_we, dmem_re};//current data memory write enable and read enable
              4'd10: display_data = board_input;//current board input
              default: display_data = 32'hDEAD_BEEF;
           endcase
   ```

   小拨码开关(V4,R3,T3,T5)用来选择需要在七段管上显示的对象，

2. MMIO base address = 0xFFFF0000, +0(switch), +8(led)

3. | 功能               | 控制器件              | `.xdc` 端口         | 物理管脚      |
   | ------------------ | --------------------- | ------------------- | ------------- |
   | 连续运行 run       | `small_switch[7]`     | `small_switch[7]`   | `U3`          |
   | 暂停               | `small_switch[7] = 0` | `small_switch[7]`   | `U3`          |
   | 单步执行 step      | `start_pg` 按键       | `start_pg`          | `R17`         |
   | CPU reset          | `rst_n`               | `rst_n`             | `P15`         |
   | 显示选择           | `small_switch[3:0]`   | `small_switch[3:0]` | `V4/R3/T3/T5` |
   | DataRam 调试读地址 | `switch[7:0]`         | `switch[7:0]`       | `P5...R1`     |

4. 现在已经通过了TopMin.v的仿真测试和上板测试，基本没有问题。

   vivado只需将src目录导入design即可，不用复制文件夹。xdc选择min.xdc

5. ```
   TopMin
   ├── MMIO
   ├── CPU (core)
   │   ├── IF
   │   ├── ID
   │   │   ├── Decoder
   │   │   ├── RegFile
   │   │   └── ControlUnit
   │   ├── EX
   │   │   ├── BranchUnit
   │   │   └── ALU
   │   ├── MEM
   │   └── WB
   ├── DataRam
   └── InstRam
   ```

6. 

7. 

8.  