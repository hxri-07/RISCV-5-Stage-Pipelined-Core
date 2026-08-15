import sys
import os


def reg(s):
    s = s.strip().lower()

    if not s.startswith("x"):
        raise ValueError(f"Invalid register: {s}")

    num = int(s[1:])

    if num < 0 or num > 31:
        raise ValueError(f"Register out of range: {s}")

    return format(num, "05b")


def check_signed(value, bits, what):
    minimum = -(1 << (bits - 1))
    maximum = (1 << (bits - 1)) - 1

    if value < minimum or value > maximum:
        raise ValueError(
            f"{what} {value} does not fit in signed {bits}-bit range"
        )


def imm_to_bin(imm, bits):
    check_signed(imm, bits, "Immediate")

    if imm < 0:
        imm = (1 << bits) + imm

    return format(imm, f"0{bits}b")


def main():

    script_dir = os.path.dirname(os.path.abspath(__file__))

    asm_file = os.path.join(script_dir, "program.asm")
    hex_file = os.path.join(script_dir, "instr.hex")

    if len(sys.argv) >= 2:
        asm_file = sys.argv[1]

    if len(sys.argv) >= 3:
        hex_file = sys.argv[2]

    labels = {}
    lines = []
    pc = 0

    # PASS 1: LABELS
    with open(asm_file, "r") as f:

        for line_no, line in enumerate(f, start=1):

            line = line.split("#")[0].strip()

            if not line:
                continue

            if ":" in line:

                label, rest = line.split(":", 1)
                label = label.strip()

                if not label:
                    raise ValueError(
                        f"Empty label at line {line_no}"
                    )

                if label in labels:
                    raise ValueError(
                        f"Duplicate label '{label}' at line {line_no}"
                    )

                labels[label] = pc

                rest = rest.strip()

                if rest:
                    lines.append((pc, rest, line_no))
                    pc += 4

            else:

                lines.append((pc, line, line_no))
                pc += 4

    # PASS 2: GENERATE MACHINE CODE
    hex_out = []

    for pc, line, line_no in lines:

        parts = (
            line.replace(",", " ")
                .replace("(", " ")
                .replace(")", " ")
                .split()
        )

        if not parts:
            continue

        inst = parts[0].lower()

        try:

            # ADDI
            if inst == "addi":

                if len(parts) != 4:
                    raise ValueError("Expected: addi rd, rs1, imm")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                imm = int(parts[3])

                imm_bin = imm_to_bin(imm, 12)

                bin_str = (
                    f"{imm_bin}"
                    f"{rs1}"
                    f"000"
                    f"{rd}"
                    f"0010011"
                )

            # ADD
            elif inst == "add":

                if len(parts) != 4:
                    raise ValueError("Expected: add rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"000"
                    f"{rd}"
                    f"0110011"
                )

            # SUB
            elif inst == "sub":

                if len(parts) != 4:
                    raise ValueError("Expected: sub rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0100000"
                    f"{rs2}"
                    f"{rs1}"
                    f"000"
                    f"{rd}"
                    f"0110011"
                )

            # AND
            elif inst == "and":

                if len(parts) != 4:
                    raise ValueError("Expected: and rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"111"
                    f"{rd}"
                    f"0110011"
                )

            # OR
            elif inst == "or":

                if len(parts) != 4:
                    raise ValueError("Expected: or rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"110"
                    f"{rd}"
                    f"0110011"
                )

            # XOR
            elif inst == "xor":

                if len(parts) != 4:
                    raise ValueError("Expected: xor rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"100"
                    f"{rd}"
                    f"0110011"
                )

            # SLL
            elif inst == "sll":

                if len(parts) != 4:
                    raise ValueError("Expected: sll rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"001"
                    f"{rd}"
                    f"0110011"
                )

            # SRL
            elif inst == "srl":

                if len(parts) != 4:
                    raise ValueError("Expected: srl rd, rs1, rs2")

                rd = reg(parts[1])
                rs1 = reg(parts[2])
                rs2 = reg(parts[3])

                bin_str = (
                    f"0000000"
                    f"{rs2}"
                    f"{rs1}"
                    f"101"
                    f"{rd}"
                    f"0110011"
                )

            # LW
            elif inst == "lw":

                if len(parts) != 4:
                    raise ValueError("Expected: lw rd, imm(rs1)")

                rd = reg(parts[1])
                imm = int(parts[2])
                rs1 = reg(parts[3])

                imm_bin = imm_to_bin(imm, 12)

                bin_str = (
                    f"{imm_bin}"
                    f"{rs1}"
                    f"010"
                    f"{rd}"
                    f"0000011"
                )

            # SW
            elif inst == "sw":

                if len(parts) != 4:
                    raise ValueError("Expected: sw rs2, imm(rs1)")

                rs2 = reg(parts[1])
                imm = int(parts[2])
                rs1 = reg(parts[3])

                imm_bin = imm_to_bin(imm, 12)

                bin_str = (
                    f"{imm_bin[:7]}"
                    f"{rs2}"
                    f"{rs1}"
                    f"010"
                    f"{imm_bin[7:]}"
                    f"0100011"
                )

            # BEQ
            elif inst == "beq":

                if len(parts) != 4:
                    raise ValueError("Expected: beq rs1, rs2, label")

                rs1 = reg(parts[1])
                rs2 = reg(parts[2])
                label = parts[3]

                if label not in labels:
                    raise ValueError(
                        f"Undefined label '{label}' at line {line_no}"
                    )

                offset = labels[label] - pc

                if offset % 2 != 0:
                    raise ValueError(
                        f"Branch target is not 2-byte aligned at line {line_no}"
                    )

                imm_bin = imm_to_bin(offset, 13)

                bin_str = (
                    f"{imm_bin[0]}"
                    f"{imm_bin[2:8]}"
                    f"{rs2}"
                    f"{rs1}"
                    f"000"
                    f"{imm_bin[8:12]}"
                    f"{imm_bin[1]}"
                    f"1100011"
                )

            # BNE
            elif inst == "bne":

                if len(parts) != 4:
                    raise ValueError("Expected: bne rs1, rs2, label")

                rs1 = reg(parts[1])
                rs2 = reg(parts[2])
                label = parts[3]

                if label not in labels:
                    raise ValueError(
                        f"Undefined label '{label}' at line {line_no}"
                    )

                offset = labels[label] - pc

                if offset % 2 != 0:
                    raise ValueError(
                        f"Branch target is not 2-byte aligned at line {line_no}"
                    )

                imm_bin = imm_to_bin(offset, 13)

                bin_str = (
                    f"{imm_bin[0]}"
                    f"{imm_bin[2:8]}"
                    f"{rs2}"
                    f"{rs1}"
                    f"001"
                    f"{imm_bin[8:12]}"
                    f"{imm_bin[1]}"
                    f"1100011"
                )

            else:

                raise ValueError(
                    f"Unsupported instruction '{inst}' at line {line_no}"
                )

            if len(bin_str) != 32:
                raise ValueError(
                    f"Internal assembler error at line {line_no}: "
                    f"generated {len(bin_str)} bits"
                )

            hex_out.append(format(int(bin_str, 2), "08x"))

        except ValueError as e:
            raise ValueError(
                f"Assembler error at line {line_no}: {e}"
            ) from e

    # WRITE HEX FILE
    with open(hex_file, "w") as f:
        f.write("\n".join(hex_out))

    print(
        f"Assembly complete: {asm_file} -> {hex_file}"
    )


if __name__ == "__main__":
    main()
