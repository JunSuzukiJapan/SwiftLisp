(prn "Hello, arc!")

(mac when (test . body)
    (list 'if test (cons 'do body)))