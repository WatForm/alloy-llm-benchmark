abstract sig Object {}

sig Name {}

sig DirEntry {
  name: one Name,
  contents: one Object
}

abstract sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
}

sig File extends Object {}

one sig Root extends Dir {}
one sig Cur extends Dir {}

fact FileInSomeDirectory {
  all f: File | some d: Dir | f in d.entries.contents
}

fact EntryBelongsToSomeDirectory {
  all e: DirEntry | some d: Dir | e in d.entries
}

fact ParentViaContentsOfEntries {
  all d: Dir | d.parent = d.entries.contents & Dir
}

fact UniqueNamesWithinDirectory {
  all d: Dir | all disj e1, e2: d.entries | e1.name != e2.name
}

fact NoDirectoryInOwnParentClosure {
  no d: Dir | d in d.^parent
}

fact RootProperties {
  no Root.parent
}

fact NonRootReachRoot {
  all d: Dir - Root | Root in d.^parent
}

fact UniqueParentForNonRoot {
  all d: Dir - Root | one d.parent
}

fact EveryDirectoryHasAnEntrySomewhere {
  all d: Dir - Root | some p: Dir | d in p.entries.contents
}

fact NoEntryPointsToCur {
  no e: DirEntry | e.contents = Cur
}