sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all a: Phone, b: a.connects {
        (some c: a.requests | b in c.*(forward)) and
        (no b.forward)
    }
}

fact {
    all p: Phone | lone p.~connects
}