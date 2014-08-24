import Foundation

let LAMBDA = "*** LAMBDA ***"
let NIL = Nil.sharedInstance

func get(str: String, env: Environment) -> LispObj {
    return env.get(str)
}

func def_var(variable: String, val: LispObj, var env: Environment) {
    env.add(variable, val: val)
}
func def_var(variable: LispObj, val: LispObj, env: Environment) {
    if let symbol = variable as? Symbol {
        def_var(symbol.name, val, env)
    }
}

func eval_args(exp: LispObj, env: Environment) -> LispObj {
    if let list = exp.listp() {  //  as? ConsCell {
        let car_exp = list.head.eval(env)
        if car_exp is Error {
            return car_exp
        } else {
            let cdr_exp = eval_args(list.tail, env)
            if cdr_exp is Error {
                return cdr_exp
            } else {
                return cons(car_exp, cdr_exp)
            }
        }
    } else {
        return exp.eval(env)
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
initialEnv.add("def", val: DefineFunction())
initialEnv.add("+", val: Math.Add())
initialEnv.add("-", val: Math.Minus())
initialEnv.add("*", val: Math.Times())
initialEnv.add("/", val: Math.Divide())

/*
initialEnv.add("test", val: LispNum(value: 1000))
initialEnv.add("test2", val: LispStr(value: "hogehoge"))

var initialexec = "(= x (lambda (y) (list y y y)))"
let strPort = StringInputPort(initialexec)
let initReader = Reader(port: strPort)
println(initReader.read().eval(initialEnv).toStr())
*/

// TODO if文追加
// TODO +-*/追加
// TODO define関数追加
/*
実行
*/

let stdinPort = StdinPort()
let stdReader = Reader(port: stdinPort)

while (true) {
    print(" > ")
    
    println(stdReader.read().eval(initialEnv).toStr())
}
