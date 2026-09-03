sig Person {
    spouse: one Person,
    shaken: set Person
}

one sig Jocelyn, Hilary extends Person {}

fact NoSelfOrSpouseShake {
    no p: Person | p in p.shaken or p.spouse in p.shaken
}

fact SymmetricShake {
    all p, q: Person | p in q.shaken => q in p.shaken
}

fact SpouseSymmetric {
    all p, q: Person | (p != q and p.spouse = q) => q.spouse = p
}

fact DistinctSpouse {
    all p, q: Person | p != q => p.spouse != q.spouse
}

fact SpouseSpouseSelf {
    all p: Person | p.spouse.spouse = p
}

fact NoSelfSpouse {
    no p: Person | p.spouse = p
}

fact HilarySpouseJocelyn {
    Hilary.spouse = Jocelyn
}

fact DistinctShakeCountsExceptJocelyn {
    all p, q: Person | (p != q and p != Jocelyn and q != Jocelyn) => #p.shaken != #q.shaken
}

fact NoTwoSameShakeCountExceptJocelyn {
    all p, q: Person | (p != q and p != Jocelyn and q != Jocelyn) => #p.shaken != #q.shaken
}