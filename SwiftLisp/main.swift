import Foundation

let NIL = Nil.sharedInstance;

let PRIMITIVE = "*** PRIMITIVE ***";
let LAMBDA = "*** LAMBDA ***";

// 解析結果のトークンリストを入れる配列
var tokenlist: [String] = [];

// どこまで読み込んだかを表す配列
var tokenIndex = 0;

func get_token() -> String {
    if tokenlist.count <= tokenIndex {
        return ""; //"";
    } else {
        var s = tokenlist[tokenIndex];
        tokenIndex = tokenIndex + 1;
        if s == "" {
            return get_token();
        } else {
            return s;
        }
    }
}

func read_next(var token: String) -> LispObj {
    var carexp: LispObj, cdrexp: LispObj;
    var list: LispObj = NIL;
    
    if token == "" {
        return NIL;
    }
    if (token != "(") {  // "(" じゃないときの処理
        if let n = token.toInt() {
            return LispNum(value: n);
        } else {
            let prefix = token.hasPrefix("\"");
            let suffix = token.hasSuffix("\"");
            let length = token.utf16Count;
            
            if prefix && suffix {  // "hogehoge" のようにセミコロンで囲われている場合
                if length > 2 {
                    return LispStr(value: token[1...token.utf16Count-2]);
                } else {
                    return LispStr(value: "");
                }
            } else if prefix || suffix {  // "hogehoge のように片方だけセミコロンが付いている場合
                return Error(message: "wrong String:" + token);
            } else {
                return Symbol(name: token);
            }
        }
    }
    
    
    token = get_token();  // ( の次のトークンを取得
    while (true) {  // "(" から始まるとき
        if (token == ")") {
            return list;
        }
        
        carexp = read_next(token);  // 読み込んだトークンをcar部分として処理
        token = get_token();     // 次のトークン取得
        if (token == ".") {       // ペアの場合
            token = get_token();
            cdrexp = read_next(token);  // 取得した次のトークンを cdr にセット
            
            token = get_token();   // ペアの後は ) がくるはず
            if token != ")" {
                // エラー処理を書く
                println(") required!");
            }
            return ConsCell(car: carexp, cdr: cdrexp);
        }
        
        list = concat(list, cons(carexp, NIL));
        //        break;
    }
    
}

/*
標準入力から文字列取得
// TODO: 括弧の数チェッカーをここに作ってループする。右括弧の方が多ければエラーにする
*/
func read() -> String {
    var tmp = NSFileHandle.fileHandleWithStandardInput();
    
    var rawdata = tmp.availableData;
    var str = NSString(data: rawdata, encoding: NSUTF8StringEncoding);
    
    return str;
}

func tokenize(str: String) { //-> ([String], Int) {
    // ' (quote記号を (quote  ... ) に置き換え
    
    var str2 = ""
    var quoteFlag = false
    for a in str {
        if a == "'" {
            str2 += "(quote "
            quoteFlag = true
        } else if a == ")" && quoteFlag {
            str2 += "))"
            quoteFlag = false;
        } else {
            str2 += a
        }
    }
    
    // "(" と ")" を空白付きに変換
    let replacedStr = str2
        .stringByReplacingOccurrencesOfString("(", withString: " ( ", options: nil, range: nil)
        .stringByReplacingOccurrencesOfString(")", withString: " ) ", options: nil, range: nil)
        .stringByReplacingOccurrencesOfString("\n", withString: " ", options: nil, range: nil);
    
    tokenlist = replacedStr.componentsSeparatedByString(" ");
    tokenIndex = 0;
}

func parse() -> LispObj {
    var c: LispObj;
    c = read_next(get_token());
    return c;
}

func get(str: String, env: Environment) -> LispObj {
    return env.get(str);
}

func def_var(variable: String, val: LispObj, var env: Environment) {
    env.add(variable, val: val);
}
func def_var(variable: LispObj, val: LispObj, env: Environment) {
    if let symbol = variable as? Symbol {
        def_var(symbol.name, val, env);
    }
}

func eval(exp: LispObj, env: Environment) -> LispObj {
    return exp.eval(env)
}

func eval_args(exp: LispObj, env: Environment) -> LispObj {
    if let list = exp.listp() {  //  as? ConsCell {
        let car_exp = eval(list.left, env);
        if car_exp is Error {
            return car_exp;
        } else {
            let cdr_exp = eval_args(list.right, env);
            if cdr_exp is Error {
                return cdr_exp;
            } else {
                return cons(car_exp, cdr_exp);
            }
        }
    } else {
        return eval(exp, env);
    }
}

var initialEnv =  Environment.InitialEnvironment
initialEnv.add("car", val:PrimCar())
initialEnv.add("cdr", val:PrimCdr())
initialEnv.add("=", val: Setf())
initialEnv.add("list", val: PrimList())
initialEnv.add("quote", val: PrimQuote())
initialEnv.add("fn", val: Lambda())
initialEnv.add("lambda", val: Lambda())

initialEnv.add("test", val: LispNum(value: 1000))
initialEnv.add("test2", val: LispStr(value: "hogehoge"))

var initialexec = "(= x (lambda (y) (list y y y)))"
tokenize(initialexec);
eval(parse(), initialEnv).toStr()


// TODO if文追加
// TODO +-*/追加
// TODO define関数追加
/*
実行
*/
while (true) {
    print(" > ")
    var str = read()
    // TODO: 括弧の数チェッカーをここに作ってループする。右括弧の方が多ければエラーにする
    
    tokenize(str)
    println(eval(parse(), initialEnv).toStr())
}
