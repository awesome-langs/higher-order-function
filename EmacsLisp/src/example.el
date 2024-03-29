;; -*- lexical-binding: t -*-  

(require 'seq)
(require 'subr-x)

(defun p_e_escape-string (s)
    (let ((p_e_escape-char (lambda (c)
            (cond
                ((char-equal c ?\\) "\\\\")
                ((char-equal c ?\") "\\\"")
                ((char-equal c ?\n) "\\n")
                ((char-equal c ?\t) "\\t")
                (t (string c))))))
        (string-join (seq-map p_e_escape-char s) "")))

(defun p_e_bool ()
    (lambda (b)
    (unless (booleanp b) (throw "" t))
    (if b "true" "false")))

(defun p_e_int ()
    (lambda (i)
    (unless (integerp i) (throw "" t))
    (number-to-string i)))

(defun p_e_double ()
    (lambda (d)
    (unless (floatp d) (throw "" t))
    (let* ((s0 (format "%.7f" d))
        (s1 (substring s0 0 (- (length s0) 1))))
        (if (string= s1 "-0.000000") "0.000000" s1))))

(defun p_e_string ()
    (lambda (s)
    (unless (stringp s) (throw "" t))
    (concat "\"" (p_e_escape-string s) "\"")))

(defun p_e_list (f0)
    (lambda (lst)
        (unless (listp lst) (throw "" t))
        (concat "[" (string-join (seq-map f0 lst) ", ") "]")))

(defun p_e_ulist (f0)
    (lambda (lst)
        (unless (listp lst) (throw "" t))
        (concat "[" (string-join (seq-sort #'string< (seq-map f0 lst)) ", ") "]")))
    
(defun p_e_idict (f0)
    (let ((f1 (lambda (k v) (concat (funcall (p_e_int) k) "=>" (funcall f0 v)))))
        (lambda (dct)
            (unless (hash-table-p dct) (throw "" t))
            (let ((ret ()))
                (maphash (lambda (k v) (push (funcall f1 k v) ret)) dct)
                (concat "{" (string-join (seq-sort #'string< ret) ", ") "}")))))

(defun p_e_sdict (f0)
    (let ((f1 (lambda (k v) (concat (funcall (p_e_string) k) "=>" (funcall f0 v)))))
        (lambda (dct)
            (unless (hash-table-p dct) (throw "" t))
            (let ((ret ()))
                (maphash (lambda (k v) (push (funcall f1 k v) ret)) dct)
                (concat "{" (string-join (seq-sort #'string< ret) ", ") "}")))))

(defun p_e_option (f0)
    (lambda (opt)
        (if opt (funcall f0 opt) "null")))

(defun p_e_create-dict (lst)
    (let ((ret (make-hash-table)))
        (dolist (pair lst)
            (puthash (car pair) (cdr pair) ret))
        ret))

(let ((p_e_out (string-join (list
            (funcall (p_e_bool) t)
            (funcall (p_e_bool) nil)
            (funcall (p_e_int) 3)
            (funcall (p_e_int) -107)
            (funcall (p_e_double) 0.0)
            (funcall (p_e_double) -0.0)
            (funcall (p_e_double) 3.0)
            (funcall (p_e_double) 31.4159265)
            (funcall (p_e_double) 123456.789)
            (funcall (p_e_string) "Hello, World!")
            (funcall (p_e_string) "!@#$%^&*()[]{}<>:;,.'\"?|")
            (funcall (p_e_string) "/\\\n\t")
            (funcall (p_e_list (p_e_int)) (list))
            (funcall (p_e_list (p_e_int)) (list 1 2 3))
            (funcall (p_e_list (p_e_bool)) (list t nil t))
            (funcall (p_e_list (p_e_string)) (list "apple" "banana" "cherry"))
            (funcall (p_e_list (p_e_list (p_e_int))) (list))
            (funcall (p_e_list (p_e_list (p_e_int))) (list (list 1 2 3) (list 4 5 6)))
            (funcall (p_e_ulist (p_e_int)) (list 3 2 1))
            (funcall (p_e_list (p_e_ulist (p_e_int))) (list (list 2 1 3) (list 6 5 4)))
            (funcall (p_e_ulist (p_e_list (p_e_int))) (list (list 4 5 6) (list 1 2 3)))
            (funcall (p_e_idict (p_e_int)) (p_e_create-dict (list)))
            (funcall (p_e_idict (p_e_string)) (p_e_create-dict (list (cons 1 "one") (cons 2 "two"))))
            (funcall (p_e_sdict (p_e_int)) (p_e_create-dict (list (cons "one" 1) (cons "two" 2))))
            (funcall (p_e_idict (p_e_list (p_e_int))) (p_e_create-dict (list)))
            (funcall (p_e_idict (p_e_list (p_e_int))) (p_e_create-dict (list (cons 1 (list 1 2 3)) (cons 2 (list 4 5 6)))))
            (funcall (p_e_sdict (p_e_list (p_e_int))) (p_e_create-dict (list (cons "one" (list 1 2 3)) (cons "two" (list 4 5 6)))))
            (funcall (p_e_list (p_e_idict (p_e_int))) (list (p_e_create-dict (list (cons 1 2))) (p_e_create-dict (list (cons 3 4)))))
            (funcall (p_e_idict (p_e_idict (p_e_int))) (p_e_create-dict (list (cons 1 (p_e_create-dict (list (cons 2 3)))) (cons 4 (p_e_create-dict (list (cons 5 6)))))))
            (funcall (p_e_sdict (p_e_sdict (p_e_int))) (p_e_create-dict (list (cons "one" (p_e_create-dict (list (cons "two" 3)))) (cons "four" (p_e_create-dict (list (cons "five" 6)))))))
            (funcall (p_e_option (p_e_int)) 42)
            (funcall (p_e_option (p_e_int)) nil)
            (funcall (p_e_list (p_e_option (p_e_int))) (list 1 nil 3))
        ) "\n")))
    (write-region p_e_out nil "stringify.out"))