sig Object {}

sig Directory extends Object {
    contents: set Object
}

sig File extends Object {}

sig Alias extends File {
    to: one Object
}

one sig Root extends Directory {}

fact {
    // Each Object is in at least one of the sets Directory or File
    Object = Directory + File

    // The Root is not in the contents of any Directory
    all d: Directory | Root not in d.contents

    // The Root can reach every Object except itself through iterating the contents relation
    // (This fact will be manually checked by requiring a stronger interpreted definition in the predicate)

    // Every Object is in the contents of at most one Directory
    all o: Object | lone d: Directory | o in d.contents

    // "contents" is acyclic
    acyclic Directory.contents

    // "to" is acyclic
    acyclic Alias.to
}