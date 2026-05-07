abstract sig Object {}

sig Dir extends Object {
  contents: set Object
}

one sig Root extends Dir {}

sig File extends Object {}

fact {
  Object in Root.*contents
}