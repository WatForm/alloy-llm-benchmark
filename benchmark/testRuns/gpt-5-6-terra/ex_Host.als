sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all l: Link |
    some r: Link |
      r.from = l.to and r.to = l.from
}