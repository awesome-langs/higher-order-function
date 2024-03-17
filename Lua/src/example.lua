local function p_e_escape_string(s)
    local p_e_escape_char = function(c)
        if c == '\\' then return "\\\\" end
        if c == '\"' then return "\\\"" end
        if c == '\n' then return "\\n" end
        if c == '\t' then return "\\t" end
        return c
    end
    local t = {}
    for i = 1, #s do
        table.insert(t, p_e_escape_char(s:sub(i, i)))
    end
    return table.concat(t)
end

local function p_e_bool()
    return function(b)
        if type(b) ~= "boolean" then
            error()
        end
        return b and "true" or "false"
    end
end

local function p_e_int()
    return function(i)
        if type(i) ~= "number" or math.floor(i) ~= i then
            error()
        end
        return tostring(i)
    end
end

local function p_e_double()
    return function(d)
        if type(d) ~= "number" then
            error()
        end
        local s0 = string.format("%.7f", d)
        local s1 = s0:sub(1, #s0 - 1)
        return s1 == "-0.000000" and "0.000000" or s1
    end
end

local function p_e_string()
    return function(s)
        if type(s) ~= "string" then
            error()
        end
        return "\"" .. p_e_escape_string(s) .. "\""
    end
end

local function p_e_list(f0)
    return function(lst)
        if type(lst) ~= "table" then
            error()
        end
        local t = {}
        for i = 1, #lst do
            table.insert(t, f0(lst[i]))
        end
        return "[" .. table.concat(t, ", ") .. "]"
    end
end

local function p_e_ulist(f0)
    return function(lst)
        if type(lst) ~= "table" then
            error()
        end
        local t = {}
        for i = 1, #lst do
            table.insert(t, f0(lst[i]))
        end
        table.sort(t)
        return "[" .. table.concat(t, ", ") .. "]"
    end
end

local function p_e_idict(f0)
    local f1 = function(k, v)
        return p_e_int()(k) .. "=>" .. f0(v)
    end
    return function(dct)
        if type(dct) ~= "table" then
            error()
        end
        local t = {}
        for k, v in pairs(dct) do
            table.insert(t, f1(k, v))
        end
        table.sort(t)
        return "{" .. table.concat(t, ", ") .. "}"
    end
end

local function p_e_sdict(f0)
    local f1 = function(k, v)
        return p_e_string()(k) .. "=>" .. f0(v)
    end
    return function(dct)
        if type(dct) ~= "table" then
            error()
        end
        local t = {}
        for k, v in pairs(dct) do
            table.insert(t, f1(k, v))
        end
        table.sort(t)
        return "{" .. table.concat(t, ", ") .. "}"
    end
end

local function p_e_option(f0)
    return function(opt)
        return opt and f0(opt) or "null"
    end
end

local p_e_out = table.concat({
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
    p_e_string()("!@#$%^&*()[]{}<>:;,.'\"?|"),
    p_e_string()("/\\\n\t"),
    p_e_list(p_e_int())({}),
    p_e_list(p_e_int())({1, 2, 3}),
    p_e_list(p_e_bool())({true, false, true}),
    p_e_list(p_e_string())({"apple", "banana", "cherry"}),
    p_e_list(p_e_list(p_e_int()))({}),
    p_e_list(p_e_list(p_e_int()))({{1, 2, 3}, {4, 5, 6}}),
    p_e_ulist(p_e_int())({3, 2, 1}),
    p_e_list(p_e_ulist(p_e_int()))({{2, 1, 3}, {6, 5, 4}}),
    p_e_ulist(p_e_list(p_e_int()))({{4, 5, 6}, {1, 2, 3}}),
    p_e_idict(p_e_int())({}),
    p_e_idict(p_e_string())({[1] = "one", [2] = "two"}),
    p_e_sdict(p_e_int())({["one"] = 1, ["two"] = 2}), 
    p_e_idict(p_e_list(p_e_int()))({}),
    p_e_idict(p_e_list(p_e_int()))({[1] = {1, 2, 3}, [2] = {4, 5, 6}}),
    p_e_sdict(p_e_list(p_e_int()))({["one"] = {1, 2, 3}, ["two"] = {4, 5, 6}}),
    p_e_list(p_e_idict(p_e_int()))({{[1] = 2}, {[3] = 4}}),
    p_e_idict(p_e_idict(p_e_int()))({[1] = {[2] = 3}, [4] = {[5] = 6}}),
    p_e_sdict(p_e_sdict(p_e_int()))({["one"] = {["two"] = 3}, ["four"] = {["five"] = 6}}),
    p_e_option(p_e_int())(42),
    p_e_option(p_e_int())(nil),
    p_e_list(p_e_option(p_e_int()))({1, nil, 3})
}, "\n")

local writer = io.open("stringify.out", "w")
writer:write(p_e_out)