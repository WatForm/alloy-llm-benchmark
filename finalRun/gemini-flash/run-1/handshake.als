sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact {
    all p: Person | p not in p.shaken and p.spouse not in p.shaken
    all p1, p2: Person | p1 in p2.shaken implies p2 in p1.shaken
    all disj p1, p2: Person | p1.spouse = p2 implies p2.spouse = p1
    all disj p1, p2: Person | p1.spouse != p2.spouse
    all p: Person | p.spouse.spouse = p
    all p: Person | p.spouse != p
    Hilary.spouse = Jocelyn
    all disj p1, p2: Person - Jocelyn | #p1.shaken != #p2.shaken
    no disj p1, p2: Person - Jocelyn | #p1.shaken = #p2.shaken
}