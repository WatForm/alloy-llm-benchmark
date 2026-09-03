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
    no Directory & File
    Object = Directory + File
    all d: Directory | Root not in d.contents
    all o: Object - Root | o in Root.^contents
    no iden & ^contents
    all o: Object | lone o.~contents
    no iden & ^to
}