abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

one sig Root extends Directory {}

fact {
  no d: Directory | Root in d.contents
}

fact {
  all o: Object - Root | o in Root.*contents
}

fact {
  acyclic[contents]
}

fact {
  all o: Object | lone d: Directory | o in d.contents
}

fact {
  acyclic[to]
}