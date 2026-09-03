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
  some g: Game | g in FieldComplex.schedule
  
  all g1, g2: Game | g1 != g2 and g1.where = g2.where implies g1.when != g2.when
  
  some g: Game | g not in FieldComplex.schedule
}