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

fact {
  no d: Directory | d in d.^contents
}

fact {
  Object in Root.*contents
}

fact {
  all o: Object - Root | one p: Directory | o in p.contents
}