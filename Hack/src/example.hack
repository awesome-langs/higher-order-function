use HH\Lib\Vec;
use HH\Lib\Str;
use HH\Lib\Dict;

function p_e_escape_string(string $s): string {
    $p_e_escape_char = (string $c): string ==> {
        if ($c === "\\") return "\\\\";
        if ($c === "\"") return "\\\"";
        if ($c === "\n") return "\\n";
        if ($c === "\t") return "\\t";
        return $c;
    };
    return Str\join(Vec\map(Str\chunk($s), $p_e_escape_char), "");
}

function p_e_bool(): (function(bool): string) {
    return $b ==> $b ? "true" : "false";
}

function p_e_int(): (function(int): string) {
    return $i ==> (string)$i;
}

function p_e_double(): (function(float): string) {
    return $d ==> {
        $s0 = Str\format("%.7f", $d);
        $s1 = Str\slice($s0, 0, Str\length($s0) - 1);
        return $s1 === "-0.000000" ? "0.000000" : $s1;
    };
}

function p_e_string(): (function(string): string) {
    return $s ==> "\"" . p_e_escape_string($s) . "\"";
}

function p_e_list<V>((function(V): string) $f0): (function(vec<V>): string) {
    return (vec<V> $lst): string ==> {
        return "[" . Str\join(Vec\map($lst, $f0), ", ") . "]";
    };
}

function p_e_ulist<V>((function(V): string) $f0): (function(vec<V>): string) {
    return (vec<V> $lst): string ==> {
        return "[" . Str\join(Vec\sort(Vec\map($lst, $f0)), ", ") . "]";
    };
}

function p_e_idict<V>((function(V): string) $f0): (function(dict<int, V>): string) {
    $f1 = (int $k, V $v): string ==> p_e_int()($k) . "=>" . $f0($v);
    return (dict<int, V> $dct): string ==> {        
        return "{" . Str\join(Vec\sort(Dict\map_with_key($dct, $f1)), ", ") . "}";
    };
}

function p_e_sdict<V>((function(V): string) $f0): (function(dict<string, V>): string) {
     $f1 = (string $k, V $v): string ==> p_e_string()($k) . "=>" . $f0($v);
    return (dict<string, V> $dct): string ==> {       
        return "{" . Str\join(Vec\sort(Dict\map_with_key($dct, $f1)), ", ") . "}";
    };
}

function p_e_option<V>((function(V): string) $f0): (function(?V): string) {
    return (?V $opt): string ==> $opt !== null ? $f0($opt) : "null";
}

<<__EntryPoint>>
function main(): void {
    $p_e_out = Str\join(vec[
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
        p_e_string()("!@#\$%^&*()[]{}<>:;,.'\"?|"),
        p_e_string()("/\\\n\t"),
        p_e_list(p_e_int())(vec[]),
        p_e_list(p_e_int())(vec[1, 2, 3]),
        p_e_list(p_e_bool())(vec[true, false, true]),
        p_e_list(p_e_string())(vec["apple", "banana", "cherry"]),
        p_e_list(p_e_list(p_e_int()))(vec[]),
        p_e_list(p_e_list(p_e_int()))(vec[vec[1, 2, 3], vec[4, 5, 6]]),
        p_e_ulist(p_e_int())(vec[3, 2, 1]),
        p_e_list(p_e_ulist(p_e_int()))(vec[vec[2, 1, 3], vec[6, 5, 4]]),
        p_e_ulist(p_e_list(p_e_int()))(vec[vec[4, 5, 6], vec[1, 2, 3]]),
        p_e_idict(p_e_int())(dict[]),
        p_e_idict(p_e_string())(dict[1 => "one", 2 => "two"]),
        p_e_sdict(p_e_int())(dict["one" => 1, "two" => 2]),
        p_e_idict(p_e_list(p_e_int()))(dict[]),
        p_e_idict(p_e_list(p_e_int()))(dict[1 => vec[1, 2, 3], 2 => vec[4, 5, 6]]),
        p_e_sdict(p_e_list(p_e_int()))(dict["one" => vec[1, 2, 3], "two" => vec[4, 5, 6]]),
        p_e_list(p_e_idict(p_e_int()))(vec[dict[1 => 2], dict[3 => 4]]),
        p_e_idict(p_e_idict(p_e_int()))(dict[1 => dict[2 => 3], 4 => dict[5 => 6]]),
        p_e_sdict(p_e_sdict(p_e_int()))(dict["one" => dict["two" => 3], "four" => dict["five" => 6]]),
        p_e_option(p_e_int())(42),
        p_e_option(p_e_int())(null),
        p_e_list(p_e_option(p_e_int()))(vec[1, null, 3])
    ], "\n");
    $file = fopen("stringify.out", "w");
    fwrite($file, $p_e_out);
}