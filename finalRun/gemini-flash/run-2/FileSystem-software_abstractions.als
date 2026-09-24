abstract sig Object {}

sig Directory extends Object {
    contents: set Object
}

sig File extends Object {}

sig Alias extends File {
    to: one Object
}

one sig Root extends Directory {}

fact {
    Root !in Directory.contents
    Root.^contents = Object - Root
    no iden & ^contents
    all o: Object | lone contents.o
    no iden & ^to
}