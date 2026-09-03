sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p1, p2 : Phone {
        (p1.connects = p2) implies (
            (some p1.requests) and
            (some p_dest : p1.requests | (p2 in p_dest.*forward and no p2.forward))
        )
    }
}

fact {
    all p : Phone | lone connects.p
}