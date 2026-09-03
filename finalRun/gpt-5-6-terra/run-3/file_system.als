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

fact {
  all f: File |
    some d: Dir, e: d.entries | e.contents = f

  all d: Dir |
    d.parent = d.~contents.~entries

  all d: Dir |
    all disj e1, e2: d.entries |
      e1.name != e2.name

  no (iden & ^parent)

  all d: Dir - Root |
    Root in d.^parent

  no Root.parent

  all e: DirEntry |
    one e.~entries

  all d: Dir - Root |
    one d.parent and one d.~contents
}