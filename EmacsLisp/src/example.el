;; -*- lexical-binding: t -*-  

(require 'seq)
(require 'subr-x)

(defun p_e_escape-string (s)
    (let ((p_e_escape-char (lambda (c)
            (cond
                ((char-equal c ?\n) "\\n")
                ((char-equal c ?\r) "\\r")
                ((char-equal c ?\t) "\\t")
                ((char-equal c ?\\) "\\\\")
                ((char-equal c ?\") "\\\"")
                (t (string c))))))
        (string-join (seq-map p_e_escape-char s) "")))

(defun p_e_bool ()
    (lambda (b)
    (when (not (booleanp b)) (throw "" t))
    (if b "true" "false")))

(defun p_e_int ()
    (lambda (i)
    (when (not (integerp i)) (throw "" t))
    (number-to-string i)))

(defun p_e_double ()
    (lambda (d)
    (when (not (floatp d)) (throw "" t))
    (format "%.6f" d)))

(defun p_e_string ()
    (lambda (s)
    (when (not (stringp s)) (throw "" t))
    (concat "\"" (p_e_escape-string s) "\"")))

(defun p_e_list (f0)
    (lambda (lst)
        (when (not (listp lst)) (throw "" t))
        (concat "[" (string-join (seq-map f0 lst) ", ") "]")))

(defun p_e_ulist (f0)
    (lambda (lst)
        (when (not (listp lst)) (throw "" t))
        (concat "[" (string-join (seq-sort #'string< (seq-map f0 lst)) ", ") "]")))
    
(defun p_e_idict (f0)
    (let ((f1 (lambda (k v) (concat (funcall (p_e_int) k) "=>" (funcall f0 v)))))
        (lambda (dct)
            (when (not (hash-table-p dct)) (throw "" t))
            (let ((ret ()))
                (maphash (lambda (k v) (push (funcall f1 k v) ret)) dct)
                (concat "{" (string-join (seq-sort #'string< ret) ", ") "}")))))

(defun p_e_sdict (f0)
    (let ((f1 (lambda (k v) (concat (funcall (p_e_string) k) "=>" (funcall f0 v)))))
        (lambda (dct)
            (when (not (hash-table-p dct)) (throw "" t))
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

(let ((p_e_out (string-join
                (list
                    (funcall (p_e_bool) t)
                    (funcall (p_e_int) 3)
                    (funcall (p_e_double) 3.141592653)
                    (funcall (p_e_double) 3.0)
                    (funcall (p_e_string) "Hello, World!")
                    (funcall (p_e_string) "!@#$%^&*()\\\"\n")
                    (funcall (p_e_list (p_e_int)) '(1 2 3))
                    (funcall (p_e_list (p_e_bool)) '(t nil t))
                    (funcall (p_e_ulist (p_e_int)) '(3 2 1))
                    (funcall (p_e_idict (p_e_string)) (p_e_create-dict (list (cons 1 "one") (cons 2 "two"))))
                    (funcall (p_e_sdict (p_e_list (p_e_int))) (p_e_create-dict (list (cons "one" (list 1 2 3)) (cons "two" (list 4 5 6)))))
                    (funcall (p_e_option (p_e_int)) 42)
                    (funcall (p_e_option (p_e_int)) nil)   
                ) "\n")))
    (write-region p_e_out nil "stringify.out"))