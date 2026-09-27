abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias in File {
  to: one Object
}

one sig Root in Directory {}

fact {
  all d: Directory | Root not in d.contents
  Object - Root in Root.^contents
  all o: Object | o not in o.^contents
  all o: Object | lone d: Directory | o in d.contents
  all a: Alias | a not in a.^to
}