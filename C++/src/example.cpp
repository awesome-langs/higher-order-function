#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <unordered_map>
#include <algorithm>
#include <optional>
#include <functional> 
#include <ranges>
#include <format>

using namespace std;
using namespace std::literals;

string p_e_escapeString(string s) {
    auto p_e_escape_char = [](char c) -> string {
        if (c == '\\') return "\\\\";
        if (c == '\"') return "\\\"";
        if (c == '\n') return "\\n";
        if (c == '\t') return "\\t";
        return string(1, c);
    };
    // Commented code will be availabe in g++14
    // vector<string> res = s | views::transform(p_e_escape_char) | ranges::to<vector<string>>();
    auto tmp = s | views::transform(p_e_escape_char);
    vector<string> res = vector<string>(tmp.begin(), tmp.end());
    return ranges::fold_left(res | views::join_with(""sv), string(), plus());
}

function<string(bool)> p_e_bool() {
    return [](auto b) { return b ? "true" : "false"; };
}

function<string(int)> p_e_int() {
    return [](auto i) { return to_string(i); };
}

function<string(double)> p_e_double() {
    return [](auto d) { 
        string s0 = format("{:.7f}", d);
        string s1 = s0.substr(0, s0.length() - 1);
        return (s1 == "-0.000000") ? "0.000000" : s1;
    };
}

function<string(string)> p_e_string() {
    return [](auto s) { return "\"" + p_e_escapeString(s) + "\""; };
}

template <typename V>
function<string(vector<V>)> p_e_list(function<string(V)> f0) {
    return [f0](vector<V> lst) -> string {
        // vector<string> vs = lst | views::transform(f0) | ranges::to<vector<string>>();
        auto tmp = lst | views::transform(f0);
        vector<string> vs = vector<string>(tmp.begin(), tmp.end());
        return "[" + ranges::fold_left(vs | views::join_with(", "sv), string(), plus()) + "]";
    };
}

template <typename V>
function<string(vector<V>)> p_e_ulist(function<string(V)> f0) {
    return [f0](vector<V> lst) -> string {
        // vector<string> vs = lst | views::transform(f0) | ranges::to<vector<string>>();
        auto tmp = lst | views::transform(f0);
        vector<string> vs = vector<string>(tmp.begin(), tmp.end());
        ranges::sort(vs);
        return "[" + ranges::fold_left(vs | views::join_with(", "sv), string(), plus()) + "]";
    };
}

template <typename V>
function<string(unordered_map<int, V>)> p_e_idict(function<string(V)> f0) {
    function<string(pair<int, V>)> f1 = [f0](auto kv){return p_e_int()(kv.first) + "=>" + f0(kv.second); };
    return [f1](unordered_map<int, V> dct) -> string {
        // vector<string> vs = dct | views::transform(f1) | ranges::to<vector<string>>();
        auto tmp = dct | views::transform(f1);
        vector<string> vs = vector<string>(tmp.begin(), tmp.end());
        ranges::sort(vs);
        return "{" + ranges::fold_left(vs | views::join_with(", "sv), string(), plus()) + "}";
    };
}

template <typename V>
function<string(unordered_map<string, V>)> p_e_sdict(function<string(V)> f0) {
    function<string(pair<string, V>)> f1 = [f0](auto kv){return p_e_string()(kv.first) + "=>" + f0(kv.second); };
    return [f1](unordered_map<string, V> dct) -> string {
        // vector<string> vs = dct | views::transform(f1) | ranges::to<vector<string>>();
        auto tmp = dct | views::transform(f1);
        vector<string> vs = vector<string>(tmp.begin(), tmp.end());
        ranges::sort(vs);
        return "{" + ranges::fold_left(vs | views::join_with(", "sv), string(), plus()) + "}";
    };
}

template <typename V>
function<string(optional<V>)> p_e_option(function<string(V)> f0) {
    return [f0](optional<V> opt) -> string {
        if (opt.has_value()) {
            return f0(opt.value());
        } else {
            return "null";
        }
    };
}

int main() {
    string p_e_out = ranges::fold_left(vector<string>{
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
            p_e_idict(p_e_string())({{1, "one"}, {2, "two"}}),
            p_e_sdict(p_e_int())({{"one", 1}, {"two", 2}}),
            p_e_idict(p_e_list(p_e_int()))({}),
            p_e_idict(p_e_list(p_e_int()))({{1, {1, 2, 3}}, {2, {4, 5, 6}}}),            
            p_e_sdict(p_e_list(p_e_int()))({{"one", {1, 2, 3}}, {"two", {4, 5, 6}}}),
            p_e_list(p_e_idict(p_e_int()))({{{1, 2}}, {{3, 4}}}),
            p_e_idict(p_e_idict(p_e_int()))({{1, {{2, 3}}}, {4, {{5, 6}}}}),
            p_e_sdict(p_e_sdict(p_e_int()))({{"one", {{"two", 3}}}, {"four", {{"five", 6}}}}),
            p_e_option(p_e_int())(make_optional(42)),
            p_e_option(p_e_int())(nullopt),
            p_e_list(p_e_option(p_e_int()))({make_optional(1), nullopt, make_optional(3)})
        } | views::join_with("\n"sv), string(), plus());
    ofstream("stringify.out") << p_e_out;
}