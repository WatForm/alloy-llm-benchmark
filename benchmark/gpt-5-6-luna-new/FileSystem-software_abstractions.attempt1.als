sig Object {}

sig Directory, File extends Object {}

sig Alias in File {}

one sig Root extends Directory {}

sig contents {
}

fact {
  Object = Directory + File
  contents: Directory -> Object
}