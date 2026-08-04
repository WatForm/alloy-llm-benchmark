sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
    all p: Person |
        p not in p.shaken and
        p.spouse not in p.shaken

    all p, q: Person |
        q in p.shaken implies p in q.shaken

    all disj p, q: Person |
        p.spouse = q implies q.spouse = p

    all disj p, q: Person |
        p.spouse != q.spouse

    all p: Person |
        p.spouse.spouse = p

    all p: Person |
        p.spouse != p

    Hilary.spouse = Jocelyn

    all disj p, q: Person - Jocelyn |
        #p.shaken != #q.shaken

    all disj p, q: Person - Jocelyn |
        #p.shaken != #q.shaken
}