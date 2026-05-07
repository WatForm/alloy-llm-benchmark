abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

fact NoCyclicContainment {
  no d: Directory | d in d.^contents
}

fact RootContainsAllObjects {
  Object in Root.*contents
}

fact UniqueDirectParentExceptRoot {
  all o: Object - Root | one d: Directory | o in d.contents
}

