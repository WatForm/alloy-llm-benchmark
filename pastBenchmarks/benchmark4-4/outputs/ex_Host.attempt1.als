sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all link: Link |
    some rev: Link |
      rev.from = link.to and rev.to = link.from
}