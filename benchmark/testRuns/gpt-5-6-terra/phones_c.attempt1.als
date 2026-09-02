sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in requests.*forward
  connects in Phone -> (Phone - forward.Phone)
  all p: Phone | lone p.~connects
}