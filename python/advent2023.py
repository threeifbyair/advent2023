#!/usr/bin/env python3

import re
import sys
import argparse
import os

import day1, day2

daylist = {
    1: day1.Day1,
    2: day2.Day2,
}

def main(args):
    parser = argparse.ArgumentParser(description='Advent of Code 2023')
    parser.add_argument('-i', '--input', type=str, help='Input file')
    parser.add_argument('-p', '--part-two', action='store_true', help='Perform part two of the challenge')
    parser.add_argument('-v', '--verbose', action='store_true', help='Print verbose output')
    parser.add_argument('-a', '--argint', type=int, help='An extra argument')
    parser.add_argument('day', type=int, nargs='*', help='Which day to run')
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f'File not found: {args.input}')
        return 1

    with open(args.input, 'r') as f:
        lines = f.readlines()

    if args.day:
        day = args.day[0]
    else:
        day = 1

    if day not in daylist:
        print(f'Invalid day: {day}')
        return 1
    
    result = daylist[day](lines, args)
    print(result.run())

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))