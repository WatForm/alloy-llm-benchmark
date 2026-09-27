sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

fact {
  Object = Directory + File
  no Directory & File
}

fact NoSelfContainment {
  no d: Directory | d in d.^contents
}

fact AllReachableFromRoot {
  Object = Root.*contents
}

fact UniqueParent {
  all o: Object - Root | one d: Directory | o in d.contents
}