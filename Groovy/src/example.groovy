def p_e_escapeString(s) {
    def p_e_escapeChar = { c ->
        if (c == '\r') return "\\r"
        if (c == '\n') return "\\n"
        if (c == '\t') return "\\t"
        if (c == '\\') return "\\\\"
        if (c == '\"') return "\\\""
        return c.toString()
    }
    return s.collect { p_e_escapeChar(it) }.join()
}

def p_e_bool() {
    return { Boolean b -> b ? "true" : "false" }
}

def p_e_int() {
    return {Integer i -> i.toString() }
}

def p_e_double() {
    return { BigDecimal d -> String.format("%.6f", d) }
}

def p_e_string() {
    return { String s -> "\"" + p_e_escapeString(s) + "\"" }
}

def p_e_list(f0) {
    return { List lst ->
        return "[" + lst.collect(f0).join(", ") + "]"
    }
}

def p_e_ulist(f0) {
    return { List lst ->
        return "[" + lst.collect(f0).sort().join(", ") + "]"
    }
}

def p_e_idict(f0) {
    def f1 = { k, v -> p_e_int()(k) + "=>" + f0(v) }
    return { Map dct ->        
        return "{" + dct.collect(f1).join(", ") + "}"
    }
}

def p_e_sdict(f0) {
    def f1 = { k, v -> p_e_string()(k) + "=>" + f0(v) }
    return { Map dct ->        
        return "{" + dct.collect(f1).join(", ") + "}"
    }
}

def p_e_option(f0) {
    return { opt -> opt != null ? f0(opt) : "null" }
}

p_e_out = [
    p_e_bool()(true),
    p_e_int()(3),
    p_e_double()(3.141592653),
    p_e_double()(3.0),
    p_e_string()("Hello, World!"),
    p_e_string()("!@#\$%^&*()\\\"\n\t"),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_idict(p_e_string())([1: "one", 2: "two"]),
    p_e_sdict(p_e_list(p_e_int()))(["one": [1, 2, 3], "two": [4, 5, 6]]),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(null)
].join("\n")
new File("stringify.out").text = p_e_out