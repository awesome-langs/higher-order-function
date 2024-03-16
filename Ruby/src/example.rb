def p_e_escape_string(s)
    p_e_escape_char = lambda do |c|
        case c 
            when "\r" then "\\r"
            when "\n" then "\\n"
            when "\t" then "\\t"
            when "\\" then "\\\\"
            when "\"" then "\\\""
            else c
        end
    end
    s.chars.map(&p_e_escape_char).join
end

def p_e_bool()
    lambda do |b|
        raise "Not a boolean" unless b.is_a?(TrueClass) || b.is_a?(FalseClass)
        b ? "true" : "false"
    end
end

def p_e_int()
    lambda do |i|
        raise "Not an integer" unless i.is_a?(Integer)
        i.to_s
    end
end

def p_e_double()
    lambda do |d|
        raise "Not a number" unless d.is_a?(Float)
        "%.6f" % d
    end
end

def p_e_string()
    lambda do |s|
        raise "Not a string" unless s.is_a?(String)
        "\"" + p_e_escape_string(s) + "\""
    end
end

def p_e_list(f0)
    lambda do |lst|
        raise "Not a list" unless lst.is_a?(Array)
        "[" + lst.map(&f0).join(", ") + "]"
    end
end

def p_e_ulist(f0)
    lambda do |lst|
        raise "Not a list" unless lst.is_a?(Array)
        "[" + lst.map(&f0).sort.join(", ") + "]"
    end
end

def p_e_idict(f0)
    f1 = lambda { |k, v| p_e_int.call(k) + "=>" + f0.call(v) }
    lambda do |dct|
        raise "Not a dictionary" unless dct.is_a?(Hash)
        "{" + dct.map(&f1).join(", ") + "}"
    end
end

def p_e_sdict(f0)
    f1 = lambda { |k, v| p_e_string.call(k) + "=>" + f0.call(v) }
    lambda do |dct|
        raise "Not a dictionary" unless dct.is_a?(Hash)
        "{" + dct.map(&f1).join(", ") + "}"
    end
end

def p_e_option(f0)
    lambda do |opt|
        if opt.nil? then "null" else f0.call(opt) end
    end
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
File.open("stringify.out", "w") { |f| f.write(p_e_out) }