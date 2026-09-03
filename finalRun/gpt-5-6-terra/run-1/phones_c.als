sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forwards: lone Phone
}

fact {
  all p: Phone | all q: p.connects |
    some r: p.requests | q in r.*forwards and no q.forwards

  all p: Phone | lone p.~connects
}