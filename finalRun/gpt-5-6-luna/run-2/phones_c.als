sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p: Phone | lone p.~connects
    all p, q: Phone |
        p->q in connects implies
            some d: p.requests | q in d.*forward and no q.forward
}