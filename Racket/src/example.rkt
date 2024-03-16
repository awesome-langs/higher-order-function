#lang racket

(define (p_e_escape-string s)
    (define (p_e_escape-char c)
        (cond
            [(char=? c #\newline) "\\n"]
            [(char=? c #\return) "\\r"]
            [(char=? c #\tab) "\\t"]
            [(char=? c #\\) "\\\\"]
            [(char=? c #\") "\\\""]
            [else (string c)]))
    (string-join (map p_e_escape-char (string->list s)) ""))

(define (p_e_bool)
    (lambda (b) 
        (unless (boolean? b) (error 'failed))
        (if b "true" "false")))

(define (p_e_int)
    (lambda (i) 
        (unless (integer? i) (error 'failed))
        (number->string i)))

(define (p_e_double)
    (lambda (d) 
        (unless (real? d) (error 'failed))
        (~r #:precision '(= 6) d)))

(define (p_e_string)
    (lambda (s) 
        (unless (string? s) (error 'failed))
        (string-append "\"" (p_e_escape-string s) "\"")))

(define (p_e_list f0)
    (lambda (lst) 
        (unless (list? lst) (error 'failed))
        (string-append "[" (string-join (map f0 lst) ", ") "]")))

(define (p_e_ulist f0)
    (lambda (lst) 
        (unless (list? lst) (error 'failed))
        (string-append "[" (string-join (sort (map f0 lst) string<?) ", ") "]")))

(define (p_e_idict f0)
    (let ([f1 (lambda (kv) (string-append ((p_e_int) (car kv)) "=>" (f0 (cdr kv))))])
        (lambda (dct) 
            (unless (hash? dct) (error 'failed))
            (string-append "{" (string-join (sort (map f1 (hash->list dct)) string<?) ", ") "}"))))

(define (p_e_sdict f0)
    (let ([f1 (lambda (kv) (string-append ((p_e_string) (car kv)) "=>" (f0 (cdr kv))))])
        (lambda (dct) 
            (unless (hash? dct) (error 'failed))
            (string-append "{" (string-join (sort (map f1 (hash->list dct)) string<?) ", ") "}"))))
    
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
        ((p_e_idict (p_e_string)) #hash((1 . "one") (2 . "two")))
        ((p_e_sdict (p_e_list (p_e_int))) #hash(("one" . (1 2 3)) ("two" . (4 5 6))))
        ((p_e_option (p_e_int)) 42)
        ((p_e_option (p_e_int)) #f)) "\n")])
    (call-with-output-file "stringify.out" (lambda (out) (display p_e_out out)) #:exists 'replace))