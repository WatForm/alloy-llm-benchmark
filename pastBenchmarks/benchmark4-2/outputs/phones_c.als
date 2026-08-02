sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact {
  connects in requests.*forward
  no Phone.connects.forward
  all target: Phone | lone connects.target
}