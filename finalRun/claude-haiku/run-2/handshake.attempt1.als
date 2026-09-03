sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
    all p: Person | p = Jocelyn or p = Hilary
}

fact {
    all p: Person | p not in p.shaken and p.spouse not in p.shaken
}

fact {
    all p1, p2: Person | p1 in p2.shaken implies p2 in p1.shaken
}

fact {
    all p1, p2: Person | p1 != p2 and p2 = p1.spouse implies p1 = p2.spouse
}

fact {
    all p1, p2: Person | p1 != p2 implies p1.spouse != p2.spouse
}

fact {
    all p: Person | p = p.spouse.spouse
}

fact {
    all p: Person | p != p.spouse
}

fact {
    Hilary.spouse = Jocelyn
}

fact {
    all p1, p2: Person | p1 != p2 and p1 != Jocelyn and p2 != Jocelyn implies #(p1.shaken) != #(p2.shaken)
}

fact {
    all p1, p2: Person | p1 != p2 and p1 != Jocelyn and p2 != Jocelyn implies #(p1.shaken) != #(p2.shaken)
}