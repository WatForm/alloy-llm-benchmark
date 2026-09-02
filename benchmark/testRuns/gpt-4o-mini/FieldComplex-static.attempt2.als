sig Field {}

sig Game {
    where: one Field,
    when: one Date
}

sig Date {}

one sig FieldComplex {
    schedule: Game -> FieldComplex
}

fact {
    some g: Game | g in schedule[FieldComplex] or (g.where = none and g.when = none)
    some g: Game | g not in schedule[FieldComplex] or (g.where != none and g.when != none)
    all g1, g2: Game | g1 != g2 and g1.where = g2.where implies g1.when != g2.when
    some g: Game | g not in schedule[FieldComplex]
}