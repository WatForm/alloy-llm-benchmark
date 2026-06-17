sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all link: Link |
    some reverse: Link |
      reverse.from = link.to and reverse.to = link.from
}