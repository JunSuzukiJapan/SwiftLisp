//
//  types.swift
//  HelloSwift
//
//  Created by toru on 8/10/14.
//  Copyright (c) 2014 toru. All rights reserved.
//

import Foundation


class LispObj {
    func toStr() -> String { return "" }
    
    // list ならば キャストして値を返す
    func listp() -> ConsCell? { return nil }
    
    func eval(env: Environment) -> LispObj {
        return self
    }

    func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return Error(message: "関数またはスペシャルフォームでないものを呼び出そうとしました.")
    }
}

class FunctionOrSpecialForm : LispObj {
    func isFunction() -> Bool {
        return false
    }
    
    func isSpecialForm() -> Bool {
        return false
    }
}

class Function : FunctionOrSpecialForm {
    override func toStr() -> String {
        return "<Function>"
    }
    override func isFunction() -> Bool {
        return true
    }
}

class SpecialForm : FunctionOrSpecialForm {
    override func toStr() -> String {
        return "<SpecialForm>"
    }
    override func isSpecialForm() -> Bool {
        return true
    }
}

/*
Singleton の例
参考: http://qiita.com/1024jp/items/3a7bc437af3e79f74505
*/
class Nil: LispObj {
    private override init() {
    }
    
    class var sharedInstance: Nil {
    struct Singleton {
        private static let instance = Nil()
        }
        return Singleton.instance
    }
    
    override func toStr() -> String {
        return "nil";
    }
}


/*
Stringクラスの拡張
str.substring(from, to) を str[from...to] で実現する
参考: http://stackoverflow.com/questions/24044851/how-do-you-use-string-substringwithrange-or-how-do-ranges-work-in-swift
*/
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}


// instanceof -> is
// cast -> as or as?  asは強制、as?は失敗するとnilが入る
// AnyObject という何でも表す型がある?
// Any という型もある

class ConsCell: LispObj, SequenceType {
    var head: LispObj
    var tail: LispObj
    
    init(car: LispObj, cdr: LispObj = Nil.sharedInstance) {
        self.head = car
        self.tail = cdr
    }
    
    override func toStr() -> String {
        var returnValue: String = "";
        returnValue += "(";
        var tmpcell = self;
        
        while (true) {
            returnValue += tmpcell.head.toStr();
            
            if let cdrcell = tmpcell.tail.listp() {
                tmpcell = cdrcell;
            } else if tmpcell.tail is Nil {
                break;
            } else {
                returnValue += ".";
                returnValue += tmpcell.tail.toStr();
                break;
            }
            returnValue += " ";
        }
        returnValue += ")"
        
        return returnValue;
    }
    
    override func listp() -> ConsCell? {
        return self;
    }
    
    override func eval(env: Environment) -> LispObj {
        let function = self.head.eval(env)
        let functionOrSpecialForm = function as? FunctionOrSpecialForm
        if functionOrSpecialForm == nil {
            if eq(car(function), LAMBDA) {
                // lambda式の実行
                // oparator_body : ("*** lambda ***" (x) (list x x x) [env])
                let lambda_params = cadr(functionOrSpecialForm!)    // (x)
                let lambda_body = car(cddr(functionOrSpecialForm!)) // (list x x x)
                if let lambda_env = cadr(cddr(functionOrSpecialForm!)) as? Environment { // [env]
                    let operand_check = eval_args(self.tail, env)
                    if (operand_check is Error) {
                        return operand_check
                    }
                    
                    if let ex_env = lambda_env.extend(lambda_params, operand: operand_check) {
                        return lambda_body.eval(ex_env)
                    } else {
                        return Error(message: "eval lambda params error: " + lambda_params.toStr() + " " + self.tail.toStr())
                    }
                }
            }
            
            return Error(message: "関数またはスペシャルフォームでないものを呼び出そうとしました。")
        }
        
        if functionOrSpecialForm!.isFunction() {
            var tail = self.tail

            if tail is Nil {
                // do nothing
            }else if let list = tail as? ConsCell {
                tail = list.mapEval(env)
            }
            
            return functionOrSpecialForm!.apply(tail, env)
        
        }else if functionOrSpecialForm!.isSpecialForm() {
            return functionOrSpecialForm!.apply(self.tail, env)

        }else{
            return Error(message: "ありえないエラーです（関数またはスペシャルフォームでないものを呼び出そうとしました）。")
        }
    }
    
    func mapEval(env: Environment) -> LispObj {
        var result : LispObj = Nil.sharedInstance
        var current : ConsCell? = nil
        
        for obj in self {
            let value = obj.eval(env)
            if result is Nil {
                current = ConsCell(car: value, cdr: Nil.sharedInstance)
                result = current!

            }else{
                let cell2 = ConsCell(car: value, cdr: Nil.sharedInstance)
                current!.tail = cell2
                current = cell2
            }
        }
        
        return result
    }
    
    // for-inでアクセスできるようになる
    func generate() -> GeneratorOf<LispObj> {
        var current: LispObj = self

        return GeneratorOf<LispObj> {
            if let cell : ConsCell = current as? ConsCell {
                current = cell.tail
                return cell.head
            }else{
                return .None
            }
        }
    }
}

class Symbol: LispObj {
    var name: String;
    init(name: String) {
        self.name = name;
    }
    
    override func toStr() -> String {
        return name;
    }
    
    override func eval(env: Environment) -> LispObj {
        var value = get(self.name, env);
        if !(value is Nil) {
            return value;
        } else {
            return Error(message: "Undefined Value: " + self.name);
        }
    }
}

class LispNum: LispObj {
    var value: Int;
    init(value: Int) {
        self.value = value;
    }
    
    override func toStr() -> String {
        return String(value);
    }
}

class LispStr: LispObj {
    var value: String;
    init(value: String) {
        self.value = value;
    }
    
    override func toStr() -> String {
        return "\"" + value + "\"";
    }
}

class Error: LispObj {
    var message: String;
    init(message: String) {
        self.message = message;
    }
    
    override func toStr() -> String {
        return "Error: " + message;
    }
}

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
    
    func extend(lambda_params: LispObj, operand: LispObj) -> Environment? {
        env.insert(Dictionary<String, LispObj>(), atIndex: 0)
        if (addlist(lambda_params, operand: operand)) {
            return self
        } else {
            return nil
        }
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
                // TODO: サイズが合わない場合のエラー処理
                return false
            } else {
                return true
            }
        }
    }
}