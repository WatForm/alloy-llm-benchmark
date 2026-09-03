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

fact {
    // Root has no parent
    Root.parent = none
    
    // Cur is not Root
    Cur != Root
    
    // Every File is the contents of at least one DirEntry
    all f: File | some de: DirEntry | de.contents = f
    
    // Every DirEntry belongs to exactly one Dir's entries
    all de: DirEntry | one d: Dir | de in d.entries
    
    // No duplicate Names within one Dir's entries
    all d: Dir | all de1, de2: d.entries | de1.name = de2.name implies de1 = de2
    
    // Every Dir other than Root has exactly one parent
    all d: Dir - Root | one d.parent
    
    // Every Dir other than Root is the contents of exactly one DirEntry
    all d: Dir - Root | one de: DirEntry | de.contents = d
    
    // Every Dir's parent corresponds to the Dir whose entries contains it
    all d: Dir - Root | d.parent = {d2: Dir | some de: d2.entries | de.contents = d}
    
    // No cycles in parent relation
    no d: Dir | d in d.^parent
    
    // Every Dir other than Root can reach Root
    all d: Dir - Root | Root in d.parent.*
}