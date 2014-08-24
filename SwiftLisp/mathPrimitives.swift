//
//  mathPrimitives.swift
//  SwiftLisp
//
//  Created by suzukijun on 2014/08/24.
//  Copyright (c) 2014年 toru. All rights reserved.
//

import Foundation

class Math {
    class Add : Function {
        override func apply(operand: LispObj, _ env: Environment) -> LispObj {
            var num = 0
            var list = operand

            while true {
                if let number = car(list) as? LispNum {
                    num += number.value
                }else if list is Nil {
                    return LispNum(value: 0)
                }else{
                    return Error(message: "+演算子の引数が整数ではありません。")
                }

                if let cell = list as? ConsCell {
                    list = cell.tail
                }else{
                    return Error(message: "+演算子の引数がおかしいです。")
                }

                if (list is Nil) {
                    return LispNum(value: num)
                }
            }
        }
    }
}