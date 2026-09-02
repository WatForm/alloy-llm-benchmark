sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in requests.*forward & (Phone -> (Phone - forward.univ))
  all p: Phone | lone connects.p
}