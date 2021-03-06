;;; $Id: chap2g.tst,v 4.0 1995/07/10 06:51:06 queinnec Exp $

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

;;; tests on let.

(let () 33)
   33
(let ((x 1)) x)
   1
(let ((x (* 2 3))
      (y (* 4 5)) )
  (+ x y) )
   26
(let ((x 1))
  1 2 3 )
   3

;;; tests on uninitialied variables
xyzy
   *** ; undefined

;;; tests on letrec
(letrec ((fact (lambda (n)
                 (if (= n 1) 1 (* n (fact (- n 1)))) )))
   (letrec ((odd? (lambda (n) (if (= n 0) #f (even? (- n 1)))))
            (even? (lambda (n) (if (= n 0) #t (odd? (- n 1))))) )
     (list (fact 5) (odd? 5) (odd? 4) (even? 4) (even? 3)) ) )
   (120 #t #f #t #f)

((label fact (lambda (n) (if (= n 1) 1 (* n (fact (- n 1))))))
 5 )
   120

;;; end of chap2g.tst
