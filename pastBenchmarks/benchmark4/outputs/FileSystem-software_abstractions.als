abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends Object {
  to: one Object
}

one sig Root extends Directory {}

fact {
  Root not in Directory.contents
  Root.^contents = Object - Root
  no o: Object | o in o.^contents
  all o: Object | lone contents.o
  no o: Object | o in o.^to
}