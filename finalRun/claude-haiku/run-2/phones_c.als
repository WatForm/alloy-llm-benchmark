sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact ConnectsConstraint {
    all p1, p2: Phone | p1->p2 in connects implies (
        (exists q: Phone | p1->q in requests and p2 in q.*forward) and
        (p2 not in Phone.forward)
    )
}

fact UniqueTargetOfConnects {
    all p1, p2, p3: Phone | (p1->p3 in connects and p2->p3 in connects) implies p1 = p2
}