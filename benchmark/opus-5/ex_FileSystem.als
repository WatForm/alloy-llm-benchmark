sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

fact {
  Object = Directory + File
}

fact noSelfContainment {
  no d: Directory | d in d.^contents
}

fact allReachableFromRoot {
  Object in Root.*contents
}

fact oneParent {
  all o: Object - Root | one d: Directory | o in d.contents
}