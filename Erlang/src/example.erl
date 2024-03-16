-module(example).
-export([main/0]).

p_e_escape_string(S) ->
    Pe__escape_char = fun(C) ->
        case C of
            $\r -> "\\r";
            $\n -> "\\n";
            $\t -> "\\t";
            $\\ -> "\\\\";
            $" -> "\\\"";
            _ -> [C]
        end
    end,
    lists:flatten(lists:map(Pe__escape_char, S)).

p_e_bool() ->
    fun(B) ->
        case not ((B =:= true) or (B =:= false)) of 
            true -> erlang:error();
            false -> ok
        end,
        if B -> "true"; true -> "false" end
    end.


p_e_int() ->
    fun(I) ->
        case not is_integer(I) of 
            true -> erlang:error();
            false -> ok
        end,
        integer_to_list(I)
    end.

p_e_double() ->
    fun(D) ->
        case not is_float(D) of 
            true -> erlang:error();
            false -> ok
        end,
        lists:flatten(io_lib:format("~.6f", [D]))
    end.

p_e_string() ->
    fun(S) ->
        case not is_list(S) of 
            true -> erlang:error();
            false -> ok
        end,
        "\"" ++ p_e_escape_string(S) ++ "\""
    end.

p_e_list(F0) ->
    fun(Lst) -> 
        case not is_list(Lst) of 
            true -> erlang:error();
            false -> ok
        end,
        "[" ++ string:join(lists:map(F0, Lst), ", ") ++ "]"
    end.

p_e_ulist(F0) ->
    fun(Lst) -> 
        case not is_list(Lst) of 
            true -> erlang:error();
            false -> ok
        end,
        "[" ++ string:join(lists:sort(lists:map(F0, Lst)), ", ") ++ "]"
    end.

p_e_idict(F0) ->
    F1 = fun({K, V}) -> (p_e_int())(K) ++ "=>" ++ F0(V) end,
    fun(Dct) ->
        case not is_map(Dct) of 
            true -> erlang:error();
            false -> ok
        end,        
        "{" ++ string:join(lists:sort(lists:map(F1, maps:to_list(Dct))), ", ") ++ "}"
    end.

p_e_sdict(F0) ->
    F1 = fun({K, V}) -> (p_e_string())(K) ++ "=>" ++ F0(V) end,
    fun(Dct) ->
        case not is_map(Dct) of 
            true -> erlang:error();
            false -> ok
        end,
        "{" ++ string:join(lists:sort(lists:map(F1, maps:to_list(Dct))), ", ") ++ "}"
    end.

p_e_option(F0) ->
    fun(Opt) ->
        case Opt of
            none -> "null";
            X  -> F0(X)
        end
    end.

main() ->
    Pe__out = lists:join("\n", [
                (p_e_bool())(true),
                (p_e_int())(3),
                (p_e_double())(3.141592653),
                (p_e_double())(3.0),
                (p_e_string())("Hello, World!"),
                (p_e_string())("!@#$%^&*()\\\"\n\t"),
                (p_e_list(p_e_int()))([1, 2, 3]),
                (p_e_list(p_e_bool()))([true, false, true]),
                (p_e_ulist(p_e_int()))([3, 2, 1]),
                (p_e_idict(p_e_string()))(#{1 => "one", 2 => "two"}),
                (p_e_sdict(p_e_list(p_e_int())))(#{"one" => [1, 2, 3], "two" => [4, 5, 6]}),
                (p_e_option(p_e_int()))(42),
                (p_e_option(p_e_int()))(none)
            ]
        ),
    file:write_file("stringify.out", Pe__out).
