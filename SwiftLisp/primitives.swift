//
//  function.swift
//  SwiftLisp
//

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
        let obj = car(operand)
        println(obj.toStr())
        return Nil.sharedInstance
    }
}

class PrimPr : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let obj = car(operand)
        print(obj.toStr())
        return Nil.sharedInstance
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
