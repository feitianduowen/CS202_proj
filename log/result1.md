Successfully connected to COM5

--- Loading program: D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/vpu_test.txt ---
Read 79 instructions from D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/vpu_test.txt
Loading 79 instructions to 0x00000000...
  Progress: 79/79
Verifying...
Verify OK: all 79 instructions correct
Program loaded successfully


--- TestCase Batch Test (Data Base: 0x4000 - Hardwired to GP) ---
  [1/24] case=0 ops=[0x000000FF, 0x00000000] => 0x40400000 (expect 0xFFFFFF00) FAIL
  [2/24] case=0 ops=[0xFF00FF00, 0x00000000] => 0x40400000 (expect 0x00FF00FF) FAIL
  [3/24] case=1 ops=[0x00000001, 0x00000000] => 0x40400000 (expect 0xFFFFFFFF) FAIL
  [4/24] case=1 ops=[0x00000080, 0x00000000] => 0x40400000 (expect 0xFFFFFF80) FAIL
  [5/24] case=2 ops=[0xFFFFFF80, 0x00000000] => 0x40400000 (expect 0x00000080) FAIL
  [6/24] case=2 ops=[0x0000007F, 0x00000000] => 0x40400000 (expect 0x0000007F) FAIL
  [7/24] case=3 ops=[0x01020304, 0x01010101] => 0x40400000 (expect 0x02030405) FAIL
  [8/24] case=3 ops=[0x0A0B0C0D, 0x01010101] => 0x40400000 (expect 0x0B0C0D0E) FAIL
  [9/24] case=4 ops=[0x04030201, 0x01010101] => 0x40400000 (expect 0x03020100) FAIL
  [10/24] case=4 ops=[0x0A0B0C0D, 0x01010101] => 0x40400000 (expect 0x090A0B0C) FAIL
  [11/24] case=5 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0x0F000F00) FAIL
  [12/24] case=5 ops=[0x12345678, 0xF0F0F0F0] => 0x40400000 (expect 0x10305070) FAIL
  [13/24] case=6 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0xFF0FFF0F) FAIL
  [14/24] case=6 ops=[0x12345678, 0x0F0F0F0F] => 0x40400000 (expect 0x1F3F5F7F) FAIL
  [15/24] case=7 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0xF00FF00F) FAIL
  [16/24] case=7 ops=[0x12345678, 0xFFFFFFFF] => 0x40400000 (expect 0xEDCBA987) FAIL
  [17/24] case=8 ops=[0x01020304, 0x01010101] => 0x40400000 (expect 0x02040608) FAIL
  [18/24] case=8 ops=[0x01010101, 0x00000002] => 0x40400000 (expect 0x01010104) FAIL
  [19/24] case=9 ops=[0x02040608, 0x01010101] => 0x40400000 (expect 0x01020304) FAIL
  [20/24] case=9 ops=[0x80402010, 0x00000001] => 0x40400000 (expect 0x80402008) FAIL
  [21/24] case=10 ops=[0x05030201, 0x04030608] => 0x40400000 (expect 0x04030201) FAIL
  [22/24] case=10 ops=[0x01020304, 0x04030201] => 0x40400000 (expect 0x01020201) FAIL
  [23/24] case=11 ops=[0x05030201, 0x04030608] => 0x40400000 (expect 0x05030608) FAIL
  [24/24] case=11 ops=[0x01020304, 0x04030201] => 0x40400000 (expect 0x04030304) FAIL

====== Result: 0/24 passed ======


--- Loading program: D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/fp_test.txt ---
Read 34 instructions from D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/fp_test.txt
Loading 34 instructions to 0x00000000...
  Progress: 34/34
Verifying...
Verify OK: all 34 instructions correct
Program loaded successfully


