sig Object {}

sig Directory in Object {
    contents: set Object
}

one sig Root in Directory {}

sig File in Object {}

fact {
    all o: Object | o in Directory or o in File
    no Directory & File
}

fact {
    no d: Directory | d in d.^contents
}

fact {
    all o: Object | o in Root.*contents
}

fact {
    all o: Object - Root | one contents.o
}