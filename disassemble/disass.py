# Opcodes
# for each, we store the mnemonic and mode id (see 'modes' dict below)

opcodes = {
      0: [ 'BRK' ,  9 ],
      1: [ 'ORA' , 11 ],
      4: [ 'TSB' , 10 ],
      5: [ 'ORA' , 10 ],
      6: [ 'ASL' , 10 ],
      7: [ 'RMB0', 10 ],
      8: [ 'PHP' ,  9 ],
      9: [ 'ORA' ,  6 ],
     10: [ 'ASL' ,  5 ],
     12: [ 'TSB' ,  0 ],
     13: [ 'ORA' ,  0 ],
     14: [ 'ASL' ,  0 ],
     15: [ 'BBR0',  8 ],
     16: [ 'BPL' ,  8 ],
     17: [ 'ORA' , 15 ],
     18: [ 'ORA' , 14 ],
     20: [ 'TRB' , 10 ],
     21: [ 'ORA' , 12 ],
     22: [ 'ASL' , 12 ],
     23: [ 'RMB1', 10 ],
     24: [ 'CLC' ,  7 ],
     25: [ 'ORA' ,  3 ],
     26: [ 'INC' ,  5 ],
     28: [ 'TRB' ,  0 ],
     29: [ 'ORA' ,  2 ],
     30: [ 'ASL' ,  2 ],
     31: [ 'BBR1',  8 ],
     32: [ 'JSR' ,  0 ],
     33: [ 'AND' , 11 ],
     36: [ 'BIT' , 10 ],
     37: [ 'AND' , 10 ],
     38: [ 'ROL' , 10 ],
     39: [ 'RMB2', 10 ],
     40: [ 'PLP' ,  9 ],
     41: [ 'AND' ,  6 ],
     42: [ 'ROL' ,  5 ],
     44: [ 'BIT' ,  0 ],
     45: [ 'AND' ,  0 ],
     46: [ 'ROL' ,  0 ],
     47: [ 'BBR2',  8 ],
     48: [ 'BMI' ,  8 ],
     49: [ 'AND' , 15 ],
     50: [ 'AND' , 14 ],
     52: [ 'BIT' , 12 ],
     53: [ 'AND' , 12 ],
     54: [ 'ROL' , 12 ],
     55: [ 'RMB3', 10 ],
     56: [ 'SEC' ,  7 ],
     57: [ 'AND' ,  3 ],
     58: [ 'DEC' ,  5 ],
     60: [ 'BIT' ,  2 ],
     61: [ 'AND' ,  2 ],
     62: [ 'ROL' ,  2 ],
     63: [ 'BBR3',  8 ],
     64: [ 'RTI' ,  9 ],
     65: [ 'EOR' , 11 ],
     69: [ 'EOR' , 10 ],
     70: [ 'LSR' , 10 ],
     71: [ 'RMB4', 10 ],
     72: [ 'PHA' ,  9 ],
     73: [ 'EOR' ,  6 ],
     74: [ 'LSR' ,  5 ],
     76: [ 'JMP' ,  0 ],
     77: [ 'EOR' ,  0 ],
     78: [ 'LSR' ,  0 ],
     79: [ 'BBR4',  8 ],
     80: [ 'BVC' ,  8 ],
     81: [ 'EOR' , 15 ],
     82: [ 'EOR' , 14 ],
     85: [ 'EOR' , 12 ],
     86: [ 'LSR' , 12 ],
     87: [ 'RMB5', 10 ],
     88: [ 'CLI' ,  7 ],
     89: [ 'EOR' ,  3 ],
     90: [ 'PHY' ,  9 ],
     93: [ 'EOR' ,  2 ],
     94: [ 'LSR' ,  2 ],
     95: [ 'BBR5',  8 ],
     96: [ 'RTS' ,  9 ],
     97: [ 'ADC' , 11 ],
    100: [ 'STZ' , 10 ],
    101: [ 'ADC' , 10 ],
    102: [ 'ROR' , 10 ],
    103: [ 'RMB6', 10 ],
    104: [ 'PLA' ,  9 ],
    105: [ 'ADC' ,  6 ],
    106: [ 'ROR' ,  5 ],
    108: [ 'JMP' ,  4 ],
    109: [ 'ADC' ,  0 ],
    110: [ 'ROR' ,  0 ],
    111: [ 'BBR6',  8 ],
    112: [ 'BVS' ,  8 ],
    113: [ 'ADC' , 15 ],
    114: [ 'ADC' , 14 ],
    116: [ 'STZ' , 12 ],
    117: [ 'ADC' , 12 ],
    118: [ 'ROR' , 12 ],
    119: [ 'RMB7', 10 ],
    120: [ 'SEI' ,  7 ],
    121: [ 'ADC' ,  3 ],
    122: [ 'PLY' ,  9 ],
    124: [ 'JMP' ,  1 ],
    125: [ 'ADC' ,  2 ],
    126: [ 'ROR' ,  2 ],
    127: [ 'BBR7',  8 ],
    128: [ 'BRA' ,  8 ],
    129: [ 'STA' , 11 ],
    132: [ 'STY' , 10 ],
    133: [ 'STA' , 10 ],
    134: [ 'STX' , 10 ],
    135: [ 'SMB0', 10 ],
    136: [ 'DEY' ,  7 ],
    137: [ 'BIT' ,  6 ],
    138: [ 'TXA' ,  7 ],
    140: [ 'STY' ,  0 ],
    141: [ 'STA' ,  0 ],
    142: [ 'STX' ,  0 ],
    143: [ 'BBS0',  8 ],
    144: [ 'BCC' ,  8 ],
    145: [ 'STA' , 15 ],
    146: [ 'STA' , 14 ],
    148: [ 'STY' , 12 ],
    149: [ 'STA' , 12 ],
    150: [ 'STX' , 13 ],
    151: [ 'SMB1', 10 ],
    152: [ 'TYA' ,  7 ],
    153: [ 'STA' ,  3 ],
    154: [ 'TXS' ,  7 ],
    156: [ 'STZ' ,  0 ],
    157: [ 'STA' ,  2 ],
    158: [ 'STZ' ,  2 ],
    159: [ 'BBS1',  8 ],
    160: [ 'LDY' ,  6 ],
    161: [ 'LDA' , 11 ],
    162: [ 'LDX' ,  6 ],
    164: [ 'LDY' , 10 ],
    165: [ 'LDA' , 10 ],
    166: [ 'LDX' , 10 ],
    167: [ 'SMB2', 10 ],
    168: [ 'TAY' ,  7 ],
    169: [ 'LDA' ,  6 ],
    170: [ 'TAX' ,  7 ],
    172: [ 'LDY' ,  0 ],
    173: [ 'LDA' ,  0 ],
    174: [ 'LDX' ,  0 ],
    175: [ 'BBS2',  8 ],
    176: [ 'BCS' ,  8 ],
    177: [ 'LDA' , 15 ],
    178: [ 'LDA' , 14 ],
    180: [ 'LDY' , 12 ],
    181: [ 'LDA' , 12 ],
    182: [ 'LDX' , 13 ],
    183: [ 'SMB3', 10 ],
    184: [ 'CLV' ,  7 ],
    185: [ 'LDA' ,  3 ],
    186: [ 'TSX' ,  7 ],
    188: [ 'LDY' ,  2 ],
    189: [ 'LDA' ,  2 ],
    190: [ 'LDX' ,  3 ],
    191: [ 'BBS3',  8 ],
    192: [ 'CPY' ,  6 ],
    193: [ 'CMP' , 11 ],
    196: [ 'CPY' , 10 ],
    197: [ 'CMP' , 10 ],
    198: [ 'DEC' , 10 ],
    199: [ 'SMB4', 10 ],
    200: [ 'INY' ,  7 ],
    201: [ 'CMP' ,  6 ],
    202: [ 'DEX' ,  7 ],
    203: [ 'WAI' ,  7 ],
    204: [ 'CPY' ,  0 ],
    205: [ 'CMP' ,  0 ],
    206: [ 'DEC' ,  0 ],
    207: [ 'BBS4',  8 ],
    208: [ 'BNE' ,  8 ],
    209: [ 'CMP' , 15 ],
    210: [ 'CMP' , 14 ],
    213: [ 'CMP' , 12 ],
    214: [ 'DEC' , 12 ],
    215: [ 'SMB5', 10 ],
    216: [ 'CLD' ,  7 ],
    217: [ 'CMP' ,  3 ],
    218: [ 'PHX' ,  9 ],
    219: [ 'STP' ,  7 ],
    221: [ 'CMP' ,  2 ],
    222: [ 'DEC' ,  2 ],
    223: [ 'BBS5',  8 ],
    224: [ 'CPX' ,  6 ],
    225: [ 'SBC' , 11 ],
    228: [ 'CPX' , 10 ],
    229: [ 'SBC' , 10 ],
    230: [ 'INC' , 10 ],
    231: [ 'SMB6', 10 ],
    232: [ 'INX' ,  7 ],
    233: [ 'SBC' ,  6 ],
    234: [ 'NOP' ,  7 ],
    236: [ 'CPX' ,  0 ],
    237: [ 'SBC' ,  0 ],
    238: [ 'INC' ,  0 ],
    239: [ 'BBS6',  8 ],
    240: [ 'BEQ' ,  8 ],
    241: [ 'SBC' , 15 ],
    242: [ 'SBC' , 14 ],
    245: [ 'SBC' , 12 ],
    246: [ 'INC' , 12 ],
    247: [ 'SMB7', 10 ],
    248: [ 'SED' ,  7 ],
    249: [ 'SBC' ,  3 ],
    250: [ 'PLX' ,  9 ],
    253: [ 'SBC' ,  2 ],
    254: [ 'INC' ,  2 ],
    255: [ 'BBS7',  8 ],
}

