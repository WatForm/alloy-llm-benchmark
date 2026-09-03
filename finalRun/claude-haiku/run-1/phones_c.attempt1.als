sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    all p1, p2 : Phone {
        (connects[p1] = p2) implies (
            (some requests[p1]) and
            (some p_dest : requests[p1] | p2 in forward*(p_dest)) and
            (no p2.forward)
        )
    }
}

fact {
    all p : Phone | lone connects.p
}