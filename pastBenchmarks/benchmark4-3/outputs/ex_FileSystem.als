abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

fact {
  no d: Directory | d in d.^contents
  Object in Root.*contents
  all o: Object - Root | one contents.o
}