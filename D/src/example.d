import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.typecons;
import std.array;
import std.functional;

string p_e_escapeString(string s) {
    string p_e_escapeChar(dchar c) {
        if (c == '\\') return "\\\\";
        if (c == '\"') return "\\\"";
        if (c == '\n') return "\\n";
        if (c == '\t') return "\\t";
        return to!string(c);
    }
    return s.map!(p_e_escapeChar).join("");
}

string delegate(bool) p_e_bool() {
    return b => b ? "true" : "false";
}

string delegate(int) p_e_int() {
    return i => to!string(i);
}

string delegate(double) p_e_double() {
    return (d) {
        string s0 = format("%.7f", d);
        string s1 = s0[0 .. $ - 1];
        return s1 == "-0.000000" ? "0.000000": s1;
    };
}

string delegate(string) p_e_string() {
    return s => "\"" ~ p_e_escapeString(s) ~ "\"";
}

string delegate(V[]) p_e_list(V)(string delegate(V) f0) {
    return (V[] lst) {
        return "[" ~ lst.map!(f0).join(", ") ~ "]";
    };
}

string delegate(V[]) p_e_ulist(V)(string delegate(V) f0) {
    return (V[] lst) {
        return "[" ~ lst.map!(f0).array.sort().join(", ") ~ "]";
    };
}

string delegate(V[int]) p_e_idict(V)(string delegate(V) f0) {
    string delegate(Tuple!(int, V)) f1 = kv => p_e_int()(kv[0]) ~ "=>" ~ f0(kv[1]);
    return (V[int] dct) {        
        return "{" ~ dct.byPair.map!(f1).array.sort().join(", ") ~ "}";
    };
}

string delegate(V[string]) p_e_sdict(V)(string delegate(V) f0) {
    string delegate(Tuple!(string, V)) f1 = kv => p_e_string()(kv[0]) ~ "=>" ~ f0(kv[1]);
    return (V[string] dct) {        
        return "{" ~ dct.byPair.map!(f1).array.sort().join(", ") ~ "}";
    };
}

string delegate(Nullable!V) p_e_option(V)(string delegate(V) f0) {
    return (Nullable!V opt) {
        return opt.isNull ? "null" : f0(opt.get);
    };
}

void main() {
    string p_e_out = [
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
        p_e_idict(p_e_int())(null),
        p_e_idict(p_e_string())([1: "one", 2: "two"]),
        p_e_sdict(p_e_int())(["one": 1, "two": 2]),
        p_e_idict(p_e_list(p_e_int()))(null),
        p_e_idict(p_e_list(p_e_int()))([1: [1, 2, 3], 2: [4, 5, 6]]),
        p_e_sdict(p_e_list(p_e_int()))(["one": [1, 2, 3], "two": [4, 5, 6]]),
        p_e_list(p_e_idict(p_e_int()))([[1: 2], [3: 4]]),
        p_e_idict(p_e_idict(p_e_int()))([1: [2: 3], 4: [5: 6]]),
        p_e_sdict(p_e_sdict(p_e_int()))(["one": ["two": 3], "four": ["five": 6]]),
        p_e_option(p_e_int())(Nullable!int(42)),
        p_e_option(p_e_int())(Nullable!int()),
        p_e_list(p_e_option(p_e_int()))([Nullable!int(1), Nullable!int(), Nullable!int(3)])
    ].join("\n");
    File("stringify.out", "w").write(p_e_out);
}