let p_e_escape_string (s : string) : string =
    let p_e_escape_char (c : char) : string =
        match c with
        | '\r' -> "\\r"
        | '\n' -> "\\n"
        | '\t' -> "\\t"
        | '\\' -> "\\\\"
        | '\"' -> "\\\""
        | _ -> String.make 1 c
    in s |> String.to_seq |> List.of_seq |> List.map p_e_escape_char |> String.concat ""

let p_e_bool (b : bool) : string =
    if b then "true" else "false"

let p_e_int (i : int) : string =
    string_of_int i

let p_e_double (d : float) : string =
    Printf.sprintf "%.6f" d

let p_e_string (s : string) : string =
    "\"" ^ p_e_escape_string s ^ "\""

let p_e_list (f0 : 'a -> string) (lst : 'a list) : string =
    "[" ^ String.concat ", " (lst |> List.map f0) ^ "]"

let p_e_ulist (f0 : 'a -> string) (lst : 'a list) : string =
    "[" ^ String.concat ", " (lst |> List.map f0 |> List.sort compare) ^ "]"

let p_e_idict (f0 : 'a -> string) (dct : (int, 'a) Hashtbl.t) : string =
    let f1 (k, v) = p_e_int k ^ "=>" ^ f0 v
    in "{" ^ String.concat ", " (dct |> Hashtbl.to_seq |> List.of_seq |> List.map f1 |> List.sort compare) ^ "}"

let p_e_sdict (f0 : 'a -> string) (dct : (string, 'a) Hashtbl.t) : string =
    let f1 (k, v) = p_e_string k ^ "=>" ^ f0 v
    in "{" ^ String.concat ", " (dct |> Hashtbl.to_seq |> List.of_seq |> List.map f1 |> List.sort compare) ^ "}"

let p_e_option (f0 : 'a -> string) (opt : 'a option) : string =
    match opt with
    | Some x -> f0 x
    | None -> "null"

let () =
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
                ; (p_e_idict (p_e_string)) (Hashtbl.of_seq (List.to_seq [(1, "one"); (2, "two")]))
                ; (p_e_sdict (p_e_list (p_e_int))) (Hashtbl.of_seq (List.to_seq [("one", [1; 2; 3]); ("two", [4; 5; 6])]))
                ; (p_e_option (p_e_int)) (Some 42)
                ; (p_e_option (p_e_int)) None
            ]
    in
    let oc = open_out "stringify.out" in
    Printf.fprintf oc "%s" p_e_out;
    close_out oc