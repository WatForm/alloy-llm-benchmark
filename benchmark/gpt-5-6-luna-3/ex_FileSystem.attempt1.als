sig Object {}

sig Directory in Object {
    contents: set Object
}

sig File in Object {}

one sig Root in Object {}

fact {
    Object = Directory + File
    no Directory & File
    no d: Directory | d in d.^contents
    Object in Root.*contents
    all o: Object - Root | one contents.o
}