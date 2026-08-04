sig Object {}

sig Directory, File in Object {}

sig Alias in File {
    to: one Object
}

one sig Root extends Directory {}

sig Directory {
    contents: set Object
}

fact {
    no Directory & File
    Object = Directory + File
    no d: Directory | Root in d.contents
    all o: Object - Root | o in Root.^contents
    no d: Directory | d in d.^contents
    all o: Object | lone o.~contents
    no a: Alias | a in a.^to
}