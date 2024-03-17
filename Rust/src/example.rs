use std::collections::HashMap;

fn p_e_escape_string(s: String) -> String {
    let p_e_escape_char = |c: char| match c {
        '\\' => "\\\\".to_string(),
        '\"' => "\\\"".to_string(),
        '\n' => "\\n".to_string(),
        '\t' => "\\t".to_string(),
        _ => c.to_string()
    };
    s.chars().map(p_e_escape_char).collect::<Vec<String>>().join("")
}

fn p_e_bool() -> impl Fn(bool) -> String {
    move |b| if b { "true".to_string() } else { "false".to_string() }
}

fn p_e_int() -> impl Fn(i32) -> String {
    move |i| i.to_string()
}

fn p_e_double() -> impl Fn(f64) -> String {
    move |d| {
        let s0 = format!("{:.7}", d);
        let s1 = s0[..s0.len()-1].to_string();
        if s1 == "-0.000000" { "0.000000".to_string() } else { s1 }
    }
}

fn p_e_string() -> impl Fn(String) -> String {
    move |s| format!("\"{}\"", p_e_escape_string(s))
}

fn p_e_list<V>(f0: impl Fn(V) -> String) -> impl Fn(Vec<V>) -> String {
    move |lst| format!("[{}]", lst.into_iter().map(&f0).collect::<Vec<String>>().join(", "))
}

fn p_e_ulist<V>(f0: impl Fn(V) -> String) -> impl Fn(Vec<V>) -> String {
    move |lst| { 
        let mut vs = lst.into_iter().map(&f0).collect::<Vec<String>>(); 
        vs.sort(); 
        format!("[{}]", vs.join(", ")) 
    }
}

fn p_e_idict<V>(f0: impl Fn(V) -> String) -> impl Fn(HashMap<i32, V>) -> String {
    let f1 = move |(k, v)| format!("{}=>{}", p_e_int()(k), f0(v));
    move |dct| {        
        let mut vs = dct.into_iter().map(&f1).collect::<Vec<String>>();
        vs.sort();
        format!("{{{}}}", vs.join(", "))
    }
}

fn p_e_sdict<V>(f0: impl Fn(V) -> String) -> impl Fn(HashMap<String, V>) -> String {
    let f1 = move |(k, v)| format!("{}=>{}", p_e_string()(k), f0(v));
    move |dct| {        
        let mut vs = dct.into_iter().map(&f1).collect::<Vec<String>>();
        vs.sort();
        format!("{{{}}}", vs.join(", "))
    }
}

fn p_e_option<V>(f0: impl Fn(V) -> String) -> impl Fn(Option<V>) -> String {
    move |opt| match opt {
        Some(x) => f0(x),
        None => "null".to_string()
    }
}

fn main() {
    let p_e_out = vec![
            p_e_bool()(true),
            p_e_bool()(false),
            p_e_int()(3),
            p_e_int()(-107),
            p_e_double()(0.0),
            p_e_double()(-0.0),
            p_e_double()(3.0),
            p_e_double()(31.4159265),
            p_e_double()(123456.789),
            p_e_string()("Hello, World!".to_string()),
            p_e_string()("!@#$%^&*()[]{}<>:;,.'\"?|".to_string()),
            p_e_string()("/\\\n\t".to_string()),
            p_e_list(p_e_int())(vec![]),
            p_e_list(p_e_int())(vec![1, 2, 3]),
            p_e_list(p_e_bool())(vec![true, false, true]),
            p_e_list(p_e_string())(vec!["apple".to_string(), "banana".to_string(), "cherry".to_string()]),
            p_e_list(p_e_list(p_e_int()))(vec![]),
            p_e_list(p_e_list(p_e_int()))(vec![vec![1, 2, 3], vec![4, 5, 6]]),
            p_e_ulist(p_e_int())(vec![3, 2, 1]),
            p_e_list(p_e_ulist(p_e_int()))(vec![vec![2, 1, 3], vec![6, 5, 4]]),
            p_e_ulist(p_e_list(p_e_int()))(vec![vec![4, 5, 6], vec![1, 2, 3]]),
            p_e_idict(p_e_int())(HashMap::from([])),
            p_e_idict(p_e_string())(HashMap::from([(1, "one".to_string()), (2, "two".to_string())])),
            p_e_sdict(p_e_int())(HashMap::from([("one".to_string(), 1), ("two".to_string(), 2)])),
            p_e_idict(p_e_list(p_e_int()))(HashMap::from([])),
            p_e_idict(p_e_list(p_e_int()))(HashMap::from([(1, vec![1, 2, 3]), (2, vec![4, 5, 6])])),
            p_e_sdict(p_e_list(p_e_int()))(HashMap::from([("one".to_string(), vec![1, 2, 3]), ("two".to_string(), vec![4, 5, 6])])),
            p_e_list(p_e_idict(p_e_int()))(vec![HashMap::from([(1, 2)]), HashMap::from([(3, 4)])]),
            p_e_idict(p_e_idict(p_e_int()))(HashMap::from([(1, HashMap::from([(2, 3)])), (4, HashMap::from([(5, 6)]))])),
            p_e_sdict(p_e_sdict(p_e_int()))(HashMap::from([("one".to_string(), HashMap::from([("two".to_string(), 3)])), ("four".to_string(), HashMap::from([("five".to_string(), 6)]))])),
            p_e_option(p_e_int())(Some(42)),
            p_e_option(p_e_int())(None),
            p_e_list(p_e_option(p_e_int()))(vec![Some(1), None, Some(3)])
        ].join("\n");
    std::fs::write("stringify.out", p_e_out).unwrap();
}