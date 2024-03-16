package main

import (
    "fmt"
    "os"
    "slices"
    "strconv"
    "strings"
)

func p_e_escapeString(s string) string {
    p_e_escapeChar := func(c rune) string {
        if c == '\r' {
            return "\\r"
        }
        if c == '\n' {
            return "\\n"
        }
        if c == '\t' {
            return "\\t"
        }
        if c == '\\' {
            return "\\\\"
        }
        if c == '"' {
            return "\\\""
        }
        return string(c)
    }
    res := []string{}
    for _, c := range s {
        res = append(res, p_e_escapeChar(c))
    }
    return strings.Join(res, "")
}

func p_e_bool() func(bool) string {
    return func(b bool) string {
        if b {
            return "true"
        } else {
            return "false"
        }
    }
}

func p_e_int() func(int) string {
    return func(i int) string {
        return strconv.Itoa(i)
    }
}

func p_e_double() func(float64) string {
    return func(d float64) string {
        return fmt.Sprintf("%.6f", d)
    }
}

func p_e_string() func(string) string {
    return func(s string) string {
        return "\"" + p_e_escapeString(s) + "\""
    }
}

func p_e_list[V any](f0 func(V) string) func([]V) string {
    return func(lst []V) string {
        vs := []string{}
        for _, e := range lst {
            vs = append(vs, f0(e))
        }
        return "[" + strings.Join(vs, ", ") + "]"
    }
}

func p_e_ulist[V any](f0 func(V) string) func([]V) string {
    return func(lst []V) string {
        vs := []string{}
        for _, e := range lst {
            vs = append(vs, f0(e))
        }
        slices.Sort(vs)
        return "[" + strings.Join(vs, ", ") + "]"
    }
}

func p_e_idict[V any](f0 func(V) string) func(map[int]V) string {
    f1 := func(k int, v V) string {
        return p_e_int()(k) + "=>" + f0(v)
    } 
    return func(dct map[int]V) string {
        vs := []string{}
        for k, v := range dct {
            vs = append(vs, f1(k, v))
        }
        slices.Sort(vs)
        return "{" + strings.Join(vs, ", ") + "}"
    }
}

func p_e_sdict[V any](f0 func(V) string) func(map[string]V) string {
    f1 := func(k string, v V) string {
        return p_e_string()(k) + "=>" + f0(v)
    }
    return func(dct map[string]V) string {
        vs := []string{}
        for k, v := range dct {
            vs = append(vs, f1(k, v))
        }
        slices.Sort(vs)
        return "{" + strings.Join(vs, ", ") + "}"
    }
}

func p_e_option[V any](f0 func(V) string) func(*V) string {
    return func(opt *V) string {
        if opt == nil {
            return "null"
        } else {
            return f0(*opt)
        }
    }
}

func main() {
    p_e_out := strings.Join([]string{
        p_e_bool()(true),
        p_e_int()(3),
        p_e_double()(3.141592653),
        p_e_double()(3.0),
        p_e_string()("Hello, World!"),
        p_e_string()("!@#$%^&*()\\\"\n\t"),
        p_e_list(p_e_int())([]int{1, 2, 3}),
        p_e_list(p_e_bool())([]bool{true, false, true}),
        p_e_ulist(p_e_int())([]int{3, 2, 1}),
        p_e_idict(p_e_string())(map[int]string{1: "one", 2: "two"}),
        p_e_sdict(p_e_list(p_e_int()))(map[string][]int{"one": []int{1, 2, 3}, "two": []int{4, 5, 6}}),
        p_e_option(p_e_int())(&[]int{3}[0]),
        p_e_option(p_e_int())(nil),
    }, "\n")
    f, _ := os.Create("stringify.out")
    f.WriteString(p_e_out)
    f.Close()
}