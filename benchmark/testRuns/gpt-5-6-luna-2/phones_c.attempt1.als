sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p: Phone | all q: p.connects | q in p.requests.*forward and no q.forward
    all p: Phone | lone p.~connects
}