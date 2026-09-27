abstract sig Object {}

sig File extends Object {}

sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
}

sig Name {}

sig DirEntry {
  name: one Name,
  contents: one Object
}

one sig Root in Dir {}

lone sig Cur in Dir {}

fact {
  // Root has no parent
  no Root.parent

  // Cur is not Root
  no Cur & Root

  // Every File is the contents of at least one DirEntry
  // that belongs to the entries of some Dir
  all f: File |
    some e: DirEntry |
      e.contents = f and some d: Dir | e in d.entries

  // Every DirEntry belongs to the entries of exactly one Dir
  all e: DirEntry |
    one d: Dir | e in d.entries

  // No duplicate Names within one Dir's entries
  all d: Dir |
    no disj e1, e2: d.entries | e1.name = e2.name

  // Every Dir other than Root has exactly one parent and is
  // the contents of exactly one DirEntry
  all d: Dir - Root |
    one d.parent and
    one e: DirEntry | e.contents = d

  // Every Dir's parent is exactly the unique Dir whose entries
  // contains a DirEntry whose contents is that Dir
  all d: Dir - Root |
    one p: Dir |
      (some e: p.entries | e.contents = d) and d.parent = p

  // The parent relation contains no cycles
  all d: Dir | d not in d.^parent

  // Every Dir other than Root can reach Root via parent
  all d: Dir - Root | Root in d.^parent
}