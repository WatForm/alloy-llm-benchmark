sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
    all p: Person | p not in p.shaken and p.spouse not in p.shaken
    all p1, p2: Person | p2 in p1.shaken implies p1 in p2.shaken
    all p1, p2: Person | p1 != p2 and p1.spouse = p2 implies p2.spouse = p1
    all p1, p2: Person | p1 != p2 implies p1.spouse != p2.spouse
    all p: Person | p.spouse.spouse = p
    all p: Person | p.spouse != p
    Hilary.spouse = Jocelyn
    all p1, p2: Person - Jocelyn | p1 != p2 implies #p1.shaken != #p2.shaken
}