;;; $Id: chap1.scm,v 4.4 2006/11/27 09:01:48 queinnec Exp $
#lang r5rs
;; need r5rs *at least* for set-cdr!

;;;(((((((((((((((((((((((((((((((( L i S P ))))))))))))))))))))))))))))))))
;;; This file is derived from the files that accompany the book:
;;;     LISP Implantation Semantique Programmation (InterEditions, France)
;;;     or  Lisp In Small Pieces (Cambridge University Press).
;;; By Christian Queinnec <Christian.Queinnec@INRIA.fr>
;;; The original sources can be downloaded from the author's website at
;;;   http://pagesperso-systeme.lip6.fr/Christian.Queinnec/WWW/LiSP.html
;;; This file may have been altered from the original in order to work with
;;; modern schemes. The latest copy of these altered sources can be found at
;;;   https://github.com/appleby/Lisp-In-Small-Pieces
;;; If you want to report a bug in this program, open a GitHub Issue at the
;;; repo mentioned above.
;;; Check the README file before using this file.
;;;(((((((((((((((((((((((((((((((( L i S P ))))))))))))))))))))))))))))))))

;;;                      Programs of chapter 1.
;;; This is a naive evaluator for Scheme written in naive Scheme.

(define (naive-evaluate e env)
  (if (atom? e) 
      (cond ((symbol? e) (lookup e env))
            ((or (number? e) (string? e) (char? e)
                 (boolean? e) (vector? e) )
             e )
            (else (wrong "Cannot evaluate" e)) )
      (case (car e)
        ((quote)  (cadr e))
        ((if)     (if (naive-evaluate (cadr e) env)
                      (naive-evaluate (caddr e) env)
                      (naive-evaluate (cadddr e) env) ))
        ((begin)  (eprogn (cdr e) env))
        ((set!)   (update! (cadr e) env (naive-evaluate (caddr e) env)))
        ((lambda) (make-function (cadr e) (cddr e) env))
        (else     (invoke (naive-evaluate (car e) env)
                          (evlis (cdr e) env) )) ) ) )

