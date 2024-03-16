using System;
using System.Collections.Generic;
using System.Linq;

class Example {
    static string p_e_EscapeString(string s) {
        string p_e_EscapeChar(char c) {
            if (c == '\r') return "\\r";
            if (c == '\n') return "\\n";
            if (c == '\t') return "\\t";
            if (c == '\\') return "\\\\";
            if (c == '\"') return "\\\"";
            return c.ToString();
        };
        return string.Concat(s.Select(p_e_EscapeChar));
    }

    static Func<bool, string> p_e_bool() {
        return b => b ? "true" : "false";
    }

    static Func<int, string> p_e_int() {
        return i => i.ToString();
    }

    static Func<double, string> p_e_double() {
        return d => d.ToString("F6");
    }

    static Func<string, string> p_e_string() {
        return s => "\"" + p_e_EscapeString(s) + "\"";
    }
    
    static Func<List<T>, string> p_e_list<T>(Func<T, string> f0) {
        return lst => "[" + string.Join(", ", lst.Select(f0)) + "]";
    }

    static Func<List<T>, string> p_e_ulist<T>(Func<T, string> f0) {
        return lst => "[" + string.Join(", ", lst.Select(f0).OrderBy(x => x)) + "]";
    }

    static Func<Dictionary<int, T>, string> p_e_idict<T>(Func<T, string> f0) {
        Func<KeyValuePair<int, T>, string> f1 = kv => p_e_int()(kv.Key) + "=>" + f0(kv.Value);
        return dct => "{" + string.Join(", ", dct.Select(f1).OrderBy(x => x)) + "}";
    }

    static Func<Dictionary<string, T>, string> p_e_sdict<T>(Func<T, string> f0) {
        Func<KeyValuePair<string, T>, string> f1 = kv => p_e_string()(kv.Key) + "=>" + f0(kv.Value);
        return dct => "{" + string.Join(", ", dct.Select(f1).OrderBy(x => x)) + "}";
    }

    static Func<Nullable<T>, string> p_e_option<T>(Func<T, string> f0) where T : struct {
        return opt => opt.HasValue ? f0(opt.Value) : "null";
    }

    static void Main() {
        var p_e_out = string.Join("\n", new string[] {
            p_e_bool()(true),
            p_e_int()(3),
            p_e_double()(3.141592653),
            p_e_double()(3.0),
            p_e_string()("Hello, World!"),
            p_e_string()("!@#$%^&*()\\\"\n\t"),
            p_e_list(p_e_int())(new List<int> {1, 2, 3}),
            p_e_list(p_e_bool())(new List<bool> {true, false, true}),
            p_e_ulist(p_e_int())(new List<int> {3, 2, 1}),
            p_e_idict(p_e_string())(new Dictionary<int, string> {{1, "one"}, {2, "two"}}),
            p_e_sdict(p_e_list(p_e_int()))(new Dictionary<string, List<int>> {{"one", new List<int> {1, 2, 3}}, {"two", new List<int> {4, 5, 6}}}),
            p_e_option(p_e_int())(42),
            p_e_option(p_e_int())(null)
        });
        System.IO.File.WriteAllText("stringify.out", p_e_out);
    }
}