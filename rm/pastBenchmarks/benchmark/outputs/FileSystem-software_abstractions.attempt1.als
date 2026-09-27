sig Object {}

sig Dir extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

one sig Root extends Dir {}

fact NoRootInContents {
  no d: Dir | Root in d.contents
}

fact RootContainsEverythingElse {
  all o: Object - Root | o in Root.*contents
}

fact NoDirInOwnClosure {
  all d: Dir | d not in d.^contents
}

fact UniqueParent {
  all o: Object | lone contents.o
}

fact NoAliasLoops {
  all a: Alias | a not in a.^to
}

run {} for 5