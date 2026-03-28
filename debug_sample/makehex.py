#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv

binfile = argv[1]
nwords = int(argv[2])

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) < 4*nwords
assert len(bindata) % 4 == 0

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4*i : 4*i+4]
        print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]))
    else:
        print("0")

header='''#File_format=Hex
#Address_depth=4096
#Data_width=8\n'''

f0=open('ram0.mi','w')
f0.write(header)
f1=open('ram1.mi','w')
f1.write(header)
f2=open('ram2.mi','w')
f2.write(header)
f3=open('ram3.mi','w')
f3.write(header)

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4*i : 4*i+4]
        print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]))
        f0.write('{:02x}\n'.format(w[0]))
        f1.write('{:02x}\n'.format(w[1]))
        f2.write('{:02x}\n'.format(w[2]))
        f3.write('{:02x}\n'.format(w[3]))
    else:
        print("0")


f0.close()
f1.close()
f2.close()
f3.close()