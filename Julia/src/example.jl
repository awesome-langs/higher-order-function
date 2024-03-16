using Printf

function p_e_escape_string(s::String)::String
    p_e_escape_char(c::Char)::String = begin
        if c == '\r'
            return "\\r"
        elseif c == '\n'
            return "\\n"
        elseif c == '\t'
            return "\\t"
        elseif c == '\\'
            return "\\\\"
        elseif c == '\"'
            return "\\\""
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
    return (d::Float64) -> @sprintf("%.6f", d)
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
    return (opt::Union{Any, Missing}) -> ismissing(opt) ? "null" : f0(opt)
end

p_e_out = join([
    p_e_bool()(true),
    p_e_int()(3),
    p_e_double()(3.141592653),
    p_e_double()(3.0),
    p_e_string()("Hello, World!"),
    p_e_string()("!@#\$%^&*()\\\"\n\t"),
    p_e_list(p_e_int())([1, 2, 3]),
    p_e_list(p_e_bool())([true, false, true]),
    p_e_ulist(p_e_int())([3, 2, 1]),
    p_e_idict(p_e_string())(Dict(1 => "one", 2 => "two")),
    p_e_sdict(p_e_list(p_e_int()))(Dict("one" => [1, 2, 3], "two" => [4, 5, 6])),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(missing)
], "\n")
open("stringify.out", "w") do writer
    write(writer, p_e_out)
end
