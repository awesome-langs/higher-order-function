fun p_e_replaceNeg (s: string) : string =
    if String.isPrefix "~" s then "-" ^ String.extract (s, 1, NONE) else s;

fun p_e_escapeString (s: string) : string =
    let
        fun p_e_escapeChar (c: char) : string =
            case c of
                #"\r" => "\\r"
                | #"\n" => "\\n"
                | #"\t" => "\\t"
                | #"\"" => "\\\""
                | #"\\" => "\\\\"
                | _ => String.str c
    in
        String.concat (List.map p_e_escapeChar (String.explode s))
    end;

fun p_e_bool (b: bool) : string =
    if b then "true" else "false";

fun p_e_int (i: int) : string =
    p_e_replaceNeg (Int.toString i);

fun p_e_double (d: real) : string =
    let 
        val s0 = Real.fmt (StringCvt.FIX (SOME 7)) d;
        val s1 = p_e_replaceNeg (String.substring (s0, 0, size s0 - 1));
    in
        if s1 = "-0.000000" then "0.000000" else s1
    end;

fun p_e_string (s: string) : string =
    "\"" ^ p_e_escapeString s ^ "\"";

fun p_e_list (f0: 'a -> string) (lst: 'a list) : string =
    "[" ^ String.concatWith ", " (List.map f0 lst) ^ "]";

fun p_e_ulist (f0: 'a -> string) (lst: 'a list) : string =
    "[" ^ String.concatWith ", " (ListMergeSort.sort op > (List.map f0 lst)) ^ "]";


fun p_e_idict (f0: 'a -> string) (dct: (int, 'a) HashTable.hash_table) : string =
    let
        fun f1 (k, v) = p_e_int k ^ "=>" ^ f0 v
    in
        "{" ^ String.concatWith ", " (ListMergeSort.sort op > (List.map f1 (HashTable.listItemsi dct))) ^ "}"
    end

fun p_e_sdict (f0: 'a -> string) (dct: (string, 'a) HashTable.hash_table) : string =
    let
        fun f1 (k, v) = p_e_string k ^ "=>" ^ f0 v
    in
        "{" ^ String.concatWith ", " (ListMergeSort.sort op > (List.map f1 (HashTable.listItemsi dct))) ^ "}"
    end

fun p_e_option (f0: 'a -> string) (opt: 'a option) : string =
    case opt of
        SOME x => f0 x
        | NONE => "null";

fun p_e_createIdict (lst: (int * 'a) list) : (int, 'a) HashTable.hash_table =
    let
        val ht = HashTable.mkTable (Word.fromInt, op=) (10, Fail "")
    in
        List.app (fn (k, v) => HashTable.insert ht (k, v)) lst;
        ht
    end;

fun p_e_createSdict (lst: (string * 'a) list) : (string, 'a) HashTable.hash_table =
    let
        val ht = HashTable.mkTable (HashString.hashString, op=) (10, Fail "")
    in
        List.app (fn (k, v) => HashTable.insert ht (k, v)) lst;
        ht
    end;

let
    val p_e_out = String.concatWith "\n" [
            (p_e_bool) true,
            (p_e_bool) false,
            (p_e_int) 3,
            (p_e_int) ~107,
            (p_e_double) 0.0,
            (p_e_double) ~0.0,
            (p_e_double) 3.0,
            (p_e_double) 31.4159265,
            (p_e_double) 123456.789,
            (p_e_string) "Hello, World!",
            (p_e_string) "!@#$%^&*()[]{}<>:;,.'\"?|",
            (p_e_string) "/\\\n\t",
            (p_e_list (p_e_int)) [],
            (p_e_list (p_e_int)) [1, 2, 3],
            (p_e_list (p_e_bool)) [true, false, true],
            (p_e_list (p_e_string)) ["apple", "banana", "cherry"],
            (p_e_list (p_e_list (p_e_int))) [],
            (p_e_list (p_e_list (p_e_int))) [[1, 2, 3], [4, 5, 6]],
            (p_e_ulist (p_e_int)) [3, 2, 1],
            (p_e_list (p_e_ulist (p_e_int))) [[2, 1, 3], [6, 5, 4]],
            (p_e_ulist (p_e_list (p_e_int))) [[4, 5, 6], [1, 2, 3]],
            (p_e_idict (p_e_int)) (p_e_createIdict []),
            (p_e_idict (p_e_string)) (p_e_createIdict [(1, "one"), (2, "two")]),
            (p_e_sdict (p_e_int)) (p_e_createSdict [("one", 1), ("two", 2)]),
            (p_e_idict (p_e_list (p_e_int))) (p_e_createIdict []),
            (p_e_idict (p_e_list (p_e_int))) (p_e_createIdict [(1, [1, 2, 3]), (2, [4, 5, 6])]),
            (p_e_sdict (p_e_list (p_e_int))) (p_e_createSdict [("one", [1, 2, 3]), ("two", [4, 5, 6])]),
            (p_e_list (p_e_idict (p_e_int))) [(p_e_createIdict [(1, 2)]), (p_e_createIdict [(3, 4)])],
            (p_e_idict (p_e_idict (p_e_int))) (p_e_createIdict [(1, (p_e_createIdict [(2, 3)])), (4, (p_e_createIdict [(5, 6)]))]),
            (p_e_sdict (p_e_sdict (p_e_int))) (p_e_createSdict [("one", (p_e_createSdict [("two", 3)])), ("four", (p_e_createSdict [("five", 6)]))]),
            (p_e_option (p_e_int)) (SOME 42),
            (p_e_option (p_e_int)) NONE,
            (p_e_list (p_e_option (p_e_int))) [SOME 1, NONE, SOME 3]
        ]
in
    let
        val oc = TextIO.openOut "stringify.out"
    in
        TextIO.output (oc, p_e_out);
        TextIO.closeOut oc
    end
end;