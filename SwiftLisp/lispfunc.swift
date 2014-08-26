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


/*** Lispの関数 ***/

func cons(car_val: LispObj, cdr_val: LispObj) -> LispObj {
    var newcell = ConsCell(car: car_val, cdr: cdr_val);
    return newcell;
}

func eq(exp: LispObj, str: String) -> Bool {
    if let tmp = exp as? LispStr {
        return tmp.value == str;
    } else {
        return false;
    }
}

func car(exp: LispObj) -> LispObj {
    if let operand = exp.listp() {
        return operand.head;
    } else {
        return Error(message: "at (car " + exp.toStr() + ")");
    }
}
func cdr(exp: LispObj) -> LispObj {
    if let operand = exp.listp() {
        return operand.tail;
    } else {
        return Error(message: "at (cdr " + exp.toStr() + ")");
    }
}

func cadr(exp: LispObj) -> LispObj {
    return car(cdr(exp));
}

func cddr(exp: LispObj) -> LispObj {
    return cdr(cdr(exp));
}


func concat(list: LispObj, lastcell: LispObj) -> LispObj {
    if list is Nil {
        return lastcell;
    } else if let tmpcell = list.listp() {
        return cons(tmpcell.head, concat(tmpcell.tail, lastcell));
    } else {
        // tmpcell == atom のとき(呼ばれないはず)
        return cons(list, lastcell);
    }
}