sig Picture {}

sig Client {
  loaned: set Picture,
  desires: set Picture
}

sig Museum {
  permanent: set Picture,
  onDisplay: set Picture
}

// At least one Picture
fact { #Picture >= 1 }

// At least one Client
fact { #Client >= 1 }

// Exactly one Museum
fact { #Museum = 1 }

// Every Picture is either in onDisplay in the Museum or loaned to a Client
fact {
  all p: Picture |
    (some m: Museum | p in m.onDisplay) or
    (some c: Client | p in c.loaned)
}

// If a picture is permanent in a Museum, then it is in onDisplay in that Museum
fact {
  all m: Museum |
    m.permanent in m.onDisplay
}

// No Picture is both in onDisplay in a Museum and loaned to any Client
fact {
  all m: Museum, c: Client |
    no (m.onDisplay & c.loaned)
}

// A Client's desires cannot equal the permanent set of the Museum
fact {
  all c: Client, m: Museum |
    c.desires != m.permanent
}

// For every Client, no Picture is both in that client's desires and in that client's loaned set
fact {
  all c: Client |
    no (c.desires & c.loaned)
}

// Every Picture that appears in the desires set of any Client is in the loaned set of at least one Client
fact {
  all p: Picture |
    (some c: Client | p in c.desires) =>
    (some c: Client | p in c.loaned)
}

// For every two distinct Clients, no Picture is in both of their loaned sets
fact {
  all disj c1, c2: Client |
    no (c1.loaned & c2.loaned)
}