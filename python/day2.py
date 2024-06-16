#!/usr/bin/env python3

import re
import sys, os

import adventday

from typing import NamedTuple

class RGB(NamedTuple):
    r: int
    g: int
    b: int

class Day2(adventday.AdventDay):
    def parse_game(self, line):
        line = line.strip()
        if len(line) == 0:
            return []
        rgbs = []
        game = line.split(':')
        assert len(game) == 2, F'Eek! Line {line} gives game={game}!'
        gameid = int(game[0][5:])
        subgames = game[1].split(';')
        for subgame in subgames:
            subgame = subgame.strip()
            if len(subgame) == 0:
                continue
            subgame = subgame.split(',')
            retrgb = RGB(0, 0, 0)
            for subsub in subgame:
                subsub = subsub.strip()
                if len(subsub) == 0:
                    continue
                m = re.match(r'(\d+) (\w+)', subsub)
                assert m is not None, F'Eek! Line {line} gives subsub={subsub}!'
                assert m.group(2) in ['red', 'green', 'blue'], F'Eek! Line {line} gives subsub={subsub}!'
                num = int(m.group(1))
                if m.group(2) == 'red':
                    retrgb = RGB(num, retrgb.g, retrgb.b)
                elif m.group(2) == 'green':
                    retrgb = RGB(retrgb.r, num, retrgb.b)
                elif m.group(2) == 'blue':
                    retrgb = RGB(retrgb.r, retrgb.g, num)

            rgbs.append(retrgb)
        return (gameid, rgbs)

    def calc_game_part1(self, line, maxrgb):
        (gameid, rgbs) = self.parse_game(line)
        if len(rgbs) == 0:
            return 0
        for rgb in rgbs:
            if rgb.r > maxrgb.r or rgb.g > maxrgb.g or rgb.b > maxrgb.b:
                return 0
        return gameid

    def calc_game_part2(self, line):
        (gameid, rgbs) = self.parse_game(line)
        maxrgb = RGB(0, 0, 0)
        if len(rgbs) == 0:
            return 0
        for rgb in rgbs:
            if rgb.r > maxrgb.r:
                maxrgb = RGB(rgb.r, maxrgb.g, maxrgb.b)
            if rgb.g > maxrgb.g:
                maxrgb = RGB(maxrgb.r, rgb.g, maxrgb.b)
            if rgb.b > maxrgb.b:
                maxrgb = RGB(maxrgb.r, maxrgb.g, rgb.b)
        return maxrgb.r * maxrgb.g * maxrgb.b

    def part_one(self):
        return sum(self.calc_game_part1(x, RGB(12, 13, 14)) for x in self.lines)

    def part_two(self):
        return sum(self.calc_game_part2(x) for x in self.lines)
