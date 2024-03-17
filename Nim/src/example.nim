import strutils
import options
import algorithm
import sequtils
import tables
import typetraits
import sugar

proc p_e_escapeString(s: string): string =
    let p_e_escapeChar = proc (c: char): string =
        if c == '\\': return "\\\\"
        if c == '\"': return "\\\""
        if c == '\n': return "\\n"
        if c == '\t': return "\\t"
        return $c
    result = s.map(p_e_escapeChar).join("")

proc p_e_bool(): proc (b: bool): string =
    result = (b: bool) => (if b: "true" else: "false")

proc p_e_int(): proc (i: int): string =
    result = (i: int) => $i

proc p_e_double(): proc (d: float): string =
    result = proc (d: float): string =
        let s0 = d.formatFloat(ffDecimal, 7)
        let s1 = s0.substr(0, s0.len - 2)
        result = if s1 == "-0.000000": "0.000000" else: s1

proc p_e_string(): proc (s: string): string =
    result = (s: string) => "\"" & p_e_escapeString(s) & "\""

proc p_e_list[V](f0: proc (v: V): string): proc (lst: seq[V]): string =
    result = (lst: seq[V]) => "[" & lst.map(f0).join(", ") & "]"

proc p_e_ulist[V](f0: proc (v: V): string): proc (lst: seq[V]): string =
    result = (lst: seq[V]) => "[" & lst.map(f0).sorted().join(", ") & "]"

proc p_e_idict[V](f0: proc (v: V): string): proc (dct: Table[int, V]): string =
    let f1 = proc (kv: (int, V)): string = p_e_int()(kv[0]) & "=>" & f0(kv[1])
    result = (dct: Table[int, V]) => 
        "{" & toSeq(dct.pairs).map(f1).sorted().join(", ") & "}"

proc p_e_sdict[V](f0: proc (v: V): string): proc (dct: Table[string, V]): string =
    let f1 = proc (kv: (string, V)): string = p_e_string()(kv[0]) & "=>" & f0(kv[1])
    result = (dct: Table[string, V]) =>
        "{" & toSeq(dct.pairs).map(f1).sorted().join(", ") & "}"
    
proc p_e_option[V](f0: proc (v: V): string): proc (opt: Option[V]): string =
    result = (opt: Option[V]) => (if opt.isSome: f0(opt.get) else: "null")

var p_e_out = [
    p_e_bool()(true),
    p_e_bool()(false),
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
    p_e_list(p_e_int())(@[]),
    p_e_list(p_e_int())(@[1, 2, 3]),
    p_e_list(p_e_bool())(@[true, false, true]),
    p_e_list(p_e_string())(@["apple", "banana", "cherry"]),
    p_e_list(p_e_list(p_e_int()))(@[]),
    p_e_list(p_e_list(p_e_int()))(@[@[1, 2, 3], @[4, 5, 6]]),
    p_e_ulist(p_e_int())(@[3, 2, 1]),
    p_e_list(p_e_ulist(p_e_int()))(@[@[2, 1, 3], @[6, 5, 4]]),
    p_e_ulist(p_e_list(p_e_int()))(@[@[4, 5, 6], @[1, 2, 3]]),
    p_e_idict(p_e_int())(initTable[int, int]()),
    p_e_idict(p_e_string())({1: "one", 2: "two"}.toTable),
    p_e_sdict(p_e_int())({"one": 1, "two": 2}.toTable),
    p_e_idict(p_e_list(p_e_int()))(initTable[int, seq[int]]()),
    p_e_idict(p_e_list(p_e_int()))({1: @[1, 2, 3], 2: @[4, 5, 6]}.toTable),
    p_e_sdict(p_e_list(p_e_int()))({"one": @[1, 2, 3], "two": @[4, 5, 6]}.toTable),
    p_e_list(p_e_idict(p_e_int()))(@[{1: 2}.toTable, {3: 4}.toTable]),
    p_e_idict(p_e_idict(p_e_int()))({1: {2: 3}.toTable, 4: {5: 6}.toTable}.toTable),
    p_e_sdict(p_e_sdict(p_e_int()))({"one": {"two": 3}.toTable, "four": {"five": 6}.toTable}.toTable),
    p_e_option(p_e_int())(some(42)),
    p_e_option(p_e_int())(none(int)),
    p_e_list(p_e_option(p_e_int()))(@[some(1), none(int), some(3)])
].join("\n")
writeFile("stringify.out", p_e_out)