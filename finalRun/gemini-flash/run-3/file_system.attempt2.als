An Alloy specification that accurately and concisely models all the requirements:

```alloy
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
    // Every File is the contents of at least one DirEntry that belongs to the entries of some Dir
    all f: File | some d: Dir, e: d.entries | e.contents = f

    // Every Dir's parent is exactly the unique Dir whose entries contains a DirEntry whose contents is that Dir
    all d: Dir | d.parent = { p: Dir | some e: p.entries | e.contents = d }

    // There are no duplicate Names within one Dir's entries
    all d: Dir, disj e1, e2: d.entries | e1.name != e2.name

    // The parent relation contains no cycles
    all d: Dir | d not in d.^parent

    // Every Dir that is not the Root can reach the Root in one or more steps of the parent relation
    all d: Dir - Root | Root in d.^parent

    // Root has no parent
    no Root.parent

    // Cur is not the Root
    no Root & Cur

    // Every DirEntry belongs to the entries of exactly one Dir
    all e: DirEntry | one entries.e

    // Every Dir other than Root has exactly one parent and is the contents of exactly one DirEntry
    all d: Dir - Root | one d.parent and one contents.d
}
```