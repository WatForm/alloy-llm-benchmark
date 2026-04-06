sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact NoSelfLink {
  all l: Link | l.from != l.to
}

fact MutualLinkExists {
  some disj l1, l2: Link | l1.from = l2.to and l1.to = l2.from
}

run {}