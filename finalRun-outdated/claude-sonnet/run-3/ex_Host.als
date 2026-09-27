sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact ReverseLinkExists {
  all l: Link | some l2: Link | l2.from = l.to and l2.to = l.from
}