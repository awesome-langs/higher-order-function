module Fs = NodeJs.Fs
module Buffer = NodeJs.Buffer

let p_e_escapeString = (s: string): string => {
    let p_e_escapeChar = (c: string): string =>
        switch c {
        | "\r" => "\\r"
        | "\n" => "\\n"
        | "\t" => "\\t"
        | "\\" => "\\\\"
        | "\"" => "\\\""
        | _ => c
        }
    s->String.split("")->Array.map(p_e_escapeChar)->Array.joinWith("")
}

let p_e_bool = () => (b: bool): string => {
    if b { "true" } else { "false" }
}

let p_e_int = () => (i: int): string => {
    Int.toString(i)
}

let p_e_double = () => (d: float): string => {
    Float.toFixedWithPrecision(d, ~digits=6)
}

let p_e_string = () => (s: string): string => {
    "\"" ++ p_e_escapeString(s) ++ "\""
}

let p_e_list = (f0: 'a => string) => (lst: array<'a>): string => {
    "[" ++ lst->Array.map(f0)->Array.joinWith(", ") ++ "]"
}

let p_e_ulist = (f0: 'a => string) => (lst: array<'a>): string => {
    "[" ++ lst->Array.map(f0)->Array.toSorted(String.compare)->Array.joinWith(", ") ++ "]"
}

let p_e_idict = (f0: 'a => string) => (dct: Map.t<int, 'a>): string => {
    let f1 = ((k: int, v: 'a)): string => p_e_int()(k) ++ "=>" ++ f0(v)
    "{" ++ dct->Map.entries->Iterator.toArray->Array.map(f1)->Array.toSorted(String.compare)->Array.joinWith(", ") ++ "}"
}

let p_e_sdict = (f0: 'a => string) => (dct: Map.t<string, 'a>): string => {
    let f1 = ((k: string, v: 'a)): string => p_e_string()(k) ++ "=>" ++ f0(v)
    "{" ++ dct->Map.entries->Iterator.toArray->Array.map(f1)->Array.toSorted(String.compare)->Array.joinWith(", ") ++ "}"
}

let p_e_option = (f0: 'a => string) => (opt: option<'a>): string => {
    switch opt {
    | Some(v) => f0(v)
    | None => "null"
    }
}

Console.log(p_e_list(p_e_int())([1, 2, 3]))

let p_e_out = Array.joinWith([
    p_e_bool()(true),
    p_e_int()(3),
    p_e_double()(3.141592653),
    p_e_double()(3.0),
    p_e_string()("Hello, World!"),
    p_e_string()("!@#$%^&*()\\\"\n\t"),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_idict(p_e_string())(Map.fromArray([(1, "one"), (2, "two")])),
    p_e_sdict(p_e_list(p_e_int()))(Map.fromArray([("one", [1, 2, 3]), ("two", [4, 5, 6])])),
    p_e_option(p_e_int())(Some(42)),
    p_e_option(p_e_int())(None)
], "\n")

Fs.writeFileSync("stringify.out", p_e_out->Buffer.fromString)