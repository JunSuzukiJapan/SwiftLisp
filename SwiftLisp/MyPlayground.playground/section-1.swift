// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

extension String {
    func toArray() -> [Character] {
        var array: [Character] = [Character]()

        for ch in self {
            array.append(ch)
        }

        return array
    }
}

let ary = str.toArray()
let c = ary[5]

var str3: String! = "hello"
str3!.uppercaseString

/*
println(">")
var fh: AnyObject! = NSFileHandle.fileHandleWithStandardInput()
if let data = fh.availableData {
    let str = NSString(data: data, encoding: NSUTF8StringEncoding) as String
    
    println("str = " + str)
}
*/

