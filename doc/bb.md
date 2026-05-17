5. Difftest_gui 下载链接：[CS202ComputerOrganization/CPU_FinalProject_26S](https://github.com/CS202ComputerOrganization/CPU_FinalProject_26S) ，最新window版本为v1.4

  The document description may be slightly adjusted according to the class situation. Please always refer to the latest version posted on BB. It is recommended to refresh and check before submitting your assignment to avoid missing any updates.

  文档描述可能会根据课堂情况微调，请务必以BB上发布的最新版本为准。提交作业前建议刷新查看，避免遗漏更新。

  Recall: No Vivado-built-in or third-party IP cores are allowed in the Vivado project. And ensure that the test instruction hex file is properly initialized in the memory verilog code you submit (test it in advance to verify that the relative path is correct).

  再次强调：vivado工程中不允许使用任何vivado自带或第三方IP核, 并在你提交的memory verilog代码中初始化好测试指令hex文件（提前测试确保相对路径正确） 

  ## 1. General Description 总体说明

  ### 1.1 Honesty in Project 作业诚信

  If you have used network code or AI-generated code in this project, please make sure to explain it in the project document and project presentation (such as which part of the code references the network implementation, provide the website address, which part uses AI, provide the name of the AI tool). If no explanation is given, if the code is checked for duplication and it is found to have a high degree of similarity, it will be directly determined as dishonest in the project, and the project score will be 0.

  如本次作业中使用了网络代码或者AI生成代码，请务必在项目文档及项目汇报中说明（比如哪部分代码参考了网络实现，给出网址，哪部分使用了AI，给出AI工具名），如不做说明，则代码查重时若发现重复度高将直接判定为作业不诚信，项目分数为0分。

  ### 1.2 Form a team 组队

  #### 1.2.1 Team Formation Rules 组队规则：

  1. It is necessary to ensure that all team members are present within the In-class Design time. If someone is absent, their team membership will be automatically reduced, and the contribution ratio for the team will be adjusted based on the actual number of members.  必须保证在现场设计时间内全员到场, 不到场则自动减少组队人数，由实际人数分配100%贡献比。
  2. Students from the same experimental class can form teams together, or they can form teams across different theoretical or experimental classes (since all members must be present for the In-class Design, it is not recommended to form teams across different classes). 同一个实验班的同学组队，也可以跨理论/实验班组队（由于现场设计时必须全员到场，因此不建议跨班组队）。
  3. It is recommended that three students form a team (in special cases, two students can also form a team, but it is not recommended and there will be no additional rewards for the two-person team). 建议3人组队（特殊情况也可以2人组队，但不建议，且2人组队无额外奖励）。

  #### 1.2.2 Reorganization team NOTES 拆组重组说明：

  1. If the group needs to be disbanded due to special circumstances, with the consent of more than half of the members, providing substantive evidence such as chat records and git logs, an email can be used to apply for the disbandment. One member will write the email, elaborating on the reasons for the disbandment and confirming the copyright ownership of each part of the code. The email should be sent to the instructor of the experimental course and copied to all members.   如小组因特殊原因需要拆组，经半数以上成员同意，提供聊天记录、git日志等实质证据，可以邮件申请拆组。由一名成员撰写邮件，详细说明拆组原因，并确认好各部分代码版权归属，主送给实验课老师并抄送给所有成员。
  2. The deadline for disbanding is 13th week Sunday at the end of the day. After this time, disbanding will no longer be supported. Please be cautious. 拆组的截止时间为13周周日end of day，超过该时间后不再支持拆组，请同学慎重。
  3. The reorganization after disassembly will be decided by the students themselves. Please send the reorganized results to the instructor of the experimental course and also forward them to all members of the group.  拆组后的重组由同学自行协商，重组后的结果请主送实验课老师并抄送给小组所有成员。

  ### 1.3 Development board borrowing and return 开发板领用和归还

  1. Each group will be provided with a development board. Please take good care of the development board. In case of loss or damage to the development board, data cable, or accessories, you will be required to make a compensation at the original price. 每小组一块开发板, 请保护好开发板，如有开发板、数据线、配件丢失或损坏需照价赔偿。
  2. The development board should complete the tests for functions such as switches and buttons within one week of borrowing. If any problems occur, please provide specific details of the issue and contact the teacher to have it replaced within one week. 开发板借用一周内自行完成开关、按键等功能测试，如有问题请反馈具体问题并在一周内找老师更换。
  3. After the project presentation is completed, all the development boards should be returned uniformly. For the specific arrangements, please pay attention to the subsequent notifications.  项目汇报完成后统一归还开发板，具体安排请留意后续通知。

  ## 2. Scoring criteria and deadline 评分规则和截止时间

  ### 2.1 Deadline (submit to the BB site before 23:59 on Monday of Week 15) 截止时间（15周周一晚上23：59之前提交bb站点）

  **Project submission: The deadlines for code, documentation, and videos are all the same. The code and documentation will be submitted on Blackboard, while the video will be uploaded to the cloud drive (the link will be sent later).**

  **项目提交**：代码、文档、视频截止时间均为**统一时间**。代码和文档将在Blackboard上提交，视频在云盘提交（后续发链接）

  ### 2.2 Scoring coefficients related to time 时间系数

  If the submission is made before the deadline, the coefficient is 1. For each day of delay, the coefficient decreases by 0.1. That is:  截止时间之前提交，系数=1，每推迟一天，系数 - 0.1，即：

  - Submit by 23:59 on Tuesday of Week 15, coefficient = 0.9 (15周周二晚上23：59之前提交，系数=0.9)，
  - Submit by 23:59 of Wednesday of Week 15th, coefficient = 0.8 (15周周三晚上23：59之前提交，系数=0.8)，
  - Submit by 23:59 of Thursday of Week 15th, coefficient = 0.7 (15周周四晚上23：59之前提交，系数=0.7)，
  - Submit by 23:59 of Friday of Week 15th, coefficient = 0.6 (15周周五晚上23：59之前提交，系数=0.6)，
  - Submit after 23:59 of Friday of Week 15th, coefficient = 0 (15周周五晚上23：59**之后**提交，系数=**0)**

  ### 2.3 Scoring Explanation评分说明

  1. Full marks and overage: The project is scored out of 100 points. If the score exceeds 100, the overage portion will be proportionally included in the overall assessment. Note: The overage points included in the overall assessment do not exceed 3 points.  **满分及溢出**：项目满分100分，得分如超过100，则溢出的部分将按比例计入总评。说明：纳入总评的溢出分不超过3分)。
  2. **Scoring Mechanism Explanation 评分机制说明：**
     - **Personal total score = Team score \* Time coefficient \* Number of team members \* Personal contribution ratio + Progress Confirmation-week13(1) + Submission format (2) + in-class design (5)      个人总分** = 团队得分 * 时间系数 * 团队人数 * 个人贡献比 + 进度确认-13周(1) + 提交格式(2) + 现场设计(5)
     - **Team score = Basic functions (80) + Project documentation (7) + Project video (5) + Bonus (10)         团队得分** = 基础功能(80) + 项目文档(7) + 项目视频(5) + bonus(10)
     - **Basic Function: Offline automated use case testing (based on TestCase Verify). It is recommended that students test it independently using the Difftest tool before submitting.    基础功能：** 离线自动化用例测试（基于 TestCase Verify）。建议学生提交前，利用Difftest工具自行测试。
     - **Bonus Function: Comprehensive scoring is conducted based on project documents and demonstration videos.     Bonus 功能：** 基于项目文档与演示视频进行综合评分。
     - **Recheck mechanism: It is necessary to ensure that all base + bonus functions are 100% reproducible. Subsequently, the Inspector and teaching assistants will conduct manual verification.   复核机制：** 需确保所有基础+bonus功能 100% 可复现，后续 Inspector 和助教将开展人工核查。
     - **Time factor: The submission must be completed before 23:59 on the day of the specified deadline.       时间系数**：规定截止时间当天23：59分之前提交
     - **Contribution ratio: There are no requirements for the distribution method. The excess portion will be handled according to the "full score and overage" rule.     贡献比**：分配方式不做要求，溢出部分按“满分及溢出”规则执行
     - **Submission format: To ensure the smooth generation of the .bit file and successful verification, please organize the file directory structure and naming according to the specified requirements.   提交格式**：为确保自动生成.bit和验证顺利进行，请严格按要求整理文件目录层级和命名。
     - **In-class design: In an offline environment, students must use Vivado on the provided lab computers to design a simple instruction of comparable difficulty to RV32I. The instructor will provide the instruction format, opcode, and 32-bit machine code on site. Each group must modify the CPU hardware design accordingly, initialize or write the instructions into the instruction memory, and run the test. Immediate successful verification earns the credit. The use of personal laptops or mobile phones is strictly prohibited; any violation will be treated as cheating.   现场设计**：断网环境下，使用学生机的vivado，设计一条和RV32I同等难度的简单指令，根据教师现场提供的指令格式、opcode，32位机器码，小组自行修改cpu硬件设计并将指令初始化或写入指令内存进行测试，当场验证成功可获得分数。严禁使用个人电脑、手机，违者按作弊处理。

  ## 3. CPU Function Requirements  CPU功能要求

  ### 3.1 Basic funciton [max: 80]  基础功能【max：80】

  1. case 0, logical and caculation.  用例0，and运算，逻辑与运算。
  2. case 1, shift logical left calculation.   用例1，sll运算，逻辑左移运算，第二个操作数的低5bit是移动的位数。
  3. case 2, shift right arithmatic calculation.   用例2，sra运算，算术右移运算，第二个操作数的低5bit是移动的位数。
  4. case 3, The lui+add operation involves performing the lui operation first and then the add operation. (Corresponding to lu12i+add.w in LoongArch)      用例3， lui+add 运算，先做lui运算，再做add运算。(对应LoongArch 的 lu12i+add.w)
  5. case 4, jal + auipc (corresponding to bl + pcaddu12i in LoongArch), specific scenarios to be provided later.   用例4， jal+auipc，具体场景后续给出 (对应 LoongArch 的 bl+pcaddu12i)
  6. case 5, jal + jalr (corresponding to bl + jirl in LoongArch), specific scenarios to be provided later.   用例5， jal+jalr，具体场景后续给出 (对应 LoongArch 的 bl+jirl)
  7. case 6, To implement the calculation of the Fibonacci sequence, input the index of the number in the Fibonacci sequence, and output the corresponding data in the Fibonacci sequence.   用例6，实现斐波拉契数列计算，输入斐波拉契数列中数字的下标，输出对应的斐波拉契数列中的数据
  8. case 7, Input 8-bit data, and output the number of 1s in the 8-bit data.  用例7， 输入8bit数据，输出8bit数据中1的个数
  9. case 8, Type determination of 16-bit IEEE754 encoded floating-point numbers.  
     Input 16-bit data, identify it as a 16-bit IEEE-754 single-precision floating-point number (sign 1 bit, exponent 5 bits, mantissa 10 bits), and output its corresponding type code (0: positive or negative zero, 1: positive or negative infinity, 2: NaN, 3: normalized number, 4: non-normalized number)   用例8， 16bit IEEE754 编码浮点数的类型判断。16bit数据，将其作为16bit的IEEE-754单精度浮点数（符号位1bit，指数位5bit，尾数位10bit）识别，输出其对应的类型编码（0：正负0，1：正负无穷大，2：NaN，3:规约化数，4:非规约化数） 
  10. case 9, Quantization processing of floating-point numbers (converting 16-bit floating-point numbers to fixed-point numbers of Q3.4 format)   Input 16-bit data, identify it as a 16-bit IEEE-754 single-precision floating-point number (with 1 bit for the sign, 5 bits for the exponent, and 10 bits for the mantissa), convert it to a Q3.4 fixed-point number (from the highest bit to the lowest bit in sequence: the highest bit is the sign bit, 3 bits for the integer part, and 4 bits for the fractional part), and perform quantization. Output the quantized result. (The test data includes positive and negative numbers. If it is a negative number, output the corresponding complement code.)    用例9， 浮点数的量化处理（16bit浮点数转为Q3.4的定点数）输入入16bit数据，将其作为16bit的IEEE-754单精度浮点数（符号位1bit，指数位5bit，尾数位10bit）识别，将其转为Q3.4定点数(从最高位往最低位的方向依次为：最高位是符号位，3bit的整数部分，4bit的小数部分)并进行量化，将量化的结果做输出。（测试数据包括正数和负数,如果是负数则输出对应的补码）

  ### 3.2 bonus【max：10】

  ​     The functions include but are not limited to：  功能包括但不限于：

  1. Support for complex peripheral interfaces (such as VGA interface, keyboard, etc.) [max5]   复杂外设接口的支持（如VGA接口、键盘等）【max: 5】
     - The complexity of implementation and user experience will be used as the evaluation criteria.  实现复杂度和用户体验将作为考察标准
  2. ISA instruction extension [max: 4], such as ecall (based on the complexity rating of functions [max: 2]), floating-point instructions (based on the complexity rating of functions [max: 3]), or other hardware acceleration instructions (based on the complexity rating of functions [max: 4])   ISA指令扩展【max：4】，如ecall（视功能复杂度评分【max：2】），浮点数指令（视功能复杂度评分【max：3】）等，或其他硬件加速指令（视功能复杂度评分【max：4】）
     - Instructions implemented using Verilog operators such as '*' and '/' do not receive additional points.      直接用'*', '/'等verilog操作符实现的指令不额外加分。
     - You are required to provide your own test cases and explain the modifications made to the CPU structure in the class for implementing this extended instruction, as well as the performance improvement achieved compared to a pure software implementation.    需自行提供测试用例，并说明实现该扩展指令相比于课上CPU结构所做修改，以及相比纯软件实现对性能的提升。
  3. Architecture optimization, such as pipeline [max: 6]: Implementing the pipeline also requires implementing a single-cycle CPU. Integrating the two CPUs into a single top module and supporting switching modes (which can reduce the size of the imem and dmem to 32KB or 16KB) is necessary. The CPU performance improvement should be demonstrated based on the same test case (such as a loop). The code fragments (one or more) containing control hazards and data hazards should be able to run correctly.   架构优化，如pipeline【max：6】：如实现pipeline，也需要实现单周期CPU，将两种CPU整合到一个top模块中，并支持切换模式(可减小imem和dmem的大小到32KB或16KB)。需基于同一测试用例(如循环)展示CPU性能提升。能正确运行包含control hazard，data hazard的代码片段(一个或多个)
     - It is necessary to be able to pause and control the progression of clock cycles through the debug mode, so as to observe the register values and the resolution of hazards in real time.  需能够通过debug模式暂停、控制时钟周期行进，以便实时观察寄存器值和hazard解决情况
     - You are required to provide your own assembly code for testing and ensure that it passes the test.   需自行提供测试用的汇编代码并测试通过。
  4. Hardware-software collaborative application [max: 5]: Custom software applications based on the CPU, such as games, image processing, sound processing, or others.   软硬件协同应用【max：5】：基于CPU自创软件应用，如游戏、图像、声音处理或其他。
  5. Tools for enhancing teaching and experimental efficiency [max: 2]   教学、实验效率提升辅助工具【max：2】
  6. Other creative ideas not listed above.       其他以上未列出的创意

  ## 4. Project submission  项目提交

  ### 4.1 version control  版本控制

  1. Use Git for version control and manage the project through the remote repository on GitHub Classroom. The operation steps are as follows.   请使用Git做版本控制，并使用课程远程仓库 Gihub Classroom管理项目，操作方法如下

  - Log in and access. Click on the assignment link (https://classroom.github.com/a/vPG8xHwH), and log in with your GitHub account. If this is your first time using it, the system may ask you to authorize GitHub Classroom.    登录并访问 点击作业链接（https://classroom.github.com/a/vPG8xHwH），并登录你的 GitHub 账号。如果是首次使用，系统可能会要求你授权 GitHub Classroom。
  - Create or join a team  创建或加入队伍
    - Create a new team (suggested to be operated by the team leader or the student responsible for submitting the final code): In the "Create a new team" input box on the page, enter the name of your team, and click "Create team".   创建新团队（建议由队长或负责提交最终代码的同学操作）： 在页面中的 "Create a new team" 输入框内填写你们的队伍名称，点击 Create team。
    - Join an existing team (with other team members operating): Locate the already established team in the list and click "Join".      加入已有团队（其余组员操作）： 在列表中找到已经建好的队伍，点击 Join。
    - **Important Warning: Regarding Team Enrollment and Academic Integrity.  重要警告：关于团队加入与学术诚信**
      1. **Do not add groups at will: Please carefully check the name of the team created by the team leader before clicking to join! The system does not support leaving the group on your own.     严禁随意加组：** 请务必核对队长创建的队伍名称后再点击加入！系统**不支持自行退出**。
      2. **Behavior Monitoring: The teacher's backend can monitor in real time the personnel changes of all teams. Any unauthorized participation in another team will be treated as cheating once discovered. If it was an honest mistake, please contact the teacher immediately for handling.    行为监控：** 教师后台可实时监控所有队伍的人员变动。任何未经授权加入他人团队的行为，一经发现，将按作弊处理。如确属手滑加错，请立刻联系老师处理。
  - After the team is formed, click on "Accept this assignment" on the page..      接受作业 组队完成后，点击页面上的 Accept this assignment。
  - Obtain the repository and start development. The system will process it (usually within just a few seconds). After refreshing the page, you will see a dedicated team code repository link. Click on it to enter the repository and clone the code to your local machine. Then you can start collaborative development.  获取仓库并开发 等待系统处理（通常只需几秒钟），刷新页面后，你会看到一个专属的团队代码仓库链接。点击进入该仓库，将代码 Clone 到本地，即可开始协作开发。

  1. Create a .gitignore file in the local repository and copy the following content to it, in order to avoid submitting excessive and redundant temporary files.       本地仓库创建.gitignore文件并复制以下内容，用来避免提交过量冗余临时文件

     ```
     # ==========================================
     # Vivado Git Ignore List
     # ==========================================
     *.jou
     *.log
     *.str
     *.dmp
     *.pb
     *.backup.*
     .Xil/
     *.sim/
     *.cache/
     *.hw/
     *.ip_user_files/
     *.gen/
     *.wdb
     *.vcd
     xsim.dir/
     .DS_Store
     Thumbs.db
     
     # Ignore the "runs" directory, but force the submission of the ".bit" and ".dcp" files under "runs/impl_1".              忽略.runs目录，但强制提交runs/impl_1下的.bit和.dcp文件
     *.runs/*
     !*.runs/impl_1/
     *.runs/impl_1/*
     !*.runs/impl_1/*.bit
     !*.runs/impl_1/*.dcp
     ```

  ### 4.2 submission 提交

  Each group will appoint ONE member to be responsible for submitting the code, videos, documents, etc. Meanwhile, the names of the group members who submit the assignments should be registered in the shared document. (The completeness of the files and the correctness of the naming will be included in the scoring. Those who fail to submit as required will receive 0 points in this section.)      每小组安排一名组员负责提交**代码、视频、文档**等内容，同时在共享文档中登记提交作业的组员名称。(文件完整性以及命名正确性纳入评分，未按要求提交者该部分得0分。)

  #### 4.2.1 Source code 源代码

  1. **The submitted content  提交内容：**

  - cpu_project/
    - This directory is the root directory of the Vivado project and contains the following files or folders:       该目录为vivado工程根目录，内含以下文件或文件夹
    - cpu_project.xpr
    - cpu_project.srcs/
    - cpu_project.runs/impl_1/TopDebug.bit
    - cpu_project.runs/impl_1/xxx.dcp （总共三个dcp文件）
    - **NOTES 注意**：
      - The project name should be uniformly set as "cpu_project", the top-level file module name should be "TopDebug", and the bistream name should be "TopDebug.bit". To ensure the smooth execution of the automated verification process, please do not rename the above-mentioned parts by yourself.   工程名统一为cpu_project，顶层文件模块名为TopDebug，bistream名为TopDebug.bit，为保证自动化验证流程顺利执行，请勿对以上提到的部分自行命名。
      - In the Vivado project, it is not allowed to use any IP cores provided by Vivado itself or from third parties.     vivado工程中不允许使用任何vivado自带或第三方IP核
      - Before submitting, please perform the following checks: Open this directory on another computer. Ensure that by double-clicking the .xpr file, the Vivado project can be directly launched and a verifiable bitstream file can be compiled without any configuration, so that in special cases, the Inspector can conduct manual verification.        提交前请作以下检查：在另一台电脑中打开该目录，确保双击.xpr可直接启动vivado工程，并可在不做任何配置情况下编译生成可验证的bitstream文件，以便特殊情况下inspector做人工核验
  - assembly/
    - batch_test.asm （Note: All basic scenario assembly code should be written in this file 注意：所有基础场景汇编都写到该文件中）
    - batch_test.hex （Corresponding hexadecimal machine code for all basic scenarios 对应所有基础场景的16进制机器码）
    - All other `.asm` source code and the `.txt` file containing the instructions in hexadecimal format.其他测试用例对应的.asm源码，以及hex格式的指令.txt文件
  - other/
    - The remaining code or tools related to bonus,  其余和bonus相关的代码或工具
  - gitlog.txt
    - The commit log dumped by the "git log" command includes complete information such as commit, author information, Date, and comment.        使用"**git log**"命令dump出的提交日志，包含commit、提交人信息、Date、comment等完整信息
    - **notes:  注意**：
      - The beginning of gitlog.txt lists the information of each commiter corresponding to the member name.          gitlog.txt开头列出每个提交人信息对应成员名姓名
      - **Important: The course team will conduct duplicate checking on all Verilog and ASM codes after the project presentation! If there is any violation of academic integrity in the assignment, the project score will be 0. The information of each submitter is listed at the beginning of gitlog.txt, corresponding to the member's name.          重要：课程组将于项目汇报后对所有verilog、asm代码进行查重！如违背作业诚信，项目成绩为0分**

  1. Place the above content in a folder and name it "c_Instruction Set Type (rv or la)_Member Name List", such as "c_rv_zhangsan_lisi_wangwu", or "c_la_zhangsan_lisi_wangwu". Then, compress this folder into a zip file and submit it. For example.   将以上内容放入文件夹中，命名为c_指令集类型(rv或la)_成员姓名列表，如 **c_rv_zhangsan_lisi_wangwu**, 或者**c_la_zhangsan_lisi_wangwu**，将该文件夹打包成压缩包并提交。举例：

     ```
     c_rv_zhangsan_lisi_wangwu/
     ├── cpu_project/
     │   ├── cpu_project.xpr
     │   ├── cpu_project.srcs/*
     │   └── cpu_project.runs/*
     │       └── impl_1/
     │           ├── TopDebug.bit
     │           ├── TopDebug_opt.dcp
     │           ├── TopDebug_placed.dcp
     │           └── TopDebug_routed.dcp
     ├── assembly/*
     ├── other/*
     └── gitlog.txt
     ```

     - With '/*' indicating that the entire subdirectory needs to be submitted.   带 ‘/*’ 表示需提交整个子目录
     - **Important: The main folder and all its subfolders must not contain any Chinese characters.     重要，作业文件夹及下层子目录不可包含任何中文字符**

  2. To ensure the smooth execution of the automated evaluation, this project does not allow the use of any built-in or third-party IP cores provided by Vivado (If memory and PLL are needed, please implement equivalent functions using Verilog code as described in the experimental course instructions).  为保证自动化评测顺利执行，本次project不允许使用任何vivado自带或第三方IP核（如需使用memory和pll，请根据实验课介绍的方法，用verilog代码实现等价功能）。

  3. To ensure the smooth execution of automated testing, please initialize the Instruction Memory in the Verilog code using `readmemh` with the `batch_test.hex` file, so that the generated bitstream already contains the instructions for basic functional testing.为保证自动化评测顺利执行，请在Instruction Memory的Verilog代码中将batch_test.hex文件使用readmemh进行初始化，确保生成的bitstream已经自带完成基础功能测试的指令。

  #### 4.2.2 Document and Vedio. 文档及视频

  1. Document (in PDF format), document name: d_Instruction Set Type (RV or LA)_List of Member Names, document content requirements can be found in the appendix.          文档（pdf格式），文档名：d_指令集类型(rv或la)_成员姓名列表，文档内容要求见附录
  2. Video (in mp4 format), file name: v_Instruction Set Type (RV or LA)_List of Member Names, recommended size not to exceed 500M (if the size exceeds this limit, please handle it yourself before uploading).        视频（mp4格式），文件名：v_指令集类型(rv或la)_成员姓名列表，大小建议不超过500M（如超过该大小，请自行处理后再上传）
     - Please upload the files separately to BB. Do not include them in a compressed package.       请分两个文件上传至BB，不要打进压缩包
     - The document should focus on explaining the implementation principle of the CPU and the verification steps for mounting it on the board. The video should focus on demonstrating the verification process and expected results for mounting the board.       文档应侧重介绍CPU实现原理以及上板验证步骤，视频应侧重展示上板验证过程及预期效果。
     - It is necessary to ensure that the inspector can reproduce the verification scenarios based on the content of the documents and videos for scoring purposes.         需保证inspector能够根据文档和视频内容复现验证场景用于评分

  ## 5. Requirement on document and vedio. 文档及视频要求

  ### 5.1 document 文档

  Note: Please complete the document as required. The document does not need to be lengthy; you can use Chinese.       注意：请大家按照要求完成文档，文档不需要长篇大论，可以使用中文。

  1. Developer's Information: Each member's student number, name, assigned work, and contribution percentage.  开发者说明：每个成员的学号、姓名、所负责的工作、贡献百分比。

  2. Vivado version, such as 2017.4, operating system, such as Windows/Ubuntu, development board model, such as ego1 【0.5】     Vivado版本, 如2017.4，操作系统，如windows/Ubuntu, 开发板型号，如ego1 【0.5】

  3. Development plan schedule and implementation status, GitHub Classroom team name, member account corresponding to student name, repository address  【0.5】      开发计划日程安排和实施情况，github classroom团队名称，组员账号对应学生姓名，仓库地址 【0.5】

  4. Description of CPU Architecture Design【4.5】   CPU架构设计说明 【4.5】

     - CPU characteristics: ISA (including all instructions (instruction names, corresponding codes, usage methods), the referenced ISA, any updates or optimizations made for this assignment based on the referenced ISA; register (bit width and number) and other information); support for exception handling CPU特性： ISA（含所有指令（指令名、对应编码、使用方式），参考的ISA，基于参考ISA本次作业所做的更新或优化；寄存器（位宽和数目）等信息）；对于异常处理的支持情况。

     - CPU clock cycle, CPI, whether it is a single-cycle or multi-cycle CPU, and whether it supports pipeline (if so, how many levels of pipeline, and what method is used to resolve pipeline conflict issues)     CPU时钟周期、CPI，属于单周期还是多周期CPU，是否支持pipeline（如支持，是几级流水，采用什么方式解决的流水线冲突问题）。

     - Address space design: Whether it belongs to the von Neumann architecture or the Harvard architecture; Addressing unit, size of the instruction space and data space, base address of the stack space.   寻址空间设计：属于冯.诺依曼结构还是哈佛结构；寻址单位，指令空间、数据空间的大小，栈空间的基地址。

     - Support for peripheral I/O: Whether to use separate instructions for accessing peripherals (please specify the corresponding instructions) or MMIO (please specify the corresponding addresses for the related peripherals), and whether to access I/O through polling or interrupt methods.  对外设IO的支持：采用单独的访问外设的指令（需写明相应的指令）还是MMIO（需写明相关外设对应的地址），采用轮询还是中断的方式访问IO。

     - CPU interface: Clock, reset, UART interface, description of other I/O interfaces   CPU接口：时钟、复位、uart接口、其他IO接口说明。

     - System board operation instructions: Instructions for input and output operations related to system operation on the development board. (Such as the input device used for resetting, how to perform the reset; the keys for switching CPU working modes and how to achieve mode selection; the observation area for output signals and the corresponding relationship with output data, etc.)     系统上板使用说明： 开发板上与系统操作相关输入、输出操作说明。（如复位使用的输入设备、如何实现复位；CPU工作模式切换的按键及如何实现模式选择；输出信号的观测区域，与输出数据的对应关系等）

     - Description on self-tests.  自测试说明：

       List the test methods (simulation, board placement, Difftest), test types (unit, integration), test case descriptions (excluding those in this article and OJ), test results (pass, fail), and the final test conclusion in a tabular format.    以表格的方式罗列出测试方法（仿真、上板、Difftest）、测试类型（单元、集成）、测试用例（除本文及OJ以外的用例）描述、测试结果（通过、不通过）；以及最终的测试结论。

  5. bonus（if there is） [Score together with the previous part] 【和前面部分一起评分】

     - Bonus corresponding to the design description of functional points.        bonus 对应功能点的设计说明
     - Design concept and relationship with surrounding modules         设计思路及与周边模块的关系
     - Core code and necessary explanations         核心代码及必要说明
     - Test Description: Detailed test cases, methods, and results.        测试说明：详细测试用例、方法、结果。

  ​     \6. Problems and Summaries: Problems encountered during the development process, thoughts, summaries, as well as opinions and suggestions regarding the course project. [1.5]  （This section does not need to be included in the document; it will be submitted as a questionnaire, and the link will be updated later.）    问题及总结：开发过程中遇到的问题、思考、总结，以及对课程项目的意见和建议。【1.5】（该部分无需写进文档，将以问卷形式提交，链接后续更新）

  ### 5.2 Video视频

  1. The beginning of the video introduces the information of all members and their general roles (all members need to appear on camera) [0.5]        视频开头介绍全组成员信息和大致分工（需全员出镜）【0.5】
  2. During the introduction process, the computer operation interface, FPGA development board, and other peripheral devices (if any) should be displayed to enable a clear understanding of the operation process and input/output effects. [1.5]        介绍过程中需展示电脑操作界面、FPGA开发板，以及其他外设（如有），以便清晰了解操作流程以及输入输出效果【1.5】
  3. For the basic part, at least two complex use cases need to be introduced along with their complete verification processes [3].         对于基础部分，需介绍至少两个复杂用例的完整验证过程【3】
  4. For bonuses (if any), it is necessary to describe the tools used for bonuses and demonstrate the key features [and rate together with the previous part]         对于bonus（如有），需介绍bonus使用的工具、以及重点功能演示【和前面部分一起评分】
  5. The video can be edited. Finally, all the contents will be combined into a complete video for submission. It is not allowed to use AI to generate the voice in the video.        视频可剪辑，最后将所有内容合并成一个完整视频提交。不可使用AI自动生成视频中的语音

  ## 6. Project evaluation method 项目评测方式

  1. **Base and Bonus: Insertion Function       基础和Bonus：上板功能**
     1. This semester, we will use Difftest for offline testing (both risc-v and loongarch can be used). The basic principles and testing methods of the testing tool can be found in the video: https://meeting.tencent.com/crm/23YBZYMq68.    本学期使用Difftest做离线评测（risc-v， loongarch均可使用），评测工具基本原理和评测方法见视频：https://meeting.tencent.com/crm/23YBZYMq68
     2. It is suggested to first implement the CPU based on traditional testing methods (using switches, buttons, LEDs for data input and result output), and then add the Debug function (Difftest).   建议先实现基于传统测试方法的CPU（拨码开关、按键、LED等做数据输入和结果输出），再添加Debug功能（Difftest）
     3. The implementation method of the Debug function and the related code will be released to everyone in a separate file format in the future.    Debug功能实现方法和相关代码后续将以单独文件形式发布给大家
  2. **In-class Design 现场设计：**
     1. Time: For the 15-week experimental course.           时间：15周实验课
     2. In an no-internet environment, students must use Vivado on the provided lab computers to design a simple instruction of comparable difficulty to RV32I. The instructor will provide the instruction format, opcode, and 32‑bit machine code on site. Each group must modify the CPU hardware design accordingly, then initialize or write the machine code into the instruction memory and run the test. Immediate successful verification earns the credit. The use of personal laptops or mobile phones is strictly prohibited; any violation will be treated as cheating.       内容：断网环境下，使用学生机的vivado，设计一条和RV32I同等难度的简单指令，根据教师现场提供的指令格式、opcode，32位机器码，小组自行修改cpu硬件设计并将指令初始化或写入指令内存进行测试，当场验证成功可获得分数。严禁使用个人电脑、手机，违者按作弊处理。 
     3. All members are required to attend. Groups that submit code late will be scheduled for a make‑up live design session during the final exam week.      全班需出席，代码迟交小组，期末周，统一安排时间进行现场设计。
     4. **Any member who does not participate will receive 0 points, and the remaining group members will be automatically split (i.e., regrouped without the absent member)..             未参加成员0分，剩余组员自动拆组。**

  ## 7. If automatic evaluation cannot be achieved     如无法实现自动评测

  Submit the code, documents and videos within the specified time. The inspector will conduct a manual evaluation. The requirements are as follows:         请在规定时间内提交代码、文档和视频，inspector会进行人工评测，要求如下：

  1. **It is necessary to ensure that the traditional toggle switches, LEDs and other peripheral devices can be used for testing.          需确保能够使用传统拨码开关、LED等外设进行测试**

  2. The development must be carried out using the Vivado 2017.4 version.        必须使用vivado 2017.4版本进行开发

  3. The document and video should provide a detailed description of the bitstream generation process, as well as each sample test step, to ensure that the inspector can reproduce the results in other environments for scoring purposes.  文档和视频中需详细介绍bitstream生成流程，每个样例测试步骤，以确保inspector可在其他环境中进行复现，用于评分

  4. If it is impossible to test on the develop board, a simulation must be provided and the testing method should be demonstrated. The score will be = actual simulation score * 0.3  如果无法上板，需提供仿真，并展示测试方法，分数=实际仿真得分*0.3

  5. The score shall be based on the actual test results provided by the inspector.           得分以inspector实际测试结果为准

  6. If the inspector is unable to reproduce the verification scenario based on the code, documentation, and video content, they must make an additional appointment for on-site testing. Otherwise, they will receive a score of 0.  若inspector无法根据代码、文档和视频内容复现验证场景，需单独预约时间进行现场测试，否则0分。

     