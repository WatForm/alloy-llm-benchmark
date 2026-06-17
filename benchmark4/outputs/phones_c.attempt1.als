sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forwards: lone Phone
}

fact {
  connects in requests.*forwards
  no connects.forwards
  all p: Phone | lone connects.p
}