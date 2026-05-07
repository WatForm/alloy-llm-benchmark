sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

fact FileSystemHierarchy {
  no d: Directory | Root in d.contents
  Object - Root in Root.^contents
  no d: Directory | d in d.^contents
  all o: Object - Root | one d: Directory | o in d.contents
  no a: Alias | a in a.^to
}