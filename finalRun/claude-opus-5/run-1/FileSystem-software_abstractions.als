abstract sig Object {}

sig Directory extends Object {
	contents: set Object
}

sig File extends Object {}

sig Alias extends File {
	to: one Object
}

one sig Root extends Directory {}

fact rootNotContained {
	no d: Directory | Root in d.contents
}

fact rootReachesAll {
	Object - Root in Root.^contents
}

fact contentsAcyclic {
	no o: Object | o in o.^contents
}

fact atMostOneContainer {
	all o: Object | lone contents.o
}

fact toAcyclic {
	no a: Alias | a in a.^to
}