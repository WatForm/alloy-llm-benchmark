sig Object {}

sig Directory in Object {
    contents: set Object
}

sig File in Object {}

one sig Root in Directory {}

fact {
    Object = Directory + File
    no Directory & File
    no d: Directory | d in d.^contents
    Object in Root.*contents
    all o: Object - Root | one d: Directory | o in d.contents
}