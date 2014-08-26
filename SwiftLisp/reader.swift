//
//  InputPort.swift
//  SwiftLisp
//

import Foundation

extension String {
    // Stringを[Character]に変換して返す。
    func toArray() -> [Character] {
        var array: [Character] = [Character]()

        for ch in self {
            array.append(ch)
        }

        return array
    }
}

extension Character {
    func isWhiteSpace() -> Bool {
        switch(self){
        case " ", "\t", "\n", "\r":
            return true
        default:
            return false
        }
    }
}

// 入力ポート
protocol InputPort {
    func readChar() -> Character?
    func unreadChar(char: Character) -> Void
}

class StringInputPort : LispObj, InputPort {
    private let charArray : [Character]
    private var index : Int

    // 文字列から１文字だけ取り出すのが意外に面倒そうなので、
    // 最初に文字の配列に変換しておく。
    init(_ string: String){
        self.charArray = string.toArray()
        self.index  = 0
    }

    func readChar() -> Character? {
        if index >= charArray.count {
            return nil
        }

        return charArray[index++]
    }

    func unreadChar(char: Character) {
        index--
    }
}

class FileInputPort : LispObj, InputPort {
    private var line: [Character] = [Character]()
    private var index: Int = 0
    private let fh: NSFileHandle
    private var eof: Bool = false

    init(path: String){
        fh = NSFileHandle(forReadingAtPath: path)
    }
    
    init(handle: NSFileHandle){
        fh = handle
    }
    
    private func readLine() -> [Character] {
        index = 0
        
        if let data = fh.availableData {
            let str = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            
            return str.toArray()
            
        }else{
            return [Character]()
        }
    }
    
    func readChar() -> Character? {
        if(line.count <= index){
            line = readLine()
            
            if line.count == 0 {
                eof = true
                return nil
            }
        }
        
        return line[index++]
    }
    
    func unreadChar(char: Character){
        index--
    }
    
    func isEOF() -> Bool {
        return eof
    }
}


class StdinPort : FileInputPort, InputPort {
    init(){
        super.init(handle: NSFileHandle.fileHandleWithStandardInput())
    }
}

class Reader : LispObj {
    private let port : InputPort

    init(port: InputPort){
        self.port = port
    }

    func char2num(ch: Character) -> Int {
        switch(ch){
        case "0":
            return 0
        case "1":
            return 1
        case "2":
            return 2
        case "3":
            return 3
        case "4":
            return 4
        case "5":
            return 5
        case "6":
            return 6
        case "7":
            return 7
        case "8":
            return 8
        case "9":
            return 9
        default:
            return 0
        }
    }

    func readSymbol() -> LispObj {
        var name: String = ""
        while true {
            let ch = port.readChar()
            if ch!.isWhiteSpace() {
                break
            }
            if ch! == ")" {
                port.unreadChar(ch!)
                break
            }
            //name.append(ch!)
            name += ch!
        }
        
        switch(name.lowercaseString){
        case "nil":
            return Nil.sharedInstance
        case "t":
            return LispT.sharedInstance
        default:
            return Symbol(name: name)
        }
    }

    func read() -> LispObj? {
        if let ch: Character? = port.readChar() {
            if ch == nil { // XCode Beta5だとこれがないとエラーになる。本来はnilならここにこないはずだけど。。。
                return nil
            }
            //println("ch: " + ch!)

            switch(ch!){
            case "(": // read list
                var list: LispObj = Nil.sharedInstance

                while(true){
                    if let ch2 = port.readChar() {
                        if ch2 == ")" {
                            return list
                        }else{
                            port.unreadChar(ch2)

                            let obj = read()
                            list = concat(list, ConsCell(car: obj!))

                        }
                    }else{
                        return Error(message:"syntax error")
                    }
                }

                break

            case "'": // read quote
                let body = read()
                if let err = body as? Error {
                    return body  // error occured
                }

                return ConsCell(car: Symbol(name: "quote"), cdr: ConsCell(car: body!, cdr: Nil.sharedInstance))

            case "\"": // read string
                var string : String = ""
                while let ch = port.readChar() {
                    switch(ch){
                    case "\"":
                        return LispStr(value: string)

                    default:
                        //string.append(ch)
                        string += ch
                        break
                    }
                }

                break

            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": // read number
                var number = char2num(ch!)
                while (true) {
                    let c = port.readChar()
                    if c == nil {
                        return LispNum(value: number)
                    }

                    switch(c!){
                    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        number = (number * 10) + char2num(c!)
                    default:
                        port.unreadChar(c!)
                        return LispNum(value: number)
                    }
                }
                
            default:
                // 空白文字を読み飛ばす。
                if ch!.isWhiteSpace(){
                    var ch3 = ch
                    do {
                        ch3 = port.readChar()
                    } while ch3!.isWhiteSpace()
                    port.unreadChar(ch3!)

                    return read()
                }

                // とりあえずシンボルとして読んでみる。
                port.unreadChar(ch!)
                return readSymbol()
            }
        }else{
            return nil
        }

        return Error(message: "synax error")
    }
}
















