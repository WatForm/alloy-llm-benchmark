sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in { p: Phone, q: Phone |
    some r: p.requests |
      q in r.*forward and no q.forward
  }
}

fact {
  all q: Phone | lone connects.q
}