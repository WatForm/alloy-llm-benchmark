abstract sig Object {}

sig Dir extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Dir {}

fact Reachability {
  Object in Root.*contents
}

assert SomeDir {
  all o: Object - Root | some d: Dir | o in d.contents
}

assert RootTop {
  no d: Dir | Root in d.contents
}

assert FileInDir {
  all f: File | some d: Dir | f in d.contents
}

check SomeDir
check RootTop
check FileInDir