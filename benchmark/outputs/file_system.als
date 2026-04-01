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
} {
  parent = contents.~entries
  lone entries.name
  this not in ^parent
  this != Root implies Root in ^parent[this]
}

one sig Root extends Dir {} {
  no parent
}

one sig Cur extends Dir {}

fact EntryOwnership {
  all e: DirEntry | one entries.e
}

pred OneParent_buggyVersion {
  all d: Dir - Root | one d.parent
}

pred OneParent_correctVersion {
  all d: Dir - Root | one d.parent and one contents.d
}

pred NoDirAliases {
  all d: Dir | lone contents.d
}

check BuggyShowsException {
  OneParent_buggyVersion
  not OneParent_correctVersion
} for 6

check CorrectHasNoException {
  OneParent_correctVersion
} for 6