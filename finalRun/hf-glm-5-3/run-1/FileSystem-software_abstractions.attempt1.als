```
abstract sig Object {}

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
  // The Root is not in the contents of any Directory
  Root not in Directory.contents

  // The Root can reach every Object except itself through contents
  Object - Root in Root.^contents

  // contents is acyclic
  all d: Directory | d not in d.^contents

  // Every Object is in the contents of at most one Directory
  all o: Object | lone contents.o

  // to is acyclic
  all a: Alias | a not in a.^to
}
```

Wait — the signature declarations for `Directory` and `Alias` cannot be declared twice. Here is the corrected specification:

```
abstract sig Object {}

sig Directory, File extends Object {}

one sig Root extends Directory {}

sig Directory extends Object {
  contents: set Object
}

sig Alias extends File {
  to: one Object
}

fact {
  // The Root is not in the contents of any Directory
  Root not in Directory.contents

  // The Root can reach every Object except itself through contents
  Object - Root in Root.^contents

  // contents is acyclic
  all d: Directory | d not in d.^contents

  // Every Object is in the contents of at most one Directory
  all o: Object | lone contents.o

  // to is acyclic
  all a: Alias | a not in a.^to
}
```

The corrected specification (with each signature declared exactly once):

```
abstract sig Object {}

sig Directory extends Object {
  contents: set Object
}

sig File extends Object {}

one sig Root extends Directory {}

sig Alias extends File {
  to: one Object
}

fact {
  // The Root is not in the contents of any Directory
  Root not in Directory.contents

  // The Root can reach every Object except itself through contents
  Object - Root in Root.^contents

  // contents is acyclic
  all d: Directory | d not in d.^contents

  // Every Object is in the contents of at most one Directory
  all o: Object | lone contents.o

  // to is acyclic
  all a: Alias | a not in a.^to
}
```

I apologize for the confusion above. The final, correct Alloy specification is the last one shown, where `Directory` and `File` are non-overlapping subsets of `Object` (declared via `extends` from the abstract `Object` signature, ensuring every `Object` is in at least one of them), `Alias` is a subset of `File`, `Root` is a single distinguished `Directory`, and all the stated constraints are captured in the fact block.