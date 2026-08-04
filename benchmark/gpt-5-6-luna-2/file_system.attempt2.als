abstract sig Object {}
sig Name {}

sig File, Dir extends Object {}

sig DirEntry {
    name: one Name,
    contents: one Object
}

sig Dir {
    entries: set DirEntry,
    parent: lone Dir
}

one sig Root extends Dir {}
lone sig Cur extends Dir {}

fact {
    no Root.parent
    no Cur & Root

    all d: Dir |
        d.parent = {
            p: Dir |
            some e: DirEntry |
            e in p.entries and e.contents = d
        }

    all f: File |
        some d: Dir, e: DirEntry |
        e in d.entries and e.contents = f

    all d: Dir |
        all disj e1, e2: d.entries |
        e1.name != e2.name

    no d: Dir | d in d.^parent

    all d: Dir - Root |
        Root in d.^parent

    all e: DirEntry |
        one d: Dir |
        e in d.entries

    all d: Dir - Root |
        one d.parent

    all d: Dir - Root |
        one e: DirEntry |
        e.contents = d
}