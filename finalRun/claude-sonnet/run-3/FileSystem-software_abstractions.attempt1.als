sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

sig Alias extends File {
  to: one Object
}

one sig Root extends Directory {}

fact {
  Directory + File = Object
  no Directory & File
}

fact {
  no contents.Root
}

fact {
  Object in Root.^contents
  Root not in Root.^contents
}

fact {
  no ^contents & iden
}

fact {
  all o: Object | lone contents.o
}

fact {
  no ^to & iden
}