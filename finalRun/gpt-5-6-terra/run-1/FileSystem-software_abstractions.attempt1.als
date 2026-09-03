sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias in File {
  to: one Object
}

one sig Root extends Directory {}

fact {
  Object in Directory + File
}

fact {
  Root not in Directory.contents
}

fact {
  all o: Object - Root | o in Root.^contents
}

fact {
  no iden & ^contents
}

fact {
  all o: Object | lone o.~contents
}

fact {
  no iden & ^to
}