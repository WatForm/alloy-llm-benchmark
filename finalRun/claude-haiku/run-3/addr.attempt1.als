abstract sig Listing {}

sig Address extends Listing {}

sig Name extends Listing {}

sig Book {
  entry: set Name,
  listed: Name -> Listing
}

fun lookup[b: Book, n: Name]: set Listing {
  let direct = b.listed[n] |
    direct + {l: Listing | some n': (direct & Name) | l in lookup[b, n']}
}

fact {
  all b: Book, n: Name, l: Listing |
    n -> l in b.listed => n in b.entry

  all b: Book, n: Name |
    n in b.entry => lone b.listed[n]

  all b: Book, n: Name, n': Name |
    n' in lookup[b, n] => n' in b.entry

  all b: Book, n: Name |
    n not in lookup[b, n]
}