sig Object {}

sig Directory in Object {
  contents: set Object
}

one sig Root in Directory {}

sig File in Object {}

fact {
  Object = Directory + File
  no Directory & File
  no d: Directory | d in d.^contents
  Object in Root.*contents
  all o: Object - Root | one contents.o
}