sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

one sig Root extends Directory {}

fact {
  Directory + File = Object
  no Directory & File
}

fact {
  no d: Directory | Root in d.contents
}

fact {
  Object - Root in Root.^contents
}

fact {
  no o: Object | o in o.^contents
}

fact {
  all o: Object | lone d: Directory | o in d.contents
}

fact {
  no a: Alias | a in a.^to
}