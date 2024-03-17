def p_e_escape_string(s : String) : String
    p_e_escape_char = ->(c : Char) : String {
        case c
            when '\\' then "\\\\"
            when '"' then "\\\""
            when '\n' then "\\n"
            when '\t' then "\\t"
            else c.to_s
        end
    }
    s.chars.map(&p_e_escape_char).join
end

def p_e_bool : (Bool -> String)
    ->(b : Bool) : String {
        b ? "true" : "false"
    }
end

def p_e_int : (Int32 -> String)

    ->(i : Int32) : String {
        i.to_s
    }
end

def p_e_double : (Float64 -> String)
    ->(d : Float64) : String {
        s0 = sprintf("%.7f", d)
        s1 = s0[0, s0.size - 1]
        s1 == "-0.000000" ? "0.000000"  : s1
    }
end

def p_e_string : (String -> String)
    ->(s : String) : String {
        "\"" + p_e_escape_string(s) + "\""
    }
end

def p_e_list(f0 : (V -> String)) : (Array(V) -> String) forall V
    ->(lst : Array(V)) : String {
        "[" + lst.map(&f0).join(", ") + "]"
    }
end

def p_e_ulist(f0 : (V -> String)) : (Array(V) -> String) forall V
    ->(lst : Array(V)) : String {
        "[" + lst.map(&f0).sort.join(", ") + "]"
    }
end

def p_e_idict(f0 : (V -> String)) : (Hash(Int32, V) -> String) forall V
    f1 = ->(kv : Tuple(Int32, V)) : String {
        p_e_int.call(kv[0]) + "=>" + f0.call(kv[1])
    }
    ->(dct : Hash(Int32, V)) : String {
        "{" + dct.map(&f1).sort.join(", ") + "}"
    }
end

def p_e_sdict(f0 : (V -> String)) : (Hash(String, V) -> String) forall V
    f1 = ->(kv : Tuple(String, V)) : String {
        p_e_string.call(kv[0]) + "=>" + f0.call(kv[1])
    }
    ->(dct : Hash(String, V)) : String {
        "{" + dct.map(&f1).sort.join(", ") + "}"
    }
end

def p_e_option(f0 : (V -> String)) : ((V | Nil) -> String) forall V 
    ->(opt : (V | Nil)) : String {
        opt.nil? ? "null" : f0.call(opt)
    }
end

p_e_out = [
    p_e_bool().call(true),
    p_e_bool().call(false),
    p_e_int().call(3),
    p_e_int().call(-107),
    p_e_double().call(0.0),
    p_e_double().call(-0.0),
    p_e_double().call(3.0),
    p_e_double().call(31.4159265),
    p_e_double().call(123456.789),
    p_e_string().call("Hello, World!"),
    p_e_string().call("!@\#$%^&*()[]{}<>:;,.'\"?|"),
    p_e_string().call("/\\\n\t"),
    p_e_list(p_e_int()).call([] of Int32),
    p_e_list(p_e_int()).call([1, 2, 3]),
    p_e_list(p_e_bool()).call([true, false, true]),
    p_e_list(p_e_string()).call(["apple", "banana", "cherry"]),
    p_e_list(p_e_list(p_e_int())).call([] of Array(Int32)),
    p_e_list(p_e_list(p_e_int())).call([[1, 2, 3], [4, 5, 6]]),
    p_e_ulist(p_e_int()).call([3, 2, 1]),
    p_e_list(p_e_ulist(p_e_int())).call([[2, 1, 3], [6, 5, 4]]),
    p_e_ulist(p_e_list(p_e_int())).call([[4, 5, 6], [1, 2, 3]]),
    p_e_idict(p_e_int()).call({} of Int32 => Int32),
    p_e_idict(p_e_string()).call({1 => "one", 2 => "two"}),
    p_e_sdict(p_e_int()).call({"one" => 1, "two" => 2}),
    p_e_idict(p_e_list(p_e_int())).call({} of Int32 => Array(Int32)),
    p_e_idict(p_e_list(p_e_int())).call({1 => [1, 2, 3], 2 => [4, 5, 6]}),
    p_e_sdict(p_e_list(p_e_int())).call({"one" => [1, 2, 3], "two" => [4, 5, 6]}),
    p_e_list(p_e_idict(p_e_int())).call([{1 => 2}, {3 => 4}]),
    p_e_idict(p_e_idict(p_e_int())).call({1 => {2 => 3}, 4 => {5 => 6}}),
    p_e_sdict(p_e_sdict(p_e_int())).call({"one" => {"two" => 3}, "four" => {"five" => 6}}),
    p_e_option(p_e_int()).call(42),
    p_e_option(p_e_int()).call(nil),
    p_e_list(p_e_option(p_e_int())).call([1, nil, 3])
].join("\n")

File.write("stringify.out", p_e_out)