#! /usr/bin/env python3

import sys

def end8( index, count):
    if index == 7:
        return( ", -- %d\n" % ( count / 8))
    else:
        return( ", ")


if len( sys.argv) < 2:
    print( "convert binary file to constant integer array for VHDL import")
    print( "usage: %s <filename>" % sys.argv[0] )
    sys.exit()


index = 0
count = 0

with open( sys.argv[ 1], "rb") as f:

    data = f.read()

    for byte in data:
        print( "16#%02x#" % byte, end = end8( index, count))
        index = ( index + 1) % 8
        count += 1
        #print( "%d " % list( byte))
