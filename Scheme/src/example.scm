(use-modules (ice-9 hash-table))
(use-modules (ice-9 format))

(define (p_e_escape-string s)
    (define (p_e_escape-char c)
        (cond
            [(char=? c #\newline) "\\n"]
            [(char=? c #\return) "\\r"]
            [(char=? c #\tab) "\\t"]
            [(char=? c #\\) "\\\\"]
            [(char=? c #\") "\\\""]
            [else (string c)]))
    (apply string-append (map p_e_escape-char (string->list s))))

(define (p_e_bool)
    (lambda (b) (if b "true" "false")))

(define (p_e_int)
    (lambda (i) (number->string i)))

(define (p_e_double)
    (lambda (d) (format #f "~1,6f" d)))

(define (p_e_string)
    (lambda (s) (string-append "\"" (p_e_escape-string s) "\"")))

(define (p_e_list f0)
    (lambda (lst) (string-append "[" (string-join (map f0 lst) ", ") "]")))

(define (p_e_ulist f0)
    (lambda (lst) (string-append "[" (string-join (sort (map f0 lst) string<?) ", ") "]")))

(define (p_e_idict f0)
    (let ([f1 (lambda (k v) (string-append ((p_e_int) k) "=>" (f0 v)))])
        (lambda (dct) (string-append "{" (string-join (sort (hash-map->list f1 dct) string<?) ", ") "}"))))

(define (p_e_sdict f0)
    (let ([f1 (lambda (k v) (string-append ((p_e_string) k) "=>" (f0 v)))])
        (lambda (dct) (string-append "{" (string-join (sort (hash-map->list f1 dct) string<?) ", ") "}"))))
    
(define (p_e_option f0)
    (lambda (opt) (if opt (f0 opt) "null")))

(let ([p_e_out (string-join (list
        ((p_e_bool) #t)
        ((p_e_int) 3)
        ((p_e_double) 3.141592653)
        ((p_e_double) 3.0)
        ((p_e_string) "Hello, World!")
        ((p_e_string) "!@#$%^&*()\\\"\n\t")
        ((p_e_list (p_e_int)) '(1 2 3))
        ((p_e_list (p_e_bool)) '(#t #f #t))
        ((p_e_ulist (p_e_int)) '(3 2 1))
        ((p_e_idict (p_e_string)) (alist->hash-table '((1 . "one") (2 . "two"))))
        ((p_e_sdict (p_e_list (p_e_int))) (alist->hash-table '(("one" . (1 2 3)) ("two" . (4 5 6)))))
        ((p_e_option (p_e_int)) 42)
        ((p_e_option (p_e_int)) #f)) "\n")])
    (let ((out-port (open-file "stringify.out" "w")))
        (display p_e_out out-port)
        (close-port out-port)))