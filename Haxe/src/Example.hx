import de.polygonal.Printf;

class Example {
    static function p_e_escapeString(s: String): String {
        function p_e_escapeChar(c: String): String {
            switch c {
                case "\r": return "\\r";
                case "\n": return "\\n";
                case "\t": return "\\t";
                case "\\": return "\\\\";
                case "\"": return "\\\"";
                case _: return c;
            }
        }
        return s.split("").map(p_e_escapeChar).join("");
    }

    static function p_e_bool(): Bool -> String {
        return function(b) { return b ? "true" : "false"; };
    }

    static function p_e_int(): Int -> String {
        return function(i) { return Std.string(i); };
    }

    static function p_e_double(): Float -> String {
        return function(d) { return Printf.format("%.6f", [d]); };
    }

    static function p_e_string(): String -> String {
        return function(s) { return "\"" + p_e_escapeString(s) + "\""; };
    }

    static function p_e_list<V>(f0: V -> String): Array<V> -> String {
        return function(lst) {
            return "[" + lst.map(f0).join(", ") + "]";
        };
    }

    static function p_e_ulist<V>(f0: V -> String): Array<V> -> String {
        return function(lst) {
            var vs = lst.map(f0);
            vs.sort(Reflect.compare);
            return "[" + lst.join(", ") + "]";
        };
    }
    
    static function p_e_idict<V>(f0: V -> String): Map<Int, V> -> String {
        function f1(k: Int, v: V): String {
            return p_e_int()(k) + "=>" + f0(v);
        }
        return function(dct) {
            var vs = [for (k => v in dct) f1(k, v)];
            vs.sort(Reflect.compare);
            return "{" + vs.join(", ") + "}";
        };
    }

    static function p_e_sdict<V>(f0: V -> String): Map<String, V> -> String {
        function f1(k: String, v: V): String {
            return p_e_string()(k) + "=>" + f0(v);
        }
        return function(dct) {
            var vs = [for (k => v in dct) f1(k, v)];
            vs.sort(Reflect.compare);
            return "{" + vs.join(", ") + "}";
        };
    }

    static function p_e_option<V>(f0: V -> String): Null<V> -> String {
        return function(opt) {
            return opt == null ? "null" : f0(opt);
        };
    }

    static function main() {
        var p_e_out = [
            p_e_bool()(true),
            p_e_int()(3),
            p_e_double()(3.141592653),
            p_e_double()(3.0),
            p_e_string()("Hello, World!"),
            p_e_string()("!@#$%^&*()\\\"\n\t"),
            p_e_list(p_e_int())([1, 2, 3]),
            p_e_list(p_e_bool())([true, false, true]),
            p_e_ulist(p_e_int())([3, 2, 1]),
            p_e_idict(p_e_string())([1 => "one", 2 => "two"]),
            p_e_sdict(p_e_list(p_e_int()))(["one" => [1, 2, 3], "two" => [4, 5, 6]]),
            p_e_option(p_e_int())(42),
            p_e_option(p_e_int())(null)
        ].join("\n");
        sys.io.File.saveContent("stringify.out", p_e_out);
    }
}