#lang racket

(define (p_e_escape-string s)
    (define (p_e_escape-char c)
        (cond
            [(char=? c #\\) "\\\\"]
            [(char=? c #\") "\\\""]
            [(char=? c #\newline) "\\n"]
            [(char=? c #\tab) "\\t"]
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
        (let* ([s0 (~r #:precision '(= 7) d)]
            [s1 (substring s0 0 (- (string-length s0) 1))])
            (if (string=? s1 "-0.000000") "0.000000" s1))))

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
            ((p_e_bool) #f)
            ((p_e_int) 3)
            ((p_e_int) -107)
            ((p_e_double) 0.0)
            ((p_e_double) -0.0)
            ((p_e_double) 3.0)
            ((p_e_double) 31.4159265)
            ((p_e_double) 123456.789)
            ((p_e_string) "Hello, World!")
            ((p_e_string) "!@#$%^&*()[]{}<>:;,.'\"?|")
            ((p_e_string) "/\\\n\t")
            ((p_e_list (p_e_int)) (list))
            ((p_e_list (p_e_int)) (list 1 2 3))
            ((p_e_list (p_e_bool)) (list #t #f #t))
            ((p_e_list (p_e_string)) (list "apple" "banana" "cherry"))
            ((p_e_list (p_e_list (p_e_int))) (list))
            ((p_e_list (p_e_list (p_e_int))) (list (list 1 2 3) (list 4 5 6)))
            ((p_e_ulist (p_e_int)) (list 3 2 1))
            ((p_e_list (p_e_ulist (p_e_int))) (list (list 2 1 3) (list 6 5 4)))
            ((p_e_ulist (p_e_list (p_e_int))) (list (list 4 5 6) (list 1 2 3)))
            ((p_e_idict (p_e_int)) (make-hash (list)))
            ((p_e_idict (p_e_string)) (make-hash (list (cons 1 "one") (cons 2 "two"))))
            ((p_e_sdict (p_e_int)) (make-hash (list (cons "one" 1) (cons "two" 2))))
            ((p_e_idict (p_e_list (p_e_int))) (make-hash (list)))
            ((p_e_idict (p_e_list (p_e_int))) (make-hash (list (cons 1 (list 1 2 3)) (cons 2 (list 4 5 6)))))
            ((p_e_sdict (p_e_list (p_e_int))) (make-hash (list (cons "one" (list 1 2 3)) (cons "two" (list 4 5 6)))))
            ((p_e_list (p_e_idict (p_e_int))) (list (make-hash (list (cons 1 2))) (make-hash (list (cons 3 4)))))
            ((p_e_idict (p_e_idict (p_e_int))) (make-hash (list (cons 1 (make-hash (list (cons 2 3)))) (cons 4 (make-hash (list (cons 5 6)))))))
            ((p_e_sdict (p_e_sdict (p_e_int))) (make-hash (list (cons "one" (make-hash (list (cons "two" 3)))) (cons "four" (make-hash (list (cons "five" 6)))))))
            ((p_e_option (p_e_int)) 42)
            ((p_e_option (p_e_int)) #f)
            ((p_e_list (p_e_option (p_e_int))) (list 1 #f 3))
        ) "\n")])
    (call-with-output-file "stringify.out" (lambda (out) (display p_e_out out)) #:exists 'replace))