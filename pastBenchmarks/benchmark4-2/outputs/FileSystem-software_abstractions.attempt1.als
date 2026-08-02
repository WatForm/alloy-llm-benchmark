abstract sig Object {}

sig Directory extends Object {
    contents: set Object
}

sig File extends Object {}

sig Alias extends Object {
    to: one Object
}

one sig Root extends Directory {}

fact {
    Root not in Directory.contents
}

fact {
    Root.^contents = Object - Root
}

fact {
    no o: Object | o in o.^contents
}

fact {
    all o: Object | lone contents.o
}

fact {
    no a: Alias | a in a.^to
}