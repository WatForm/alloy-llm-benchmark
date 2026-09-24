abstract sig Object {}

sig Name {}

sig File extends Object {}

sig DirEntry {
	name: one Name,
	contents: one Object
}

sig Dir extends Object {
	entries: set DirEntry,
	parent: lone Dir
}

one sig Root extends Dir {}

lone sig Cur extends Dir {}

fact {
	// Every File is the contents of at least one DirEntry belonging to some Dir's entries
	all f: File | some d: Dir | f in d.entries.contents

	// A Dir's parent is exactly the unique Dir containing an entry whose contents is that Dir
	all d: Dir | d.parent = { p: Dir | d in p.entries.contents }

	// No duplicate names within one Dir's entries
	all d: Dir | no disj e1, e2: d.entries | e1.name = e2.name

	// The parent relation contains no cycles
	no d: Dir | d in d.^parent

	// Every Dir other than Root can reach Root through one or more parent steps
	all d: Dir - Root | Root in d.^parent

	// Root has no parent
	no Root.parent

	// Cur is not Root
	no Cur & Root

	// Every DirEntry belongs to the entries of exactly one Dir
	all e: DirEntry | one d: Dir | e in d.entries

	// Every Dir other than Root has exactly one parent and is the contents of exactly one DirEntry
	all d: Dir - Root | (one d.parent) and (one e: DirEntry | e.contents = d)
}