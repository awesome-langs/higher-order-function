use strict;

use builtin qw(true false is_bool);
use feature qw(signatures);
use List::Util qw(pairmap);

sub p_e_escape_string($s) {
    my $p_e_escape_char = sub($c) {
        if ($c eq "\r") { return "\\r"; }
        if ($c eq "\n") { return "\\n"; }
        if ($c eq "\t") { return "\\t"; }
        if ($c eq "\\") { return "\\\\"; }
        if ($c eq "\"") { return "\\\""; }
        return $c;
    };
    return join("", map { $p_e_escape_char->($_) } split(//, $s));
}

sub p_e_bool() {
    return sub($b) {
        if (!is_bool($b)) { die; }
        return $b ? "true" : "false";
    };
}

sub p_e_int() {
    return sub($i) {
        if (!($i =~ /^-?\d+\z/)) { die; }
        return $i;
    };
}

sub p_e_double() {
    return sub($d) {
        if (!($d =~ /^-?(?:\d+\.?|\.\d)\d*\z/)) { die; }
        return sprintf("%.6f", $d);
    };
}

sub p_e_string() {
    return sub($s) {
        return "\"" . p_e_escape_string($s) . "\"";
    };
}

sub p_e_list($f0) {
    return sub($lst) {
        if(!(ref $lst eq "ARRAY")) { die; }
        return "[" . join(", ", map { $f0->($_) } @$lst) . "]";
    };
}

sub p_e_ulist($f0) {
    return sub($lst) {
        if(!(ref $lst eq "ARRAY")) { die; }
        return "[" . join(", ", sort map { $f0->($_) } @$lst) . "]";
    };
}

sub p_e_idict($f0) {
    my $f1 = sub($k, $v) {
        return p_e_int()->($k) . "=>" . $f0->($v);
    };
    return sub($dct) {
        if(!(ref $dct eq "HASH")) { die; }
        return "{" . join(", ", sort { $a <=> $b } pairmap { $f1->($a, $b) } %$dct) . "}";
    };
}

sub p_e_sdict($f0) {
    my $f1 = sub($k, $v) {
        return p_e_string()->($k) . "=>" . $f0->($v);
    };
    return sub($dct) {
        if(!(ref $dct eq "HASH")) { die; }
        return "{" . join(", ", sort { $a <=> $b } pairmap { $f1->($a, $b) } %$dct) . "}";
    };
}

sub p_e_option($f0) {
    return sub($opt) {
        return $opt ? $f0->($opt) : "null";
    };
}

my $p_e_out = join("\n", (
    p_e_bool()->(true),
    p_e_int()->(3),
    p_e_double()->(3.141592653),
    p_e_double()->(3.0),
    p_e_string()->("Hello, World!"),
    p_e_string()->("!\@#\$%^&*()\\\"\n\t"),
    p_e_list(p_e_int())->([1, 2, 3]),
    p_e_list(p_e_bool())->([true, false, true]),
    p_e_ulist(p_e_int())->([3, 2, 1]),
    p_e_idict(p_e_string())->({1 => "one", 2 => "two"}),
    p_e_sdict(p_e_list(p_e_int()))->({"one" => [1, 2, 3], "two" => [4, 5, 6]}),
    p_e_option(p_e_int())->(42),
    p_e_option(p_e_int())->(undef)
));
open(my $fh, ">", "stringify.out");
print $fh $p_e_out;
close $fh;