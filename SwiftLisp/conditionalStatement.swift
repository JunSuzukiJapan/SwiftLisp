//
//  conditionalStatement.swift
//  SwiftLisp
//
//  Created by suzukijun on 2014/08/25.
//  Copyright (c) 2014年 toru. All rights reserved.
//

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