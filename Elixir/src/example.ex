defmodule Example do
    def p_e_escape_string(s) do
        p_e_escape_char = fn c ->
            case c do
            "\r" -> "\\r"
            "\n" -> "\\n"
            "\t" -> "\\t"
            "\\" -> "\\\\"
            "\"" -> "\\\""
            _ -> c
            end
        end
        s |> String.codepoints() |> Enum.map(p_e_escape_char) |> Enum.join()
    end
    
    def p_e_bool do
        fn b -> 
            if !is_boolean(b) do
                raise ArgumentError
            end
            if b, do: "true", else: "false"
        end
    end
    
    def p_e_int do
        fn i -> 
            if !is_integer(i) do
                raise ArgumentError
            end
            Integer.to_string(i)
        end
    end

    def p_e_double do
        fn d -> 
            if !is_float(d) do
                raise ArgumentError
            end
            :erlang.float_to_binary(d, decimals: 6)
        end
    end

    def p_e_string do
        fn s -> 
            if !is_binary(s) do
                raise ArgumentError
            end
            "\"" <> p_e_escape_string(s) <> "\""
        end
    end

    def p_e_list(f0) do
        fn lst -> 
            if !is_list(lst) do
                raise ArgumentError
            end
            "[" <> (lst |> Enum.map(f0) |> Enum.join(", ")) <> "]" 
        end
    end    
    
    def p_e_ulist(f0) do
        fn lst ->
            if !is_list(lst) do
                raise ArgumentError
            end
            "[" <> (lst |> Enum.map(f0) |> Enum.sort() |> Enum.join(", ")) <> "]"
        end
    end

    def p_e_idict(f0) do
        f1 = fn {k, v} -> p_e_int().(k) <> "=>" <> f0.(v) end
        fn dct -> 
            if !is_map(dct) do
                raise ArgumentError
            end            
            "{" <> (dct |> Enum.map(f1) |> Enum.join(", ")) <> "}"
        end
    end

    def p_e_sdict(f0) do
        f1 = fn {k, v} -> p_e_string().(k) <> "=>" <> f0.(v) end
        fn dct -> 
            if !is_map(dct) do
                raise ArgumentError
            end            
            "{" <> (dct |> Enum.map(f1) |> Enum.join(", ")) <> "}"
        end
    end

    def p_e_option(f0) do
        fn opt -> 
            case opt do
                nil -> "null"
                x -> f0.(x)
            end
        end
    end

    def main do
        p_e_out = Enum.join([
                    p_e_bool().(true) \
                    , p_e_int().(3) \
                    , p_e_double().(3.141592653) \
                    , p_e_double().(3.0) \
                    , p_e_string().("Hello, World!") \
                    , p_e_string().("!@#$%^&*()\\\"\n\t") \
                    , p_e_list(p_e_int()).([1, 2, 3]) \
                    , p_e_list(p_e_bool()).([true, false, true]) \
                    , p_e_ulist(p_e_int()).([3, 2, 1]) \
                    , p_e_idict(p_e_string()).(%{1 => "one", 2 => "two"}) \
                    , p_e_sdict(p_e_list(p_e_int())).(%{"one" => [1, 2, 3], "two" => [4, 5, 6]}) \
                    , p_e_option(p_e_int()).(42) \
                    , p_e_option(p_e_int()).(nil)
                ], "\n")
        File.write!("stringify.out", p_e_out)
    end
end

Example.main()