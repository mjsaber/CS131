#lang racket

(define product
  (lambda (ls)
    (call/cc
      (lambda (break)
        (let f ((ls ls))
          (cond
            ((null? ls) 1)
            ((= (car ls) 0) (break 0))
            (else (* (car ls) (f (cdr ls)))))))))) 

(product '(5 6 8 0 1))

(define (leaf? x) (not (list? x)))

(define (dfs l good?)
  (call/cc
    (lambda (continue)
      (cond ((null? l) #F)
            ((leaf? l)
             (if (good? l) (cons l (lambda () (continue #F))) #F))
            (#T (let ((left (dfs (car l) good?)))
                  (if left left (dfs (cdr l) good?))))))))

(define test1 (dfs '(((1 2) 3 4) 5) (lambda (x) (> x 3))))
