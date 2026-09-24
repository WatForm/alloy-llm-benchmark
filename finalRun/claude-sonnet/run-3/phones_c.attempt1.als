sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in { p, q: Phone | some r: Phone | r in p.requests and q in r.*forward and no q.forward }
}

fact {
  all disj p, q: Phone | no (p.connects & q.connects)
}