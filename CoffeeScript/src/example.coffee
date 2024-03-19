p_e_escapeString = (s) ->
    p_e_escapeChar = (c) ->
        switch c
            when '\\' then "\\\\"
            when '"' then "\\\""
            when '\n' then "\\n"
            when '\t' then "\\t"            
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
        s0 = d.toFixed(7)
        s1 = s0.slice(0, -1)
        if s1 == "-0.000000" then "0.000000" else s1

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
        "{" + [...dct].map(f1).sort().join(", ") + "}"

p_e_sdict = (f0) ->
    f1 = ([k, v]) -> p_e_string()(k) + "=>" + f0(v)
    (dct) ->
        throw new Error() unless dct instanceof Map        
        "{" + [...dct].map(f1).sort().join(", ") + "}"

p_e_option = (f0) ->
    (opt) ->
        if opt != null  
            f0(opt)
        else
            "null"

p_e_out = [
    p_e_bool()(true)
    p_e_bool()(false)
    p_e_int()(3)
    p_e_int()(-107)
    p_e_double()(0.0)
    p_e_double()(-0.0)
    p_e_double()(3.0)
    p_e_double()(31.4159265)
    p_e_double()(123456.789)
    p_e_string()("Hello, World!")
    p_e_string()("!@\#$%^&*()[]{}<>:;,.\'\"?|")
    p_e_string()("/\\\n\t")
    p_e_list(p_e_int())([])
    p_e_list(p_e_int())([1, 2, 3])
    p_e_list(p_e_bool())([true, false, true])
    p_e_list(p_e_string())(["apple", "banana", "cherry"])
    p_e_list(p_e_list(p_e_int()))([])
    p_e_list(p_e_list(p_e_int()))([[1, 2, 3], [4, 5, 6]])
    p_e_ulist(p_e_int())([3, 2, 1])
    p_e_list(p_e_ulist(p_e_int()))([[2, 1, 3], [6, 5, 4]])
    p_e_ulist(p_e_list(p_e_int()))([[4, 5, 6], [1, 2, 3]])
    p_e_idict(p_e_int())(new Map([]))
    p_e_idict(p_e_string())(new Map([[1, "one"], [2, "two"]]))
    p_e_sdict(p_e_int())(new Map([["one", 1], ["two", 2]]))
    p_e_idict(p_e_list(p_e_int()))(new Map([]))
    p_e_idict(p_e_list(p_e_int()))(new Map([[1, [1, 2, 3]], [2, [4, 5, 6]]]))
    p_e_sdict(p_e_list(p_e_int()))(new Map([["one", [1, 2, 3]], ["two", [4, 5, 6]]]))
    p_e_list(p_e_idict(p_e_int()))([new Map([[1, 2]]), new Map([[3, 4]])])
    p_e_idict(p_e_idict(p_e_int()))(new Map([[1, new Map([[2, 3]])], [4, new Map([[5, 6]])]]))
    p_e_sdict(p_e_sdict(p_e_int()))(new Map([["one", new Map([["two", 3]])], ["four", new Map([["five", 6]])]]))
    p_e_option(p_e_int())(42)
    p_e_option(p_e_int())(null)
    p_e_list(p_e_option(p_e_int()))([1, null, 3])
].join("\n")
require("fs").writeFileSync("stringify.out", p_e_out)