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