/*

The MIT License (MIT)

Copyright (c) 2014 Toru Ariga

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

class LispObj {
    func toStr() -> String { return "" }
    
    // list ならば キャストして値を返す
    func listp() -> ConsCell? { return nil }
    
    func eval(env: Environment) -> LispObj {
        return self
    }

    func apply(operand: LispObj, _ env: Environment) -> LispObj {
        return Error(message: "applyできないオブジェクトを呼び出そうとしました.")
    }
    
    func eq(obj: LispObj) -> Bool {
        return self === obj
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

class LispT: LispObj {
    private override init() {
    }
    
    class var sharedInstance: LispT {
    struct Singleton {
        private static let instance = LispT()
        }
        return Singleton.instance
    }
    
    override func toStr() -> String {
        return "t";
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
            //return Error(message: "関数またはスペシャルフォームでないものを呼び出そうとしました。")
            return function.apply(self.tail, env)
        }
        
        if functionOrSpecialForm!.isFunction() {
            var tail = self.tail

            if tail is Nil {
                // do nothing
            }else if let list = tail as? ConsCell {
                tail = list.mapEval(env)
                //tail = list
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
    
    override func eq(obj: LispObj) -> Bool {
        if let num2 = obj as? LispNum {
            return self.value == num2.value
        }
        return false
    }
}

class LispChar : LispObj {
    var ch: Character

    init(_ ch: Character){
        self.ch = ch
    }
    
    override func toStr() -> String {
        switch(self.ch){
        case "\n":
            return "#\\\\n"
        case "\r":
            return "#\\\\r"
        case " ":
            return "#\\space"
        case "\t":
            return "#\\tab"
        default:
            return "#\\" + String(ch)
        }
    }

    override func eq(obj: LispObj) -> Bool {
        if let ch2 = obj as? LispChar {
            return self.ch == ch2.ch
        }
        return false
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
    
    override func apply(operand: LispObj, _ env: Environment) -> LispObj {
        if let index = car(operand) as? LispNum {
            if index.value >= value.utf16Count {
                return Error(message: "文字列よりの長さよりも大きいインデックスです。")
            }
            return self[index.value]
        }else{
            return Error(message: "文字列に数値以外の引数が渡されました。")
        }
    }
    
    subscript(index: Int) -> LispChar {
        get {
            let str = self.value as NSString
            let sub = str.substringWithRange(NSRange(location: index, length: 1))
            let character: Character = Character(sub)
            return LispChar(character)
        }
    }
    
    override func eq(obj: LispObj) -> Bool {
        if let s2 = obj as? LispStr {
            return self.value == s2.value
        }
        return false
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

