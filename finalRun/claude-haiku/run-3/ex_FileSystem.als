abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

fact {
  Object = Directory + File
}

fact {
  no d: Directory | d in d.^contents
}

fact {
  all o: Object | o in Root.*contents
}

fact {
  all o: Object - Root | one p: Object | o in p.contents
}