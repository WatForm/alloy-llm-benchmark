sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all l: Link | one rev: Link | rev.from = l.to and rev.to = l.from
}