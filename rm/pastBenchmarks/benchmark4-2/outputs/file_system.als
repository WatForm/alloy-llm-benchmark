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
  all f: File | some d: Dir, e: d.entries | e.contents = f

  all d: Dir | d.parent = { p: Dir | some e: p.entries | e.contents = d }

  all d: Dir | all disj e1, e2: d.entries | e1.name != e2.name

  no d: Dir | d in d.^parent

  all d: Dir - Root | Root in d.^parent

  no Root.parent

  all e: DirEntry | one d: Dir | e in d.entries

  all d: Dir - Root | one d.parent and one e: DirEntry | e.contents = d
}