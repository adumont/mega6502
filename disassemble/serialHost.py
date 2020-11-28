#! /usr/bin/env python
import serial
import time
from disass import decode, render_instr
from glob import glob

port = glob("/dev/ttyUSB*")

assert( len(port) > 0 )

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
            #print("%s | %s" % (ser_line, 36*" "+ "Not an instruction" ))
            print("%s |" % (ser_line))

        # 

ser.close()
