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

            while true {
                let tail: LispObj = cdr(operand)
                if (tail is Nil) {
                    return LispNum(value: num)
                }
            }
        }
    }
}