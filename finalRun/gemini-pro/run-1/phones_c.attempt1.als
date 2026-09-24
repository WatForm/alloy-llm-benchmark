sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in {p1, p2: Phone | p2 in p1.requests.*forward and no p2.forward}
  all p: Phone | lone connects.p
}