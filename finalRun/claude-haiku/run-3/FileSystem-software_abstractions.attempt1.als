abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

one sig Root extends Directory {}

fact noRootInContents {
  all d: Directory | Root !in d.contents
}

fact rootReachesAll {
  Root.*(contents) = Object
}

fact contentsAcyclic {
  all o: Object | o !in o.^contents
}

fact singleParent {
  all o: Object | #{d: Directory | o in d.contents} <= 1
}

fact toAcyclic {
  all a: Alias | a !in a.^to
}