sig Name {}
sig Object {}

sig File extends Object {}
sig Dir extends Object {
    entries: set DirEntry,
    parent: lone Dir
}

sig DirEntry {
    name: one Name,
    contents: one Object
}

sig Root extends Dir {}
sig Cur extends Dir {}

fact { Object = File + Dir }

fact { all f: File | some de: DirEntry | de.contents = f }

fact { all d: Dir | (some d.parent) => 
    d.parent = {p: Dir | some de: p.entries | de.contents = d} }

fact { all d: Dir | all n: Name | lone de: d.entries | de.name = n }

fact { acyclic[parent, Dir] }

fact { all d: Dir - Root | Root in d.^parent }

fact { one Root }

fact { all r: Root | no r.parent }

fact { lone Cur }

fact { all de: DirEntry | one d: Dir | de in d.entries }

fact { all d: Dir - Root | one d.parent and one {de: DirEntry | de.contents = d} }