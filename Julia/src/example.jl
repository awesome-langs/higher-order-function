using Printf

function p_e_escape_string(s::String)::String
    p_e_escape_char(c::Char)::String = begin
        if c == '\\' 
            return "\\\\"
        elseif c == '\"' 
            return "\\\""
        elseif c == '\n' 
            return "\\n"
        elseif c == '\t' 
            return "\\t"
        else
            return string(c)
        end
    end
    return join(map(p_e_escape_char, collect(s)))
end

function p_e_bool()
    return (b::Bool) -> b ? "true" : "false"
end

function p_e_int()
    return (i::Int) -> string(i)
end

function p_e_double()
    return (d::Float64) -> begin
        s0 = @sprintf("%.7f", d)
        s1 = s0[1:end-1]
        s1 == "-0.000000" ? "0.000000" : s1
    end
end

function p_e_string()
    return (s::String) -> "\"" * p_e_escape_string(s) * "\""
end

function p_e_list(f0)
    return (lst::Vector) -> "[" * join(map(f0, lst), ", ") * "]"
end

function p_e_ulist(f0)
    return (lst::Vector)  -> "[" * join(sort(map(f0, lst)), ", ") * "]"
end

function p_e_idict(f0)
    f1 = kv -> p_e_int()(kv[1]) * "=>" * f0(kv[2])
    return (dct::Dict) -> "{" * join(sort(map(f1, collect(dct))), ", ") * "}"
end

function p_e_sdict(f0)
    f1 = kv -> p_e_string()(kv[1]) * "=>" * f0(kv[2])
    return (dct::Dict) -> "{" * join(sort(map(f1, collect(dct))), ", ") * "}"
end

function p_e_option(f0)
    return (opt::Union{Any, Nothing}) -> isnothing(opt) ? "null" : f0(opt)
end

p_e_out = join([
    p_e_bool()(true),
    p_e_bool()(false),
    p_e_int()(3),
    p_e_int()(-107),
    p_e_double()(0.0),
    p_e_double()(-0.0),
    p_e_double()(3.0),
    p_e_double()(31.4159265),
    p_e_double()(123456.789),
    p_e_string()("Hello, World!"),
    p_e_string()("!@#\$%^&*()[]{}<>:;,.'\"?|"),
    p_e_string()("/\\\n\t"),
    p_e_list(p_e_int())([]),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_list(p_e_string())(["apple", "banana", "cherry"]),
    p_e_list(p_e_list(p_e_int()))([]),
    p_e_list(p_e_list(p_e_int()))([[1, 2, 3], [4, 5, 6]]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_list(p_e_ulist(p_e_int()))([[2, 1, 3], [6, 5, 4]]),
    p_e_ulist(p_e_list(p_e_int()))([[4, 5, 6], [1, 2, 3]]),
    p_e_idict(p_e_int())(Dict()),
    p_e_idict(p_e_string())(Dict(1 => "one", 2 => "two")),
    p_e_sdict(p_e_int())(Dict("one" => 1, "two" => 2)),
    p_e_idict(p_e_list(p_e_int()))(Dict()),
    p_e_idict(p_e_list(p_e_int()))(Dict(1 => [1, 2, 3], 2 => [4, 5, 6])),
    p_e_sdict(p_e_list(p_e_int()))(Dict("one" => [1, 2, 3], "two" => [4, 5, 6])),
    p_e_list(p_e_idict(p_e_int()))([Dict(1 => 2), Dict(3 => 4)]),
    p_e_idict(p_e_idict(p_e_int()))(Dict(1 => Dict(2 => 3), 4 => Dict(5 => 6))),
    p_e_sdict(p_e_sdict(p_e_int()))(Dict("one" => Dict("two" => 3), "four" => Dict("five" => 6))),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(nothing),
    p_e_list(p_e_option(p_e_int()))([1, nothing, 3])
], "\n")

open("stringify.out", "w") do writer
    write(writer, p_e_out)
end
