sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p: Phone |
        p.connects in {
            q: Phone |
            some d: p.requests |
            q in d.*forward and no q.forward
        }

    all p: Phone |
        lone p.~connects
}