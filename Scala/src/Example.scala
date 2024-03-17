import java.io.File

object Example {
    def p_e_escapeString(s: String): String = {
        val p_e_escapeChar: Char => String = c => c match {
            case '\\' => "\\\\"
            case '\"' => "\\\""
            case '\n' => "\\n"
            case '\t' => "\\t"
            case c => c.toString
        }
        s.map(p_e_escapeChar).mkString
    }

    def p_e_bool(): Boolean => String = {
        case true => "true"
        case false => "false"
    }

    def p_e_int(): Int => String = {
        i => i.toString
    }

    def p_e_double(): Double => String = {
        d => {
            val s0 = f"$d%.7f"
            val s1 = s0.substring(0, s0.length - 1)
            if (s1 == "-0.000000") "0.000000" else s1
        }
    }

    def p_e_string(): String => String = {
        s => "\"" + p_e_escapeString(s) + "\""
    }

    def p_e_list[V](f0: V => String): scala.collection.Seq[V] => String = {
        lst => "[" + lst.map(f0).mkString(", ") + "]"
    }

    def p_e_ulist[V](f0: V => String): scala.collection.Seq[V] => String = {
        lst => "[" + lst.map(f0).sorted.mkString(", ") + "]"
    }

    def p_e_idict[V](f0: V => String): scala.collection.Map[Int, V] => String = {
        val f1: ((Int, V)) => String = kv => p_e_int()(kv._1) + "=>" + f0(kv._2)
        dct => "{" + dct.map(f1).toList.sorted.mkString(", ") + "}"
    }

    def p_e_sdict[V](f0: V => String): scala.collection.Map[String, V] => String = {
        val f1: ((String, V)) => String = kv => p_e_string()(kv._1) + "=>" + f0(kv._2)
        dct => "{" + dct.map(f1).toList.sorted.mkString(", ") + "}"
    }

    def p_e_option[V](f0: V => String): Option[V] => String = {
        opt => opt match {
            case Some(v) => f0(v)
            case None => "null"
        }
    }

    def main(args: Array[String]): Unit = {
        val p_e_out = Seq(
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
                p_e_list(p_e_int())(Seq()),
                p_e_list(p_e_int())(Seq(1, 2, 3)),
                p_e_list(p_e_bool())(Seq(true, false, true)),
                p_e_list(p_e_string())(Seq("apple", "banana", "cherry")),
                p_e_list(p_e_list(p_e_int()))(Seq()),
                p_e_list(p_e_list(p_e_int()))(Seq(Seq(1, 2, 3), Seq(4, 5, 6))),
                p_e_ulist(p_e_int())(Seq(3, 2, 1)),
                p_e_list(p_e_ulist(p_e_int()))(Seq(Seq(2, 1, 3), Seq(6, 5, 4))),
                p_e_ulist(p_e_list(p_e_int()))(Seq(Seq(4, 5, 6), Seq(1, 2, 3))),
                p_e_idict(p_e_int())(Map()),
                p_e_idict(p_e_string())(Map(1 -> "one", 2 -> "two")),
                p_e_sdict(p_e_int())(Map("one" -> 1, "two" -> 2)),
                p_e_idict(p_e_list(p_e_int()))(Map()),
                p_e_idict(p_e_list(p_e_int()))(Map(1 -> Seq(1, 2, 3), 2 -> Seq(4, 5, 6))),
                p_e_sdict(p_e_list(p_e_int()))(Map("one" -> Seq(1, 2, 3), "two" -> Seq(4, 5, 6))),
                p_e_list(p_e_idict(p_e_int()))(Seq(Map(1 -> 2), Map(3 -> 4))),
                p_e_idict(p_e_idict(p_e_int()))(Map(1 -> Map(2 -> 3), 4 -> Map(5 -> 6))),
                p_e_sdict(p_e_sdict(p_e_int()))(Map("one" -> Map("two" -> 3), "four" -> Map("five" -> 6))),
                p_e_option(p_e_int())(Some(42)),
                p_e_option(p_e_int())(None),
                p_e_list(p_e_option(p_e_int()))(Seq(Some(1), None, Some(3)))
            ).mkString("\n")
        new java.io.PrintWriter("stringify.out") { write(p_e_out); close }
    }
}