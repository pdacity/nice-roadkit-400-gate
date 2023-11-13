#!/usr/bin/env bash
set -xve

esptool.py --port /dev/ttyUSB0 read_flash 0x00000 0x100000 esp8265-backup.bin
