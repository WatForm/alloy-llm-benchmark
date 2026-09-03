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
    no Directory.contents & Root
    Object - Root in Root.^contents
    no iden & ^contents
    all o: Object | lone o.~contents
    no iden & ^to
}