sig Name {}

abstract sig Object {}

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

fact CurNotRoot {
  Cur != Root
}

fact RootHasNoParent {
  no Root.parent
}

fact FileIsContentsOfSomeEntry {
  all f: File | some de: DirEntry | de.contents = f and de in Dir.entries
}

fact ParentDefinition {
  all d: Dir | d.parent = { d2: Dir | some de: d2.entries | de.contents = d }
}

fact NoDuplicateNamesInEntries {
  all d: Dir | all de1, de2: d.entries | de1.name = de2.name => de1 = de2
}

fact NoCyclesInParent {
  no d: Dir | d in d.^parent
}

fact AllDirsReachRoot {
  all d: Dir | d != Root => Root in d.^parent
}

fact EveryDirEntryBelongsToExactlyOneDir {
  all de: DirEntry | one d: Dir | de in d.entries
}

fact NonRootDirHasParentAndIsContentsOfEntry {
  all d: Dir - Root | one d.parent and one de: DirEntry | de.contents = d
}