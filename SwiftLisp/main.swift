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


/*
実行
*/

func initEnvironment(initialEnv: Environment){
    initialEnv.add("car",    val: PrimCar())
    initialEnv.add("cdr",    val: PrimCdr())
    initialEnv.add("=",      val: Setf())
    initialEnv.add("list",   val: PrimList())
    initialEnv.add("quote",  val: PrimQuote())
    initialEnv.add("fn",     val: Lambda())
    initialEnv.add("lambda", val: Lambda())
    initialEnv.add("def",    val: DefineFunction())
    initialEnv.add("+",      val: MathPrimitives.Add())
    initialEnv.add("-",      val: MathPrimitives.Minus())
    initialEnv.add("*",      val: MathPrimitives.Times())
    initialEnv.add("/",      val: MathPrimitives.Divide())
    initialEnv.add("cons",   val: PrimCons())
    initialEnv.add("prn",    val: PrimPrn())
    initialEnv.add("pr",     val: PrimPr())
    initialEnv.add("mac",    val: DefineMacro())
    initialEnv.add("if",     val: PrimIf())
    initialEnv.add("do",     val: PrimDo())
}

func main(){
    // Environmentの初期化
    var initialEnv =  Environment.InitialEnvironment
    initEnvironment(initialEnv)

    // init.lispファイルの読み込み
    let bundle = NSBundle.mainBundle()
    let resourceDirectoryPath = bundle.bundlePath
    let path = "\(resourceDirectoryPath)/.site-lisp/init.lisp"
    let fin = FileInputPort(path: path)
    let fileReader = Reader(port: fin)
    while let obj = fileReader.read() {
        obj.eval(initialEnv)
    }

    // 標準入出力の設定
    let stdinPort = StdinPort()
    let stdReader = Reader(port: stdinPort)

    // read-eval-printループ
    while (true) {
        print(" > ")

        let obj = stdReader.read()!.eval(initialEnv).toStr()
        println()
        println(obj)
    }
}

main()
