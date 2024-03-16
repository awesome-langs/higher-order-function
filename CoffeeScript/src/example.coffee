p_e_escapeString = (s) ->
    p_e_escapeChar = (c) ->
        switch c
            when '\r' then "\\r"
            when '\n' then "\\n"
            when '\t' then "\\t"
            when '\\' then "\\\\"
            when '"' then "\\\""
            else c
    [...s].map(p_e_escapeChar).join('')

p_e_bool = ->
    (b) ->
        throw new Error() unless typeof b is "boolean"
        if b then "true" else "false"

p_e_int = ->
    (i) ->
        throw new Error() unless typeof i is "number" and Number.isInteger(i)
        i.toString()

p_e_double = ->
    (d) ->
        throw new Error() unless typeof d is "number"
        d.toFixed(6)

p_e_string = ->
    (s) ->
        throw new Error() unless typeof s is "string"
        "\"" + p_e_escapeString(s) + "\""

p_e_list = (f0) ->
    (lst) ->
        throw new Error() unless Array.isArray(lst)
        "[" + lst.map(f0).join(", ") + "]"

p_e_ulist = (f0) ->
    (lst) ->
        throw new Error() unless Array.isArray(lst)
        "[" + lst.map(f0).sort().join(", ") + "]"

p_e_idict = (f0) ->
    f1 = ([k, v]) -> p_e_int()(k) + "=>" + f0(v)
    (dct) ->
        throw new Error() unless dct instanceof Map
        "{" + [...dct].map(f1).join(", ") + "}"

p_e_sdict = (f0) ->
    f1 = ([k, v]) -> p_e_string()(k) + "=>" + f0(v)
    (dct) ->
        throw new Error() unless dct instanceof Map        
        "{" + [...dct].map(f1).join(", ") + "}"

p_e_option = (f0) ->
    (opt) ->
        if opt != null  
            f0(opt)
        else
            "null"


p_e_out = [
    p_e_bool()(true)
    p_e_int()(3)
    p_e_double()(3.141592653)
    p_e_double()(3.0)
    p_e_string()("Hello, World!")
    p_e_string()("!@#$%^&*()\\\"\n\t")
    p_e_list(p_e_int())([1, 2, 3])
    p_e_list(p_e_bool())([true, false, true])
    p_e_ulist(p_e_int())([3, 2, 1])
    p_e_idict(p_e_string())(new Map([[1, "one"], [2, "two"]]))
    p_e_sdict(p_e_list(p_e_int()))(new Map([["one", [1, 2, 3]], ["two", [4, 5, 6]]]))
    p_e_option(p_e_int())(42)
    p_e_option(p_e_int())(null)
].join("\n")
require('fs').writeFileSync("stringify.out", p_e_out)