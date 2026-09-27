sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all l: Link |
    one l': Link | l'.from = l.to and l'.to = l.from
}