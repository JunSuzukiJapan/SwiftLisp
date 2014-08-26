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
        return env.withExtend(params, operand: operand, body: { (exEnv: Environment) in
            return self.body.eval(exEnv)
        })
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
    
    init(_ name: String, _ params: LispObj, _ rest: LispObj) {
        self.name = name
        
        super.init(params, rest)
    }
    
    override func toStr() -> String {
        return "#<User Function: \(self.name)>"
    }

    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return env.withExtend(params, operand: operand, body: { (exEnv: Environment) in
            var result = car(self.body).eval(exEnv)
            var list = cdr(self.body)
            while list is ConsCell {
                result = car(list).eval(exEnv)
                list = cdr(list)
            }
            
            return result
        })
    }
}

class DefineFunction : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let symbol = car(operand) as Symbol    // function name
        let params = cadr(operand)             // (x)
        let rest = cddr(operand)          // (+ x 1)
        let function = UserFunction(symbol.name, params, rest)
        def_var(symbol, function, env)
        
        return function
    }
}

//
// Macro
//
class UserMacro : SpecialForm {
    private let name: String
    private let params: LispObj
    private let rest: LispObj
    
    init(_ params: LispObj, _ rest: LispObj){
        self.name = "#<User Macro>"
        self.params = params
        self.rest   = rest
    }
    
    init(_ name: String, _ params: LispObj, _ rest: LispObj) {
        self.name = name
        self.params = params
        self.rest   = rest
    }
    
    override func toStr() -> String {
        return "#<Macro: \(self.name)>"
    }
    
    // macroの実行
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return env.withExtend(params, operand: operand, body: { (exEnv: Environment) in
            // マクロを展開する。
            var expanded = car(self.rest).eval(exEnv)
            var list = cdr(self.rest)
            var result = expanded.eval(env)            // 展開したものを実行
            
            //println("expanded: \(expanded.toStr())")
            //println("self.body: \(self.rest.toStr())")
            //println("list: \(list.toStr())")
            
            while list is ConsCell {
                expanded = car(list).eval(exEnv)
                result = expanded.eval(env)            // 展開したものを実行

                list = cdr(list)
            }

            return result
        })
    }
}

class DefineMacro : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        let symbol = car(operand) as Symbol
        let params = cadr(operand)
        let rest = cddr(operand)
        let macro = UserMacro(symbol.name, params, rest)
        def_var(symbol, macro, env)
        
        return macro
    }
}


