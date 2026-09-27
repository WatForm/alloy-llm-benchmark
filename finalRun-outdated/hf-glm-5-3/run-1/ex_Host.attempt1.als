sig Host {
}

sig Link {
  from : one Host,
  to   : one Host
}

fact ReverseLink {
  all l : Link |
    some r : Link |
      r.from = l.to and
      r.to   = l.from
}