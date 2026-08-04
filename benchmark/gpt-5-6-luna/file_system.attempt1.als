abstract sig Object {}
sig Name {}

sig File, Dir extends Object {}

sig DirEntry {
    name: one Name,
    contents: one Object
}

one sig Root extends Dir {}
lone sig Cur in Dir {}

fact {
    no Root.parent
    Cur not in Root

    all d: Dir |
        d.parent = { p: Dir | some e: DirEntry | e in p.entries and e.contents = d }

    all d: Dir - Root |
        one d.parent and
        one { e: DirEntry | e in d.parent.entries and e.contents = d }

    all f: File |
        some e: DirEntry |
            e.contents = f and some d: Dir | e in d.entries

    all d: Dir |
        no disj e1, e2: d.entries | e1.name = e2.name

    all e: DirEntry |
        one { d: Dir | e in d.entries }

    no d: Dir | d in d.^parent

    all d: Dir - Root |
        Root in d.^parent
}