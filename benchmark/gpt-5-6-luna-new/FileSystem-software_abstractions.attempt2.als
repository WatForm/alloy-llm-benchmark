sig Object {}

sig Directory, File extends Object {}

sig Alias in File {}

one sig Root extends Directory {}

sig Directory {
    contents: set Object
}

sig Alias {
    to: one Object
}

fact {
    Object = Directory + File
    no Root.~contents
    Root.^contents = Object - Root
    no iden & ^contents
    all o: Object | lone contents.o
    no iden & ^to
}