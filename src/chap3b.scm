;;; $Id: chap3b.scm,v 4.2 2005/07/19 09:20:44 queinnec Exp $

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

;;; Excerpts from chapter 3 (not necessarily Scheme)

;; (define-syntax throw
;;   (syntax-rules ()
;;     ((throw tag value)
;;      (let* ((label tag)                                 ; compute once
;;             (escape (assv label (dynamic *active-catchers*))) )
;;        (if (pair? escape)
;;            ((cdr escape) value)
;;            (wrong "No associated catch to" label) ) ) ) ) )

;; (define-syntax catch
;;   (syntax-rules ()
;;     ((catch tag . body)
;;      (block label
;;        (dynamic-let ((*active-catchers*
;;                       (cons (cons tag (lambda (x)
;;                                         (return-from label x) ))
;;                             (dynamic *active-catchers*) ) ))
;;            . body ) ) ) ) )

;; (define (find-symbol id tree)
;;   (define (find tree)
;;      (if (pair? tree)
;;          (or (find (car tree))
;;              (find (cdr tree)) )
;;          (if (eq? tree id) (throw 'find #t) #f) ) )
;;   (catch 'find (find tree)) )

;;; end of chap3b.scm
