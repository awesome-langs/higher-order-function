use std::collections::HashMap;

fn p_e_escape_string(s: String) -> String {
    let p_e_escape_char = |c: char| match c {
        '\r' => "\\r".to_string(),
        '\n' => "\\n".to_string(),
        '\t' => "\\t".to_string(),
        '\\' => "\\\\".to_string(),
        '\"' => "\\\"".to_string(),
        _ => c.to_string()
    };
    s.chars().map(p_e_escape_char).collect::<Vec<String>>().join("")
}

fn p_e_bool() -> impl Fn(bool) -> String {
    |b| if b { "true".to_string() } else { "false".to_string() }
}

fn p_e_int() -> impl Fn(i32) -> String {
    |i| i.to_string()
}

fn p_e_double() -> impl Fn(f64) -> String {
    |d| format!("{:.6}", d)
}

fn p_e_string() -> impl Fn(String) -> String {
    |s| format!("\"{}\"", p_e_escape_string(s))
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
        p_e_int()(3),
        p_e_double()(3.141592653),
        p_e_double()(3.0),
        p_e_string()("Hello, World!".to_string()),
        p_e_string()("!@#$%^&*()\\\"\n\t".to_string()),
        p_e_list(p_e_int())(vec![1, 2, 3]),
        p_e_list(p_e_bool())(vec![true, false, true]),
        p_e_ulist(p_e_int())(vec![3, 2, 1]),
        p_e_idict(p_e_string())(HashMap::from([(1, "one".to_string()), (2, "two".to_string())])),
        p_e_sdict(p_e_list(p_e_int()))(HashMap::from([("one".to_string(), vec![1, 2, 3]), ("two".to_string(), vec![4, 5, 6])])),
        p_e_option(p_e_int())(Some(42)),
        p_e_option(p_e_int())(None)
    ].join("\n");
    std::fs::write("stringify.out", p_e_out).unwrap();
}