sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
    no p: Person | p in p.shaken or p.spouse in p.shaken
    all p, q: Person | p in q.shaken implies q in p.shaken
    all disj p, q: Person | p.spouse = q implies q.spouse = p
    all disj p, q: Person | p.spouse != q.spouse
    all p: Person | p.spouse.spouse = p
    no p: Person | p.spouse = p
    Hilary.spouse = Jocelyn
    all disj p, q: Person - Jocelyn | #p.shaken != #q.shaken
    all disj p, q: Person - Jocelyn | #p.shaken != #q.shaken
}