--- TestCase Batch Test (Data Base: 0x4000 - Hardwired to GP) ---
  [1/3] case=0 ops=[0x3F800000, 0x40000000] => 0x40400000 (expect 0x40400000) PASS
  [2/3] case=1 ops=[0x40000000, 0x3F800000] => 0x40400000 (expect 0x3F800000) FAIL
  [3/3] case=2 ops=[0x40400000, 0x00000000] => 0x40400000 (expect 0x40400000) PASS

====== Result: 2/3 passed ======


--- Loading program: D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/vpu_test.txt ---
Read 79 instructions from D:/comp_sci/CS202 Computer Organization/OrganProj/cpu-project-team/assembly/vpu_test.txt
Loading 79 instructions to 0x00000000...
  Progress: 79/79
Verifying...
Verify OK: all 79 instructions correct
Program loaded successfully


--- TestCase Batch Test (Data Base: 0x4000 - Hardwired to GP) ---
  [1/24] case=0 ops=[0x000000FF, 0x00000000] => 0x40400000 (expect 0xFFFFFF00) FAIL
  [2/24] case=0 ops=[0xFF00FF00, 0x00000000] => 0x40400000 (expect 0x00FF00FF) FAIL
  [3/24] case=1 ops=[0x00000001, 0x00000000] => 0x40400000 (expect 0xFFFFFFFF) FAIL
  [4/24] case=1 ops=[0x00000080, 0x00000000] => 0x40400000 (expect 0xFFFFFF80) FAIL
  [5/24] case=2 ops=[0xFFFFFF80, 0x00000000] => 0x40400000 (expect 0x00000080) FAIL
  [6/24] case=2 ops=[0x0000007F, 0x00000000] => 0x40400000 (expect 0x0000007F) FAIL
  [7/24] case=3 ops=[0x01020304, 0x01010101] => 0x40400000 (expect 0x02030405) FAIL
  [8/24] case=3 ops=[0x0A0B0C0D, 0x01010101] => 0x40400000 (expect 0x0B0C0D0E) FAIL
  [9/24] case=4 ops=[0x04030201, 0x01010101] => 0x40400000 (expect 0x03020100) FAIL
  [10/24] case=4 ops=[0x0A0B0C0D, 0x01010101] => 0x40400000 (expect 0x090A0B0C) FAIL
  [11/24] case=5 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0x0F000F00) FAIL
  [12/24] case=5 ops=[0x12345678, 0xF0F0F0F0] => 0x40400000 (expect 0x10305070) FAIL
  [13/24] case=6 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0xFF0FFF0F) FAIL
  [14/24] case=6 ops=[0x12345678, 0x0F0F0F0F] => 0x40400000 (expect 0x1F3F5F7F) FAIL
  [15/24] case=7 ops=[0xFF00FF00, 0x0F0F0F0F] => 0x40400000 (expect 0xF00FF00F) FAIL
  [16/24] case=7 ops=[0x12345678, 0xFFFFFFFF] => 0x40400000 (expect 0xEDCBA987) FAIL
  [17/24] case=8 ops=[0x01020304, 0x01010101] => 0x40400000 (expect 0x02040608) FAIL
  [18/24] case=8 ops=[0x01010101, 0x00000002] => 0x40400000 (expect 0x01010104) FAIL
  [19/24] case=9 ops=[0x02040608, 0x01010101] => 0x40400000 (expect 0x01020304) FAIL
  [20/24] case=9 ops=[0x80402010, 0x00000001] => 0x40400000 (expect 0x80402008) FAIL
  [21/24] case=10 ops=[0x05030201, 0x04030608] => 0x40400000 (expect 0x04030201) FAIL
  [22/24] case=10 ops=[0x01020304, 0x04030201] => 0x40400000 (expect 0x01020201) FAIL
  [23/24] case=11 ops=[0x05030201, 0x04030608] => 0x40400000 (expect 0x05030608) FAIL
  [24/24] case=11 ops=[0x01020304, 0x04030201] => 0x40400000 (expect 0x04030304) FAIL

====== Result: 0/24 passed ======

Disconnected.
