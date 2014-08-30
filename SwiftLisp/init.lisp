(prn "Hello, arc!")


(mac when (test . body)
    (list 'if test (cons 'do body)))

;; 奇数？
(def odd (num)
    (is (mod num 2) 1))

;; 偶数?
(def even (num)
    (is (mod num 2) 0))