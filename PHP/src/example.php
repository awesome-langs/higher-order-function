<?php

function p_e_escape_string($s) {
    $p_e_escape_char = function ($c) {
        if ($c === "\\") return "\\\\";
        if ($c === "\"") return "\\\"";
        if ($c === "\n") return "\\n";
        if ($c === "\t") return "\\t";
        return $c;
    };
    return implode(array_map($p_e_escape_char, str_split($s)));
}

function p_e_bool() {
    return fn(bool $b) => $b ? "true" : "false";
}

function p_e_int() {
    return fn(int $b) => strval($b);
}

function p_e_double() {
    return function(float $d) {
        $s0 = sprintf("%.7f", $d);
        $s1 = substr($s0, 0, strlen($s0) - 1);
        return $s1 === "-0.000000" ? "0.000000" : $s1;
    };
}

function p_e_string() {
    return fn(string $s) => "\"" . p_e_escape_string($s) . "\"";
}

function p_e_list($f0) {
    return function(array $lst) use ($f0) {
        return "[" . implode(", ", array_map($f0, $lst)) . "]";
    };
}

function p_e_ulist($f0) {
    return function(array $lst) use ($f0) {
        $vs = array_map($f0, $lst);
        sort($vs);
        return "[" . implode(", ", $vs) . "]";
    };
}

function p_e_idict($f0) {
    $f1 = fn($k, $v) => p_e_int()($k) . "=>" . $f0($v);
    return function(array $dct) use ($f1) {
        $vs = array_map($f1, array_keys($dct), array_values($dct));
        sort($vs);
        return "{" . implode(", ", $vs) . "}";
    };
}

function p_e_sdict($f0) {
    $f1 = fn($k, $v) => p_e_string()($k) . "=>" . $f0($v);
    return function(array $dct) use ($f1) {
        $vs = array_map($f1, array_keys($dct), array_values($dct));
        sort($vs);
        return "{" . implode(", ", $vs) . "}";
    };
}

function p_e_option($f0) {
    return function($opt) use ($f0) {
        return $opt !== null ? $f0($opt) : "null";
    };
}

$p_e_out = implode("\n", [
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
    p_e_list(p_e_int())([]),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_list(p_e_string())(["apple", "banana", "cherry"]),
    p_e_list(p_e_list(p_e_int()))([]),
    p_e_list(p_e_list(p_e_int()))([[1, 2, 3], [4, 5, 6]]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_list(p_e_ulist(p_e_int()))([[2, 1, 3], [6, 5, 4]]),
    p_e_ulist(p_e_list(p_e_int()))([[4, 5, 6], [1, 2, 3]]),
    p_e_idict(p_e_int())([]),
    p_e_idict(p_e_string())([1 => "one", 2 => "two"]),
    p_e_sdict(p_e_int())(["one" => 1, "two" => 2]),
    p_e_idict(p_e_list(p_e_int()))([]),
    p_e_idict(p_e_list(p_e_int()))([1 => [1, 2, 3], 2 => [4, 5, 6]]),
    p_e_sdict(p_e_list(p_e_int()))(["one" => [1, 2, 3], "two" => [4, 5, 6]]),
    p_e_list(p_e_idict(p_e_int()))([["1" => 2], ["3" => 4]]),
    p_e_idict(p_e_idict(p_e_int()))([1 => ["2" => 3], 4 => ["5" => 6]]),
    p_e_sdict(p_e_sdict(p_e_int()))(["one" => ["two" => 3], "four" => ["five" => 6]]),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(null),
    p_e_list(p_e_option(p_e_int()))([1, null, 3])
]);
file_put_contents("stringify.out", $p_e_out);