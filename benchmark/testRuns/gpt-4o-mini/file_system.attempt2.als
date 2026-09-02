sig Object {}

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
    // Every Object is either a File or a Dir
    all o: Object | o in File or o in Dir

    // Every File is the contents of at least one DirEntry in some Dir's entries
    all f: File | some de: DirEntry | de.contents = f and de in de.parent.entries

    // Every Dir's parent is the unique Dir whose entries contain a DirEntry whose contents is that Dir
    all d: Dir | d.parent = lone p: Dir | some de: p.entries | de.contents = d

    // There are no duplicate Names within one Dir's entries
    all d: Dir | all n: Name | count { de: d.entries | de.name = n } <= 1

    // The parent relation contains no cycles
    all d: Dir | d.parent.parent != d

    // Every Dir that is not the Root can reach the Root in one or more steps of the parent relation
    all d: Dir | d != Root implies d.parent.*parent = Root

    // There is exactly one Root, and Root is a Dir with no parent
    one Root

    // There is at most one Cur, which is not the Root, and Cur is a Dir
    lone Cur | Cur != Root

    // Every DirEntry belongs to the entries of exactly one Dir
    all de: DirEntry | one d: Dir | de in d.entries

    // Every Dir other than Root has exactly one parent and is the contents of exactly one DirEntry
    all d: Dir | d != Root implies one d.parent and one de: DirEntry | de.contents = d
}