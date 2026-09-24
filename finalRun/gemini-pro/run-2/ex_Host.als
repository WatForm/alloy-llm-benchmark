sig Host {}

sig Link {
  from: one Host,
  to: one Host
}

fact {
  all l: Link | some reverse: Link | reverse.from = l.to and reverse.to = l.from
}