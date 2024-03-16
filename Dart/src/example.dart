import "dart:io";

String p_e_escapeString(String s) {
    String p_e_escapeChar(String c) {
        if (c == '\r') return "\\r";
        if (c == '\n') return "\\n";
        if (c == '\t') return "\\t";
        if (c == '\\') return "\\\\";
        if (c == '\"') return "\\\"";
        return c;
    }
    return s.split('').map(p_e_escapeChar).join('');
}

String Function(bool) p_e_bool() {
    return (b) => b ? "true" : "false";
}

String Function(int) p_e_int() {
    return (i) => i.toString();
}

String Function(double) p_e_double() {
    return (d) => d.toStringAsFixed(6);
}

String Function(String) p_e_string() {
    return (s) => "\"" + p_e_escapeString(s) + "\"";
}

String Function(List<V>) p_e_list<V>(String Function(V) f0) {
    return (List<V> lst) {
        return "[" + lst.map(f0).join(", ") + "]";
    };
}

String Function(List<V>) p_e_ulist<V>(String Function(V) f0) {
    return (List<V> lst) {
        return "[" + (lst.map(f0).toList()..sort()).join(", ") + "]";
    };
}

String Function(Map<int, V>) p_e_idict<V>(String Function(V) f0) {
    var f1 = (MapEntry<int, V> e) => p_e_int()(e.key) + "=>" + f0(e.value);
    return (Map<int, V> dct) {        
        return "{" + (dct.entries.map(f1).toList()..sort()).join(", ") + "}";
    };
}

String Function(Map<String, V>) p_e_sdict<V>(String Function(V) f0) {
    var f1 = (MapEntry<String, V> e) => p_e_string()(e.key) + "=>" + f0(e.value);
    return (Map<String, V> dct) {
        return "{" + (dct.entries.map(f1).toList()..sort()).join(", ") + "}";
    };
}

String Function(V?) p_e_option<V>(String Function(V) f0) {
    return (V? opt) {
        return opt == null ? "null" : f0(opt);
    };
}

void main() {
    var p_e_out = [
        p_e_bool()(true),
        p_e_int()(3),
        p_e_double()(3.141592653),
        p_e_double()(3.0),
        p_e_string()("Hello, World!"),
        p_e_string()("!@#\$%^&*()\\\"\n\t"),
        p_e_list(p_e_int())([1, 2, 3]),
        p_e_list(p_e_bool())([true, false, true]),
        p_e_ulist(p_e_int())([3, 2, 1]),
        p_e_idict(p_e_string())({1: "one", 2: "two"}),
        p_e_sdict(p_e_list(p_e_int()))({"one": [1, 2, 3], "two": [4, 5, 6]}),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(null)
    ].join("\n");
    var file = File("stringify.out");
    file.writeAsStringSync(p_e_out);
}