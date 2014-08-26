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

class Environment: LispObj {
    class var InitialEnvironment: Environment {
    struct Singleton {
        private static let instance = Environment()
        }
        return Singleton.instance
    }
    
    var env: [Dictionary<String, LispObj>] = [];
    override init() {
        env.insert(Dictionary<String, LispObj>(), atIndex: 0);
    }
    
    override func toStr() -> String {
        return "[env]";
    }
    
    func add(variable: String, val: LispObj) {
        env[0].updateValue(val, forKey: variable)
    }
    
    func get(name: String) -> LispObj {
        for dic in env {
            if let value = dic[name] {
                return value;
            }
        }
        return Nil.sharedInstance
    }
    
    func copy() -> Environment {
        // Swiftは値渡しのようなので、以下でコピーになる
        var newenv = Environment()
        newenv.env = self.env
        return newenv
    }
    
    func withExtend(lambda_params: LispObj, operand: LispObj, body: (Environment) -> LispObj) -> LispObj {
        env.insert(Dictionary<String, LispObj>(), atIndex: 0)
        if (addlist(lambda_params, operand: operand)) {
            let result = body(self)
            env.removeAtIndex(0)
            return result
        }else{
            return Error(message: "illegal lambda parameters")
        }
    }
    
    func withExtend(body: (Environment) -> LispObj) -> LispObj {
        env.insert(Dictionary<String, LispObj>(), atIndex: 0)
        let result = body(self)
        env.removeAtIndex(0)

        return result
    }
    
    func addlist(params: LispObj, operand: LispObj) -> Bool {
        if let params_cell = params.listp() {  // && で繋げて書くと上手くいかない(なぜ??)
            if let operand_cell = operand.listp() {
                
                // これだと param_cell.car がLispStrのとき不具合になりそう
                self.add(params_cell.head.toStr(), val: operand_cell.head)
                return addlist(params_cell.tail, operand: operand_cell.tail)
            } else {
                // TODO: サイズが合わない場合のエラー処理
                return false
            }
        } else {
            if let operand_cell = operand.listp() {
                if let symbol = params as? Symbol {
                    //println("symbol: \(symbol.toStr())")
                    //println("operand_cell: \(operand_cell.toStr())")
                    
                    self.add(symbol.toStr(), val: operand_cell)
                    return true

                }else{
                    // TODO: サイズが合わない場合のエラー処理
                    return false
                }
            
            } else {
                return true
            }
        }
    }
}