sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p, q: Phone |
        q in p.connects implies
            (some d: p.requests | q in d.*forward and no q.forward)

    all q: Phone |
        lone connects.q
}