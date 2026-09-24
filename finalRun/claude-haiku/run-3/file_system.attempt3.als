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
  no Root.parent
  
  Cur != Root
  
  all f: File | some d: Dir, e: d.entries | e.contents = f
  
  all d: Dir | all e: d.entries | (e.contents in Dir implies e.contents.parent = d)
  all d: Dir | (d != Root implies d.parent in {dir: Dir | d in dir.entries.contents})
  
  all d: Dir | all e1, e2: d.entries | (e1.name = e2.name implies e1 = e2)
  
  all d: Dir | d not in d.^parent
  
  all d: Dir | (d != Root implies Root in d.parent.*)
  
  all e: DirEntry | one d: Dir | e in d.entries
  
  all d: Dir | (d != Root implies #d.parent = 1)
  
  all d: Dir | (d != Root implies #{e: DirEntry | e.contents = d} = 1)
}