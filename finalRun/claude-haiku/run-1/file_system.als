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
    Root.parent = none
    
    all c: Cur | c != Root
    
    all f: File | some de: DirEntry | de.contents = f
    
    all de: DirEntry | one d: Dir | de in d.entries
    
    all d: Dir | all de1, de2: d.entries | de1.name = de2.name implies de1 = de2
    
    all d: Dir - Root | one d.parent
    
    all d: Dir - Root | one de: DirEntry | de.contents = d
    
    all d: Dir - Root | d.parent = {d2: Dir | some de: DirEntry | (de in d2.entries and de.contents = d)}
    
    no d: Dir | d in d.^parent
    
    all d: Dir - Root | Root in d.*parent
}