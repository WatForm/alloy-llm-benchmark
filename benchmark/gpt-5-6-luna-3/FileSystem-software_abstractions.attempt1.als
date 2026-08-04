sig Object {}

sig Directory, File in Object {}

sig Alias in File {}

one sig Root in Directory {}

sig Directory {
    contents: set Object
}

sig Alias {
    to: one Object
}

fact {
    no Directory & File
    Object = Directory + File
    no Root.~contents
    Object - Root in Root.^contents
    no iden & ^contents
    all o: Object | lone o.~contents
    no iden & ^to
}