#! /usr/bin/env python
import serial
import time
from glob import glob

port = glob("/dev/ttyUSB*")

assert( len(port) > 0 )

# Opcodes
# for each, we store the mnemonic and mode id (see 'modes' dict below)
opcodes = {
    0: [ 'brk', 10 ], 1: [ 'ora', 8 ], 5: [ 'ora', 1 ], 6: [ 'asl', 1 ], 8: [ 'php', 10 ], 9: [ 'ora', 0 ], 10: [ 'asl', 10 ],
    13: [ 'ora', 4 ], 14: [ 'asl', 4 ], 16: [ 'bpl', 11 ], 17: [ 'ora', 9 ], 21: [ 'ora', 2 ], 22: [ 'asl', 2 ], 24: [ 'clc', 10 ],
    25: [ 'ora', 6 ], 29: [ 'ora', 5 ], 30: [ 'asl', 5 ], 32: [ 'jsr', 4 ], 33: [ 'and', 8 ], 36: [ 'bit', 1 ], 37: [ 'and', 1 ],
    38: [ 'rol', 1 ], 40: [ 'plp', 10 ], 41: [ 'and', 0 ], 42: [ 'rol', 10 ], 44: [ 'bit', 4 ], 45: [ 'and', 4 ], 46: [ 'rol', 4 ],
    48: [ 'bmi', 11 ], 49: [ 'and', 9 ], 53: [ 'and', 2 ], 54: [ 'rol', 2 ], 56: [ 'sec', 10 ], 57: [ 'and', 6 ], 61: [ 'and', 5 ],
    62: [ 'rol', 5 ], 64: [ 'rti', 10 ], 65: [ 'eor', 8 ], 66: [ 'wdm', 0 ], 66: [ 'wdm', 1 ], 69: [ 'eor', 1 ], 70: [ 'lsr', 1 ],
    72: [ 'pha', 10 ], 73: [ 'eor', 0 ], 74: [ 'lsr', 10 ], 76: [ 'jmp', 4 ], 77: [ 'eor', 4 ], 78: [ 'lsr', 4 ], 80: [ 'bvc', 11 ],
    81: [ 'eor', 9 ], 85: [ 'eor', 2 ], 86: [ 'lsr', 2 ], 88: [ 'cli', 10 ], 89: [ 'eor', 6 ], 93: [ 'eor', 5 ], 94: [ 'lsr', 5 ],
    96: [ 'rts', 10 ], 97: [ 'adc', 8 ], 101: [ 'adc', 1 ], 102: [ 'ror', 1 ], 104: [ 'pla', 10 ], 105: [ 'adc', 0 ], 
    106: [ 'ror', 10 ], 108: [ 'jmp', 7 ], 109: [ 'adc', 4 ], 110: [ 'ror', 4 ], 112: [ 'bvs', 11 ], 113: [ 'adc', 9 ], 
    117: [ 'adc', 2 ], 118: [ 'ror', 2 ], 120: [ 'sei', 10 ], 121: [ 'adc', 6 ], 125: [ 'adc', 5 ], 126: [ 'ror', 5 ], 129: [ 'sta', 8 ],
    132: [ 'sty', 1 ], 133: [ 'sta', 1 ], 134: [ 'stx', 1 ], 136: [ 'dey', 10 ], 138: [ 'txa', 10 ], 140: [ 'sty', 4 ], 141: [ 'sta', 4 ],
    142: [ 'stx', 4 ], 144: [ 'bcc', 11 ], 145: [ 'sta', 9 ], 148: [ 'sty', 2 ], 149: [ 'sta', 2 ], 150: [ 'stx', 3 ], 152: [ 'tya', 10 ],
    153: [ 'sta', 6 ], 154: [ 'txs', 10 ], 157: [ 'sta', 5 ], 160: [ 'ldy', 0 ], 161: [ 'lda', 8 ], 162: [ 'ldx', 0 ], 164: [ 'ldy', 1 ],
    165: [ 'lda', 1 ], 166: [ 'ldx', 1 ], 168: [ 'tay', 10 ], 169: [ 'lda', 0 ], 170: [ 'tax', 10 ], 172: [ 'ldy', 4 ], 173: [ 'lda', 4 ],
    174: [ 'ldx', 4 ], 176: [ 'bcs', 11 ], 177: [ 'lda', 9 ], 180: [ 'ldy', 2 ], 181: [ 'lda', 2 ], 182: [ 'ldx', 3 ], 184: [ 'clv', 10 ],
    185: [ 'lda', 6 ], 186: [ 'tsx', 10 ], 188: [ 'ldy', 5 ], 189: [ 'lda', 5 ], 190: [ 'ldx', 6 ], 192: [ 'cpy', 0 ], 193: [ 'cmp', 8 ],
    196: [ 'cpy', 1 ], 197: [ 'cmp', 1 ], 198: [ 'dec', 1 ], 200: [ 'iny', 10 ], 201: [ 'cmp', 0 ], 202: [ 'dex', 10 ], 204: [ 'cpy', 4 ],
    205: [ 'cmp', 4 ], 206: [ 'dec', 4 ], 208: [ 'bne', 11 ], 209: [ 'cmp', 9 ], 213: [ 'cmp', 2 ], 214: [ 'dec', 2 ], 216: [ 'cld', 10 ],
    217: [ 'cmp', 6 ], 221: [ 'cmp', 5 ], 222: [ 'dec', 5 ], 224: [ 'cpx', 0 ], 225: [ 'sbc', 8 ], 228: [ 'cpx', 1 ], 229: [ 'sbc', 1 ],
    230: [ 'inc', 1 ], 232: [ 'inx', 10 ], 233: [ 'sbc', 0 ], 234: [ 'nop', 10 ], 236: [ 'cpx', 4 ], 237: [ 'sbc', 4 ], 238: [ 'inc', 4 ],
    240: [ 'beq', 11 ], 241: [ 'sbc', 9 ], 245: [ 'sbc', 2 ], 246: [ 'inc', 2 ], 248: [ 'sed', 10 ], 249: [ 'sbc', 6 ], 253: [ 'sbc', 5 ],
    254: [ 'inc', 5 ]
}

