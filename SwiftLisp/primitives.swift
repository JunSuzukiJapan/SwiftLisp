/*

The MIT License (MIT)

Copyright (c) 2014 Toru Ariga, Jun Suzuki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import Foundation

class PrimCar : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return car(car(operand))
    }
}

class PrimCdr : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return cdr(car(operand))
    }
}

class PrimList : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return operand
    }
}

class PrimQuote : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if cdr(operand) is Nil {
            return car(operand);
        } else {
            return Error(message: "Wrong number of arguments: " + operand.toStr());
        }
    }
}

class PrimCons : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return cons(car(operand), cadr(operand))
    }
}

class PrimPrn : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        var list = operand
        var result: LispObj = car(list)
        
        while list is ConsCell {
            let item = car(list)
            if let str = item as? LispStr {
                print(str.value)
            }else{
                print(item.toStr())
            }
            
            list = cdr(list)
        }
        println()
        
        return result
    }
}

class PrimPr : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        var list = operand
        var result: LispObj = car(list)
        
        while list is ConsCell {
            let item = car(list)
            if let str = item as? LispStr {
                print(str.value)
            }else{
                print(item.toStr())
            }
            
            list = cdr(list)
        }
        
        return result
    }
}

class Setf : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        // (= x 10)
        // (= y "test")
        // (= z (+ 1 2))
        if let variable = car(operand) as? Symbol {  // -> x, y
            let body = cadr(operand);   // 10, "test"
            let value = body.eval(env)
            def_var(variable, value, env)
            
            return variable
        } else {
            return Error(message: "Wrong type argument: " + car(operand).toStr())
        }

    }
}
