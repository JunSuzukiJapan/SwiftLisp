//
//  userFunction.swift
//  SwiftLisp
//
//  Created by suzukijun on 2014/08/25.
//  Copyright (c) 2014年 toru. All rights reserved.
//

import Foundation


//
// Lambda
//
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

//
// User Defined Function
//
class UserFunction : LambdaFunction {
    private let name: String
    
    init(_ name: String, _ params: LispObj, _ body: LispObj) {
        self.name = name
        
        super.init(params, body)
    }
    
    override func toStr() -> String {
        return "#<User Function: \(self.name)>"
    }
}

class DefineFunction : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let symbol = car(operand) as Symbol    // function name
        let params = cadr(operand)             // (x)
        let body = car(cddr(operand))          // (+ x 1)
        let function = UserFunction(symbol.name, params, body)
        def_var(symbol, function, env)
        
        return function
    }
}

//
// Macro
//
class UserMacro : LambdaFunction {
    private let name: String
    
    init(_ name: String, _ params: LispObj, _ body: LispObj) {
        self.name = name
        
        super.init(params, body)
    }
    
    override func toStr() -> String {
        return "#<Macro: \(self.name)>"
    }
    
    // macroの実行
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if let ex_env = env.extend(params, operand: operand) {
            let expanded = body.eval(ex_env)    // マクロを展開する。
            return expanded.eval(env)           // 展開したものを実行
        } else {
            return Error(message: "eval macro params error: " + params.toStr() + " " + self.body.toStr())
        }
    }
}

class DefineMacro : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let symbol = car(operand) as Symbol    // function name
        let params = cadr(operand)             // (x)
        let body = car(cddr(operand))          // (+ x 1)
        let macro = UserMacro(symbol.name, params, body)
        def_var(symbol, macro, env)
        
        return macro
    }
}


