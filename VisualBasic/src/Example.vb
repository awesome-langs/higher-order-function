Module Example
    Function p_e_EscapeString(s As String) As String
        Dim p_e_EscapeChar As Func(Of Char, String) = Function(c As Char)
            If c = vbCr Then Return "\r"
            If c = vbLf Then Return "\n"
            If c = vbTab Then Return "\t"
            If c = "\" Then Return "\\"
            If c = """" Then Return "\"""
            Return c.ToString()
        End Function
        Return String.Join("", s.Select(Function(c) p_e_EscapeChar(c)))
    End Function

    Function p_e_bool() As Func(Of Boolean, String)
        Return Function(b As Boolean) If(b, "true", "false")
    End Function

    Function p_e_int() As Func(Of Integer, String)
        Return Function(i As Integer) i.ToString()
    End Function

    Function p_e_double() As Func(Of Double, String)
        Return Function(d As Double) d.ToString("F6")
    End Function

    Function p_e_string() As Func(Of String, String)
        Return Function(s As String) """" & p_e_EscapeString(s) & """"
    End Function

    Function p_e_list(Of V)(f0 As Func(Of V, String)) As Func(Of List(Of V), String)
        Return Function(lst As List(Of V)) "[" & String.Join(", ", lst.Select(f0)) & "]"
    End Function

    Function p_e_ulist(Of V)(f0 As Func(Of V, String)) As Func(Of List(Of V), String)
        Return Function(lst As List(Of V)) "[" & String.Join(", ", lst.Select(f0).OrderBy(Function(x) x)) & "]"
    End Function

    Function p_e_idict(Of V)(f0 As Func(Of V, String)) As Func(Of Dictionary(Of Integer, V), String)
        Dim f1 As Func(Of KeyValuePair(Of Integer, V), String) = Function(kv) p_e_int()(kv.Key) & "=>" & f0(kv.Value)
        Return Function(dct As Dictionary(Of Integer, V)) "{" & String.Join(", ", dct.Select(f1).OrderBy(Function(x) x)) & "}"
    End Function

    Function p_e_sdict(Of V)(f0 As Func(Of V, String)) As Func(Of Dictionary(Of String, V), String)
        Dim f1 As Func(Of KeyValuePair(Of String, V), String) = Function(kv) p_e_string()(kv.Key) & "=>" & f0(kv.Value)
        Return Function(dct As Dictionary(Of String, V)) "{" & String.Join(", ", dct.Select(f1).OrderBy(Function(x) x)) & "}"
    End Function

    Function p_e_option(Of V As Structure)(f0 As Func(Of V, String)) As Func(Of V?, String)
        Return Function(opt As V?) If(opt.HasValue, f0(opt.Value), "null")
    End Function

    Sub Main()
        Dim p_e_out As String = String.Join(Environment.NewLine, {
            p_e_bool()(True),
            p_e_int()(3),
            p_e_double()(3.141592653),
            p_e_double()(3.0),
            p_e_string()("Hello, World!"),
            p_e_string()("!@#$%^&*()\""" & vbLf & vbTab),
            p_e_list(p_e_int())(New List(Of Integer) From {1, 2, 3}),
            p_e_list(p_e_bool())(New List(Of Boolean) From {True, False, True}),
            p_e_ulist(p_e_int())(New List(Of Integer) From {3, 2, 1}),
            p_e_idict(p_e_string())(New Dictionary(Of Integer, String) From {{1, "one"}, {2, "two"}}),
            p_e_sdict(p_e_list(p_e_int()))(New Dictionary(Of String, List(Of Integer)) From {{"one", New List(Of Integer) From {1, 2, 3}}, {"two", New List(Of Integer) From {4, 5, 6}}}),
            p_e_option(p_e_int())(42),
            p_e_option(p_e_int())(Nothing)
        })
        System.IO.File.WriteAllText("stringify.out", p_e_out)
    End Sub
End Module