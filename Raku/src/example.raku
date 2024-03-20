sub p_e_escape-string(Str $s) {
    my $p_e_escape-char = -> Str $c {
        given $c {
            when "\n" { "\\n" }
            when "\t" { "\\t" }
            when "\\"  { "\\\\" }
            when "\""  { "\\\"" }
            default { $c }
        }
    };
    return $s.comb.map($p_e_escape-char).join;
}

sub p_e_bool() {
    return -> Bool $b { $b ?? "true" !! "false" };
}

sub p_e_int() {
    return -> Int $i { $i.Str };
}

sub p_e_double() {
    return -> Rat $d { 
        my $s0 = sprintf("%.7f", $d);
        my $s1 = substr($s0, 0, $s0.chars - 1);
        $s1 eq "-0.000000" ?? "0.000000" !! $s1
    }
}

sub p_e_string() {
    return -> Str $s { "\"" ~ p_e_escape-string($s) ~ "\"" };
}

sub p_e_list($f0) {
    return -> Array $lst { "[" ~ $lst.map($f0).join(", ") ~ "]" };
}

sub p_e_ulist($f0) {
    return -> Array $lst { "[" ~ $lst.map($f0).sort.join(", ") ~ "]" };
}

sub p_e_idict($f0) {
    my $f1 = -> $kv { p_e_int().($kv.key) ~ "=>" ~ $f0.($kv.value) };
    return -> Hash $dct { "\{" ~ $dct.map($f1).sort.join(", ") ~ "\}" };
}

sub p_e_sdict($f0) {
    my $f1 = -> $kv { p_e_string().($kv.key) ~ "=>" ~ $f0.($kv.value) };
    return -> Hash $dct { "\{" ~ $dct.map($f1).sort.join(", ") ~ "\}" };
}

sub p_e_option($f0) {
    return -> $opt { $opt.defined ?? $f0.($opt) !! "null" };
}

my $p_e_out = [
        p_e_bool().(True),
        p_e_bool().(False),
        p_e_int().(3),
        p_e_int().(-107),
        p_e_double().(0.0),
        p_e_double().(-0.0),
        p_e_double().(3.0),
        p_e_double().(31.4159265),
        p_e_double().(123456.789),
        p_e_string().("Hello, World!"),
        p_e_string().("!\@#\$%^&*()[]\{\}<>:;,.'\"?|"),
        p_e_string().("/\\\n\t"),
        p_e_list(p_e_int()).([]),
        p_e_list(p_e_int()).([1, 2, 3]),
        p_e_list(p_e_bool()).([True, False, True]),
        p_e_list(p_e_string()).(["apple", "banana", "cherry"]),
        p_e_list(p_e_list(p_e_int())).([]),
        p_e_list(p_e_list(p_e_int())).([[1, 2, 3], [4, 5, 6]]),
        p_e_ulist(p_e_int()).([3, 2, 1]),
        p_e_list(p_e_ulist(p_e_int())).([[2, 1, 3], [6, 5, 4]]),
        p_e_ulist(p_e_list(p_e_int())).([[4, 5, 6], [1, 2, 3]]),
        p_e_idict(p_e_int()).(:{}),
        p_e_idict(p_e_string()).(:{1 => "one", 2 => "two"}),
        p_e_sdict(p_e_int()).(:{"one" => 1, "two" => 2}),
        p_e_idict(p_e_list(p_e_int())).(:{}),
        p_e_idict(p_e_list(p_e_int())).(:{1 => [1, 2, 3], 2 => [4, 5, 6]}),
        p_e_sdict(p_e_list(p_e_int())).(:{"one" => [1, 2, 3], "two" => [4, 5, 6]}),
        p_e_list(p_e_idict(p_e_int())).([:{1 => 2}, :{3 => 4}]),
        p_e_idict(p_e_idict(p_e_int())).(:{1 => :{2 => 3}, 4 => :{5 => 6}}),
        p_e_sdict(p_e_sdict(p_e_int())).(:{"one" => :{"two" => 3}, "four" => :{"five" => 6}}),
        p_e_option(p_e_int()).(42),
        p_e_option(p_e_int()).(Nil),
        p_e_list(p_e_option(p_e_int())).([1, Nil, 3])
    ].join("\n");
spurt "stringify.out", $p_e_out;