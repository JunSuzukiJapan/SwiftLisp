//
//  function.swift
//  SwiftLisp
//
//  Created by suzukijun on 2014/08/23.
//  Copyright (c) 2014年 toru. All rights reserved.
//

import Foundation

class PrimCar : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return car(car(operand).eval(env))
    }
}

class PrimCdr : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return cdr(car(operand).eval(env))
    }
}

class PrimList : Function {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return eval_args(operand, env)
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

class Lambda : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        // lambda式の定義
        // (lambda (x) (+ x 1))
        // operand: ((x) (+ x  1))
        let params = car(operand)   // (x)
        let body = cadr(operand)    // (+ x 1)
        
        let tmp = cons(LispStr(value: LAMBDA), cons(params, cons(body, cons(env.copy(), Nil.sharedInstance))));
        return tmp
    }
}


