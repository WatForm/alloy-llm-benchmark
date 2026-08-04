sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p, q: Phone |
        q in p.connects implies
            some r: p.requests | q in r.*forward and no q.forward

    all p: Phone | lone p.~connects
}