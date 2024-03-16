function p_e_escape_string(s) {
    const p_e_escape_char = (c) => {
        if (c === '\r') return "\\r";
        if (c === '\n') return "\\n";
        if (c === '\t') return "\\t";
        if (c === '\\') return "\\\\";
        if (c === '\"') return "\\\"";
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
        return d.toFixed(6);
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
        return "{" + [...dct].map(f1).join(", ") + "}";
    }
}

function p_e_sdict(f0) {
    const f1 = ([k, v]) => p_e_string()(k) + "=>" + f0(v);
    return (dct) => {
        if (!dct instanceof Map) throw new Error();        
        return "{" + [...dct].map(f1).join(", ") + "}";
    }
}

function p_e_option(f0) {
    return (opt) => {
        return opt === null ? "null" : f0(opt);
    }
}

const p_e_out = [
    p_e_bool()(true),
    p_e_int()(3),
    p_e_double()(3.141592653),
    p_e_double()(3.0),
    p_e_string()("Hello, World!"),
    p_e_string()("!@#$%^&*()\\\"\n\t"),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_idict(p_e_string())(new Map([[1, "one"], [2, "two"]])),
    p_e_sdict(p_e_list(p_e_int()))(new Map([["one", [1, 2, 3]], ["two", [4, 5, 6]]])),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(null)
].join("\n");
const fs = require('fs');
fs.writeFileSync("stringify.out", p_e_out);
