(define match-junk
  (lambda (k frag) 
    (call/cc (lambda (backtrack)  
      (if
        (and (<= 0 k)
          (pair? frag))
          (cons frag (lambda () (backtrack match-junk (- k 1) (cdr frag))))
          (cons '() (lambda () backtrack #f)))))))

(define match-*
  (lambda (matcher frag)
    (call/cc (lambda (backtrack)
       (cons frag (lambda () (backtrack (let ((tail (matcher frag)))
                   (and
                    tail
                    (match-* matcher (car tail)))))))))))

(define match-symbol
  (lambda (s frag)
    (call/cc (lambda (backtrack)
      (and (pair? frag)
      (eq? s (car frag))
      (cons (cdr frag) (lambda () backtrack #f)))))))

(define make-matcher
  (lambda (pat)
    (cond

      ((symbol? pat)
        (lambda (frag)
          (match-symbol pat frag)))

      ((eq? 'or (car pat))
        (let make-or-matcher ((pats (cdr pat)))
        (if (null? pats)
            (lambda (frag) #f)
           
            (let ((head-matcher (make-matcher (car pats)))
                  (tail-matcher (make-or-matcher (cdr pats))))
                        (lambda (frag)
                                (call/cc (lambda (backtrack)
                                        (let ((res (head-matcher frag)))
                                                (if (eq? res #f)
                                                (tail-matcher frag)
                                                 (cons (car res) (lambda () (backtrack
                                                        (let ((match_next ((cdr res))))
                                                                (if (eq? match_next #f)
                                                                        (tail-matcher frag)
                                                                match_next))))))))))))))
        ((eq? 'list (car pat))
            (let make-list-matcher ((pats (cdr pat)))
                (if (null? pats)
                (lambda (frag)
                  (call/cc (lambda (backtrack)
                        (cons frag (lambda () (backtrack #f))))))
               
                (let ((head-matcher (make-matcher (car pats)))
                              (tail-matcher (make-list-matcher (cdr pats))))
                                        (lambda (frag)
                                        (call/cc (lambda (backtrack)
                                                (let ((res (head-matcher frag)))
                                                        (if 
                                                          (eq? res #f)
                                                          #f
                                                          (let ((tail (tail-matcher (car res))))
                                                              (if (eq? tail #f)
                                                                #f
                                                                (cons (car tail)
                                                                (lambda () (backtrack
                                                                (let ((match_next ((cdr res))))
                                                                (if (eq? match_next #f)
                                                                        #f
                                                                        (tail-matcher (car match_next))))))))))))))))))

((eq? 'junk (car pat))
      (let ((k (cadr pat)))
        (lambda (frag)
          (match-junk k frag))))
 
     ((eq? '* (car pat))
      (let ((matcher (make-matcher (cadr pat))))
        (lambda (frag)
          (match-* matcher frag)))))))

