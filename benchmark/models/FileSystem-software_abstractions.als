abstract sig Object {}
sig Directory extends Object {contents: set Object}
one sig Root extends Directory {}
sig File extends Object {}
sig Alias extends File {to: Object}

fact{
	
	all d: Directory | all r: Root| not r in d.contents
	
	all r: Root | r.^contents = Object - Root
	
	all d: Directory | not d in d.^contents
	
	contents in Directory lone -> set Object
	
	all a: Alias | not a in a.^to
	}
