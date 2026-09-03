abstract sig Object {}

sig Directory extends Object {
	contents: set Object
}

sig File extends Object {}

sig Alias extends File {
	to: one Object
}

one sig Root extends Directory {}

fact RootNotContained {
	no d: Directory | Root in d.contents
}

fact RootReachesAll {
	Object - Root in Root.^contents
}

fact ContentsAcyclic {
	no o: Object | o in o.^contents
}

fact AtMostOneParent {
	all o: Object | lone d: Directory | o in d.contents
}

fact ToAcyclic {
	no o: Object | o in o.^to
}