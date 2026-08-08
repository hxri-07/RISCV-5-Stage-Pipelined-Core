import sys

def reg(s):
    # Converts 'x1' to a 5-bit binary string '00001'
    return format(int(s.replace('x', '')), '05b')

def imm_to_bin(imm, bits):
    # Handles two's complement for negative numbers (branching backwards)
    if imm < 0:
        imm = (1 << bits) + imm
    return format(imm, f'0{bits}b')

def main():
    labels = {}
    lines = []
    pc = 0
    
    # Pass 1: Find Labels
    with open("program.asm", "r") as f:
        for line in f:
            line = line.split('#')[0].strip() # Remove comments
            if not line: continue
            
            if ':' in line:
                label, rest = line.split(':')
                labels[label.strip()] = pc
                if rest.strip():
                    lines.append((pc, rest.strip()))
                    pc += 4
            else:
                lines.append((pc, line))
                pc += 4

    # Pass 2: Assemble to Machine Code
    hex_out = []
    for pc, line in lines:
        parts = line.replace(',', ' ').replace('(', ' ').replace(')', ' ').split()
        inst = parts[0]
        
        if inst == 'addi':
            rd, rs1, imm = reg(parts[1]), reg(parts[2]), int(parts[3])
            imm_bin = imm_to_bin(imm, 12)
            bin_str = f"{imm_bin}{rs1}000{rd}0010011"
            
        elif inst == 'add':
            rd, rs1, rs2 = reg(parts[1]), reg(parts[2]), reg(parts[3])
            bin_str = f"0000000{rs2}{rs1}000{rd}0110011"
            
        elif inst == 'sub':
            rd, rs1, rs2 = reg(parts[1]), reg(parts[2]), reg(parts[3])
            bin_str = f"0100000{rs2}{rs1}000{rd}0110011"
            
        elif inst == 'beq':
            rs1, rs2, label = reg(parts[1]), reg(parts[2]), parts[3]
            offset = labels[label] - pc
            imm_bin = imm_to_bin(offset, 13)
            bin_str = f"{imm_bin[0]}{imm_bin[2:8]}{rs2}{rs1}000{imm_bin[8:12]}{imm_bin[1]}1100011"
            
        elif inst == 'bne':
            rs1, rs2, label = reg(parts[1]), reg(parts[2]), parts[3]
            offset = labels[label] - pc
            imm_bin = imm_to_bin(offset, 13)
            bin_str = f"{imm_bin[0]}{imm_bin[2:8]}{rs2}{rs1}001{imm_bin[8:12]}{imm_bin[1]}1100011"
            
        else:
            bin_str = "00000000000000000000000000010011" # NOP fallback
            
        hex_out.append(format(int(bin_str, 2), '08x'))

    with open("instr.hex", "w") as f:
        f.write('\n'.join(hex_out))
    print("Assembly complete! Generated instr.hex")

if __name__ == "__main__":
    main()