abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias in File {
  to: one Object
}

one sig Root extends Directory {}

fact {
  Root not in Directory.contents
  Root.^contents = Object - Root
  no iden & ^contents
  all o: Object | lone o.~contents
  no iden & ^to
}