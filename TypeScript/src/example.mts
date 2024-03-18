import * as fs from 'fs';

function p_e_escapeString(s: string): string {
    const p_e_escapeChar = (c: string): string => {
        if (c === "\\") return "\\\\";
        if (c === "\"") return "\\\"";
        if (c === "\n") return "\\n";
        if (c === "\t") return "\\t";
        return c;
    };
    return s.split('').map(p_e_escapeChar).join('');
}

function p_e_bool(): (b: boolean) => string {
    return (b: boolean) => b ? "true" : "false";
}

function p_e_int(): (i: number) => string {
    return (i: number): string => {
        if (!Number.isInteger(i)) throw new Error();
        return i.toString();
    }
}

function p_e_double(): (d: number) => string {
    return (d: number) => {
        const s0 = d.toFixed(7);
        const s1 = s0.substring(0, s0.length - 1);
        return s1 === "-0.000000" ? "0.000000" : s1;
    }
}

function p_e_string(): (s: string) => string {
    return (s: string) => "\"" + p_e_escapeString(s) + "\"";
}

function p_e_list<V>(f0: (v: V) => string): (lst: V[]) => string {
    return (lst: V[]) => "[" + lst.map(f0).join(", ") + "]";
}

function p_e_ulist<V>(f0: (v: V) => string): (lst: V[]) => string {
    return (lst: V[]) => "[" + lst.map(f0).sort().join(", ") + "]";
}

function p_e_idict<V>(f0: (v: V) => string): (dct: Map<number, V>) => string {
    const f1 = (kv: [number, V]): string => p_e_int()(kv[0]) + "=>" + f0(kv[1]);
    return (dct: Map<number, V>) => "{" + [...dct].map(f1).sort().join(", ") + "}";
}

function p_e_sdict<V>(f0: (v: V) => string): (dct: Map<string, V>) => string {
    const f1 = (kv: [string, V]): string => p_e_string()(kv[0]) + "=>" + f0(kv[1]);
    return (dct: Map<string, V>) => "{" + [...dct].map(f1).sort().join(", ") + "}";
}

function p_e_option<V>(f0: (v: V) => string): (opt: V | null) => string {
    return (opt: V | null) => opt !== null ? f0(opt) : "null";
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
fs.writeFileSync("stringify.out", p_e_out);