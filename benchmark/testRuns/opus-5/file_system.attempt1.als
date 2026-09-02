abstract sig Object {}

sig Name {}

sig File extends Object {}

sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
}

sig DirEntry {
  name: one Name,
  contents: one Object
}

one sig Root extends Dir {}

lone sig Cur extends Dir {}

fact FileSystem {
  // Every File is the contents of at least one DirEntry belonging to some Dir's entries
  all f: File | some d: Dir, e: d.entries | e.contents = f

  // A Dir's parent is exactly the Dir whose entries contain a DirEntry whose contents is that Dir
  all d: Dir | d.parent = { p: Dir | some e: p.entries | e.contents = d }

  // No duplicate names within one Dir's entries
  all d: Dir, e1, e2: d.entries | e1.name = e2.name => e1 = e2

  // The parent relation contains no cycles
  no d: Dir | d in d.^parent

  // Every Dir other than Root reaches Root through parent
  all d: Dir - Root | Root in d.^parent

  // Root has no parent
  no Root.parent

  // Cur is not the Root
  no Cur & Root

  // Every DirEntry belongs to the entries of exactly one Dir
  all e: DirEntry | one d: Dir | e in d.entries

  // Every Dir other than Root has exactly one parent and is the contents of exactly one DirEntry
  all d: Dir - Root | one d.parent
  all d: Dir - Root | one e: DirEntry | e.contents = d
}