sig Field {}

sig Date {}

sig Game {
  where: one Field,
  when: one Date
}

one sig FieldComplex {
  schedule: set Game
}

fact SomeGameScheduledOrEmpty {
  some g: Game | g in FieldComplex.schedule or (no g.where and no g.when)
}

fact SomeGameNotScheduledOrFull {
  some g: Game | g not in FieldComplex.schedule or (one g.where and one g.when)
}

fact DistinctGamesDifferentWhen {
  all g1, g2: Game | (g1 != g2 and g1.where = g2.where) implies g1.when != g2.when
}

fact SomeGameNotScheduled {
  some g: Game | g not in FieldComplex.schedule
}