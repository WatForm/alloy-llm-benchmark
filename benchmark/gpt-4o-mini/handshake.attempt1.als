module handshake

sig Person {
    spouse: one Person,
    shaken: set Person
}

-- Distinct persons Jocelyn and Hilary
one sig Jocelyn, Hilary extends Person {}

-- Constraints
fact {
    // Each Person has exactly one spouse and a shaken set
    all p: Person | no p.shaken in p.shaken
  
    // Spouse of a person’s spouse is themselves
    all p: Person | p.spouse.spouse = p
    
    // No person is their own spouse
    no p: Person | p.spouse = p

    // Hilary's spouse is Jocelyn
    Hilary.spouse = Jocelyn

    // For every two distinct Persons, if one’s spouse is the other, then it’s mutual
    all p1, p2: Person | p1 != p2 implies (p1.spouse = p2 <=> p2.spouse = p1)

    // For every two distinct Persons, their spouse values are different
    all p1, p2: Person | p1 != p2 implies p1.spouse != p2.spouse

    // If a person is in another person's shaken set, then the reverse is true
    all p1, p2: Person | p1 in p2.shaken implies p2 in p1.shaken

    // Number of people shaken by different persons other than Jocelyn is different
    all p1, p2: Person | p1 != p2 and p1 != Jocelyn and p2 != Jocelyn implies #(p1.shaken) != #(p2.shaken)
    
    // Other than Jocelyn, no two distinct people have shaken the same number of times
    all p1, p2: Person | p1 != p2 and p1 != Jocelyn and p2 != Jocelyn implies #(p1.shaken) != #(p2.shaken)
}