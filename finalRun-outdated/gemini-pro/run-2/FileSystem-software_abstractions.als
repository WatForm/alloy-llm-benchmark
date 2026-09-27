abstract sig Object {}

sig Directory extends Object {
	contents: set Object
}

sig File extends Object {}

sig Alias in File {
	to: one Object
}

one sig Root in Directory {}

fact {
	no contents.Root
	Object - Root in Root.^contents
	no iden & ^contents
	all o: Object | lone contents.o
	no iden & ^to
}