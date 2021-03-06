//
//  mathPrimitives.swift
//  SwiftLisp
//

import Foundation

class MathPrimitives {
    class Add : Function {
        override func apply(operand: LispObj, _ env: Environment) -> LispObj {
            var num = 0
            var list = operand

            while true {
                if (list is Nil) {
                    return LispNum(value: num)
                }

                if let number = car(list) as? LispNum {
                    num += number.value
                }else{
                    return Error(message: "+演算子の引数が整数ではありません。")
                }

                if let cell = list as? ConsCell {
                    list = cell.tail
                }else{
                    return Error(message: "+演算子の引数がおかしいです。")
                }

            }
        }
    }

    class Minus : Function {
        override func apply(operand: LispObj, _ env: Environment) -> LispObj {
            var num = 0
            var list = operand
            
            while true {
                if (list is Nil) {
                    return LispNum(value: num)
                }
                
                if let number = car(list) as? LispNum {
                    num -= number.value
                }else{
                    return Error(message: "-演算子の引数が整数ではありません。")
                }
                
                if let cell = list as? ConsCell {
                    list = cell.tail
                }else{
                    return Error(message: "-演算子の引数がおかしいです。")
                }
                
            }
        }
    }

    class Times : Function {
        override func apply(operand: LispObj, _ env: Environment) -> LispObj {
            var num = 1
            var list = operand
            
            while true {
                if (list is Nil) {
                    return LispNum(value: num)
                }
                
                if let number = car(list) as? LispNum {
                    num *= number.value
                }else{
                    return Error(message: "*演算子の引数が整数ではありません。")
                }
                
                if let cell = list as? ConsCell {
                    list = cell.tail
                }else{
                    return Error(message: "*演算子の引数がおかしいです。")
                }
                
            }
        }
    }

    class Divide : Function {
        override func apply(operand: LispObj, _ env: Environment) -> LispObj {
            let temp = car(operand) as? LispNum
            if temp == nil {
                return Error(message: "/演算子に引数がひとつも与えられませんでした。")
            }

            var num = temp!.value
            var list = cdr(operand)
            
            while true {
                if (list is Nil) {
                    return LispNum(value: num)
                }
                
                if let number = car(list) as? LispNum {
                    num /= number.value
                }else{
                    return Error(message: "/演算子の引数が整数ではありません。")
                }
                
                if let cell = list as? ConsCell {
                    list = cell.tail
                }else{
                    return Error(message: "/演算子の引数がおかしいです。")
                }
                
            }
        }
    }
}