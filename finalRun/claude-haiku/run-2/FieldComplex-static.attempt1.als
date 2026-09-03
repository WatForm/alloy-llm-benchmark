sig Field {}
sig Date {}
sig Game {
  where: lone Field,
  when: lone Date
}
sig FieldComplex {
  schedule: set Game
}

fact {
  #FieldComplex = 1
}

fact {
  some g: Game | g in FieldComplex.schedule or (no g.where and no g.when)
}

fact {
  some g: Game | g not in FieldComplex.schedule or (one g.where and one g.when)
}

fact {
  all g1, g2: Game | (g1 != g2 and g1.where = g2.where) implies (g1.when != g2.when)
}

fact {
  some g: Game | g not in FieldComplex.schedule
}