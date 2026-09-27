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

fact FileInSomeEntry {
    all f: File | some d: Dir, e: d.entries | e.contents = f
}

fact ParentDefinition {
    all d: Dir | all p: Dir | (p = d.parent) <=> (some e: p.entries | e.contents = d)
}

fact NoDuplicateNames {
    all d: Dir | all disj e1, e2: d.entries | e1.name != e2.name
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

fact DirEntryOwnedByExactlyOneDir {
    all de: DirEntry | one d: Dir | de in d.entries
}

fact NonRootDirProperties {
    all d: Dir - Root | (one d.parent) and (one de: DirEntry | de.contents = d)
}