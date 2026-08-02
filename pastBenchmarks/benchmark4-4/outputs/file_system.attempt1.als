abstract sig Object {}

sig Name {}

sig DirEntry {
  name: one Name,
  contents: one Object
}

sig File extends Object {}

sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
}

one sig Root extends Dir {}

lone sig Cur extends Dir {}

fact {
  all f: File | some d: Dir, e: d.entries | e.contents = f
}

fact {
  all d: Dir | d.parent = {p: Dir | some e: p.entries | e.contents = d}
}

fact {
  all d: Dir | all disj e1, e2: d.entries | e1.name != e2.name
}

fact {
  no d: Dir | d in d.^parent
}

fact {
  all d: Dir - Root | Root in d.^parent
}

fact {
  no Root.parent
}

fact {
  all e: DirEntry | one d: Dir | e in d.entries
}

fact {
  all d: Dir - Root | (one d.parent) and (one e: DirEntry | e.contents = d)
}