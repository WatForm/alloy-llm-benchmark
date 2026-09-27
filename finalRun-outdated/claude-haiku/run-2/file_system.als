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

one sig Root extends Dir {}
lone sig Cur extends Dir {}

fact { Object = File + Dir }

fact { all f: File | some de: DirEntry, d: Dir | de.contents = f and de in d.entries }

fact { all d: Dir | some d.parent implies (some de: d.parent.entries | de.contents = d) }

fact { all d: Dir | all n: Name | lone de: d.entries | de.name = n }

fact { all d: Dir | d not in d.^parent }

fact { all d: Dir - Root | Root in d.^parent }

fact { no Root.parent }

fact { some Cur implies Cur != Root }

fact { all de: DirEntry | one d: Dir | de in d.entries }

fact { all d: Dir - Root | one d.parent }

fact { all d: Dir - Root | one de: DirEntry | de.contents = d }