sig Phone {
    requests: set Phone,
    connects: lone Phone,
    forward: lone Phone
}  

fact ConnectsFact {
    all p1: Phone | 
        all p2: Phone | 
            (p1 in p2.requests implies (p2 in p1.connects.requests) and 
            (p2 in (p1.forward.*(forward) - forward.*(forward) + Phone - forward.*(forward))) )
}

fact NoMultipleConnects {
    all p1: Phone | 
        lone p2: Phone | 
            p2 in p1.connects
} 

assert ValidConnects {
    all p1: Phone |
        all p2: Phone |
            (p1 in p2.requests implies
            (p2 in p1.connects) and 
            (p2 in (p1.forward.*(forward) - forward.*(forward) + Phone - forward.*(forward))))
} 

check ValidConnects for 5 Phone