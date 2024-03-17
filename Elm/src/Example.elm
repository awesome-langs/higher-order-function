module Example exposing (..)
import Dict exposing (Dict)
import Posix.IO as IO exposing (..)
import Posix.IO.Process as Process
import Posix.IO.File as File
import Round

p_e_escapeString : String -> String
p_e_escapeString s =
    let p_e_escapeChar : Char -> String
        p_e_escapeChar c =
            case c of
                '\\' -> "\\\\"
                '\"' -> "\\\""
                '\n' -> "\\n"
                '\t' -> "\\t"
                _ -> String.fromChar c
    in s|> String.toList |> List.map p_e_escapeChar |> String.join ""

p_e_bool : Bool -> String
p_e_bool b =
    if b then "true" else "false"

p_e_int : Int -> String
p_e_int i =
    String.fromInt i

p_e_double : Float -> String
p_e_double d =
    let s0 = Round.round 7 d
        s1 = String.slice 0 (String.length s0 - 1) s0
    in if s1 == "-0.000000" then "0.000000" else s1

p_e_string : String -> String
p_e_string s =
    "\"" ++ p_e_escapeString s ++ "\""

p_e_list : (a -> String) -> List a -> String
p_e_list f0 lst =
    "[" ++ String.join ", " (lst |> List.map f0) ++ "]"

p_e_ulist : (a -> String) -> List a -> String
p_e_ulist f0 lst =
    "[" ++ String.join ", " (lst |> List.map f0 |> List.sort) ++ "]"

p_e_idict : (a -> String) -> Dict Int a -> String
p_e_idict f0 dct =
    let f1 kv = p_e_int (Tuple.first kv) ++ "=>" ++ f0 (Tuple.second kv)
    in "{" ++ String.join ", " (dct |> Dict.toList |> List.map f1 |> List.sort) ++ "}"

p_e_sdict : (a -> String) -> Dict String a -> String
p_e_sdict f0 dct =
    let f1 kv = p_e_string (Tuple.first kv) ++ "=>" ++ f0 (Tuple.second kv)
    in "{" ++ String.join ", " (dct |> Dict.toList |> List.map f1 |> List.sort) ++ "}"

p_e_option : (a -> String) -> Maybe a -> String
p_e_option f0 opt =
    case opt of
        Just x -> f0 x
        Nothing -> "null"

program : Process -> IO ()
program process =
    let p_e_out = String.join "\n" [ 
                (p_e_bool) True,
                (p_e_bool) False,
                (p_e_int) 3,
                (p_e_int) -107,
                (p_e_double) 0.0,
                (p_e_double) -0.0,
                (p_e_double) 3.0,
                (p_e_double) 31.4159265,
                (p_e_double) 123456.789,
                (p_e_string) "Hello, World!",
                (p_e_string) "!@#$%^&*()[]{}<>:;,.'\"?|",
                (p_e_string) "/\\\n\t",
                (p_e_list (p_e_int)) [],
                (p_e_list (p_e_int)) [1, 2, 3],
                (p_e_list (p_e_bool)) [True, False, True],
                (p_e_list (p_e_string)) ["apple", "banana", "cherry"],
                (p_e_list (p_e_list (p_e_int))) [],
                (p_e_list (p_e_list (p_e_int))) [[1, 2, 3], [4, 5, 6]],
                (p_e_ulist (p_e_int)) [3, 2, 1],
                (p_e_list (p_e_ulist (p_e_int))) [[2, 1, 3], [6, 5, 4]],
                (p_e_ulist (p_e_list (p_e_int))) [[4, 5, 6], [1, 2, 3]],
                (p_e_idict (p_e_int)) (Dict.fromList []),
                (p_e_idict (p_e_string)) (Dict.fromList [(1, "one"), (2, "two")]),
                (p_e_sdict (p_e_int)) (Dict.fromList [("one", 1), ("two", 2)]),
                (p_e_idict (p_e_list (p_e_int))) (Dict.fromList []),
                (p_e_idict (p_e_list (p_e_int))) (Dict.fromList [(1, [1, 2, 3]), (2, [4, 5, 6])]),
                (p_e_sdict (p_e_list (p_e_int))) (Dict.fromList [("one", [1, 2, 3]), ("two", [4, 5, 6])]),
                (p_e_list (p_e_idict (p_e_int))) [Dict.fromList [(1, 2)], Dict.fromList [(3, 4)]],
                (p_e_idict (p_e_idict (p_e_int))) (Dict.fromList [(1, Dict.fromList [(2, 3)]), (4, Dict.fromList [(5, 6)])]),
                (p_e_sdict (p_e_sdict (p_e_int))) (Dict.fromList [("one", Dict.fromList [("two", 3)]), ("four", Dict.fromList [("five", 6)])]),
                (p_e_option (p_e_int)) (Just 42),
                (p_e_option (p_e_int)) Nothing,
                (p_e_list (p_e_option (p_e_int))) [(Just 1), Nothing, (Just 3)]
            ]
    in File.writeContentsTo "stringify.out" p_e_out