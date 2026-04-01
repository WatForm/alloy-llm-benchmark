sig Object {
  contents: set Object
}

sig Dir extends Object {}
sig File extends Object {}

one sig Root extends Dir {}

fact {
  all o: Object | o in Root.*contents
  all o: Object - Root | some o.contents
  no o: Object | Root in o.contents
  all f: File | some f.contents
}

assert SomeDir {
  all o: Object - Root | some o.contents
}

assert RootTop {
  no o: Object | Root in o.contents
}

assert FileInDir {
  all f: File | some f.contents
}

check SomeDir
check RootTop
check FileInDir