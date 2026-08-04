sig Object {}

sig Directory in Object {
    contents: set Object
}

sig File in Object {}

sig Alias in File {
    to: one Object
}

one sig Root in Directory {}

fact {
    no Directory & File
    Object = Directory + File
    no d: Directory | Root in d.contents
    all o: Object - Root | o in Root.^contents
    no o: Object | o in o.^contents
    all o: Object | lone o.~contents
    no a: Alias | a in a.^to
}