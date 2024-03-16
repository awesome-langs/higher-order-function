let p_e_escapeString (s : string) : string =
    let p_e_escapeChar (c : char) : string =
        match c with
        | '\r' -> "\\r"
        | '\n' -> "\\n"
        | '\t' -> "\\t"
        | '\\' -> "\\\\"
        | '\"' -> "\\\""
        | _ -> string c
    s |> Seq.map p_e_escapeChar |> Seq.fold (+) ""

let p_e_bool (b : bool) : string =
    if b then "true" else "false"

let p_e_int (i : int) : string =
    string i

let p_e_double (d : float) : string =
    sprintf "%.6f" d

let p_e_string (s : string) : string =
    "\"" + p_e_escapeString s + "\""

let p_e_list (f0 : 'a -> string) (lst : 'a list) : string =
    "[" + String.concat ", " (List.map f0 lst) + "]"

let p_e_ulist (f0 : 'a -> string) (lst : 'a list) : string =
    "[" + String.concat ", " (List.map f0 lst |> List.sort) + "]"

let p_e_idict (f0 : 'a -> string) (dct : Map<int, 'a>) : string =
    let f1 (k, v) = string k + "=>" + f0 v
    "{" + String.concat ", " (dct |> Map.toList |> List.map f1 |> List.sort ) + "}"

let p_e_sdict (f0 : 'a -> string) (dct : Map<string, 'a>) : string =
    let f1 (k, v) = p_e_string k + "=>" + f0 v
    "{" + String.concat ", " (dct |> Map.toList |> List.map f1 |> List.sort ) + "}"

let p_e_option (f0 : 'a -> string) (opt : 'a option) : string =
    match opt with
    | Some x -> f0 x
    | None -> "null"

let p_e_out = String.concat "\n" [
            (p_e_bool) true
            ; (p_e_int) 3
            ; (p_e_double) 3.141592653
            ; (p_e_double) 3.0
            ; (p_e_string) "Hello, World!"
            ; (p_e_string) "!@#$%^&*()\\\"\n\t"
            ; (p_e_list (p_e_int)) [1; 2; 3]
            ; (p_e_list (p_e_bool)) [true; false; true]
            ; (p_e_ulist (p_e_int)) [3; 2; 1]
            ; (p_e_idict (p_e_string)) (Map [1, "one"; 2, "two"])
            ; (p_e_sdict (p_e_list (p_e_int))) (Map ["one", [1; 2; 3]; "two", [4; 5; 6]])
            ; (p_e_option (p_e_int)) (Some 42)
            ; (p_e_option (p_e_int)) None
        ]
System.IO.File.WriteAllText("stringify.out", p_e_out)