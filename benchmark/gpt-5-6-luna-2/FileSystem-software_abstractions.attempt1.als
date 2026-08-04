sig Object {}

sig Directory extends Object {
    contents: set Object
}

sig File extends Object {}

sig Alias in File {
    to: one Object
}

one sig Root extends Directory {}

fact {
    Object = Directory + File
    no Root.~contents
    Object - Root in Root.^contents
    all o: Object | lone o.~contents
    no d: Directory | d in d.^contents
    no a: Alias | a in a.^to
}