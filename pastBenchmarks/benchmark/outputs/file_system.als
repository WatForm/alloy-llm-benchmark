sig Name {}

abstract sig Object {}

sig File extends Object {} {
  some d: Dir | this in d.entries.contents
}

sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
} {
  all p: parent | this in p.entries.contents
  all disj e1, e2: entries | e1.name != e2.name
  this not in ^parent
  this != Root implies this in Root.^(~parent)
}

one sig Root extends Dir {} {
  no parent
}

lone sig Cur extends Dir {}

sig DirEntry {
  name: one Name,
  contents: one Object
} {
  one d: Dir | this in d.entries
}

pred OneParent_buggyVersion {
  all d: Dir - Root | one d.parent
}

pred OneParent_correctVersion {
  all d: Dir - Root | one d.parent and one e: DirEntry | e.contents = d
}

pred NoDirAliases {
  all d: Dir | lone e: DirEntry | e.contents = d
}

check BuggyCheck {
  OneParent_buggyVersion implies NoDirAliases
} for 5

check CorrectCheck {
  OneParent_correctVersion implies NoDirAliases
} for 5