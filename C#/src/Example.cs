using System;
using System.Collections.Generic;
using System.Linq;

class Example {
    static string p_e_EscapeString(string s) {
        string p_e_EscapeChar(char c) {
            if (c == '\\') return "\\\\";
            if (c == '\"') return "\\\"";
            if (c == '\n') return "\\n";
            if (c == '\t') return "\\t";
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
        return d => {
            string s0 = d.ToString("F7");
            string s1 = s0.Substring(0, s0.Length - 1);
            return (s1 == "-0.000000") ? "0.000000" : s1;
        };
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
        return opt => (opt.HasValue ? f0(opt.Value) : "null");
    }

    static void Main() {
        var p_e_out = string.Join("\n", new string[] {
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
                p_e_idict(p_e_int())(new Dictionary<int, int> {}),
                p_e_idict(p_e_string())(new Dictionary<int, string> {{1, "one"}, {2, "two"}}),
                p_e_sdict(p_e_int())(new Dictionary<string, int> {{"one", 1}, {"two", 2}}),
                p_e_idict(p_e_list(p_e_int()))(new Dictionary<int, List<int>> {}),
                p_e_idict(p_e_list(p_e_int()))(new Dictionary<int, List<int>> {{1, [1, 2, 3]}, {2, [4, 5, 6]}}),
                p_e_sdict(p_e_list(p_e_int()))(new Dictionary<string, List<int>> {{"one", [1, 2, 3]}, {"two", [4, 5, 6]}}),
                p_e_list(p_e_idict(p_e_int()))([new Dictionary<int, int> {{1, 2}}, new Dictionary<int, int> {{3, 4}}]),
                p_e_idict(p_e_idict(p_e_int()))(new Dictionary<int, Dictionary<int, int>> {{1, new Dictionary<int, int> {{2, 3}}}, {4, new Dictionary<int, int> {{5, 6}}}}),
                p_e_sdict(p_e_sdict(p_e_int()))(new Dictionary<string, Dictionary<string, int>> {{"one", new Dictionary<string, int> {{"two", 3}}}, {"four", new Dictionary<string, int> {{"five", 6}}}}),
                p_e_option(p_e_int())(42),
                p_e_option(p_e_int())(null),
                p_e_list(p_e_option(p_e_int()))([1, null, 3])
            });
        System.IO.File.WriteAllText("stringify.out", p_e_out);
    }
}