abstract sig Object {}

sig Directory extends Object {
	contents : set Object
}

sig File extends Object {}

sig Alias extends File {
	to : one Object
}

one sig Root extends Directory {}

fact rootNotContained {
	no d : Directory | Root in d.contents
}

fact rootReachesAll {
	all o : Object - Root | o in Root.^contents
}

fact contentsAcyclic {
	no o : Object | o in o.^contents
}

fact atMostOneParent {
	all o : Object | lone d : Directory | o in d.contents
}

fact toAcyclic {
	no a : Alias | a in a.^to
}