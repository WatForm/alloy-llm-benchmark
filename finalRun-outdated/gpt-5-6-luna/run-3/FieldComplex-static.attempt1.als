sig Field {}

sig Game {
  where: one Field,
  when: one Date
}

sig Date {}

one sig FieldComplex {
  schedule: set Game
}

fact {
  some g: Game | g in FieldComplex.schedule or (no g.where and no g.when)
  some g: Game | g not in FieldComplex.schedule or (#g.where = 1 and #g.when = 1)
  all disj g1, g2: Game |
    g1.where = g2.where implies g1.when != g2.when
  some g: Game | g not in FieldComplex.schedule
}