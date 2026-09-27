sig Object {}

sig Directory, File extends Object {}

sig Alias extends File {}

one sig Root extends Directory {}

sig Directory extends Object {
  contents: set Object
}

sig Alias extends File {
  to: one Object
}

fact {
  Root not in Directory.contents

  Object - Root in Root.^contents

  all d: Directory | d not in d.^contents

  all o: Object | lone contents.o

  all a: Alias | a not in a.^to
}