import Foundation

func p_e_escapeString(_ s: String) -> String {
    let p_e_escapeChar: (Character) -> String = { c in
        if c == "\\" { return "\\\\" }
        if c == "\"" { return "\\\"" }
        if c == "\n" { return "\\n" }
        if c == "\t" { return "\\t" }
        return String(c)
    }
    return s.map { p_e_escapeChar($0) }.joined()
}

func p_e_bool() -> (Bool) -> String {
    return { b in b ? "true" : "false" }
}

func p_e_int() -> (Int) -> String {
    return { i in String(i) }
}

func p_e_double() -> (Double) -> String {
    return { d in 
        let s0 = String(format: "%.7f", d)
        let s1 = String(s0.prefix(s0.count - 1))
        return s1 == "-0.000000" ? "0.000000" : s1
    }
}

func p_e_string() -> (String) -> String {
    return { s in "\"" + p_e_escapeString(s) + "\"" }
}

func p_e_list<V>(_ f0: @escaping (V) -> String) -> ([V]) -> String {
    return { lst in "[" + lst.map(f0).joined(separator: ", ") + "]" }
}

func p_e_ulist<V>(_ f0: @escaping (V) -> String) -> ([V]) -> String {
    return { lst in "[" + lst.map(f0).sorted().joined(separator: ", ") + "]" }
}

func p_e_idict<V>(_ f0: @escaping (V) -> String) -> ([Int: V]) -> String {
    let f1: (Int, V) -> String = { k, v in p_e_int()(k) + "=>" + f0(v) }
    return { dct in "{" + dct.map(f1).sorted().joined(separator: ", ") + "}" }
}

func p_e_sdict<V>(_ f0: @escaping (V) -> String) -> ([String: V]) -> String {
    let f1: (String, V) -> String = { k, v in p_e_string()(k) + "=>" + f0(v) }
    return { dct in "{" + dct.map(f1).sorted().joined(separator: ", ") + "}" }
}

func p_e_option<V>(_ f0: @escaping (V) -> String) -> (V?) -> String {
    return { opt in opt == nil ? "null" : f0(opt!) }
}

let p_e_out = [
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
        p_e_list(p_e_int())([]),
        p_e_list(p_e_int())([1, 2, 3]),
        p_e_list(p_e_bool())([true, false, true]),
        p_e_list(p_e_string())(["apple", "banana", "cherry"]),
        p_e_list(p_e_list(p_e_int()))([]),
        p_e_list(p_e_list(p_e_int()))([[1, 2, 3], [4, 5, 6]]),
        p_e_ulist(p_e_int())([3, 2, 1]),
        p_e_list(p_e_ulist(p_e_int()))([[2, 1, 3], [6, 5, 4]]),
        p_e_ulist(p_e_list(p_e_int()))([[4, 5, 6], [1, 2, 3]]),
        p_e_idict(p_e_int())([:]),
        p_e_idict(p_e_string())([1: "one", 2: "two"]),
        p_e_sdict(p_e_int())(["one": 1, "two": 2]),
        p_e_idict(p_e_list(p_e_int()))([:]),
        p_e_idict(p_e_list(p_e_int()))([1: [1, 2, 3], 2: [4, 5, 6]]),
        p_e_sdict(p_e_list(p_e_int()))(["one": [1, 2, 3], "two": [4, 5, 6]]),
        p_e_list(p_e_idict(p_e_int()))([[1: 2], [3: 4]]),
        p_e_idict(p_e_idict(p_e_int()))([1: [2: 3], 4: [5: 6]]),
        p_e_sdict(p_e_sdict(p_e_int()))(["one": ["two": 3], "four": ["five": 6]]),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(nil),
        p_e_list(p_e_option(p_e_int()))([1, nil, 3])
    ].joined(separator: "\n")
try p_e_out.write(toFile: "stringify.out", atomically: false, encoding: .utf8)