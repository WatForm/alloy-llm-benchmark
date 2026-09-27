abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

fact NoDirectoryContainsItselfTransitively {
  no d: Directory | d in d.^contents
}

fact EverythingIsUnderRoot {
  Object in Root.*contents
}

fact UniqueParentExceptRoot {
  all o: Object - Root | one contents.o
}

assert RootIsRoot {
  no d: Directory | Root in d.contents
}

run {} for 5