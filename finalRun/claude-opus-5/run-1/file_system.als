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

fact FileInSomeDir {
  all f: File | some d: Dir | f in d.entries.contents
}

fact ParentDefinition {
  all d: Dir, p: Dir | d in p.entries.contents <=> d.parent = p
}

fact UniqueNames {
  all d: Dir | all e1, e2: d.entries | e1.name = e2.name => e1 = e2
}

fact NoCycles {
  no d: Dir | d in d.^parent
}

fact RootReachable {
  all d: Dir - Root | Root in d.^parent
}

fact RootHasNoParent {
  no Root.parent
}

fact EntryInOneDir {
  all e: DirEntry | one d: Dir | e in d.entries
}

fact NonRootDirs {
  all d: Dir - Root | one d.parent and (one e: DirEntry | e.contents = d)
}