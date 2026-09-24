sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact ReverseLinkExists {
  all l: Link | some l': Link | l'.from = l.to and l'.to = l.from
}