# Addressing modes
# for each, we store the mode name and instructions length
modes = {
    0: [ 'Imm', 2 ],
    1: [ 'ZP', 2 ],
    2: [ 'ZPX', 2 ],
    3: [ 'ZPY', 2 ],
    4: [ 'ABS', 3 ],
    5: [ 'ABSX', 3 ],
    6: [ 'ABSY', 3 ],
    7: [ 'IND', 3 ],
    8: [ 'INDX', 2 ],
    9: [ 'INDY', 2 ],
    10: [ 'SNGL', 1 ],
    11: [ 'BRA', 2 ],
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

    if o.startswith("b") and o not in ["bit", "brk"] :
        if miss==0 :
            dest = addr + 2
            operand = hex2dec(operand)
            if operand > 0x7f:
                dest -= 0x100 - operand
            else:
                dest += operand
            operand = "%04x" % dest
        else:
            # add an extra unknown byte
            operand = unknown + operand
    
    if l>1:
        operand = "$"+operand

    if m == "Imm":
        operand = "#"+operand
    if m.endswith('X'):
        operand += ",X"
    if m.startswith('IND'):
        operand = "(" + operand + ")"
    if m.endswith('Y'):
        operand += ",Y"
    if hex2dec(opcode) in [ 10, 74, 42, 106 ]:
        operand = "A"
    
    return ("%04x  %-12s %s %-10s   %-4s %s" % (addr, hexdump, o, operand, m, comment))

ser = serial.Serial(
    port=port[0],
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=0
)

print("connected to: " + ser.portstr)

#this will store the line
seq = []
count = 1

miss = 0
instr=[]

while True:
    for c in ser.read():
        if chr(c) != '\n':
            seq.append(chr(c)) #convert to ascii
            continue

        ser_line = ''.join(str(v) for v in seq) #Make a string from array
        seq = []

        try:
            addr_cursor, b, rw, sync = ser_line.split(" ")
        except ValueError:
            print(ser_line)
            continue

        if sync=="1":
            # new instruction started
            # opcode fetched
            instr=[addr_cursor, b]
            _,_,l = decode(b)
            miss = l
        else:
            instr.append(b)

        miss -= 1
        if miss >= 0:
            print("%s | %s" % (ser_line, render_instr(instr) ))
        else:
            print("%s | %s" % (ser_line, 36*" "+ "Not an instruction" ))

        # 

ser.close()
