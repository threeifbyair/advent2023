#!/usr/bin/env python3

import re
import sys, os

import adventday

class Day1(adventday.AdventDay):
    def calc_calibration(self, line):
        first = None
        last = None
        line = line.strip()
        if len(line) == 0:
            return 0
        for i in range(len(line)):
            if line[i:].startswith('0') or line[i:].startswith('1') or line[i:].startswith('2') or line[i:].startswith('3') or line[i:].startswith('4') or line[i:].startswith('5') or line[i:].startswith('6') or line[i:].startswith('7') or line[i:].startswith('8') or line[i:].startswith('9'):
                last = ord(line[i]) - ord('0')
            elif self.args.part_two:
                if line[i:].startswith('one'):
                    last = 1
                elif line[i:].startswith('two'):
                    last = 2
                elif line[i:].startswith('three'):
                    last = 3
                elif line[i:].startswith('four'):
                    last = 4
                elif line[i:].startswith('five'):
                    last = 5
                elif line[i:].startswith('six'):
                    last = 6
                elif line[i:].startswith('seven'):
                    last = 7
                elif line[i:].startswith('eight'):
                    last = 8
                elif line[i:].startswith('nine'):
                    last = 9

            if first is None and last is not None:
                first = last
        assert first is not None and last is not None, F'Eek! Line {line} gives first={first} and last={last}!'
        return 10 * first + last

    def part_one(self):
        return sum(self.calc_calibration(x) for x in self.lines)

    def part_two(self):
        return self.part_one()