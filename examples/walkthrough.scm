(load "init.scm")

;; Walkthrough: Debugging

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


;; Example: Instrumentation

(exec-at-metalevel (load "examples/taba.blk"))
(load "examples/cnv.scm")
(taba (cnv walk) (cnv '(1 2 3) '(a b c)))

;; Example: Meta-Level Undo

(exec-at-metalevel (load "examples/undo.blk"))
(exec-at-metalevel (define old-eval-var eval-var))
(exec-at-metalevel (set! eval-var (lambda (e r k) (if (eq? e 'n) (k 0) (old-eval-var e r k)))))
(define n 1)
n
(exec-at-metalevel (eq? old-eval-var eval-var))
(exec-at-metalevel (undo!))
n
(exec-at-metalevel (eq? old-eval-var eval-var))
