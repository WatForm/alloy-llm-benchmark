sig Field {}

sig Game {
    where: Field,
    when: Date
}

sig Date {}

one sig FieldComplex {
    schedule: Game -> FieldComplex
}

pred fieldComplexPredicate {
    some g: Game | g in schedule[FieldComplex] or (g.where = none and g.when = none)
}

pred gamePredicate {
    some g: Game | g not in schedule[FieldComplex] or (g.where != none and g.when != none)
}

pred distinctWhen {
    all g1, g2: Game | g1 != g2 implies (g1.where = g2.where => g1.when != g2.when)
}

fact {
    fieldComplexPredicate
    gamePredicate
    distinctWhen
    some g: Game | g not in schedule[FieldComplex]
}