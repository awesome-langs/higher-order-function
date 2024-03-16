import java.io.*;
import java.util.*;
import java.util.function.*;
import java.util.stream.*;

public class Example {
    static String p_e_escapeString(String s) {
        Function<Character, String> p_e_escapeChar = c -> {
            if (c == '\r') return "\\r";
            if (c == '\n') return "\\n";
            if (c == '\t') return "\\t";
            if (c == '\\') return "\\\\";
            if (c == '\"') return "\\\"";
            return Character.toString(c);
        };
        return s.chars().mapToObj(c -> p_e_escapeChar.apply((char)c)).collect(Collectors.joining());
    }
    
    static Function<Boolean, String> p_e_bool() {
        return b -> b ? "true" : "false";
    }

    static Function<Integer, String> p_e_int() {
        return i -> Integer.toString(i);
    }

    static Function<Double, String> p_e_double() {
        return d -> String.format("%.6f", d);
    }

    static Function<String, String> p_e_string() {
        return s -> "\"" + p_e_escapeString(s) + "\"";
    }
    
    static <V> Function<List<V>, String> p_e_list(Function<V, String> f0) {
        return lst -> "[" + lst.stream().map(f0).collect(Collectors.joining(", ")) + "]";
    }

    static <V> Function<List<V>, String> p_e_ulist(Function<V, String> f0) {
        return lst -> "[" + lst.stream().map(f0).sorted().collect(Collectors.joining(", ")) + "]";
    }

    static <V> Function<Map<Integer, V>, String> p_e_idict(Function<V, String> f0) {
        Function<Map.Entry<Integer, V>, String> f1 = kv -> p_e_int().apply(kv.getKey()) + "=>" + f0.apply(kv.getValue());
        return dct -> "{" + dct.entrySet().stream().map(f1).sorted().collect(Collectors.joining(", ")) + "}";
    }

    static <V> Function<Map<String, V>, String> p_e_sdict(Function<V, String> f0) {
        Function<Map.Entry<String, V>, String> f1 = kv -> p_e_string().apply(kv.getKey()) + "=>" + f0.apply(kv.getValue());
        return dct -> "{" + dct.entrySet().stream().map(f1).sorted().collect(Collectors.joining(", ")) + "}";
    }

    static <V> Function<Optional<V>, String> p_e_option(Function<V, String> f0) {
        return opt -> opt.isPresent() ? f0.apply(opt.get()) : "null";
    }
    
    public static void main(String[] args) throws IOException {
        String p_e_out = String.join("\n", new String[] {
            p_e_bool().apply(true),
            p_e_int().apply(3),
            p_e_double().apply(3.141592653),
            p_e_double().apply(3.0),
            p_e_string().apply("Hello, World!"),
            p_e_string().apply("!@#$%^&*()\\\"\n\t"),
            p_e_list(p_e_int()).apply(List.of(1, 2, 3)),
            p_e_list(p_e_bool()).apply(List.of(true, false, true)),
            p_e_ulist(p_e_int()).apply(List.of(3, 2, 1)),
            p_e_idict(p_e_string()).apply(Map.of(1, "one", 2, "two")),
            p_e_sdict(p_e_list(p_e_int())).apply(Map.of("one", List.of(1, 2, 3), "two", List.of(4, 5, 6))),
            p_e_option(p_e_int()).apply(Optional.of(42)),
            p_e_option(p_e_int()).apply(Optional.empty())
        });
        try (PrintWriter writer = new PrintWriter("stringify.out")) {
            writer.println(p_e_out);
        }
    }
}
