sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in { p, q: Phone | some r: p.requests | q in r.*forward and no q.forward }
  all p: Phone | lone connects.p
}