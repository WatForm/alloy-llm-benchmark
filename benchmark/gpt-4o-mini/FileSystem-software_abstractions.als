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

    // Every Object is in the contents of at most one Directory
    all o: Object | lone d: Directory | o in d.contents

    // "contents" is acyclic
    no d: Directory | d.contents in d.contents

    // "to" is acyclic
    no a: Alias | a.to in a.to
}