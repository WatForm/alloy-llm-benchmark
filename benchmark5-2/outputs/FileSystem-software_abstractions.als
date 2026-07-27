sig Object {}

sig Directory in Object {
  contents: set Object
}

sig File in Object {}

sig Alias in File {
  to: one Object
}

one sig Root in Directory {}

fact {
  no Directory & File
  Object = Directory + File

  no Root & Directory.contents

  Root.^contents = Object - Root

  no iden & ^contents

  all o: Object | lone contents.o

  no iden & ^to
}