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
    no Root.~contents
    Object - Root in Root.^contents
    no iden & ^contents
    all o: Object | lone o.~contents
    no iden & ^to
}