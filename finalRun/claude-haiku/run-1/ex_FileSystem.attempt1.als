sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

fact {
  // Every element of Object is either Directory or File (partition)
  Object = Directory + File
  no Directory & File
  
  // No directory contains itself (no cycles)
  all d: Directory | d not in d.^contents
  
  // Every element of Object is reachable from Root
  all o: Object | o in Root.(*contents)
  
  // Every element other than Root has exactly one parent
  all o: Object - Root | one o.~contents
}