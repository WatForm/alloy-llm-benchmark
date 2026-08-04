sig Object {}

sig Directory extends Object {
  contents: set Object
}

one sig Root extends Directory {}

sig File extends Object {}

fact {
  Object = Directory + File
  no d: Directory | d in d.^contents
  Object in Root.*contents
  all o: Object - Root | one d: Directory | o in d.contents
}