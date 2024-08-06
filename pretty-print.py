#!/usr/bin/env python3
import re
import sys
import fileinput
import itertools
from tabulate import tabulate
from enum import StrEnum, auto

name_of_script = sys.argv[0]
input = ''
for line in fileinput.input(encoding="utf-8"):
    input += line

calendar = []
hoursCount = []

class Day(StrEnum):
    MON = auto()
    TUE = auto()
    WED = auto()
    THU = auto()
    FRI = auto()
    SAT = auto()
    def __lt__(self, other: 'Day'):
        if self == other:
            return False
        # the following works because the order of elements in the definition is preserved
        for elem in Day:
            if self == elem:
                return True
            elif other == elem:
                return False
        raise RuntimeError('Bug: we should never arrive here')  # I just like being pedantic

    def __gt__(self, other):
        return not (self < other)

    def __ge__(self, other):
        if self == other:
            return True
        return not (self < other)



class MetaAssignment(type):
    def __iter__(self):
        for attr in dir(self):
            if not attr.startswith("__"):
                yield attr

class Assignment(metaclass=MetaAssignment):
    def __str__(self):
        return f"{self.week},{self.day},{self.hour},{self.sub}"

    week = 0
    day = Day('mon')
    hour = 0
    sub = ''

def pprint(clingo_str):
    file = open('clingo.log', 'w')
    file.write(clingo_str)
    file.close()

    tokens = clingo_str.split()
    for token in tokens:
        if 'assign' in token:
            m = re.search(r"\(([A-Za-z0-9,_]+)\)", token)
            args = m.group(1).split(',')
            a = Assignment()
            a.week = args[0]
            a.day = Day(args[1])
            a.hour = args[2]
            a.sub = args[3]
            # updateCalendar(a)
            calendar.append(a)
        elif 'hoursCount' in token:
            m = re.search(r"\(([A-Za-z0-9,_]+)\)", token)
            args = m.group(1).split(',')
            hoursCount.append(f"{args[0]}:{args[1]}")

    for h in hoursCount:
        print(h)

    calendar.sort(key=lambda x: (x.week, x.day, x.hour))
    key_fun = lambda x: x.week
    weeks_calendar = [list(group) for key, group in itertools.groupby(calendar, key_fun)]

    for w in weeks_calendar:
        key_fun = lambda x: x.day
        days_calendar = [list(group) for key, group in itertools.groupby(w, key_fun)]
        print('-------------------------------------------------------------------------')
        print(f'week {w[0].week}')

        for d in days_calendar:
            d.sort(key=lambda x: (x.day, x.hour))
            print()
            print(d[0].day)
            for attr in ('hour', 'sub'):
                print(' '.join('%-8s'%getattr(item, attr) for item in d))



        # tab = tabulate(w, headers[""])
        # print(tab)
        # key_fun = lambda x: x.day
        # days = [list(group) for key, group in itertools.groupby(w, key_fun)]
        # for d in days:
        # print(f'{d[0].day}')

pprint(input)
