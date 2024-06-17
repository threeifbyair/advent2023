#!/usr/bin/env python3

import re
import sys, os

import adventday

from typing import NamedTuple

class Day3(adventday.AdventDay):
    def parse_map(self):
        self.map = []
        for line in self.lines:
            self.map.append('.' + line.strip() + '.') # Add a border of dead cells
        self.map.insert(0, '.' * len(self.map[0])) # Add a border of dead cells
        self.map.append('.' * len(self.map[0])) # Add a border of dead cells

    def part_one(self):
        self.parse_map()
        part_numbers = 0
        for i in range(1, len(self.map) - 1):
            if self.args.verbose:
                print(f"Checking line {i}:\n{self.map[i-1]}\n{self.map[i]}\n{self.map[i+1]}")
            in_digit = False
            for j in range(1, len(self.map[i])):
                if self.map[i][j] >= '0' and self.map[i][j] <= '9':
                    in_digit = True
                elif in_digit:
                    in_digit = False
                    # OK, we've found the end of a number. Search back for both the start and any surrounding parts.
                    search = j - 1
                    found_symbol = self.map[i][j] not in '0123456789.' or self.map[i-1][j] not in '0123456789.' or self.map[i+1][j] not in '0123456789.' 
                    while self.map[i][search] >= '0' and self.map[i][search] <= '9':
                        if self.map[i][search] not in '0123456789.' or self.map[i-1][search] not in '0123456789.' or self.map[i+1][search] not in '0123456789.' :
                            found_symbol = True
                        search -= 1
                    if self.map[i][search] not in '0123456789.' or self.map[i-1][search] not in '0123456789.' or self.map[i+1][search] not in '0123456789.' :
                        found_symbol = True
                    this_part = int(self.map[i][search + 1:j])
                    if found_symbol:
                        if self.args.verbose:
                            print(f"Found part {this_part} at i {i} j {j}")
                        part_numbers += this_part
            assert in_digit == False, f'Found a digit at the end of the line {i}'

        return part_numbers

    def find_number(self, i, j):
        backsearch = j
        while self.map[i][backsearch] >= '0' and self.map[i][backsearch] <= '9':
            backsearch -= 1
        forwardsearch = j+1
        while self.map[i][forwardsearch] >= '0' and self.map[i][forwardsearch] <= '9':
            forwardsearch += 1
        return int(self.map[i][backsearch + 1:forwardsearch])

    def part_two(self):
        self.parse_map()
        gear_ratios = 0
        for i in range(1, len(self.map) - 1):
            if self.args.verbose:
                print(f"Checking line {i}:\n{self.map[i-1]}\n{self.map[i]}\n{self.map[i+1]}")
            for j in range(1, len(self.map[i])):
                if self.map[i][j] == '*':
                    # We've found a gear. First of all, check above.
                    gears = []
                    if self.map[i-1][j] in '0123456789':
                        # We have one digit. Go back and forward to find the number.
                        gears.append(self.find_number(i-1, j))
                    else:
                        if self.map[i-1][j-1] in '0123456789':
                            gears.append(self.find_number(i-1, j-1))
                        if self.map[i-1][j+1] in '0123456789':
                            gears.append(self.find_number(i-1, j+1))
                    if self.map[i][j-1] in '0123456789':
                        gears.append(self.find_number(i, j-1))
                    if self.map[i][j+1] in '0123456789':
                        gears.append(self.find_number(i, j+1))
                    if self.map[i+1][j] in '0123456789':
                        gears.append(self.find_number(i+1, j))
                    else:
                        if self.map[i+1][j-1] in '0123456789':
                            gears.append(self.find_number(i+1, j-1))
                        if self.map[i+1][j+1] in '0123456789':
                            gears.append(self.find_number(i+1, j+1))
                    if self.args.verbose:
                        print(f"Found gears {gears}")
                    if len(gears) == 2:
                        gear_ratios += gears[0] * gears[1]
        return gear_ratios