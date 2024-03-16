
def p_e_escape_string(s : String) : String
    p_e_escape_char = ->(c : Char) : String {
        case c
            when '\\' then "\\\\"
            when '"' then "\\\""
            when '\r' then "\\r"
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
        sprintf("%.6f", d)
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
        "{" + dct.map(&f1).join(", ") + "}"
    }
end

def p_e_sdict(f0 : (V -> String)) : (Hash(String, V) -> String) forall V
    f1 = ->(kv : Tuple(String, V)) : String {
        p_e_string.call(kv[0]) + "=>" + f0.call(kv[1])
    }
    ->(dct : Hash(String, V)) : String {
        "{" + dct.map(&f1).join(", ") + "}"
    }
end

def p_e_option(f0 : (V -> String)) : ((V | Nil) -> String) forall V 
    ->(opt : (V | Nil)) : String {
        opt.nil? ? "null" : f0.call(opt)
    }
end

p_e_out = [
    p_e_bool().call(true),
    p_e_int().call(3),
    p_e_double().call(3.141592653),
    p_e_double().call(3.0),
    p_e_string().call("Hello, World!"),
    p_e_string().call("!@#$%^&*()\\\"\n\t"),
    p_e_list(p_e_int()).call([1, 2, 3]),
    p_e_list(p_e_bool()).call([true, false, true]),
    p_e_ulist(p_e_int()).call([3, 2, 1]),
    p_e_idict(p_e_string()).call({1 => "one", 2 => "two"}),
    p_e_sdict(p_e_list(p_e_int())).call({"one" => [1, 2, 3], "two" => [4, 5, 6]}),
    p_e_option(p_e_int()).call(42),
    p_e_option(p_e_int()).call(nil)
].join("\n")

File.write("stringify.out", p_e_out)