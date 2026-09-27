sig Phone {
  requests: set Phone,
  connects: lone Phone,
  forward: lone Phone
}

fact NoConferenceCalls {
  all p: Phone | lone p.connects
}

fact ConnectionsHaveRequests {
  all p, q: Phone |
    q in p.connects implies
      (p in q.requests or (some r: Phone | p in r.requests and r.forward = q and r != q))
}

pred showC {
  no p: Phone | p in p.requests
  #Phone >= 3
  some p, q: Phone | q in p.requests
  some p, q: Phone | q in p.connects
  some p, q, r: Phone | q in p.connects and p in r.requests and r.forward = q and r != q
}

run showC