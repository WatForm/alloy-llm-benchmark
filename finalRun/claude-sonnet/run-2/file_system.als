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

fact FileInSomeDirEntry {
  all f: File | some de: DirEntry | de.contents = f and de in Dir.entries
}

fact ParentDefinition {
  all d: Dir | all d2: Dir | (d2 = d.parent) iff (some de: d2.entries | de.contents = d)
}

fact NoDuplicateNames {
  all d: Dir | all de1, de2: d.entries | de1 != de2 implies de1.name != de2.name
}

fact NoParentCycles {
  no d: Dir | d in d.^parent
}

fact AllDirsReachRoot {
  all d: Dir - Root | Root in d.^parent
}

fact RootHasNoParent {
  no Root.parent
}

fact CurNotRoot {
  Cur != Root
}

fact DirEntryBelongsToOneDir {
  all de: DirEntry | one d: Dir | de in d.entries
}

fact NonRootDirProperties {
  all d: Dir - Root | one d.parent
  all d: Dir - Root | one de: DirEntry | de.contents = d
}