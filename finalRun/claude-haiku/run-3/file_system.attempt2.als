```alloy
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

one sig Root extends Dir {}
lone sig Cur extends Dir {}

fact {
  // Root has no parent
  no Root.parent
  
  // Cur is not Root
  Cur != Root
  
  // Every File is the contents of at least one DirEntry in some Dir
  all f: File | some d: Dir, e: d.entries | e.contents = f
  
  // Consistency between parent and entries relationships
  all d: Dir | all e: d.entries | e.contents in Dir implies e.contents.parent = d
  all d: Dir | d != Root implies d.parent in {dir: Dir | d in dir.entries.contents}
  
  // No duplicate Names within one Dir's entries
  all d: Dir | all e1, e2: d.entries | e1.name = e2.name implies e1 = e2
  
  // The parent relation contains no cycles
  all d: Dir | d not in d.^parent
  
  // Every Dir that is not Root can reach Root
  all d: Dir | d != Root implies Root in d.parent.*
  
  // Every DirEntry belongs to exactly one Dir
  all e: DirEntry | one d: Dir | e in d.entries
  
  // Every Dir other than Root has exactly one parent
  all d: Dir - Root | one d.parent
  
  // Every Dir other than Root is the contents of exactly one DirEntry
  all d: Dir - Root | one d.~contents
}
```