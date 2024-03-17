use strict;

use builtin qw(true false is_bool);
use feature qw(signatures);
use List::Util qw(pairmap);

sub p_e_escape_string($s) {
    my $p_e_escape_char = sub($c) {
        if ($c eq "\\") { return "\\\\"; }
        if ($c eq "\"") { return "\\\""; }
        if ($c eq "\n") { return "\\n"; }
        if ($c eq "\t") { return "\\t"; }
        return $c;
    };
    return join("", map { $p_e_escape_char->($_) } split(//, $s));
}

sub p_e_bool() {
    return sub($b) {
        unless (is_bool($b)) { die; }
        return $b ? "true" : "false";
    };
}

sub p_e_int() {
    return sub($i) {
        unless ($i =~ /^-?\d+\z/) { die; }
        return $i;
    };
}

sub p_e_double() {
    return sub($d) {
        unless ($d =~ /^-?(?:\d+\.?|\.\d)\d*\z/) { die; }
        my $s0 = sprintf("%.7f", $d);
        my $s1 = substr($s0, 0, length($s0) - 1);
        return $s1 eq "-0.000000" ? "0.000000" : $s1;
    };
}

sub p_e_string() {
    return sub($s) {
        return "\"" . p_e_escape_string($s) . "\"";
    };
}

sub p_e_list($f0) {
    return sub($lst) {
        unless (ref $lst eq "ARRAY") { die; }
        return "[" . join(", ", map { $f0->($_) } @$lst) . "]";
    };
}

sub p_e_ulist($f0) {
    return sub($lst) {
        unless (ref $lst eq "ARRAY") { die; }
        return "[" . join(", ", sort map { $f0->($_) } @$lst) . "]";
    };
}

sub p_e_idict($f0) {
    my $f1 = sub($k, $v) {
        return p_e_int()->($k) . "=>" . $f0->($v);
    };
    return sub($dct) {
        unless (ref $dct eq "HASH") { die; }
        return "{" . join(", ", sort { $a cmp $b } (pairmap { $f1->($a, $b) } %$dct)) . "}";
    };
}

sub p_e_sdict($f0) {
    my $f1 = sub($k, $v) {
        return p_e_string()->($k) . "=>" . $f0->($v);
    };
    return sub($dct) {
        unless (ref $dct eq "HASH") { die; }
        return "{" . join(", ", sort { $a cmp $b } (pairmap { $f1->($a, $b) } %$dct)) . "}";
    };
}

sub p_e_option($f0) {
    return sub($opt) {
        return $opt ? $f0->($opt) : "null";
    };
}

my $p_e_out = join("\n", (
    p_e_bool()->(true),
    p_e_bool()->(false),
    p_e_int()->(3),
    p_e_int()->(-107),
    p_e_double()->(0.0),
    p_e_double()->(-0.0),
    p_e_double()->(3.0),
    p_e_double()->(31.4159265),
    p_e_double()->(123456.789),
    p_e_string()->("Hello, World!"),
    p_e_string()->("!\@#\$%^&*()[]{}<>:;,.'\"?|"),
    p_e_string()->("/\\\n\t"),
    p_e_list(p_e_int())->([]),
    p_e_list(p_e_int())->([1, 2, 3]),
    p_e_list(p_e_bool())->([true, false, true]),
    p_e_list(p_e_string())->(["apple", "banana", "cherry"]),
    p_e_list(p_e_list(p_e_int()))->([]),
    p_e_list(p_e_list(p_e_int()))->([[1, 2, 3], [4, 5, 6]]),
    p_e_ulist(p_e_int())->([3, 2, 1]),
    p_e_list(p_e_ulist(p_e_int()))->([[2, 1, 3], [6, 5, 4]]),
    p_e_ulist(p_e_list(p_e_int()))->([[4, 5, 6], [1, 2, 3]]),
    p_e_idict(p_e_int())->({}),
    p_e_idict(p_e_string())->({1 => "one", 2 => "two"}),
    p_e_sdict(p_e_int())->({"one" => 1, "two" => 2}),
    p_e_idict(p_e_list(p_e_int()))->({}),
    p_e_idict(p_e_list(p_e_int()))->({1 => [1, 2, 3], 2 => [4, 5, 6]}),
    p_e_sdict(p_e_list(p_e_int()))->({"one" => [1, 2, 3], "two" => [4, 5, 6]}),
    p_e_list(p_e_idict(p_e_int()))->([{1 => 2}, {3 => 4}]),
    p_e_idict(p_e_idict(p_e_int()))->({1 => {2 => 3}, 4 => {5 => 6}}),
    p_e_sdict(p_e_sdict(p_e_int()))->({"one" => {"two" => 3}, "four" => {"five" => 6}}),
    p_e_option(p_e_int())->(42),
    p_e_option(p_e_int())->(undef),
    p_e_list(p_e_option(p_e_int()))->([1, undef, 3])
));
open(my $fh, ">", "stringify.out");
print $fh $p_e_out;
close $fh;