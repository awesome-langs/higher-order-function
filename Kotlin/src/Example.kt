fun p_e_escapeString(s: String): String {
    val p_e_escapeChar = { c: Char ->
        when (c) {
            '\r' -> "\\r"
            '\n' -> "\\n"
            '\t' -> "\\t"
            '\\' -> "\\\\"
            '\"' -> "\\\""
            else -> c.toString()
        }
    }
    return s.map(p_e_escapeChar).joinToString("")
}

fun p_e_bool(): (Boolean) -> String {
    return { b -> if (b) "true" else "false" }
}

fun p_e_int(): (Int) -> String {
    return { i -> i.toString() }
}

fun p_e_double(): (Double) -> String {
    return { d -> String.format("%.6f", d) }
}

fun p_e_string(): (String) -> String {
    return { s -> "\"" + p_e_escapeString(s) + "\"" }
}

fun <V> p_e_list(f0: (V) -> String): (List<V>) -> String {
    return { lst -> "[" + lst.map(f0).joinToString(", ") + "]" }
}

fun <V> p_e_ulist(f0: (V) -> String): (List<V>) -> String {
    return { lst -> "[" + lst.map(f0).sorted().joinToString(", ") + "]" }
}

fun <V> p_e_idict(f0: (V) -> String): (Map<Int, V>) -> String {
    val f1 = { kv: Map.Entry<Int, V> -> p_e_int()(kv.key) + "=>" + f0(kv.value) }
    return { dct -> "{" + dct.entries.map(f1).sorted().joinToString(", ") + "}" }
}

fun <V> p_e_sdict(f0: (V) -> String): (Map<String, V>) -> String {
    val f1 = { kv: Map.Entry<String, V> -> p_e_string()(kv.key) + "=>" + f0(kv.value) }
    return { dct -> "{" + dct.entries.map(f1).sorted().joinToString(", ") + "}" }
}

fun <V> p_e_option(f0: (V) -> String): (V?) -> String {
    return { opt -> if (opt == null) "null" else f0(opt!!) }
}

fun main() {
    val p_e_out = listOf(
        p_e_bool()(true),
        p_e_int()(3),
        p_e_double()(3.141592653),
        p_e_double()(3.0),
        p_e_string()("Hello, World!"),
        p_e_string()("!@#\$%^&*()\\\"\n\t"),
        p_e_list(p_e_int())(listOf(1, 2, 3)),
        p_e_list(p_e_bool())(listOf(true, false, true)),
        p_e_ulist(p_e_int())(listOf(3, 2, 1)),
        p_e_idict(p_e_string())(mapOf(1 to "one", 2 to "two")),
        p_e_sdict(p_e_list(p_e_int()))(mapOf("one" to listOf(1, 2, 3), "two" to listOf(4, 5, 6))),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(null)
    ).joinToString("\n")
    val f = java.io.File("stringify.out")
    f.writeText(p_e_out)
}