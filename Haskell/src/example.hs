import Data.List
import Data.Function 
import Data.Maybe
import Data.Map (Map)
import Text.Printf
import qualified Data.Map.Strict as Map

p_e_escapeString :: String -> String
p_e_escapeString s =
    let p_e_escapeChar :: Char -> String
        p_e_escapeChar c =
            case c of
                '\r' -> "\\r"
                '\n' -> "\\n"
                '\t' -> "\\t"
                '\\' -> "\\\\"
                '\"' -> "\\\""
                _ -> [c]
    in concatMap p_e_escapeChar s

p_e_bool :: Bool -> String
p_e_bool b =
    if b then "true" else "false"

p_e_int :: Int -> String
p_e_int i =
    show i

p_e_double :: Float -> String
p_e_double d =
    printf "%.6f" d

p_e_string :: String -> String
p_e_string s =
    "\"" ++ p_e_escapeString s ++ "\""

p_e_list :: (a -> String) -> [a] -> String
p_e_list f0 lst =
    "[" ++ intercalate ", " (lst & map f0) ++ "]"

p_e_ulist :: (a -> String) -> [a] -> String
p_e_ulist f0 lst =
    "[" ++ intercalate ", " (lst & map f0 & sort) ++ "]"

p_e_idict :: (a -> String) -> Map Int a -> String
p_e_idict f0 dct =
    let f1 (k, v) = p_e_int k ++ "=>" ++ f0 v
    in "{" ++ intercalate ", " (dct & Map.toList & map f1 & sort) ++ "}"

p_e_sdict :: (a -> String) -> Map String a -> String
p_e_sdict f0 dct =
    let f1 (k, v) = p_e_string k ++ "=>" ++ f0 v
    in "{" ++ intercalate ", " (dct & Map.toList & map f1 & sort) ++ "}"

p_e_option :: (a -> String) -> Maybe a -> String
p_e_option f0 opt =
    case opt of
        Just x -> f0 x
        Nothing -> "null"

main :: IO ()
main = do
    let p_e_out = intercalate "\n" [ 
                (p_e_bool) True
                , (p_e_int) 3
                , (p_e_double) 3.141592653
                , (p_e_double) 3.0
                , (p_e_string) "Hello, World!"
                , (p_e_string) "!@#$%^&*()\\\"\n\t"
                , (p_e_list (p_e_int)) [1, 2, 3]
                , (p_e_list (p_e_bool)) [True, False, True]
                , (p_e_ulist (p_e_int)) [3, 2, 1]
                , (p_e_idict (p_e_string)) (Map.fromList [(1, "one"), (2, "two")])
                , (p_e_sdict (p_e_list (p_e_int))) (Map.fromList [("one", [1, 2, 3]), ("two", [4, 5, 6])])
                , (p_e_option (p_e_int)) (Just 42)
                , (p_e_option (p_e_int)) Nothing
            ]
    writeFile "stringify.out" p_e_out