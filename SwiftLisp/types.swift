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
    
    func eval(env: Environment) -> LispObj { return Error(message: "something wrong!") }
}

class selfishObj: LispObj {
    override func eval(env: Environment) -> LispObj {
        return self
    }
}

/*
Singleton の例
参考: http://qiita.com/1024jp/items/3a7bc437af3e79f74505
*/
class Nil: selfishObj {
    override init() {
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

class ConsCell: LispObj {
    var car: LispObj;
    var cdr: LispObj;
    
    init(car: LispObj, cdr: LispObj) {
        self.car = car;
        self.cdr = cdr;
    }
    
    override func toStr() -> String {
        var returnValue: String = "";
        returnValue += "(";
        var tmpcell = self;
        
        while (true) {
            returnValue += tmpcell.car.toStr();
            
            if let cdrcell = tmpcell.cdr.listp() {
                tmpcell = cdrcell;
            } else if tmpcell.cdr is Nil {
                break;
            } else {
                returnValue += ".";
                returnValue += tmpcell.cdr.toStr();
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
        return apply(self.car, self.cdr, env);
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

class LispNum: selfishObj {
    var value: Int;
    init(value: Int) {
        self.value = value;
    }
    
    override func toStr() -> String {
        return String(value);
    }
}

class LispStr: selfishObj {
    var value: String;
    init(value: String) {
        self.value = value;
    }
    
    override func toStr() -> String {
        return "\"" + value + "\"";
    }
}

class Error: selfishObj {
    var message: String;
    init(message: String) {
        self.message = message;
    }
    
    override func toStr() -> String {
        return "Error: " + message;
    }
}

class Environment: selfishObj {
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
    
    func addPrimitive(name: String) {
        self.add(name, val: ConsCell(car: LispStr(value: PRIMITIVE), cdr: Symbol(name: name)));
    }
    
    func get(name: String) -> LispObj {
        for dic in env {
            if let value = dic[name] {
                return value;
            }
        }
        return NIL;
    }
    
    func copy() -> Environment {
        // Swiftは値渡しのようなので、以下でコピーになる
        var newenv = Environment()
        newenv.env = self.env;
        return newenv;
    }
    
    func extend(lambda_params: LispObj, operand: LispObj) -> Environment? {
        env.insert(Dictionary<String, LispObj>(), atIndex: 0)
        if (addlist(lambda_params, operand: operand)) {
            return self;
        } else {
            return nil;
        }
    }
    
    func addlist(params: LispObj, operand: LispObj) -> Bool {
        if let params_cell = params.listp() {  // && で繋げて書くと上手くいかない(なぜ??)
            if let operand_cell = operand.listp() {
                
                // これだと param_cell.car がLispStrのとき不具合になりそう
                self.add(params_cell.car.toStr(), val: operand_cell.car);
                return addlist(params_cell.cdr, operand: operand_cell.cdr);
            } else {
                // TODO: サイズが合わない場合のエラー処理
                return false;
            }
        } else {
            if let operand_cell = operand.listp() {
                // TODO: サイズが合わない場合のエラー処理
                return false;
            } else {
                return true;
            }
        }
    }
}