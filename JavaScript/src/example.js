function p_e_escape_string(s) {
    const p_e_escape_char = (c) => {
        if (c === '\\') return "\\\\";
        if (c === '\"') return "\\\"";
        if (c === '\n') return "\\n";
        if (c === '\t') return "\\t";
        return c;
    }
    return [...s].map(p_e_escape_char).join('');
}

function p_e_bool() {
    return (b) => {
        if (typeof b !== "boolean") throw new Error();
        return b ? "true" : "false";
    }
}

function p_e_int() {
    return (i) => {
        if (typeof i !== "number" || !Number.isInteger(i)) throw new Error();
        return i.toString();
    }
}

function p_e_double() {
    return (d) => {
        if (typeof d !== "number") throw new Error();
        const s0 = d.toFixed(7);
        const s1 = s0.substring(0, s0.length - 1);
        return s1 === "-0.000000" ? "0.000000" : s1;
    }
}

function p_e_string() {
    return (s) => {
        if (typeof s !== "string") throw new Error();
        return "\"" + p_e_escape_string(s) + "\"";
    }
}

function p_e_list(f0) {
    return (lst) => {
        if (!Array.isArray(lst)) throw new Error();
        return "[" + lst.map(f0).join(", ") + "]";
    }
}

function p_e_ulist(f0) {
    return (lst) => {
        if (!Array.isArray(lst)) throw new Error();
        return "[" + lst.map(f0).sort().join(", ") + "]";
    }
}

function p_e_idict(f0) {
    const f1 = ([k, v]) => p_e_int()(k) + "=>" + f0(v);
    return (dct) => {
        if (!dct instanceof Map) throw new Error();
        return "{" + [...dct].map(f1).sort().join(", ") + "}";
    }
}

function p_e_sdict(f0) {
    const f1 = ([k, v]) => p_e_string()(k) + "=>" + f0(v);
    return (dct) => {
        if (!dct instanceof Map) throw new Error();        
        return "{" + [...dct].map(f1).sort().join(", ") + "}";
    }
}

function p_e_option(f0) {
    return (opt) => {
        return opt === null ? "null" : f0(opt);
    }
}

const p_e_out = [
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
        p_e_idict(p_e_int())(new Map()),
        p_e_idict(p_e_string())(new Map([[1, "one"], [2, "two"]])),
        p_e_sdict(p_e_int())(new Map([["one", 1], ["two", 2]])),
        p_e_idict(p_e_list(p_e_int()))(new Map()),
        p_e_idict(p_e_list(p_e_int()))(new Map([[1, [1, 2, 3]], [2, [4, 5, 6]]])),
        p_e_sdict(p_e_list(p_e_int()))(new Map([["one", [1, 2, 3]], ["two", [4, 5, 6]]])),
        p_e_list(p_e_idict(p_e_int()))([new Map([[1, 2]]), new Map([[3, 4]])]),
        p_e_idict(p_e_idict(p_e_int()))(new Map([[1, new Map([[2, 3]])], [4, new Map([[5, 6]])]])),
        p_e_sdict(p_e_sdict(p_e_int()))(new Map([["one", new Map([["two", 3]])], ["four", new Map([["five", 6]])]])),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(null),
        p_e_list(p_e_option(p_e_int()))([1, null, 3])
    ].join("\n");
const fs = require('fs');
fs.writeFileSync("stringify.out", p_e_out);
