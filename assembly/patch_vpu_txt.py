from pathlib import Path
import re

IN_FILE = Path("vpu_test.txt")
OUT_FILE = Path("vpu_test_patched.txt")

NOP = 0x00000013
JALR_ZERO_T5_0 = 0x000F0067

CUSTOM_VPU_INSTRUCTIONS = {
    0x00730E8B,  # vpnot
    0x00731E8B,  # vpneg
    0x00732E8B,  # vpabs
    0x00733E8B,  # vpadd
    0x00734E8B,  # vpsub
    0x00735E8B,  # vpand
    0x00736E8B,  # vpor
    0x00737E8B,  # vpxor
    0x02730E8B,  # vpsll
    0x02731E8B,  # vpsrl
    0x02732E8B,  # vpmin
    0x02733E8B,  # vpmax
}


def parse_hex_word(line: str):
    s = line.strip()
    if not s or s.startswith("#"):
        return None

    token = s.split()[0]
    token = token.replace("0x", "").replace("0X", "")

    if re.fullmatch(r"[0-9a-fA-F]{1,8}", token):
        return int(token, 16)

    return None


def is_lui_t5(word: int) -> bool:
    opcode = word & 0x7F
    rd = (word >> 7) & 0x1F
    return opcode == 0x37 and rd == 30


def is_addi_t5_t5(word: int) -> bool:
    opcode = word & 0x7F
    rd = (word >> 7) & 0x1F
    funct3 = (word >> 12) & 0x7
    rs1 = (word >> 15) & 0x1F
    return opcode == 0x13 and rd == 30 and funct3 == 0 and rs1 == 30


def sext12(x: int) -> int:
    x &= 0xFFF
    return x - 0x1000 if x & 0x800 else x


def reconstruct_lui_addi_value(lui_word: int, addi_word: int) -> int:
    upper = lui_word & 0xFFFFF000
    imm12 = sext12(addi_word >> 20)
    return (upper + imm12) & 0xFFFFFFFF


def main():
    words = []

    for line in IN_FILE.read_text().splitlines():
        word = parse_hex_word(line)
        if word is not None:
            words.append(word)

    patched = []
    i = 0
    patch_count = 0

    while i < len(words):
        if (
            i + 2 < len(words)
            and is_lui_t5(words[i])
            and is_addi_t5_t5(words[i + 1])
            and words[i + 2] == JALR_ZERO_T5_0
        ):
            custom_inst = reconstruct_lui_addi_value(words[i], words[i + 1])

            if custom_inst in CUSTOM_VPU_INSTRUCTIONS:
                patched.append(custom_inst)
                patched.append(NOP)
                patched.append(NOP)
                patch_count += 1
                i += 3
                continue

        patched.append(words[i])
        i += 1

    OUT_FILE.write_text("\n".join(f"{w:08X}" for w in patched) + "\n")

    print(f"Input instructions : {len(words)}")
    print(f"Output instructions: {len(patched)}")
    print(f"Patched VPU cases  : {patch_count}")
    print(f"Output file        : {OUT_FILE}")

    if patch_count != 12:
        print("WARNING: expected to patch 12 VPU instructions.")
        print("Please check whether vpu_test.asm still uses lui/addi/jalr with t5.")


if __name__ == "__main__":
    main()