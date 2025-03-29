# lambda.py

import math


def inc_free(expr, value, depth=0):
    if isinstance(expr, list) and len(expr) == 1:
        # If abstraction
        return [inc_free(expr[0], value, depth + 1)]
    elif isinstance(expr, list):
        # If application
        left = inc_free(expr[0], value, depth)
        right = inc_free(expr[1], value, depth)
        return [left, right]
    else:
        # If variable
        if expr > depth:
            return expr + value - 1
        return expr


def substitute(expr, value, depth=None):
    if isinstance(expr, list) and len(expr) == 1:
        # If abstraction
        if depth is not None:
            return [substitute(expr[0], value, depth + 1)]
        else:
            return substitute(expr[0], value, 1)
    elif isinstance(expr, list):
        # If application
        left = substitute(expr[0], value, depth)
        right = substitute(expr[1], value, depth)
        return [left, right]
    else:
        # If variable
        if expr == depth:
            return inc_free(value, depth)
        if expr > depth:
            return expr - 1
        return expr


def reduce(expr, handedness=True):
    if isinstance(expr, list) and len(expr) == 1:
        # If abstraction
        res, s = reduce(expr[0])
        return [res], s
    elif isinstance(expr, list):
        # If application
        if isinstance(expr[0], list) and len(expr[0]) == 1:
            return substitute(expr[0], expr[1]), True
        if handedness:
            v, s = reduce(expr[1])
            if s: return [expr[0], v], True
            v, s = reduce(expr[0])
            if s: return [v, expr[1]], True
        else:
            v, s = reduce(expr[0])
            if s: return [v, expr[1]], True
            v, s = reduce(expr[1])
            if s: return [expr[0], v], True
        return expr, False
    else:
        # If variable
        return expr, False


def hsv_ansi(h, s, v):
    if math.isnan(h):
        h = 0
    h *= 6
    r = (1 + s * (min(max(abs((h + 0) % 6 - 3) - 1, 0), 1) - 1)) * v
    g = (1 + s * (min(max(abs((h + 4) % 6 - 3) - 1, 0), 1) - 1)) * v
    b = (1 + s * (min(max(abs((h + 2) % 6 - 3) - 1, 0), 1) - 1)) * v
    return f"\033[38;2;{int(r * 255)};{int(g * 255)};{int(b * 255)}m"


def int_part(x):
    try:
        b = 2**math.floor(math.log(x, 2))
        b1 = 2**math.floor(math.log(x, 2) + 1)
    except ValueError:
        return math.nan
    return (1 / b1 + x % b / b)


def _str(expr, depth):
    if expr is None:
        return "NIL"
    if depth > 20:
        return "!!!"
    if isinstance(expr, list):
        if len(expr) == 1:
            v = chr(depth % 26 + 97)
            a = _str(expr[0], depth + 1)
            return f"(L{v}.{a})"
        left = _str(expr[0], depth)
        right = _str(expr[1], depth)
        return f"({left}{right})"
    return chr((depth - expr) % 26 + 97)


def stringify(expr, color=False):
    if color:
        return ''.join(
            hsv_ansi(int_part(ord(letter) - ord('a')), 0.5, 0.9) + letter +
            "\033[0m" if 'a' <= letter <= 'z' else letter
            for letter in _str(expr, 0))
    return _str(expr, 0)


def _num(n):
    if n == 0:
        return 1
    return [2, _num(n - 1)]


def N(n):
    return [[_num(n)]]


I = [1]
M = [[1, 1]]
S = [[[[[3, 1], [2, 1]]]]]

T = K = [[2]]
F = KI = [[1]]

O = [[[1, [2, 1]]]]

Cons = [[[[[1, 3], 2]]]]
Car = [[1, T]]
Cdr = [[1, F]]
Nil = [T]

Y = [[[[2, [1, 1]]], [[2, [1, 1]]]]]
Theta = [Y, O]

# Arithmetic

MUL = [[[[3, [2, 1]]]]]
EXP = [[[1, 2]]]

if __name__ == "__main__":
    while True:
        line = input("> ")
        if line in ["quit", "exit", "q", ""]:
            break
        try:
            expr = eval(line)
            print(": " + stringify(expr, True))
            while reduce(expr)[1]:
                opt = input(" [r]educe, [s]tep: ")
                if opt in ["r", "R"]:
                    i = 0
                    while reduce(expr)[1]:
                        expr = reduce(expr)[0]
                        print(": " + stringify(expr, True))
                        i += 1
                        if i > 100:
                            break
                    if not reduce(expr)[1]:
                        break
                elif opt in ["s", "S"]:
                    res = reduce(expr)
                    expr = res[0]
                    if not res[1]:
                        break
                    print(": " + stringify(expr, True))
                else:
                    break
        except:
            try:
                exec(line)
            except Exception as e:
                print(e)
