abstract sig Object {}

sig Name {}

sig File, Dir extends Object {
    entries: set DirEntry,
    parent: lone Dir
}

sig DirEntry {
    name: one Name,
    contents: one Object
}

one sig Root in Dir {}

lone sig Cur in Dir {}

fact {
    no Cur & Root
    no Root.parent

    all f: File |
        some e: DirEntry |
            e.contents = f and some d: Dir | e in d.entries

    all d: Dir, p: Dir |
        p in d.parent iff some e: p.entries | e.contents = d

    all d: Dir |
        all disj e1, e2: d.entries |
            e1.name != e2.name

    no d: Dir | d in d.^parent

    all d: Dir - Root |
        Root in d.^parent

    all e: DirEntry |
        one d: Dir | e in d.entries

    all d: Dir - Root |
        one d.parent

    all d: Dir - Root |
        one e: DirEntry | e.contents = d
}