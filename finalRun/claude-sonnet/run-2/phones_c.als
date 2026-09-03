sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact ConnectsDef {
  connects in { p: Phone, q: Phone | some r: p.requests | q in r.*forward and no q.forward }
}

fact ConnectsInjective {
  all p1, p2: Phone | (some p1.connects and p1.connects = p2.connects) implies p1 = p2
}