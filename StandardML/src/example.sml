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
    Int.toString i;

fun p_e_double (d: real) : string =
    Real.fmt (StringCvt.FIX (SOME 6)) d;

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
        "{" ^ String.concatWith ", " (List.map f1 (HashTable.listItemsi dct)) ^ "}"
    end

fun p_e_sdict (f0: 'a -> string) (dct: (string, 'a) HashTable.hash_table) : string =
    let
        fun f1 (k, v) = p_e_string k ^ "=>" ^ f0 v
    in
        "{" ^ String.concatWith ", " (List.map f1 (HashTable.listItemsi dct)) ^ "}"
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
            p_e_bool true
            , p_e_int 3
            , p_e_double 3.141592653
            , p_e_double 3.0
            , p_e_string "Hello, World!"
            , p_e_string "!@#$%^&*()\\\"\n\t"
            , p_e_list p_e_int [1, 2, 3]
            , p_e_list p_e_bool [true, false, true]
            , p_e_ulist p_e_int [3, 2, 1]
            , p_e_idict p_e_string (p_e_createIdict [(1, "one"), (2, "two"), (3, "three")])
            , p_e_sdict (p_e_list p_e_int) (p_e_createSdict [("one", [1, 2, 3]), ("two", [4, 5, 6])])
            , p_e_option p_e_int (SOME 42)
            , p_e_option p_e_int NONE
        ]
in
    let
        val oc = TextIO.openOut "stringify.out"
    in
        TextIO.output (oc, p_e_out);
        TextIO.closeOut oc
    end
end;