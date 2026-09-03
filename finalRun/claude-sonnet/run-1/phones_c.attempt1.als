sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact ConnectsDefinition {
  connects in { p, q: Phone | some r: p.requests | q in r.*forward and no q.forward }
}

fact ConnectsUnique {
  all q: Phone | lone p: Phone | q in p.connects
}