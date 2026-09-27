sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

sig Alias extends File {
  to: one Object
}

fact {
  // The Root is not in the contents of any Directory
  Root not in Directory.contents

  // The Root can reach every Object except itself through iterating contents
  Object - Root in Root.^contents

  // contents is acyclic
  all d: Directory | d not in d.^contents

  // Every Object is in the contents of at most one Directory
  all o: Object | lone contents.o

  // to is acyclic
  all a: Alias | a not in a.^to
}