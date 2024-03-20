def p_e_escape_string(s)
    p_e_escape_char = lambda do |c|
        case c 
            when "\\" then "\\\\"
            when "\"" then "\\\""
            when "\n" then "\\n"
            when "\t" then "\\t"
            else c
        end
    end
    s.chars.map(&p_e_escape_char).join
end

def p_e_bool()
    lambda do |b|
        raise "" unless b.is_a?(TrueClass) || b.is_a?(FalseClass)
        b ? "true" : "false"
    end
end

def p_e_int()
    lambda do |i|
        raise "" unless i.is_a?(Integer)
        i.to_s
    end
end

def p_e_double()
    lambda do |d|
        raise "" unless d.is_a?(Float)
        s0 = "%.7f" % d
        s1 = s0[0..-2]
        if s1 == "-0.000000" then "0.000000" else s1 end
    end
end

def p_e_string()
    lambda do |s|
        raise "" unless s.is_a?(String)
        "\"" + p_e_escape_string(s) + "\""
    end
end

def p_e_list(f0)
    lambda do |lst|
        raise "" unless lst.is_a?(Array)
        "[" + lst.map(&f0).join(", ") + "]"
    end
end

def p_e_ulist(f0)
    lambda do |lst|
        raise "" unless lst.is_a?(Array)
        "[" + lst.map(&f0).sort.join(", ") + "]"
    end
end

def p_e_idict(f0)
    f1 = lambda { |k, v| p_e_int.call(k) + "=>" + f0.call(v) }
    lambda do |dct|
        raise "" unless dct.is_a?(Hash)
        "{" + dct.map(&f1).sort.join(", ") + "}"
    end
end

def p_e_sdict(f0)
    f1 = lambda { |k, v| p_e_string.call(k) + "=>" + f0.call(v) }
    lambda do |dct|
        raise "" unless dct.is_a?(Hash)
        "{" + dct.map(&f1).sort.join(", ") + "}"
    end
end

def p_e_option(f0)
    lambda do |opt|
        if opt.nil? then "null" else f0.call(opt) end
    end
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
        p_e_list(p_e_int()).call([]),
        p_e_list(p_e_int()).call([1, 2, 3]),
        p_e_list(p_e_bool()).call([true, false, true]),
        p_e_list(p_e_string()).call(["apple", "banana", "cherry"]),
        p_e_list(p_e_list(p_e_int())).call([]),
        p_e_list(p_e_list(p_e_int())).call([[1, 2, 3], [4, 5, 6]]),
        p_e_ulist(p_e_int()).call([3, 2, 1]),
        p_e_list(p_e_ulist(p_e_int())).call([[2, 1, 3], [6, 5, 4]]),
        p_e_ulist(p_e_list(p_e_int())).call([[4, 5, 6], [1, 2, 3]]),
        p_e_idict(p_e_int()).call({}),
        p_e_idict(p_e_string()).call({1 => "one", 2 => "two"}),
        p_e_sdict(p_e_int()).call({"one" => 1, "two" => 2}),
        p_e_idict(p_e_list(p_e_int())).call({}),
        p_e_idict(p_e_list(p_e_int())).call({1 => [1, 2, 3], 2 => [4, 5, 6]}),
        p_e_sdict(p_e_list(p_e_int())).call({"one" => [1, 2, 3], "two" => [4, 5, 6]}),
        p_e_list(p_e_idict(p_e_int())).call([{1 => 2}, {3 => 4}]),
        p_e_idict(p_e_idict(p_e_int())).call({1 => {2 => 3}, 4 => {5 => 6}}),
        p_e_sdict(p_e_sdict(p_e_int())).call({"one" => {"two" => 3}, "four" => {"five" => 6}}),
        p_e_option(p_e_int()).call(42),
        p_e_option(p_e_int()).call(nil),
        p_e_list(p_e_option(p_e_int())).call([1, nil, 3])
    ].join("\n")

File.open("stringify.out", "w") { |f| f.write(p_e_out) }