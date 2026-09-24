sig Object {}

sig Directory in Object {
  contents: set Object
}

one sig Root in Directory {}

sig File in Object {}

fact {
  Object = Directory + File
  no Directory & File
  all d: Directory | d not in d.^contents
  all o: Object | o in Root.*contents
  all o: Object - Root | one contents.o
}