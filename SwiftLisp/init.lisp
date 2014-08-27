(prn "Hello, arc!")

(mac when (test . body)
    (list 'if test (cons 'do body)))

(def odd (num)
    (is (% num 2) 1))

(def even (num)
    (is (% num 2) 0))