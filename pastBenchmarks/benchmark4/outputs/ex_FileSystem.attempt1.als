sig Object {}

sig Directory in Object {
  contents: set Object
}

one sig Root in Directory {}

sig File in Object {}

fact {
  Object = Directory + File
  no Directory & File
}

fact {
  no d: Directory | d in d.^contents
}

fact {
  Object in Root.*contents
}

fact {
  all o: Object - Root | one contents.o
}