# Addressing modes
# for each, we store the mode name and instructions length

modes = {
    0: [ 'a', 3 ],
    1: [ '(a,x)', 3 ],
    2: [ 'a,x', 3 ],
    3: [ 'a,y', 3 ],
    4: [ '(a)', 3 ],
    5: [ 'A', 1 ],
    6: [ '#', 2 ],
    7: [ 'i', 1 ],
    8: [ 'r', 2 ],
    9: [ 's', 1 ],
    10: [ 'zp', 2 ],
    11: [ '(zp,x)', 2 ],
    12: [ 'zp,x', 2 ],
    13: [ 'zp,y', 2 ],
    14: [ '(zp)', 2 ],
    15: [ '(zp),y', 2 ],
}

def isValidOpcode(b):
    return b in opcodes.keys()

# decode an opcode byte b
# returns mnemonic, mode, length
def decode(b):
    if isinstance(b,str):
        b=hex2dec(b)
    if isValidOpcode(b):
        o, m = opcodes[b]
        m, l = modes[m]
        return o, m, l
    else:
        return None,None,None

def hex2dec(s):
    return int(s,16)

def render_instr(_args):
    # args is a list: addr, mnemonic, [op1, op2]
    # addr: the instruction's address. int or hex str
    # mnemonic, op1 & op2 are strings in hex

    # we create a copy of the _args list, because we will modify it
    args=_args[:]

    # we revers the list, so we can pop each item
    # and at the end, the operand's byte are correctly ordered
    addr = args.pop(0)
    if isinstance(addr,str):
        addr=hex2dec(addr)

    opcode = args.pop(0)

    args.reverse()
    operand="".join(args)
    args.reverse() # now we need it again in the chronological order, for hexdump

    comment = ""

    unknown = ".."

    o,m,l = decode(opcode)

    miss = l - len(args) - 1 # how many operands bytes we are missing

    operand = unknown*miss + operand

    hexdump = " ".join( [opcode] + args + [ unknown for _ in range(miss) ])

    #if o.startswith("b") and o not in ["bit", "brk"] :
    if m == "r" :
        if miss==0 :
            dest = addr + 2
            operand = hex2dec(operand)
            if operand > 0x7f:
                dest -= 0x100 - operand
            else:
                dest += operand
            operand = "%04X" % dest
        else:
            # add an extra unknown byte
            operand = unknown + operand
    
    if l>1:
        operand = "$"+operand

    if m == "#":
        operand = "#"+operand
    if ',x' in m:
        operand += ",x"
    if m.startswith('('):
        operand = "(" + operand + ")"
    if m.endswith('y'):
        operand += ",y"
    if m == "A":
        operand = "A"
    
    return ("%04X  %-12s %s %-10s   %-4s %s" % (addr, hexdump.upper(), o, operand, m, comment))
