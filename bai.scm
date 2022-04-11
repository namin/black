(load "init.scm")

;; ## Warm up

;; Just like Scheme... at first.

(+ 2 1)
(define inc (lambda (x) (+ x 1)))
(inc 2)
((lambda (x) (+ x 1)) 2)
(map inc '(1 2 3))
(map (lambda (x) (+ x 1)) '(1 2 3))

;; Error loads new meta level.
(incr 2)

;; Two ways to go back down.

;; (1) call `old-cont`.
(old-cont (lambda (x) (+ x 1)))

(incr 2)
;; (2) use (base-eval exp env cont).
(base-eval 'inc old-env old-cont)



;; Going up without error.
(exit 'hello)

;; inc is not defined
inc

;; meta^2
(old-cont 1)
(old-cont 'back-to-user-level)



;; ## Counting Evaluations

(exec-at-metalevel (load "examples/instr2.blk"))
(load "examples/church.scm")
(instr (prd c2))
(instr (prd-alt c2))
(instr (to_int (prd-alt c2)))
(instr (to_int (prd c2)))



;; ## Walkthrough Debugging

(define foo (lambda (f) (lambda (x) (lambda () (f (+ x 1))))))
(define thunk ((foo 2) 3))
(thunk)

(old-cont 'ok)

(exec-at-metalevel (load "break.blk"))

(inspect thunk)
f
(set! f (lambda (x) (* 2 x)))
(exit 'done)
(thunk)
(thunk)

(define thunk2 ((foo 2) 3))
(thunk2)
(old-cont 'ok)

(exec-at-metalevel (load "examples/multn.blk"))

(thunk2)
(1 2 3 4)


;; ## Instrumentation: TABA

(exec-at-metalevel (load "examples/taba.blk"))
(load "examples/cnv.scm")
(taba (cnv walk) (cnv '(1 2 3) '(a b c)))



;; ## Meta-Level Undo

(exec-at-metalevel (load "examples/undo.blk"))
(exec-at-metalevel (define old-eval-var eval-var))
(exec-at-metalevel (set! eval-var (lambda (e r k) (if (eq? e 'n) (k 0) (old-eval-var e r k)))))
(define n 1)
n
(exec-at-metalevel (eq? old-eval-var eval-var))
(exec-at-metalevel (undo!))
n
(exec-at-metalevel (eq? old-eval-var eval-var))
