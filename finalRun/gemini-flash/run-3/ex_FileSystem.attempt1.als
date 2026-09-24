abstract sig Object {}

sig Directory extends Object {
	contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

fact {
	all d: Directory | d not in d.^contents
	all o: Object | o in Root.*contents
	all o: Object - Root | one contents.o
}