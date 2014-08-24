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

class LambdaFunction : Function {
    let params: LispObj
    let body: LispObj

    init(_ params: LispObj, _ body: LispObj){
        self.params = params
        self.body   = body
    }
    
    override func toStr() -> String {
        return "#<Lambda Function>"
    }

    // lambda式の実行
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if let ex_env = env.extend(params, operand: operand) {
            return body.eval(ex_env)
        } else {
            return Error(message: "eval lambda params error: " + params.toStr() + " " + self.body.toStr())
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
        return LambdaFunction(params, body)
    }
}

class UserFunction : LambdaFunction {
    override init(_ params: LispObj, _ body: LispObj) {
        super.init(params, body)
    }
    
    override func toStr() -> String {
        return "#<User Function>"
    }
}

class DefineFunction : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let symbol = car(operand)        // function name
        let params = cadr(operand)       // (x)
        let body = car(cddr(operand))    // (+ x 1)
        let function = UserFunction(params, body)
        def_var(symbol, function, env)
        
        return function
    }
}


