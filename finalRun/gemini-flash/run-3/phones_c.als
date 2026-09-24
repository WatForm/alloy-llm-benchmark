sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}

fact {
    connects in (requests.*forward) :> { p: Phone | no p.forward }
    all p: Phone | lone connects.p
}