(define (atom? x) (not (pair? x))) ; definitions
(define wrong 'wait) ; definitions
;; Racket has mutable pairs but the functions are named differently,
;; e.g. set-mcdr!
;; (define (set-cdr! ...)) ; => #lang r5rs
(define call/cc call-with-current-continuation) ; compat

;;; New version of evaluate taking care of interpreted booleans

(define the-false-value (cons "false" "boolean"))

(define (evaluate e env)
  (if (atom? e) 
      (cond ((symbol? e) (lookup e env))
            ((or (number? e)(string? e)(char? e)(boolean? e)(vector? e))
             e )
            (else (wrong "Cannot evaluate" e)) )
      (case (car e)
        ((quote)  (cadr e))
        ((if)     (if (not (eq? (evaluate (cadr e) env) the-false-value))
                      (evaluate (caddr e) env)
                      (evaluate (cadddr e) env) ))
        ((begin)  (eprogn (cdr e) env))
        ((set!)   (update! (cadr e) env (evaluate (caddr e) env)))
        ((lambda) (make-function (cadr e) (cddr e) env))
        (else     (invoke (evaluate (car e) env)
                          (evlis (cdr e) env) )) ) ) )

(define (eprogn exps env)
  (if (pair? exps)
      (if (pair? (cdr exps))
          (begin (evaluate (car exps) env)
                 (eprogn (cdr exps) env) )
          (evaluate (car exps) env) )
      '() ) )

(define (evlis exps env)
  (if (pair? exps)
      (cons (evaluate (car exps) env)
            (evlis (cdr exps) env) )
      '() ) ) 

(define (lookup id env)
  (if (pair? env)
      (if (eq? (caar env) id)
          (cdar env)
          (lookup id (cdr env)) )
      (wrong "No such binding" id) ) )

(define (update! id env value)
  (if (pair? env)
      (if (eq? (caar env) id)
          (begin (set-cdr! (car env) value)
                 value )
          (update! id (cdr env) value) )
      (wrong "No such binding" id) ) ) 

(define env.init '())

(define (extend env variables values)
  (cond ((pair? variables)
         (if (pair? values)
             (cons (cons (car variables) (car values))
                   (extend env (cdr variables) (cdr values)) )
             (wrong "Too less values") ) )
        ((null? variables)
             (if (null? values)
                 env 
                 (wrong "Too much values") ) )
        ((symbol? variables) (cons (cons variables values) env)) ) ) 

(define (invoke fn args)
  (if (procedure? fn) 
      (fn args)
      (wrong "Not a function" fn) ) ) 

;(define (make-function variables body env)
;  (lambda (values)
;     (eprogn body (extend env.init variables values)) ) ) 

;(define (make-function variables body env)
;  (lambda (values)
;     (eprogn body (extend env.global variables values)) ) ) 

(define (make-function variables body env)
  (lambda (values)
     (eprogn body (extend env variables values)) ) )

(define env.global env.init)

(define-syntax definitial 
  (syntax-rules ()
    ((definitial name)
     (begin (set! env.global (cons (cons 'name 'void) env.global))
            'name ) )
    ((definitial name value)
     (begin (set! env.global (cons (cons 'name value) env.global))
            'name ) ) ) )

(define-syntax defprimitive 
  (syntax-rules ()
    ((defprimitive name value arity)
     (definitial name 
        (lambda (values) 
          (if (= arity (length values))
              (apply value values)       ; The real \texttt{apply} of Scheme
              (wrong "Incorrect arity"
                     (list 'name values) ) ) ) ) ) ) )

(define-syntax defpredicate 
  (syntax-rules ()
    ((defpredicate name value arity)
     (defprimitive name
       (lambda values (or (apply value values) the-false-value))
       arity ) ) ) )

(definitial t #t)
(definitial f the-false-value)
(definitial nil '())

(definitial x)
(definitial y)
(definitial z)
(definitial a)
(definitial b)
(definitial c)
(definitial k)
(definitial foo)
(definitial bar)
(definitial hux)
(definitial fib)
(definitial fact)
(definitial visit)
(definitial length)
(definitial primes)

(defprimitive cons cons 2)
(defprimitive car car 1)
(defprimitive cdr cdr 1)
(defpredicate pair? pair? 1)
(defpredicate symbol? symbol? 1)
(defprimitive eq? eq? 2)           ; cf. exercice \ref{exer-predicate}
(defpredicate eq? eq? 2)           ; cf. exercice \ref{exer-predicate}
(defprimitive set-car! set-car! 2)
(defprimitive set-cdr! set-cdr! 2)
(defprimitive + + 2)
(defprimitive - - 2)
(defpredicate = = 2)
(defpredicate > > 2)
(defpredicate < < 2)               ; cf. exercice \ref{exer-predicate}\endlisp
(defprimitive * * 2)
(defpredicate <= <= 2)
(defpredicate >= >= 2)
(defprimitive remainder remainder 2)
(defprimitive display display 1)

(defprimitive call/cc 
  (lambda (f) 
    (call/cc (lambda (g) 
               (invoke 
                f (list (lambda (values)
                          (if (= (length values) 1)
                              (g (car values))
                              (wrong "Incorrect arity" g) ) ))) )) )
  1 )   

(definitial apply 
  (lambda (values)
    (if (>= (length values) 2)
        (let ((f (car values))
              (args (let flat ((args (cdr values)))
                      (if (null? (cdr args))
                          (car args)
                          (cons (car args) (flat (cdr args))) ) )) )
        (invoke f args) )
        (wrong "Incorrect arity" 'apply) ) ) )

(definitial list 
  (lambda (values) values) )

(define (chapter1-scheme)
  (define (toplevel)
     (display (evaluate (read) env.global))
     (newline)
     (toplevel) )
  (toplevel) )

;;;oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
;;;  Tests

(#%require racket/include)
(include "tester.scm")

;; defined per-book interpreter, no good approx. right now
(define (display-exception v) (display v))

(define tester-error 'wait) ; definitions.scm

(define (scheme1)
  (interpreter
   "Scheme? "
   "Scheme= "
   #t
   (lambda (read print error)
     (set! wrong error)
     (lambda ()
       (print (evaluate (read) env.global)) ) ) ) )

(define (test-scheme1 file)
  (suite-test
   file
   "Scheme? "
   "Scheme= "
   #t
   (lambda (read check error)
     (set! wrong error)
     (lambda ()
       (check (evaluate (read) env.global)) ) )
   (lambda (expected obtained)
     (or (equal? expected obtained)
         (and (eq? obtained the-false-value) (eq? expected #f)) ) ) ) )

;;; end of chap1.scm
