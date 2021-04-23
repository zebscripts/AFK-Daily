#!/bin/sh

hex="aaeeff"
printf "%d %d %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
