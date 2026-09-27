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
	all d: Directory | d !in d.^contents
	all o: Object | lone contents.o
	all a: Alias | a !in a.^to
}