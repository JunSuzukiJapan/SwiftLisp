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

class PrimIf : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        var condition = car(operand)
        var thenClause = cadr(operand)
        var restClause = cddr(operand)
        
        return apply(condition, thenClause, restClause, env)
    }
    
    func apply(condition: LispObj, _ thenClause: LispObj, _ rest: LispObj, _ env: Environment) -> LispObj {
        let p = condition.eval(env)
        
        if p is Nil {
            // eval else-clause
            let result = car(rest).eval(env)
            let cell = cdr(rest)

            if cell is Nil {
                return result
            }else{
                let then2 = car(cell)
                let rest2 = cdr(cell)
                return apply(result, then2, rest2, env)
            }

        }else{
            // eval then-clause
            return thenClause.eval(env)
        }
    }
}

class PrimDo : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        var list = operand
        var result: LispObj = Nil.sharedInstance

        while list is ConsCell {
            let item = car(list)
            result = item.eval(env)
            
            list = cdr(list)
        }
        
        return result
    }
}

class PrimLet : SpecialForm {
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if let name = car(operand) as? Symbol {
            let cdrList = cdr(operand)
            if cdrList is ConsCell {
                let value = cadr(operand)
                let cddrList = cdr(cdrList)
                var result: LispObj = Nil.sharedInstance

                if cddrList is ConsCell {
                    return env.withExtend({ (exEnv:Environment) in
                        let expr = car(cddrList)
                        def_var(name, value.eval(exEnv), exEnv)
                        result = expr.eval(exEnv)
                    
                        var list = cdr(cddrList)
                        while list is ConsCell {
                            car(list).eval(exEnv)

                            list = cdr(list)
                        }

                        return result
                    })

                }else{
                    return Error(message: "let の第３引数がありません。")
                }

            }else{
                return Error(message: "let の第２引数がありません。")
            }
        }else{
            return Error(message: "let の第１引数がありません。")
        }

    }
}

class PrimWith : SpecialForm {
    private func setVars(varList: ConsCell, _ env: Environment){
        var list: LispObj = varList
        while list is ConsCell {
            let name: Symbol = car(list) as Symbol
            list = cdr(list)
            let value = car(list)
            def_var(name, value.eval(env), env)
            
            list = cdr(list)
        }
    }

    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if let varList = car(operand) as? ConsCell {
            let cdrList = cdr(operand)

            if cdrList is ConsCell {
                var result: LispObj = Nil.sharedInstance

                return env.withExtend({ (exEnv:Environment) in
                    self.setVars(varList, exEnv)

                    let expr = car(cdrList)
                    result = expr.eval(exEnv)
                        
                    var list = cdr(cdrList)
                    while list is ConsCell {
                        car(list).eval(exEnv)
                            
                        list = cdr(list)
                    }
                        
                    return result
                })


            }else{
                return Error(message: "let の第２引数がありません。")
            }
        }else{
            return Error(message: "let の第１引数がありません。")
        }
    }
}




