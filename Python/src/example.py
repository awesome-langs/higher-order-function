def p_e_escape_string(s: str) -> str:
    def p_e_escape_char(c: str) -> str:
        if c == '\\': return "\\\\"
        if c == '\"': return "\\\""
        if c == '\n': return "\\n"
        if c == '\t': return "\\t"
        return c
    return ''.join(map(p_e_escape_char, s))

def p_e_bool() -> callable:
    def ret(b: bool) -> str:
        assert isinstance(b, bool)
        return "true" if b else "false"
    return ret

def p_e_int() -> callable:
    def ret(i: int) -> str:
        assert isinstance(i, int) or (isinstance(i, float) and i.is_integer())
        return str(int(i))
    return ret

def p_e_double() -> callable:
    def ret(d: float) -> str:
        assert isinstance(d, int) or isinstance(d, float)
        s0 = "{:.7f}".format(d)
        s1 = s0[:-1]
        return "0.000000" if s1 == "-0.000000" else s1
    return ret

def p_e_string() -> callable:
    def ret(s: str) -> str:
        assert isinstance(s, str)
        return "\"" + p_e_escape_string(s) + "\""
    return ret

def p_e_list(f0: callable) -> callable:
    def ret(lst: list) -> str:
        assert isinstance(lst, list)
        return "[" + ", ".join(map(f0, lst)) + "]"
    return ret

def p_e_ulist(f0: callable) -> callable:
    def ret(lst: list) -> str:
        assert isinstance(lst, list)
        return "[" + ", ".join(sorted(map(f0, lst))) + "]"
    return ret

def p_e_idict(f0: callable) -> callable:
    f1 = lambda kv: p_e_int()(kv[0]) + "=>" + f0(kv[1])
    def ret(dct: dict) -> str:
        assert isinstance(dct, dict)
        return "{" + ", ".join(sorted(map(f1, dct.items()))) + "}"
    return ret

def p_e_sdict(f0: callable) -> callable:
    f1 = lambda kv: p_e_string()(kv[0]) + "=>" + f0(kv[1])
    def ret(dct: dict) -> str:
        assert isinstance(dct, dict)
        return "{" + ", ".join(sorted(map(f1, dct.items()))) + "}"
    return ret

def p_e_option(f0: callable) -> callable:
    return lambda opt: f0(opt) if opt is not None else "null"

p_e_out = "\n".join([
        p_e_bool()(True),
        p_e_bool()(False),
        p_e_int()(3),
        p_e_int()(-107),
        p_e_double()(0.0),
        p_e_double()(-0.0),
        p_e_double()(3.0),
        p_e_double()(31.4159265),
        p_e_double()(123456.789),
        p_e_string()("Hello, World!"),
        p_e_string()("!@#$%^&*()[]{}<>:;,.'\"?|"),
        p_e_string()("/\\\n\t"),
        p_e_list(p_e_int())([]),
        p_e_list(p_e_int())([1, 2, 3]),
        p_e_list(p_e_bool())([True, False, True]),
        p_e_list(p_e_string())(["apple", "banana", "cherry"]),
        p_e_list(p_e_list(p_e_int()))([]),
        p_e_list(p_e_list(p_e_int()))([[1, 2, 3], [4, 5, 6]]),
        p_e_ulist(p_e_int())([3, 2, 1]),
        p_e_list(p_e_ulist(p_e_int()))([[2, 1, 3], [6, 5, 4]]),
        p_e_ulist(p_e_list(p_e_int()))([[4, 5, 6], [1, 2, 3]]),
        p_e_idict(p_e_int())({}),
        p_e_idict(p_e_string())({1: "one", 2: "two"}),
        p_e_sdict(p_e_int())({"one": 1, "two": 2}),
        p_e_idict(p_e_list(p_e_int()))({}),
        p_e_idict(p_e_list(p_e_int()))({1: [1, 2, 3], 2: [4, 5, 6]}),
        p_e_sdict(p_e_list(p_e_int()))({"one": [1, 2, 3], "two": [4, 5, 6]}),
        p_e_list(p_e_idict(p_e_int()))([{1: 2}, {3: 4}]),
        p_e_idict(p_e_idict(p_e_int()))({1: {2: 3}, 4: {5: 6}}),
        p_e_sdict(p_e_sdict(p_e_int()))({"one": {"two": 3}, "four": {"five": 6}}),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(None),
        p_e_list(p_e_option(p_e_int()))([1, None, 3])
    ])
with open("stringify.out", "w") as f:
    f.write(p_e_out)
