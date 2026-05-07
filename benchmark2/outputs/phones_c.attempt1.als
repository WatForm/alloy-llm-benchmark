sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact ConnectionsHaveRequestsPossiblyForwarded {
  all p: Phone |
    no p.forward implies
      p.connects in p.~requests + p.~forward.~requests
}

fact NoConferenceCalls {
  all p: Phone |
    lone p.connects
}