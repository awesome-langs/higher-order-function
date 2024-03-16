import java.io.File

object Example {
    def p_e_escapeString(s: String): String = {
        val p_e_escapeChar: Char => String = c => c match {
            case '\r' => "\\r"
            case '\n' => "\\n"
            case '\t' => "\\t"
            case '\\' => "\\\\"
            case '\"' => "\\\""
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
        d => f"$d%.6f"
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
            p_e_int()(3),
            p_e_double()(3.141592653),
            p_e_double()(3.0),
            p_e_string()("Hello, World!"),
            p_e_string()("!@#$%^&*()\\\"\n\t"),
            p_e_list(p_e_int())(Seq(1, 2, 3)),
            p_e_list(p_e_bool())(Seq(true, false, true)),
            p_e_ulist(p_e_int())(Seq(3, 2, 1)),
            p_e_idict(p_e_string())(Map(1 -> "one", 2 -> "two")),
            p_e_sdict(p_e_list(p_e_int()))(Map("one" -> Seq(1, 2, 3), "two" -> Seq(4, 5, 6))),
            p_e_option(p_e_int())(Some(42)),
            p_e_option(p_e_int())(None)
        ).mkString("\n")
        new java.io.PrintWriter("stringify.out") { write(p_e_out); close }
    }
}