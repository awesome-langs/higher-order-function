(require '[clojure.string :as string])

(defn p_e_escape-string [s]
    (let [p_e_escape-char (fn [c]
            (cond
                (= c \newline) "\\n"
                (= c \return) "\\r"
                (= c \tab) "\\t"
                (= c \\) "\\\\"
                (= c \") "\\\""
                :else (str c)))]
    (string/join (map p_e_escape-char s))))

(defn p_e_bool []
    (fn [b]
        (when-not (boolean? b) (throw IllegalArgumentException))
        (if b "true" "false")))

(defn p_e_int []
    (fn [i]
        (when-not (int? i) (throw IllegalArgumentException))
        (str i)))

(defn p_e_double []
    (fn [d]        
        (when-not (double? d) (throw IllegalArgumentException))
        (format "%.6f" d)))

(defn p_e_string []
    (fn [s]
        (when-not (string? s) (throw IllegalArgumentException))
        (str "\"" (p_e_escape-string s) "\"")))

(defn p_e_list [f0]
    (fn [lst]
        (when-not (vector? lst) (throw IllegalArgumentException))
        (str "[" (string/join ", " (map f0 lst)) "]")))

(defn p_e_ulist [f0]
    (fn [lst]
        (when-not (vector? lst) (throw IllegalArgumentException))
        (str "[" (string/join ", " (sort (map f0 lst))) "]")))

(defn p_e_idict [f0]
    (let [f1 (fn [[k v]] (str ((p_e_int) k) "=>" (f0 v)))]
        (fn [dct]
            (when-not (map? dct) (throw IllegalArgumentException))
            (str "{" (string/join ", " (sort (map f1 dct))) "}"))))

(defn p_e_sdict [f0]
    (let [f1 (fn [[k v]] (str ((p_e_string) k) "=>" (f0 v)))]
        (fn [dct]
            (when-not (map? dct) (throw IllegalArgumentException))
            (str "{" (string/join ", " (sort (map f1 dct))) "}"))))

(defn p_e_option [f0]
    (fn [opt]
        (if opt (f0 opt) "null")))

(let [p_e_out (string/join "\n" [
                ((p_e_bool) true)
                ((p_e_int) 3)
                ((p_e_double) 3.141592653)
                ((p_e_double) 3.0)
                ((p_e_string) "Hello, World!")
                ((p_e_string) "!@#$%^&*()\\\"\n\t")
                ((p_e_list (p_e_int)) [1 2 3])
                ((p_e_list (p_e_bool)) [true false true])
                ((p_e_ulist (p_e_int)) [3 2 1])
                ((p_e_idict (p_e_string)) {1 "one", 2 "two"})
                ((p_e_sdict (p_e_list (p_e_int))) {"one" [1 2 3], "two" [4 5 6]})
                ((p_e_option (p_e_int)) 42)
                ((p_e_option (p_e_int)) nil)
            ])]
    (spit "stringify.out" p_e_out))