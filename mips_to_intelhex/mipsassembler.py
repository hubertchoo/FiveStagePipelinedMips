import re

def twos_complement(val, nbits):
    """Compute the 2's complement of int value val"""
    if val < 0:
        val = (1 << nbits) + val
    else:
        if (val & (1 << (nbits - 1))) != 0:
            # If sign bit is set.
            # compute negative value.
            val = val - (1 << nbits)
    return val

'''
def signext(binString, desiredLen):
    return binString[0] * (desiredLen - len(binString)) + binString
'''

def assembler():

    regset = ['$0', '$at', '$v0', '$v1', '$a0', '$a1', '$a2', '$a3', '$t0', '$t1', '$t2', '$t3', '$t4', '$t5', '$t6', '$t7', '$s0', '$s1', '$s2', '$s3', '$s4', '$s5', '$s6', '$s7', '$t8', '$t9', '$k0', '$k1', '$gp', '$sp', '$fp', '$ra']
    
    asmfile = open("main.asm", 'r')
    outputfile = open("instructionshex.txt", 'w')
    line = asmfile.readline()
    while (line):
        # each line in the program
        
        rtype_regex = re.compile(r"^([A-Za-z]+).*(\$[A-Za-z0-9]+),.*(\$[A-Za-z0-9]+),.*(\$[A-Za-z0-9]+)$", re.IGNORECASE)
        rtype_match = rtype_regex.match(line)

        itype_regex = re.compile(r"^([A-Za-z]+).*(\$[A-Za-z0-9]+),.*([+-]?(?=\.\d|\d)(?:\d+)?(?:\.?\d*))(?:[Ee]([+-]?\d+))?\([^)]*\)$", re.IGNORECASE)
        itype_match = itype_regex.match(line)

        addi_regex = re.compile(r"^([A-Za-z]+).*(\$[A-Za-z0-9]+),.*(\$[A-Za-z0-9]+),.*([+-]?(?=\.\d|\d)(?:\d+)?(?:\.?\d*))(?:[Ee]([+-]?\d+))?$", re.IGNORECASE)
        addi_match = addi_regex.match(line)

        hex_code = ""

        if rtype_match:
            # op
            op = "000000"

            # funct
            if rtype_match.group(1).upper() == "ADD":
                funct = "100000"
            if rtype_match.group(1).upper() == "SUB":
                funct = "100010"
            if rtype_match.group(1).upper() == "AND":
                funct = "100100"
            if rtype_match.group(1).upper() == "OR":
                funct = "100101"
            if rtype_match.group(1).upper() == "SLT":
                funct = "101010"

            # shamt
            shamt = "00000"

            # reg
            d_reg = regset.index(rtype_match.group(2))
            d = bin(d_reg)[2:].zfill(5)
            s_reg = regset.index(rtype_match.group(3))
            s = bin(s_reg)[2:].zfill(5)
            t_reg = regset.index(rtype_match.group(4))
            t = bin(t_reg)[2:].zfill(5)

            bin_code = op + s + t + d + shamt + funct
            hex_code = "{0:#0{1}x}".format(int(bin_code,2),10)
        
        elif itype_match:

            # op
            if itype_match.group(1).upper() == "LW":
                op = "100011"

            elif itype_match.group(1).upper() == "SW":
                op = "101011"

            elif itype_match.group(1).upper() == "ADDI":
                op = "001000"

            # reg
            t_reg = regset.index(itype_match.group(2))
            t = bin(t_reg)[2:].zfill(5)
            # find s between the brackets
            s_str = line[line.index("(") +1 : line.index(")")].strip()
            s_reg = regset.index(s_str)
            s = bin(s_reg)[2:].zfill(5)

            # imm, between , and (
            # have to get the twos complement
            imm_str = line[line.index(",") +1 : line.index("(")].strip()
            imm = int(imm_str)
            imm = bin(twos_complement(imm, 16))[2:]

            bin_code = op + s + t + imm
            hex_code = "{0:#0{1}x}".format(int(bin_code,2),10)

        elif "beq" in line.lower():
            beq_regex = re.compile(r"^[A-Za-z]+.*(\$[A-Za-z0-9]+),.*(\$[A-Za-z0-9]+),.*([+-]?(?=\.\d|\d)(?:\d+)?(?:\.?\d*))(?:[Ee]([+-]?\d+))?$", re.IGNORECASE)
            beq_match = beq_regex.match(line)
            
            # reg
            s_reg = regset.index(beq_match.group(1))
            s = bin(s_reg)[2:].zfill(5)
            t_reg = regset.index(beq_match.group(2))
            t = bin(t_reg)[2:].zfill(5)
            
            # imm
            imm = int(line.split(",")[-1].strip())
            imm = bin(twos_complement(imm, 16))[2:]

            # op
            op = "000100"

            bin_code = op + s + t + imm
            hex_code = "{0:#0{1}x}".format(int(bin_code,2),10)

        elif addi_match:
            if addi_match.group(1).upper() == "ADDI":
                d_reg = regset.index(addi_match.group(2))
                d = bin(d_reg)[2:].zfill(5)
                s_reg = regset.index(addi_match.group(3))
                s = bin(s_reg)[2:].zfill(5)
                imm = int(line.split(',')[-1].strip())
                imm = bin(twos_complement(imm, 16))[2:]

                op = "001000"

                bin_code = op + s + d + imm
                hex_code = "{0:#0{1}x}".format(int(bin_code,2),10)

        else:
            print("No matches found")

        outputfile.write(hex_code + '\n')
        line = asmfile.readline()
        line = line.strip()

    asmfile.close()
    outputfile.close()


def intel_hex_checksum(intel_hex_input):
    # https://en.wikipedia.org/wiki/Intel_HEX

    line_data = [int(intel_hex_input[x:x+2],16) for x in range(1,len(intel_hex_input),2)]
    chksum = ((sum(line_data[:-1]) ^ 0xff)+1 ) & 0xff
    return hex(chksum)[-2:].upper()

def assembly_to_intelhex():

    # :llaaaatt[dd...]cc
    hexfile = open("instructionsoutput.hex", 'w')
    asmhexfile = open("instructionshex.txt", 'r')

    line = asmhexfile.readline().strip()
    linecounter = 0
    while (line):
        outputline = ":04"
        outputline += str(linecounter).zfill(4)
        outputline += "00"
        outputline += line[2:].upper()
        outputline += intel_hex_checksum(outputline)

        linecounter += 1
        line = asmhexfile.readline().strip()
        line = line.strip()
        hexfile.write(outputline + '\n')

    hexfile.write(":00000001FF")
    hexfile.close()
    asmhexfile.close()    

assembler()
assembly_to_intelhex()