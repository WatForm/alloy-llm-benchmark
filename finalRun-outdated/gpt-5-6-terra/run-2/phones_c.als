sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in requests.*forward
  no connects.forward
  all p: Phone | lone p.~connects
}